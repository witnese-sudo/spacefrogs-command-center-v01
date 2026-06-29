# FROG3D Quick Start

## Goal

Build a clean playable Sector7F FPS prototype in Unreal.

## Project

Use the new clean Unreal project:

```text
FROG3D_v01
```

## Run the full-auto script

1. Open Unreal project `FROG3D_v01`.
2. Make sure Python Editor Script Plugin is enabled.
3. In Unreal:

```text
Tools → Execute Python Script
```

4. Select:

```text
frog-game/unreal/scripts/FROG3D_FULL_AUTO_v01.py
```

5. Wait for logs beginning with:

```text
[FROG3D]
```

6. Press Play.

## What the script creates

```text
/Game/_FROG3D
  01_LEVELS/S7F_FPS_v01
  02_IMPORTS/Sector7F_GLB
  03_MESHES/Sector7F
  04_MATERIALS/Sector7F
  05_BLOCKOUT
  06_LIGHTING
  07_TRIPO_VISUAL_SHELL
  99_OLD
```

## GLB placement

Put Tripo `.glb` files here before running the script:

```text
Documents/FROG_GAME_PRODUCTION/TRIPO_EXPORTS
```

The script also checks:

```text
Documents/FROG_GAME_PRODUCTION
Downloads
Desktop
```

## If the visual GLB looks wrong

That is okay. The visual shell is not the real gameplay collision.

The blockout cubes are the real playable map.

## Production law

```text
GAMEPLAY FIRST.
3D ART SECOND.
```
