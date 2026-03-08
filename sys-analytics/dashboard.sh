#!/usr/bin/env bash
#
# Generate a single-page HTML dashboard from system analytics data.
# Reads JSONL files from ~/.local/share/sys-analytics/data/
# Outputs dashboard to ~/.local/share/sys-analytics/dashboard.html
#
set -euo pipefail

DATA_DIR="$HOME/.local/share/sys-analytics/data"
OUT="$HOME/.local/share/sys-analytics/dashboard.html"

# Find available data files
mapfile -t DATA_FILES < <(ls -1 "$DATA_DIR"/*.jsonl 2>/dev/null | sort -r)

if [[ ${#DATA_FILES[@]} -eq 0 ]]; then
  echo "No data files found in $DATA_DIR"
  exit 0
fi

# Use today's file by default, or the most recent
TODAY="$(date +%Y-%m-%d)"
CURRENT_FILE="$DATA_DIR/$TODAY.jsonl"
[[ -f "$CURRENT_FILE" ]] || CURRENT_FILE="${DATA_FILES[0]}"

# Build the list of available dates for the selector
DATE_OPTIONS=""
for f in "${DATA_FILES[@]}"; do
  d="$(basename "$f" .jsonl)"
  sel=""
  [[ "$f" == "$CURRENT_FILE" ]] && sel="selected"
  DATE_OPTIONS+="<option value=\"$d\" $sel>$d</option>"
done

# Extract data arrays using jq (single pass over the file)
CHART_DATA=$(jq -sc '{
  timestamps: [.[].ts],
  cpu_total: [.[].cpu.total],
  cpu_cores: (if (.[0].cpu.cores | length) > 0 then
    [range(.[0].cpu.cores | length)] | map(. as $i | [input_line_number] | []) | []
  else [] end),
  mem_used: [.[].mem.used_mb],
  mem_total: (.[0].mem.total_mb // 0),
  mem_buffers: [.[].mem.buffers_mb],
  mem_cached: [.[].mem.cached_mb],
  mem_available: [.[].mem.available_mb],
  swap_used: [.[].mem.swap_used_mb],
  swap_total: (.[0].mem.swap_total_mb // 0),
  net_rx: [.[].net.wlp4s0.rx_bytes_sec // 0],
  net_tx: [.[].net.wlp4s0.tx_bytes_sec // 0],
  disk_read: [.[].disk.nvme0n1.read_bytes_sec // 0],
  disk_write: [.[].disk.nvme0n1.write_bytes_sec // 0],
  temp_cpu: [.[].temp.cpu_tctl // null],
  temp_tccd1: [.[].temp.cpu_tccd1 // null],
  temp_tccd2: [.[].temp.cpu_tccd2 // null],
  temp_nvme: [.[].temp.nvme // null],
  temp_gpu: [.[].temp.gpu_edge // null],
  temp_dimm0: [.[].temp.dimm0 // null],
  temp_wifi: [.[].temp.wifi // null],
  load1: [.[].load.avg1],
  load5: [.[].load.avg5],
  load15: [.[].load.avg15]
}' "$CURRENT_FILE" 2>/dev/null)

# Extract per-core CPU data separately (complex nested extraction)
CORE_DATA=$(jq -sc '
  (.[0].cpu.cores | length) as $ncores |
  [range($ncores)] | map(. as $i | [input | .cpu.cores[$i]] | []) | []
' "$CURRENT_FILE" 2>/dev/null || echo "[]")

# Actually extract cores properly
CORE_DATA=$(jq -sc '
  (.[0].cpu.cores | length) as $n |
  reduce range($n) as $i ([]; . + [[ .[] | .cpu.cores[$i] ] ])
' "$CURRENT_FILE" 2>/dev/null | jq -c '
  . // []
' 2>/dev/null || echo "[]")

# Simpler: just extract the cores array transposed
CORE_DATA=$(jq -sc '[.[].cpu.cores] | transpose' "$CURRENT_FILE" 2>/dev/null || echo "[]")

CURRENT_DATE="$(basename "$CURRENT_FILE" .jsonl)"
GENERATED="$(date '+%Y-%m-%d %H:%M:%S')"

cat > "$OUT" << 'HTMLHEAD'
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<meta http-equiv="refresh" content="60">
<title>System Analytics Dashboard</title>
<script src="https://cdn.jsdelivr.net/npm/chart.js@4"></script>
<script src="https://cdn.jsdelivr.net/npm/chartjs-adapter-date-fns@3"></script>
<style>
  :root {
    --bg: #1a1b26;
    --surface: #24283b;
    --border: #3b4261;
    --text: #c0caf5;
    --text-dim: #565f89;
    --accent: #7aa2f7;
    --green: #9ece6a;
    --red: #f7768e;
    --orange: #ff9e64;
    --yellow: #e0af68;
    --cyan: #7dcfff;
    --purple: #bb9af7;
    --magenta: #ff007c;
  }
  * { margin: 0; padding: 0; box-sizing: border-box; }
  body {
    background: var(--bg);
    color: var(--text);
    font-family: 'Berkeley Mono', 'JetBrains Mono', 'Fira Code', monospace;
    padding: 20px;
    min-height: 100vh;
  }
  .header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 16px 24px;
    background: var(--surface);
    border: 1px solid var(--border);
    border-radius: 12px;
    margin-bottom: 20px;
  }
  .header h1 {
    font-size: 1.4em;
    font-weight: 600;
    color: var(--accent);
  }
  .header .meta {
    font-size: 0.8em;
    color: var(--text-dim);
  }
  .header select {
    background: var(--bg);
    color: var(--text);
    border: 1px solid var(--border);
    border-radius: 6px;
    padding: 6px 12px;
    font-family: inherit;
    font-size: 0.85em;
    cursor: pointer;
  }
  .grid {
    display: grid;
    grid-template-columns: repeat(2, 1fr);
    gap: 16px;
  }
  @media (max-width: 1200px) {
    .grid { grid-template-columns: 1fr; }
  }
  .card {
    background: var(--surface);
    border: 1px solid var(--border);
    border-radius: 12px;
    padding: 20px;
  }
  .card h2 {
    font-size: 0.95em;
    font-weight: 500;
    color: var(--text-dim);
    margin-bottom: 12px;
    text-transform: uppercase;
    letter-spacing: 0.05em;
  }
  .card canvas {
    max-height: 280px;
  }
  .card.wide {
    grid-column: span 2;
  }
  @media (max-width: 1200px) {
    .card.wide { grid-column: span 1; }
  }
  .stats-row {
    display: flex;
    gap: 12px;
    margin-bottom: 20px;
  }
  .stat-card {
    flex: 1;
    background: var(--surface);
    border: 1px solid var(--border);
    border-radius: 12px;
    padding: 16px 20px;
    text-align: center;
  }
  .stat-card .value {
    font-size: 1.8em;
    font-weight: 700;
    color: var(--accent);
  }
  .stat-card .label {
    font-size: 0.75em;
    color: var(--text-dim);
    margin-top: 4px;
    text-transform: uppercase;
    letter-spacing: 0.05em;
  }
  @media (max-width: 900px) {
    .stats-row { flex-wrap: wrap; }
    .stat-card { min-width: 120px; }
  }
</style>
</head>
<body>
HTMLHEAD

cat >> "$OUT" << HTMLHEADER
<div class="header">
  <h1>🦆 System Analytics</h1>
  <div>
    <select id="dateSelect" onchange="location.href='?date='+this.value">
      $DATE_OPTIONS
    </select>
  </div>
  <div class="meta">
    $CURRENT_DATE &middot; Updated $GENERATED
  </div>
</div>
HTMLHEADER

cat >> "$OUT" << 'HTMLBODY'
<div id="stats-row" class="stats-row"></div>
<div class="grid">
  <div class="card wide">
    <h2>CPU Usage (Per Core)</h2>
    <canvas id="cpuCores"></canvas>
  </div>
  <div class="card">
    <h2>CPU Total</h2>
    <canvas id="cpuTotal"></canvas>
  </div>
  <div class="card">
    <h2>Memory & Swap</h2>
    <canvas id="memory"></canvas>
  </div>
  <div class="card">
    <h2>Network Throughput</h2>
    <canvas id="network"></canvas>
  </div>
  <div class="card">
    <h2>Disk I/O</h2>
    <canvas id="diskio"></canvas>
  </div>
  <div class="card">
    <h2>Temperature Sensors</h2>
    <canvas id="temperature"></canvas>
  </div>
  <div class="card">
    <h2>Load Average</h2>
    <canvas id="loadavg"></canvas>
  </div>
</div>
<script>
HTMLBODY

# Inject data as JS variables
{
  echo "const DATA = $CHART_DATA;"
  echo "const CORE_DATA = $CORE_DATA;"
} >> "$OUT"

cat >> "$OUT" << 'HTMLSCRIPT'
// ── Helpers ──────────────────────────────────────────────────────────────
const COLORS = {
  accent: '#7aa2f7', green: '#9ece6a', red: '#f7768e', orange: '#ff9e64',
  yellow: '#e0af68', cyan: '#7dcfff', purple: '#bb9af7', magenta: '#ff007c',
  dim: '#565f89', text: '#c0caf5', border: '#3b4261', surface: '#24283b'
};

const CORE_COLORS = CORE_DATA.map((_, i) => {
  const hue = (i * 360 / CORE_DATA.length) % 360;
  return `hsla(${hue}, 70%, 60%, 0.6)`;
});

const labels = DATA.timestamps.map(t => {
  const d = new Date(t);
  return d.toLocaleTimeString('en-GB', { hour: '2-digit', minute: '2-digit' });
});

const baseOpts = {
  responsive: true,
  maintainAspectRatio: false,
  animation: false,
  interaction: { mode: 'index', intersect: false },
  plugins: {
    legend: { labels: { color: COLORS.text, font: { size: 11 } } },
    tooltip: { backgroundColor: COLORS.surface, titleColor: COLORS.text, bodyColor: COLORS.text, borderColor: COLORS.border, borderWidth: 1 }
  },
  scales: {
    x: { ticks: { color: COLORS.dim, maxTicksLimit: 20, font: { size: 10 } }, grid: { color: COLORS.border + '40' } },
    y: { ticks: { color: COLORS.dim, font: { size: 10 } }, grid: { color: COLORS.border + '40' } }
  }
};

function bytesToMB(b) { return (b / 1048576).toFixed(2); }
function bytesToKB(b) { return (b / 1024).toFixed(1); }

function last(arr) { return arr[arr.length - 1]; }

// ── Summary Stats ────────────────────────────────────────────────────────
const statsEl = document.getElementById('stats-row');
const latestCpu = last(DATA.cpu_total) || 0;
const latestMem = last(DATA.mem_used) || 0;
const latestTemp = last(DATA.temp_cpu) || 0;
const latestLoad = last(DATA.load1) || 0;
const latestNetRx = last(DATA.net_rx) || 0;
const latestNetTx = last(DATA.net_tx) || 0;

function statColor(val, warn, crit) {
  if (val >= crit) return COLORS.red;
  if (val >= warn) return COLORS.orange;
  return COLORS.green;
}

statsEl.innerHTML = `
  <div class="stat-card"><div class="value" style="color:${statColor(latestCpu, 70, 90)}">${latestCpu.toFixed(1)}%</div><div class="label">CPU</div></div>
  <div class="stat-card"><div class="value" style="color:${statColor(latestMem / DATA.mem_total * 100, 70, 90)}">${(latestMem / 1024).toFixed(1)}G</div><div class="label">Memory</div></div>
  <div class="stat-card"><div class="value" style="color:${statColor(latestTemp, 80, 95)}">${latestTemp.toFixed(0)}°C</div><div class="label">CPU Temp</div></div>
  <div class="stat-card"><div class="value" style="color:${statColor(latestLoad, 16, 28)}">${latestLoad.toFixed(2)}</div><div class="label">Load</div></div>
  <div class="stat-card"><div class="value">${bytesToKB(latestNetRx)}</div><div class="label">Net RX KB/s</div></div>
  <div class="stat-card"><div class="value">${bytesToKB(latestNetTx)}</div><div class="label">Net TX KB/s</div></div>
`;

// ── CPU Per Core ─────────────────────────────────────────────────────────
new Chart(document.getElementById('cpuCores'), {
  type: 'line',
  data: {
    labels,
    datasets: CORE_DATA.map((core, i) => ({
      label: `Core ${i}`,
      data: core,
      borderColor: CORE_COLORS[i],
      borderWidth: 1,
      pointRadius: 0,
      fill: false,
      tension: 0.3
    }))
  },
  options: {
    ...baseOpts,
    plugins: { ...baseOpts.plugins, legend: { display: false } },
    scales: { ...baseOpts.scales, y: { ...baseOpts.scales.y, min: 0, max: 100, title: { display: true, text: '%', color: COLORS.dim } } }
  }
});

// ── CPU Total ────────────────────────────────────────────────────────────
new Chart(document.getElementById('cpuTotal'), {
  type: 'line',
  data: {
    labels,
    datasets: [{
      label: 'Total CPU %',
      data: DATA.cpu_total,
      borderColor: COLORS.accent,
      backgroundColor: COLORS.accent + '20',
      borderWidth: 2,
      pointRadius: 0,
      fill: true,
      tension: 0.3
    }]
  },
  options: {
    ...baseOpts,
    scales: { ...baseOpts.scales, y: { ...baseOpts.scales.y, min: 0, max: 100 } }
  }
});

// ── Memory ───────────────────────────────────────────────────────────────
new Chart(document.getElementById('memory'), {
  type: 'line',
  data: {
    labels,
    datasets: [
      { label: 'Used (MB)', data: DATA.mem_used, borderColor: COLORS.red, backgroundColor: COLORS.red + '20', borderWidth: 2, pointRadius: 0, fill: true, tension: 0.3 },
      { label: 'Cached (MB)', data: DATA.mem_cached, borderColor: COLORS.cyan, borderWidth: 1.5, pointRadius: 0, fill: false, tension: 0.3 },
      { label: 'Swap Used (MB)', data: DATA.swap_used, borderColor: COLORS.orange, borderWidth: 1.5, pointRadius: 0, fill: false, tension: 0.3, borderDash: [5,3] }
    ]
  },
  options: baseOpts
});

// ── Network ──────────────────────────────────────────────────────────────
new Chart(document.getElementById('network'), {
  type: 'line',
  data: {
    labels,
    datasets: [
      { label: 'RX (KB/s)', data: DATA.net_rx.map(v => v / 1024), borderColor: COLORS.green, borderWidth: 2, pointRadius: 0, fill: false, tension: 0.3 },
      { label: 'TX (KB/s)', data: DATA.net_tx.map(v => v / 1024), borderColor: COLORS.purple, borderWidth: 2, pointRadius: 0, fill: false, tension: 0.3 }
    ]
  },
  options: { ...baseOpts, scales: { ...baseOpts.scales, y: { ...baseOpts.scales.y, min: 0 } } }
});

// ── Disk I/O ─────────────────────────────────────────────────────────────
new Chart(document.getElementById('diskio'), {
  type: 'line',
  data: {
    labels,
    datasets: [
      { label: 'Read (MB/s)', data: DATA.disk_read.map(v => v / 1048576), borderColor: COLORS.cyan, borderWidth: 2, pointRadius: 0, fill: false, tension: 0.3 },
      { label: 'Write (MB/s)', data: DATA.disk_write.map(v => v / 1048576), borderColor: COLORS.orange, borderWidth: 2, pointRadius: 0, fill: false, tension: 0.3 }
    ]
  },
  options: { ...baseOpts, scales: { ...baseOpts.scales, y: { ...baseOpts.scales.y, min: 0 } } }
});

// ── Temperature ──────────────────────────────────────────────────────────
new Chart(document.getElementById('temperature'), {
  type: 'line',
  data: {
    labels,
    datasets: [
      { label: 'CPU Tctl', data: DATA.temp_cpu, borderColor: COLORS.red, borderWidth: 2, pointRadius: 0, tension: 0.3 },
      { label: 'CCD1', data: DATA.temp_tccd1, borderColor: COLORS.orange, borderWidth: 1.5, pointRadius: 0, tension: 0.3 },
      { label: 'CCD2', data: DATA.temp_tccd2, borderColor: COLORS.yellow, borderWidth: 1.5, pointRadius: 0, tension: 0.3 },
      { label: 'NVMe', data: DATA.temp_nvme, borderColor: COLORS.cyan, borderWidth: 1.5, pointRadius: 0, tension: 0.3 },
      { label: 'GPU Edge', data: DATA.temp_gpu, borderColor: COLORS.green, borderWidth: 1.5, pointRadius: 0, tension: 0.3 },
      { label: 'WiFi', data: DATA.temp_wifi, borderColor: COLORS.purple, borderWidth: 1.5, pointRadius: 0, tension: 0.3, borderDash: [5,3] }
    ]
  },
  options: baseOpts
});

// ── Load Average ─────────────────────────────────────────────────────────
new Chart(document.getElementById('loadavg'), {
  type: 'line',
  data: {
    labels,
    datasets: [
      { label: '1 min', data: DATA.load1, borderColor: COLORS.accent, borderWidth: 2, pointRadius: 0, tension: 0.3 },
      { label: '5 min', data: DATA.load5, borderColor: COLORS.green, borderWidth: 1.5, pointRadius: 0, tension: 0.3 },
      { label: '15 min', data: DATA.load15, borderColor: COLORS.purple, borderWidth: 1.5, pointRadius: 0, tension: 0.3 }
    ]
  },
  options: { ...baseOpts, scales: { ...baseOpts.scales, y: { ...baseOpts.scales.y, min: 0 } } }
});
</script>
</body>
</html>
HTMLSCRIPT

echo "Dashboard generated: $OUT"
