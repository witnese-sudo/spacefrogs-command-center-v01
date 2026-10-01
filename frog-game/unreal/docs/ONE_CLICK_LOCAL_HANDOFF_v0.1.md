# ONE-CLICK LOCAL HANDOFF v0.1

Status: GENERATED

## Purpose
Make the next local step as simple and safe as possible.

## Run
From the checked-out command-center repository, double-click:

`frog-game\unreal\scripts\RUN_GENESIS_DISCOVERY_v01.bat`

The launcher runs:

`GENESIS_DISCOVER_RUNTIME_v01.ps1`

## Expected result
If exactly one valid preferred Unreal project is found, the script writes:

`genesis_runtime_bridge.generated.json`

next to the resolved `.uproject`.

If multiple projects are found, it stops and prints the candidates.
If no project is found, it stops with no changes.

## Next Unreal step
After the correct project is confirmed, open that project and run:

Tools -> Execute Python Script

`frog-game/unreal/scripts/HUB_PROOF_001_PRECHECK.py`

## Important
This launcher does not modify the Unreal project.
It only discovers and records local runtime state.

Truth state remains GENERATED until the local run succeeds and evidence is captured.
