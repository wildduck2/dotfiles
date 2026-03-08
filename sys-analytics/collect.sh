#!/usr/bin/env bash
#
# System analytics data collector.
# Collects CPU, memory, network, disk, temperature, and load metrics.
# Appends one JSON line per invocation to a daily JSONL file.
#
set -euo pipefail

DATA_DIR="$HOME/.local/share/sys-analytics/data"
mkdir -p "$DATA_DIR"

# Clean up files older than 30 days
find "$DATA_DIR" -name '*.jsonl' -mtime +30 -delete 2>/dev/null || true

TODAY="$(date +%Y-%m-%d)"
OUTFILE="$DATA_DIR/$TODAY.jsonl"
TS="$(date -Iseconds)"

# ── CPU usage (per-core + total) ─────────────────────────────────────────
read_cpu() {
  awk '/^cpu/ { print $1, $2, $3, $4, $5, $6, $7, $8, $9, $10 }' /proc/stat
}

SNAP1_CPU="$(read_cpu)"
SNAP1_NET="$(cat /proc/net/dev)"
SNAP1_DISK="$(cat /proc/diskstats)"

sleep 1

SNAP2_CPU="$(read_cpu)"
SNAP2_NET="$(cat /proc/net/dev)"
SNAP2_DISK="$(cat /proc/diskstats)"

cpu_json() {
  paste <(echo "$SNAP1_CPU") <(echo "$SNAP2_CPU") | awk '
  BEGIN { printf "{\"cores\":[" }
  {
    name = $1
    # fields: user nice system idle iowait irq softirq steal
    u1=$2; n1=$3; s1=$4; i1=$5; io1=$6; ir1=$7; si1=$8; st1=$9
    u2=$12; n2=$13; s2=$14; i2=$15; io2=$16; ir2=$17; si2=$18; st2=$19

    total1 = u1+n1+s1+i1+io1+ir1+si1+st1
    total2 = u2+n2+s2+i2+io2+ir2+si2+st2
    busy1 = u1+n1+s1+ir1+si1+st1
    busy2 = u2+n2+s2+ir2+si2+st2

    dt = total2 - total1
    db = busy2 - busy1
    pct = (dt > 0) ? (100.0 * db / dt) : 0

    if (name == "cpu") {
      total_pct = pct
    } else {
      if (core_count > 0) printf ","
      printf "%.1f", pct
      core_count++
    }
  }
  END { printf "],\"total\":%.1f}", total_pct }
  '
}

# ── Memory ───────────────────────────────────────────────────────────────
mem_json() {
  awk '
  /^MemTotal:/     { total=$2 }
  /^MemFree:/      { free=$2 }
  /^MemAvailable:/ { avail=$2 }
  /^Buffers:/      { buf=$2 }
  /^Cached:/       { cached=$2 }
  /^SwapTotal:/    { stotal=$2 }
  /^SwapFree:/     { sfree=$2 }
  END {
    used = total - avail
    sused = stotal - sfree
    printf "{\"total_mb\":%d,\"used_mb\":%d,\"available_mb\":%d,\"buffers_mb\":%d,\"cached_mb\":%d,\"swap_total_mb\":%d,\"swap_used_mb\":%d}",
      int(total/1024), int(used/1024), int(avail/1024), int(buf/1024), int(cached/1024), int(stotal/1024), int(sused/1024)
  }
  ' /proc/meminfo
}

# ── Network throughput ───────────────────────────────────────────────────
net_json() {
  local ifaces=("wlp4s0" "enp3s0")
  local first=1
  printf "{"
  for iface in "${ifaces[@]}"; do
    rx1=$(echo "$SNAP1_NET" | awk -v i="$iface:" '$1==i {print $2}')
    rx2=$(echo "$SNAP2_NET" | awk -v i="$iface:" '$1==i {print $2}')
    tx1=$(echo "$SNAP1_NET" | awk -v i="$iface:" '$1==i {print $10}')
    tx2=$(echo "$SNAP2_NET" | awk -v i="$iface:" '$1==i {print $10}')

    if [[ -z "$rx1" ]]; then continue; fi

    rx_rate=$(( (rx2 - rx1) ))
    tx_rate=$(( (tx2 - tx1) ))

    [[ $first -eq 0 ]] && printf ","
    printf "\"%s\":{\"rx_bytes_sec\":%d,\"tx_bytes_sec\":%d}" "$iface" "$rx_rate" "$tx_rate"
    first=0
  done
  printf "}"
}

# ── Disk I/O ─────────────────────────────────────────────────────────────
disk_json() {
  local devs=("nvme0n1" "sda")
  local first=1
  printf "{"
  for dev in "${devs[@]}"; do
    # fields: 3=device 6=sectors_read 10=sectors_written
    r1=$(echo "$SNAP1_DISK" | awk -v d="$dev" '$3==d {print $6}')
    r2=$(echo "$SNAP2_DISK" | awk -v d="$dev" '$3==d {print $6}')
    w1=$(echo "$SNAP1_DISK" | awk -v d="$dev" '$3==d {print $10}')
    w2=$(echo "$SNAP2_DISK" | awk -v d="$dev" '$3==d {print $10}')

    if [[ -z "$r1" ]]; then continue; fi

    # sectors * 512 = bytes
    rb=$(( (r2 - r1) * 512 ))
    wb=$(( (w2 - w1) * 512 ))

    [[ $first -eq 0 ]] && printf ","
    printf "\"%s\":{\"read_bytes_sec\":%d,\"write_bytes_sec\":%d}" "$dev" "$rb" "$wb"
    first=0
  done
  printf "}"
}

# ── Temperature ──────────────────────────────────────────────────────────
temp_json() {
  if ! command -v sensors &>/dev/null; then
    printf "{}"
    return
  fi
  sensors -j 2>/dev/null | jq -c '{
    cpu_tctl: (."k10temp-pci-00c3".Tctl.temp1_input // null),
    cpu_tccd1: (."k10temp-pci-00c3".Tccd1.temp3_input // null),
    cpu_tccd2: (."k10temp-pci-00c3".Tccd2.temp4_input // null),
    nvme: (."nvme-pci-0200".Composite.temp1_input // null),
    dimm0: (."spd5118-i2c-10-50".temp1.temp1_input // null),
    dimm1: (."spd5118-i2c-10-51".temp1.temp1_input // null),
    gpu_edge: (."amdgpu-pci-6900".edge.temp1_input // null),
    wifi: (."mt7921_phy0-pci-0400".temp1.temp1_input // null)
  }' 2>/dev/null || printf "{}"
}

# ── Load average ─────────────────────────────────────────────────────────
load_json() {
  awk '{printf "{\"avg1\":%.2f,\"avg5\":%.2f,\"avg15\":%.2f}", $1, $2, $3}' /proc/loadavg
}

# ── Compose and write ────────────────────────────────────────────────────
CPU="$(cpu_json)"
MEM="$(mem_json)"
NET="$(net_json)"
DISK="$(disk_json)"
TEMP="$(temp_json)"
LOAD="$(load_json)"

printf '{"ts":"%s","cpu":%s,"mem":%s,"net":%s,"disk":%s,"temp":%s,"load":%s}\n' \
  "$TS" "$CPU" "$MEM" "$NET" "$DISK" "$TEMP" "$LOAD" >> "$OUTFILE"
