"""
SPACEFROGS FIRST SIGNAL — HUB-PROOF-001 scaffold
Run inside Unreal Engine only after the correct FROG3D_v01 project is resolved.

This script is intentionally non-destructive.
It validates that Python can access the editor and prepares proof folders/logs.
It does NOT claim inventory/runtime systems exist until they are implemented.
"""

from datetime import datetime
import unreal

LOG = "[HUB-PROOF-001]"
ROOT = "/Game/_SPACEFROGS_PROOF"
PROOF_FOLDER = ROOT + "/HUB_PROOF_001"

def log(msg):
    unreal.log(f"{LOG} {msg}")
    print(f"{LOG} {msg}")

def blocked(msg):
    unreal.log_warning(f"{LOG} BLOCKED: {msg}")
    print(f"{LOG} BLOCKED: {msg}")

def ensure_folder(path):
    if not unreal.EditorAssetLibrary.does_directory_exist(path):
        unreal.EditorAssetLibrary.make_directory(path)

def main():
    log("Starting safe preflight.")
    ensure_folder(ROOT)
    ensure_folder(PROOF_FOLDER)

    subsystem = unreal.get_editor_subsystem(unreal.LevelEditorSubsystem)
    world = subsystem.get_current_level()
    if not world:
        blocked("No current level is loaded.")
        return

    level_name = world.get_name()
    log("Active level: " + level_name)

    required_runtime_symbols = [
        "FrogInventoryComponent",
        "FrogLoadoutComponent",
        "FrogProgressionComponent",
        "SpaceFrogsSaveGame",
    ]

    log("Runtime component proof is not yet implemented in this repository.")
    log("Expected symbols: " + ", ".join(required_runtime_symbols))
    log("Preflight complete.")
    log("Truth state: GENERATED / BLOCKED ON RUNTIME IMPLEMENTATION")
    log("Timestamp: " + datetime.utcnow().isoformat() + "Z")

main()
