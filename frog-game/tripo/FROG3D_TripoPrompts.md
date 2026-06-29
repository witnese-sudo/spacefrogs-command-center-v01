# FROG3D — Tripo3D Prompts

## Main map shell

Use this for Tripo text-to-3D:

```text
Create a game-ready 3D FPS level environment inspired by classic tactical World War 2 shooter map design with narrow streets, ruins, bridge choke points, courtyards, cover positions, windows, and side flanking routes, but do not copy any existing game map.

Make it a SpaceFrogs Sector 7F sci-fi biotech warzone: wet industrial ruins, broken concrete, metal walkways, pipes, cables, gothic laboratory architecture, toxic puddles, destroyed walls, elevated sniper windows, low cover blocks, a central signal relay courtyard, one main bridge route, two side flank alleys, and an exit gate.

Designed for Unreal Engine first-person shooter prototype. Clear walking paths, readable gameplay layout, bridge corridor, central arena, cover pieces, stairs or ramps, strong silhouettes. No characters, no weapons, no text, no logos. Neutral grey and dark wet materials, game asset style, modular-looking environment, high detail but clean collision-friendly shape.
```

## Negative prompt

```text
No characters, no soldiers, no guns, no text, no logos, no copyrighted map copy, no random floating parts, no tiny unusable details, no impossible stairs, no maze chaos, no melted geometry, no miniature diorama base, no cartoon style, no toy look, no closed solid block, no unusable interior clutter.
```

## Filename

```text
FROG3D_Sector7F_DODBridgeMap_v01.glb
```

## Important Unreal rule

```text
Tripo GLB = visual shell.
Unreal blockout cubes = real gameplay collision.
```
