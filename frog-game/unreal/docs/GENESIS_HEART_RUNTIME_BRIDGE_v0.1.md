# Genesis Heart Runtime Bridge v0.1

Status: GENERATED / NOT YET LOCAL-RUNTIME-VERIFIED

This branch connects the existing FROG3D Unreal workflow to the Genesis Heart safety contract.

## Existing verified source in this repository
The repository already contains:
- `frog-game/unreal/scripts/FROG3D_FULL_AUTO_v01.py`
- `frog-game/unreal/docs/FROG3D_QuickStart.md`

The documented Unreal project name is:

`FROG3D_v01`

## New bridge tools

### 1. Runtime discovery
Run on Windows PowerShell:

`frog-game/unreal/scripts/GENESIS_DISCOVER_RUNTIME_v01.ps1`

It searches approved user folders for `*.uproject`, prefers `FROG3D_v01`, checks Git state when available, and writes:

`genesis_runtime_bridge.generated.json`

It will stop instead of guessing if multiple valid projects are found.

### 2. Unreal proof preflight
Inside Unreal:

Tools -> Execute Python Script

Select:

`frog-game/unreal/scripts/HUB_PROOF_001_PRECHECK.py`

This creates only a proof folder and records current editor/map status. It does not modify gameplay or claim the hub systems are complete.

## Next implementation target
MISSION -> +SALVAGE -> HUB -> BUY ONE ARMOR ITEM -> EQUIP -> SAVE -> RESTART -> REDEPLOY

No claim outruns proof.
