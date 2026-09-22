"""
SPACEFROGS FIRST SIGNAL — GAEA-PROOF-001 precheck
Run inside Unreal Engine 5.8.

Safe/read-only intent:
- locate TEST_GAEA_GEN_SWAMP
- inspect current level
- report whether target map exists
- report landscape actor count
- report common lighting actors
- report World Partition presence when detectable

No map mutation is performed.
"""

import unreal

LOG = "[GAEA-PROOF-001]"
TARGET_MAP_TOKEN = "TEST_GAEA_GEN_SWAMP"

def log(msg):
    unreal.log(f"{LOG} {msg}")
    print(f"{LOG} {msg}")

def warn(msg):
    unreal.log_warning(f"{LOG} {msg}")
    print(f"{LOG} {msg}")

def find_target_maps():
    assets = unreal.EditorAssetLibrary.list_assets("/Game", recursive=True, include_folder=False)
    matches = []
    for path in assets:
        if TARGET_MAP_TOKEN.lower() in path.lower():
            matches.append(path)
    return matches

def current_level_name():
    subsystem = unreal.get_editor_subsystem(unreal.LevelEditorSubsystem)
    world = subsystem.get_current_level()
    return world.get_name() if world else None

def inspect_level_actors():
    actors = unreal.EditorLevelLibrary.get_all_level_actors()
    counts = {
        "Landscape": 0,
        "DirectionalLight": 0,
        "SkyLight": 0,
        "PostProcessVolume": 0,
        "ExponentialHeightFog": 0,
        "SkyAtmosphere": 0,
        "VolumetricCloud": 0,
        "WaterBody": 0,
    }

    for actor in actors:
        cls = actor.get_class().get_name()
        label = actor.get_actor_label()
        if "Landscape" in cls:
            counts["Landscape"] += 1
        if "DirectionalLight" in cls:
            counts["DirectionalLight"] += 1
        if "SkyLight" in cls:
            counts["SkyLight"] += 1
        if "PostProcessVolume" in cls:
            counts["PostProcessVolume"] += 1
        if "ExponentialHeightFog" in cls:
            counts["ExponentialHeightFog"] += 1
        if "SkyAtmosphere" in cls:
            counts["SkyAtmosphere"] += 1
        if "VolumetricCloud" in cls:
            counts["VolumetricCloud"] += 1
        if "WaterBody" in cls or "Water" in label:
            counts["WaterBody"] += 1

    return counts

def main():
    log("Starting safe GAEA precheck.")

    current = current_level_name()
    log("Current level: " + (current or "<none>"))

    matches = find_target_maps()
    if not matches:
        warn("BLOCKED: Could not find TEST_GAEA_GEN_SWAMP under /Game.")
    else:
        log("Target map candidates:")
        for path in matches:
            log(" - " + path)

    counts = inspect_level_actors()
    for key, value in counts.items():
        log(f"{key}: {value}")

    if current and TARGET_MAP_TOKEN.lower() in current.lower():
        log("Target map is currently loaded.")
    else:
        warn("Target map is not currently loaded. Do not switch automatically in precheck mode.")

    log("Precheck complete.")
    log("Truth state: GENERATED / REQUIRES HUMAN REVIEW OF OUTPUT")

main()
