# GAEA Import Test v0.1

Status: GENERATED / READY FOR HUMAN HEIGHTMAP IMPORT

## Purpose
Create a disposable Unreal level for testing the staged GAEA terrain package without modifying production maps.

## Production maps protected
Do not import into:
- TEST_GAEA_GEN_SWAMP
- GENESIS_SWAMP_CLEAN_v01

## Prepare test workspace
Open:

SF_GenesisSwamp 5.8

Then run:

Tools -> Execute Python Script

Select:

frog-game/unreal/scripts/GAEA_IMPORT_TEST_PREP_v01.py

Expected test level:

/Game/_SPACEFROGS_PROOF/GAEA_IMPORT_TEST_v01

## Height candidate
Use the staged package file:

C:\Users\x\Documents\Unreal Projects\SF_GenesisSwamp 5.8\GaeaBridge\Incoming\GEN_SWAMP_P0_004\Erosion_Out.png

## Import
In the disposable test level:
1. Switch to Landscape mode.
2. Choose Import from File.
3. Select Erosion_Out.png.
4. Do not guess Z scale if the import dialog asks for an unknown value.
5. Capture the detected/import resolution and proposed scale before creating the Landscape.

## Proof required before promotion
- imported resolution
- X/Y scale
- Z scale
- visual terrain silhouette
- Lit screenshot
- World Partition state if enabled
- comparison against the existing Genesis Swamp terrain

No claim outruns proof.
