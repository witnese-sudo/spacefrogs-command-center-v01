# FROG//GAME — Full Auto Production

This folder is the clean command-center for the new **FROG3D_v01** Unreal prototype.

Goal:

```text
Tripo3D / manual GLB exports
→ Unreal Python automation
→ playable first-person Sector7F bridge map
→ visual shell import
→ clean pipeline docs for Codex/GitHub
```

## Main Unreal script

Run this inside Unreal Engine:

```text
Tools → Execute Python Script → frog-game/unreal/scripts/FROG3D_FULL_AUTO_v01.py
```

It tries to:

1. Create a clean `/Game/_FROG3D` Content Browser structure.
2. Create a playable FPS blockout map using cube geometry.
3. Add Start platform, main bridge, relay arena, flank routes, cover, sniper-window blocks, exit gate.
4. Add Directional Light, Sky Light, Point Lights, and Player Start.
5. Import any `.glb` files it finds in common local export folders.
6. Place the imported Sector7F visual shell as atmosphere, not gameplay collision.
7. Save the level.

## Best local GLB folder

Put Tripo GLB files here on the laptop:

```text
Documents/FROG_GAME_PRODUCTION/TRIPO_EXPORTS
```

Recommended GLB filename:

```text
FROG3D_Sector7F_DODBridgeMap_v01.glb
```

## Production law

```text
GAMEPLAY FIRST.
3D ART SECOND.
```

The Unreal cube blockout is the real playable collision path. Tripo GLB is the visual Sector7F shell around it.
