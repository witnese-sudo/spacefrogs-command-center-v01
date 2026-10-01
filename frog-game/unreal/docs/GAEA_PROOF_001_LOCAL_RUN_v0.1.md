# GAEA-PROOF-001 Local Run v0.1

Status: GENERATED

## Goal
Verify the local Unreal 5.8 side of the GAEA -> Genesis Swamp pipeline before any automated map changes.

## Run
Open the verified Unreal project:

FROG3D_v01 5.8

Then:

Tools -> Execute Python Script

Select:

frog-game/unreal/scripts/GAEA_PROOF_001_PRECHECK.py

## What it checks
- current level
- presence of TEST_GAEA_GEN_SWAMP under /Game
- Landscape actor count
- DirectionalLight count
- SkyLight count
- PostProcessVolume count
- ExponentialHeightFog count
- SkyAtmosphere count
- VolumetricCloud count
- basic water actor hints

## Safety
The precheck does not:
- load another level automatically
- change lighting
- change landscape
- change materials
- change PCG
- save the map

## PASS condition for precheck
The output must prove:
1. the target map asset is found, and
2. the map can be selected deliberately for the next proof step.

This is not the Lit-rendering proof itself.

No claim outruns proof.
