"""
SPACEFROGS FIRST SIGNAL — GAEA import test prep v0.1
Run inside Unreal Engine 5.8.

Goal:
- create/open a disposable test level
- preserve production maps
- prepare a safe proof workspace for importing staged GAEA height data

This script does NOT automatically import/overwrite an existing Landscape.
"""

import unreal

LOG = "[GAEA-IMPORT-TEST]"
TEST_LEVEL = "/Game/_SPACEFROGS_PROOF/GAEA_IMPORT_TEST_v01"

def log(msg):
    unreal.log(f"{LOG} {msg}")
    print(f"{LOG} {msg}")

def warn(msg):
    unreal.log_warning(f"{LOG} {msg}")
    print(f"{LOG} {msg}")

def ensure_level():
    asset_tools = unreal.AssetToolsHelpers.get_asset_tools()

    if unreal.EditorAssetLibrary.does_asset_exist(TEST_LEVEL):
        log(f"Test level already exists: {TEST_LEVEL}")
        unreal.get_editor_subsystem(unreal.LevelEditorSubsystem).load_level(TEST_LEVEL)
        return

    created = unreal.EditorLevelLibrary.new_level(TEST_LEVEL)
    if not created:
        warn("BLOCKED: Could not create test level.")
        return

    log(f"Created disposable test level: {TEST_LEVEL}")

def add_baseline_lighting():
    actors = unreal.EditorLevelLibrary.get_all_level_actors()
    labels = {a.get_actor_label() for a in actors}

    if "GAEA_TEST_SUN" not in labels:
        sun = unreal.EditorLevelLibrary.spawn_actor_from_class(unreal.DirectionalLight, unreal.Vector(0,0,500))
        sun.set_actor_label("GAEA_TEST_SUN")
        log("Added baseline DirectionalLight.")

    if "GAEA_TEST_SKYLIGHT" not in labels:
        sky = unreal.EditorLevelLibrary.spawn_actor_from_class(unreal.SkyLight, unreal.Vector(0,0,300))
        sky.set_actor_label("GAEA_TEST_SKYLIGHT")
        log("Added baseline SkyLight.")

    if "GAEA_TEST_SKYATMOSPHERE" not in labels:
        atmosphere = unreal.EditorLevelLibrary.spawn_actor_from_class(unreal.SkyAtmosphere, unreal.Vector(0,0,0))
        atmosphere.set_actor_label("GAEA_TEST_SKYATMOSPHERE")
        log("Added baseline SkyAtmosphere.")

def main():
    log("Starting safe GAEA import test preparation.")
    ensure_level()
    add_baseline_lighting()

    unreal.EditorLevelLibrary.save_current_level()

    log("Test workspace ready.")
    log("Next manual proof step: Landscape Mode -> Import from File -> select staged Erosion_Out.png.")
    log("Do NOT import into TEST_GAEA_GEN_SWAMP or GENESIS_SWAMP_CLEAN_v01.")
    log("Truth state: GENERATED / READY FOR HUMAN HEIGHTMAP IMPORT")

main()
