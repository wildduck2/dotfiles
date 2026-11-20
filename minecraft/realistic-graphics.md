# Realistic Minecraft (TLauncher, Fabric)

A recipe for turning vanilla-looking Minecraft into the photoreal, wet-asphalt, ray-traced look from the
social clips. It is three layers stacked on Fabric: a performance mod so shaders run, a shader pack for the
lighting and reflections, and a PBR resource pack so block surfaces read as real 3D material. Everything here
is free and installs through TLauncher. Paid tiers are called out where they exist, with a free substitute.

The look does not come from one download. The shader does the rain puddles, screen-space reflections and sun
shafts; the PBR pack gives wood grain and wet stone real depth; the performance mod is what lets a shader run
at playable frame rates at all. Miss a layer and it falls flat.

## The stack

| Layer | What it does | Pick |
| --- | --- | --- |
| Loader | Loads the mods | **Fabric** (TLauncher installs it for you) |
| Performance | Rewrites the renderer, hosts shaders | **Sodium** + **Iris** + **Fabric API** |
| Shader | Lighting, shadows, water, puddles, fog | **Complementary Unbound** or **Photon** or **BSL** |
| PBR textures | 3D surface depth, wetness, roughness | **Patrix** (32x free) or a free high-res pack below |
| Distance (optional) | Renders terrain for miles | **Distant Horizons** |
| Physics (optional) | Foliage sway, rain ripples, ragdolls | **Physics Mod** |
| Sound (optional) | Echo and occlusion in caves and rooms | **Sound Physics Remastered** |

Iris is the shader loader; it needs Sodium and Fabric API alongside it. Sodium replaces OptiFine here and is
much faster on modern versions. You do **not** need Indium anymore: current Sodium implements the Fabric
rendering API itself, and Indium has not been updated past 1.21.1.

## Match the version, or nothing loads

This is the one mistake that breaks every install. Every mod file is built for a specific Minecraft version.
A Sodium for 1.21 will not load on 26.3; the game either crashes on startup or silently drops the mod. On each
Modrinth download page, filter by your exact Minecraft version **and** by Fabric before downloading.

Mods are on Modrinth (open, free, no account):

- Sodium: <https://modrinth.com/mod/sodium>
- Iris: <https://modrinth.com/mod/iris>
- Fabric API: <https://modrinth.com/mod/fabric-api>
- Distant Horizons: <https://modrinth.com/mod/distanthorizons>
- Sound Physics Remastered: <https://modrinth.com/mod/sound-physics-remastered>

Shader packs (a `.zip`, goes in `shaderpacks`, not `mods`):

- Complementary Unbound: <https://modrinth.com/shader/complementary-unbound>
- Complementary Reimagined: <https://modrinth.com/shader/complementary-reimagined>
- Photon: <https://modrinth.com/shader/photon-shader>
- BSL: <https://modrinth.com/shader/bsl-shaders>

Physics Mod is on its author's page and CurseForge (not Modrinth): <https://www.curseforge.com/minecraft/mc-mods/physics-mod>

## PBR resource packs

PBR (Physically Based Rendering) packs ship normal, specular and height maps in the LabPBR format, which the
shader reads to fake real depth and wetness on a flat block face. Resolution is sharpness up close, not the
effect itself; a 32x pack with POM and a good shader already gets most of the way.

- **Patrix**: 32x is free; 64x and up are Patreon (around $1 to $5 a month). The free 32x is the usual starting
  point. <https://www.patreon.com/Patrix_>
- **Free high-res alternatives** (full resolution, no paywall), good with a 12GB-class GPU:
  - ModernArch Realism (128x): <https://modrinth.com/resourcepack/modernarch-realism>
  - Optimum Realism (free tier): search Modrinth or CurseForge
  - Lupus / Lupa and other open LabPBR packs on Modrinth

A PBR pack is a resource pack `.zip`; it goes in `resourcepacks` and is enabled in Options, not `mods`.

## Install on TLauncher, step by step

TLauncher's game directory for a profile is `~/.minecraft` by default, so that is where `mods`,
`shaderpacks` and `resourcepacks` live. If a profile points its game directory elsewhere, use that folder's
`mods` instead.

1. **Install Fabric.** In TLauncher's version dropdown, pick the `Fabric <your version>` entry (TLauncher
   lists and installs Fabric itself; no separate installer needed). Launch it once so the profile is created,
   then quit.
2. **Make the folders** if they are missing:
   ```sh
   mkdir -p ~/.minecraft/mods ~/.minecraft/shaderpacks ~/.minecraft/resourcepacks
   ```
3. **Drop the mods** (`.jar`) into `~/.minecraft/mods`: Sodium, Iris, Fabric API, plus any optional mods. All
   must be the Fabric build for your exact Minecraft version.
