# GAEA -> Unreal Bridge v0.1

Status: GENERATED / NOT YET LOCAL-RUNTIME-VERIFIED

## Goal
Make the GAEA -> SF_GenesisSwamp handoff simple and repeatable without risking the only working landscape.

## One-click discovery
Run:

frog-game/unreal/scripts/RUN_GAEA_BRIDGE_DISCOVERY_v01.bat

The script searches common user folders for recent terrain/GAEA-looking exports and writes a discovery manifest into:

SF_GenesisSwamp 5.8/GaeaBridge/Incoming/

It does not modify the Unreal landscape.

## Stage a chosen GAEA export folder
From PowerShell:

./GAEA_BRIDGE_STAGE_v01.ps1 -SourceFolder "C:\path\to\your\GAEA\export"

Optional:

-PackageId "GENESIS_SWAMP_v02"

This copies supported terrain files into a versioned package folder and records SHA-256 checksums.

## Why v0.1 stops before automatic Landscape overwrite
The current Genesis Swamp landscape is proven to exist and load in World Partition. Replacing its source height data is a destructive operation.

The bridge therefore uses this order:

DISCOVER -> STAGE -> VERIFY PACKAGE -> IMPORT TEST COPY -> COMPARE -> PROMOTE

Automatic overwrite is not enabled until the import path has passed proof on a copy of the map.

## Next proof
GAEA-BRIDGE-PROOF-001:
1. discover real GAEA exports
2. stage one package
3. identify heightmap + masks
4. import to a disposable test landscape/map
5. compare scale and elevation
6. only then enable controlled update of GENESIS_SWAMP_CLEAN

No claim outruns proof.