4. **Drop the shader** (`.zip`, left zipped) into `~/.minecraft/shaderpacks`.
5. **Drop the PBR pack** (`.zip`, left zipped) into `~/.minecraft/resourcepacks`.
6. **Launch the Fabric profile.** In game: Options, Video Settings, Shaders (Iris). Pick your shader. Turn on
   the PBR options the shader exposes (rain puddles, screen-space or ray-traced reflections, parallax/POM).
7. **Set the PBR format.** In the shader options, set the resource pack format to **LabPBR 1.3** so depth and
   wetness maps read correctly.
8. **Enable the resource pack.** Options, Resource Packs, move the PBR pack to the top of the active list.

## Tuning by hardware

Shaders are GPU-bound. Rough guide:

- **RTX 2060 / RX 6600 and up**: 128x to 256x PBR with a high-end shader (Photon, Complementary Unbound) at
  native. Path-traced packs (SEUS PTGI) are in reach.
- **12GB+ dedicated GPU (e.g. RTX 40/50-series laptop)**: run the lot. High-res PBR, a path-traced or
  high-profile shader, Distant Horizons for the far terrain. This machine sits here.
- **Weaker or integrated GPU**: 32x or 64x PBR, the shader's Medium or Potato profile, and skip Physics Mod.
  Drop shader render quality before dropping resolution.

If frames tank, lower the shader profile first, then PBR resolution, then shadow distance. Distant Horizons
and Physics Mod are the heaviest optional additions; add them last and one at a time. But first rule out a
throttled GPU (below): a strong card held at low power looks exactly like a weak one.

## When a strong GPU still runs slow

On a gaming laptop the usual trap is not the settings, it is the power mode. The dedicated GPU gets capped to a
low wattage by the laptop's profile, so a card that should push hundreds of frames runs at half throttle. The
tell is frames that dip when you move while the GPU sits nearly idle.

Check it while the game runs:

```sh
nvidia-smi --query-gpu=utilization.gpu,power.draw,power.limit --format=csv
```

- Low utilization (single digits) with a low power limit (e.g. 65W on a card whose full TGP is 115W+) means the
  GPU is throttled and idle, not maxed out. The limit is the power cap or the CPU, not raw GPU power. Lifting
  the power mode is the fix, and it costs nothing but fan noise.
- High utilization (95 to 100%) means it genuinely is GPU-bound: then lower the shader profile or render distance.

On this ASUS ROG laptop the tool is **asusctl** (ROG Control Center, `rog-control-center`, is the GUI but the
packaged build only runs under Wayland; on an X11 session it fails with a winit backend error, so use the CLI):

```sh
asusctl profile set Performance     # Quiet | Balanced | Performance
asusctl profile get                 # shows AC and battery profiles
```

Balanced caps the dGPU at 65W; Performance raises it. Confirm the firmware actually moved the ceiling:

```sh
asusctl armoury list | grep -A1 nv_tgp   # Balanced ~65, Performance 115 (max)
```

The `nv_tgp` attribute is the dGPU power ceiling; `nv_dynamic_boost` (up to 25W) and `ppt_pl1_spl` (CPU) rise
with the profile too. The profile is set per power source, so the battery profile stays Quiet and throttles
again when unplugged; keep it on AC for gaming. `powerprofilesctl` is not installed here, asusctl owns the
platform profile directly.

One measurement gotcha: Dynamic FPS idles the game whenever its window loses focus, so `nvidia-smi` and CPU
readings fall to near zero while you are tabbed out to another window. Read the real numbers with the game
focused; F3 shows the in-game FPS.

Once the GPU is unthrottled, the remaining movement-dip costs, in order, are the shader (Complementary's shadow
quality and distance) and then the per-entity mods (Entity Texture / Model Features, Sound Physics Remastered),
which cost CPU as you load new chunks and mobs.

## Gotchas

- **Wrong version** is 90% of "it crashed" or "the shader option is greyed out". Re-check every file matches
  the Minecraft version and says Fabric.
- **Iris alone is not enough**: it needs Sodium and Fabric API in the same `mods` folder.
- **OptiFine does not mix** with Sodium/Iris. Use one path, not both. Remove any OptiFine jar.
- **Shaders go in `shaderpacks`, textures in `resourcepacks`.** A shader `.zip` in `mods` does nothing and a
  mod `.jar` in `shaderpacks` does nothing.
- **Leave the `.zip` zipped** for shaders and resource packs. Only mod `.jar` files go in loose.
- **exFAT drives** (common for a shared Windows/Linux game folder) cannot hard-link, which matters for backups
  but not for mods; mods load fine from exFAT.
- **A mod can need a newer Fabric Loader than your profile ships.** Sodium Extra 0.9.5 refuses to load on loader
  0.19.5 and wants 0.20.1+. Upgrade the loader (see below) instead of dropping the mod.
- **Performance mods can clash with cosmetic mods.** EntityCulling (by tr7zw, which bundles the TRender and
  TRansition libraries) declares itself incompatible with TLSkinCape, so the game refuses to start with both.
  Keep the cosmetic mod you actually use and drop the optimizer (Lithium still carries most of the FPS win).

## Upgrading Fabric Loader in a TLauncher custom profile

TLauncher bakes the loader version into the profile's version JSON
(`versions/<profile>/<profile>.json`), so there is no installer step; you swap two jars and bump two version
strings. Back up the JSON first.

1. Find the latest stable loader for your Minecraft version:
   `https://meta.fabricmc.net/v2/versions/loader/<mcversion>` (take the newest `stable: true`).
2. Get the exact library set it needs:
   `https://meta.fabricmc.net/v2/versions/loader/<mcversion>/<loader>/profile/json`. Newer loaders usually pull
   a newer `sponge-mixin` too, so bump both together.
3. Download both jars from `https://maven.fabricmc.net/` into `libraries/net/fabricmc/...` at their versioned
   paths.
4. In the profile JSON's `libraries`, replace the `fabric-loader` and `sponge-mixin` entries: new `name`,
   `path`, `url`, and the real `sha1` and `size` of the jars you downloaded (a wrong hash makes the launcher
   re-download or fail).
5. Launch. If the profile ever reverts, TLauncher rewrote the JSON; redo the edit with the game closed.

## Known good at time of writing

Verified against Minecraft **26.3**, Fabric loader, on an RTX 5070 Ti Laptop (12GB): Sodium, Iris, Fabric API,
Distant Horizons, and the Complementary Unbound / Reimagined, Photon and BSL shaders all publish 26.3 Fabric
builds. Indium is not needed. Pull the current file for your version from the links above rather than pinning
to these, since the mods track each Minecraft release closely.

## Installed here (gentleduck world, Minecraft 26.2 Fabric)

This is the live setup on this machine (RTX 5070 Ti Laptop, 12GB). The profile runs a per-version game
directory, so everything lives under `versions/gentleduck/`: mods in `mods/`, shaders in `shaderpacks/`,
textures in `resourcepacks/`, config in `config/` and `options.txt`.

**Loader:** Fabric 0.20.1 (upgraded from 0.19.5 so Sodium Extra would load), sponge-mixin 0.17.5.

**Already there (kept):** Sodium, Iris, Fabric API, Complementary Reimagined, FreshAnimations + Entity Texture
/ Model Features, Dynamic Lights, Xaero's map, TLSkinCape, FallingTree.

**Added for performance** (no visual change): Lithium, FerriteCore, ImmediatelyFast, Dynamic FPS, Sodium
Extra, Mod Menu. EntityCulling was tried and removed (clashes with TLSkinCape).

**Look:** the plain pre-existing setup. Complementary **Reimagined** is the active shader (`config/iris.properties`),
over FreshAnimations mob textures and otherwise vanilla blocks. No PBR resource pack is active.

**Also present (the user's own mods):** Sound Physics Remastered (room and cave acoustics), Baritone,
WorldEdit (deactivated), mc armor HUD.

**Tried for the photoreal look, then removed:**
- **Legendary RT** and **Optimum Realism** (high-res PBR packs): looked wrong indoors and on lava/redstone,
  which no PBR pack retextures, so the blocky cubes still read as cartoonish in wide shots.
- Complementary **Unbound** and **Photon** (heavier shaders): reverted to Reimagined.
- **Distant Horizons** (far-terrain LODs): its 256-chunk LOD radius with 16 threads wrote a 200MB+ SQLite
  database to the near-full exFAT drive on every move, which tanked movement to ~24 FPS and hung the client on
  exit (watchdog crash flushing the database). Removing the jar, `config/DistantHorizons.toml` and the per-world
  `DistantHorizons.sqlite*` cache fixed both.

**Performance note:** the FPS was never the mods or the GPU. The dGPU was capped at 65W by the ASUS Balanced
profile while sitting near idle; see "When a strong GPU still runs slow" above. Set the profile to Performance
and keep the laptop on AC.

**To revert the look** (already done here, kept for reference): set `shaderPack=ComplementaryReimagined_r5.9.3.zip`
in `config/iris.properties`, drop any PBR pack line from `resourcePacks` in `options.txt`, and delete the added
jars from `mods/`. Do it with the game closed, or the running client overwrites the config files on exit.
