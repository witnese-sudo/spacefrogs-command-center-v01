"""
FROG//GAME — FROG3D FULL AUTO v0.1
Run inside Unreal Engine:
Tools -> Execute Python Script -> FROG3D_FULL_AUTO_v01.py

This script is intentionally practical and forgiving.
It creates a playable FPS blockout first, then imports Tripo GLB files as visual shell.

Production law:
GAMEPLAY FIRST. 3D ART SECOND.
"""

import os
from pathlib import Path

import unreal

LOG = "[FROG3D]"
ROOT = "/Game/_FROG3D"
LEVEL_PATH = ROOT + "/01_LEVELS/S7F_FPS_v01"

FOLDERS = [
    ROOT,
    ROOT + "/01_LEVELS",
    ROOT + "/02_IMPORTS",
    ROOT + "/02_IMPORTS/Sector7F_GLB",
    ROOT + "/03_MESHES",
    ROOT + "/03_MESHES/Sector7F",
    ROOT + "/04_MATERIALS",
    ROOT + "/04_MATERIALS/Sector7F",
    ROOT + "/05_BLOCKOUT",
    ROOT + "/06_LIGHTING",
    ROOT + "/07_TRIPO_VISUAL_SHELL",
    ROOT + "/99_OLD",
]

LOCAL_GLB_FOLDERS = [
    Path.home() / "Documents" / "FROG_GAME_PRODUCTION" / "TRIPO_EXPORTS",
    Path.home() / "Documents" / "FROG_GAME_PRODUCTION",
    Path.home() / "Downloads",
    Path.home() / "Desktop",
]


def log(msg):
    unreal.log(f"{LOG} {msg}")
    print(f"{LOG} {msg}")


def warn(msg):
    unreal.log_warning(f"{LOG} WARNING: {msg}")
    print(f"{LOG} WARNING: {msg}")


def make_folders():
    log("Creating clean /Game/_FROG3D folder structure...")
    for folder in FOLDERS:
        if not unreal.EditorAssetLibrary.does_directory_exist(folder):
            unreal.EditorAssetLibrary.make_directory(folder)
            log("Created folder: " + folder)


def load_engine_cube():
    for path in ["/Engine/BasicShapes/Cube.Cube", "/Engine/EngineMeshes/Cube.Cube"]:
        asset = unreal.EditorAssetLibrary.load_asset(path)
        if asset:
            return asset
    raise RuntimeError("Could not load Unreal engine Cube static mesh.")


def spawn_static_mesh(mesh, label, location, scale, material=None):
    actor = unreal.EditorLevelLibrary.spawn_actor_from_object(
        mesh,
        unreal.Vector(location[0], location[1], location[2]),
        unreal.Rotator(0, 0, 0),
    )
    actor.set_actor_label(label)
    actor.set_actor_scale3d(unreal.Vector(scale[0], scale[1], scale[2]))
    comp = actor.get_component_by_class(unreal.StaticMeshComponent)
    if comp and material:
        comp.set_material(0, material)
    return actor


def create_material(name, folder, base_color=(0.38, 0.38, 0.38, 1.0)):
    asset_path = folder + "/" + name
    if unreal.EditorAssetLibrary.does_asset_exist(asset_path):
        return unreal.EditorAssetLibrary.load_asset(asset_path)

    tools = unreal.AssetToolsHelpers.get_asset_tools()
    mat = tools.create_asset(name, folder, unreal.Material, unreal.MaterialFactoryNew())
    if not mat:
        warn("Could not create material: " + asset_path)
        return None

    try:
        mat.set_editor_property("two_sided", True)
    except Exception:
        pass

    unreal.EditorAssetLibrary.save_asset(asset_path)
    log("Created material: " + asset_path)
    return mat


def create_or_open_level():
    if unreal.EditorAssetLibrary.does_asset_exist(LEVEL_PATH):
        log("Opening existing level: " + LEVEL_PATH)
        unreal.EditorLevelLibrary.load_level(LEVEL_PATH)
    else:
        log("Creating new level: " + LEVEL_PATH)
        try:
            unreal.EditorLevelLibrary.new_level(LEVEL_PATH)
        except Exception as exc:
            warn("new_level failed, trying LevelEditorSubsystem: " + str(exc))
            subsystem = unreal.get_editor_subsystem(unreal.LevelEditorSubsystem)
            subsystem.new_level(LEVEL_PATH)


def clear_old_frog_blockout():
    actors = unreal.EditorLevelLibrary.get_all_level_actors()
    to_delete = []
    for actor in actors:
        label = actor.get_actor_label()
        if label.startswith("FROG3D_") or label.startswith("S7F_"):
            to_delete.append(actor)
    if to_delete:
        log(f"Deleting old FROG3D/S7F actors: {len(to_delete)}")
        unreal.EditorLevelLibrary.destroy_actors(to_delete)


def add_lights_and_player_start():
    log("Adding lights and Player Start...")

    sun = unreal.EditorLevelLibrary.spawn_actor_from_class(
        unreal.DirectionalLight,
        unreal.Vector(-300, -500, 900),
        unreal.Rotator(-45, -35, 0),
    )
    sun.set_actor_label("FROG3D_DirectionalLight")

    sky = unreal.EditorLevelLibrary.spawn_actor_from_class(
        unreal.SkyLight,
        unreal.Vector(0, 0, 400),
        unreal.Rotator(0, 0, 0),
    )
    sky.set_actor_label("FROG3D_SkyLight")

    for i, loc in enumerate([(-650, -800, 350), (0, 300, 420), (650, 1050, 350)], start=1):
        light = unreal.EditorLevelLibrary.spawn_actor_from_class(
            unreal.PointLight,
            unreal.Vector(loc[0], loc[1], loc[2]),
            unreal.Rotator(0, 0, 0),
        )
        light.set_actor_label(f"FROG3D_PointLight_{i:02d}")
        try:
            comp = light.get_component_by_class(unreal.PointLightComponent)
            comp.set_editor_property("intensity", 5500.0)
            comp.set_editor_property("attenuation_radius", 900.0)
        except Exception:
            pass

    player = unreal.EditorLevelLibrary.spawn_actor_from_class(
        unreal.PlayerStart,
        unreal.Vector(0, -1850, 160),
        unreal.Rotator(0, 0, 0),
    )
    player.set_actor_label("FROG3D_PlayerStart")


def build_blockout():
    log("Building Sector7F tactical FPS bridge blockout...")
    cube = load_engine_cube()
    grey = create_material("M_S7F_Greybox", ROOT + "/04_MATERIALS/Sector7F")

    # Unreal cube is 100 cm. Scales below are actor scale multipliers.
    pieces = [
        ("S7F_Start_Platform", (0, -1750, 0), (9, 7, 0.25)),
        ("S7F_Main_Bridge", (0, -650, 0), (5.2, 17, 0.22)),
        ("S7F_Relay_Arena", (0, 650, 0), (18, 14, 0.22)),
        ("S7F_Exit_Platform", (0, 1850, 0), (8, 6, 0.25)),

        ("S7F_Left_Flank_Path", (-760, 250, 0), (3.2, 19, 0.2)),
        ("S7F_Right_Flank_Path", (760, 250, 0), (3.2, 19, 0.2)),

        ("S7F_Cover_A", (-260, 120, 95), (1.8, 1.4, 1.8)),
        ("S7F_Cover_B", (300, 220, 95), (2.0, 1.3, 1.8)),
        ("S7F_Cover_C", (-410, 820, 95), (2.2, 1.3, 1.8)),
        ("S7F_Cover_D", (420, 900, 95), (2.2, 1.3, 1.8)),

        ("S7F_Left_Ruin_Wall", (-1050, 650, 220), (1.0, 12, 4.4)),
        ("S7F_Right_Ruin_Wall", (1050, 650, 220), (1.0, 12, 4.4)),
        ("S7F_Sniper_Window_Left", (-700, 1100, 280), (1.0, 2.2, 2.0)),
        ("S7F_Sniper_Window_Right", (700, 1100, 280), (1.0, 2.2, 2.0)),

        ("S7F_Relay_Objective_Block", (0, 650, 100), (2.0, 2.0, 2.0)),
        ("S7F_Exit_Gate_Left", (-230, 2150, 180), (1.0, 1.0, 3.6)),
        ("S7F_Exit_Gate_Right", (230, 2150, 180), (1.0, 1.0, 3.6)),
    ]

    for label, loc, scale in pieces:
        spawn_static_mesh(cube, label, loc, scale, grey)


def candidate_glbs():
    found = []
    for folder in LOCAL_GLB_FOLDERS:
        if not folder.exists():
            continue
        for file_path in folder.glob("*.glb"):
            name = file_path.name.lower()
            score = 0
            if "sector7f" in name or "s7f" in name:
                score += 10
            if "dod" in name or "bridge" in name:
                score += 8
            if "frog" in name:
                score += 5
            found.append((score, file_path))
    return sorted(found, reverse=True, key=lambda row: (row[0], str(row[1])))


def import_glb_visual_shell():
    glbs = candidate_glbs()
    if not glbs:
        warn("No GLB files found in Documents/FROG_GAME_PRODUCTION/TRIPO_EXPORTS, Downloads, or Desktop. Skipping visual shell import.")
        return None

    score, glb_path = glbs[0]
    log("Best GLB candidate: " + str(glb_path))

    destination = ROOT + "/02_IMPORTS/Sector7F_GLB"
    task = unreal.AssetImportTask()
    task.filename = str(glb_path)
    task.destination_path = destination
    task.automated = True
    task.save = True
    task.replace_existing = False

    try:
        unreal.AssetToolsHelpers.get_asset_tools().import_asset_tasks([task])
    except Exception as exc:
        warn("GLB import failed: " + str(exc))
        return None

    imported_paths = list(task.imported_object_paths or [])
    log("Imported object paths: " + str(imported_paths))

    mesh_asset = None
    for path in imported_paths:
        asset = unreal.EditorAssetLibrary.load_asset(path)
        if asset and asset.get_class().get_name() == "StaticMesh":
            mesh_asset = asset
            break

    if not mesh_asset:
        # Fallback scan destination for StaticMeshes
        for path in unreal.EditorAssetLibrary.list_assets(destination, recursive=True, include_folder=False):
            asset = unreal.EditorAssetLibrary.load_asset(path)
            if asset and asset.get_class().get_name() == "StaticMesh" and "cube" not in path.lower():
                mesh_asset = asset
                break

    if not mesh_asset:
        warn("No StaticMesh found after GLB import. Import may still have created assets; check Content Browser.")
        return None

    actor = unreal.EditorLevelLibrary.spawn_actor_from_object(
        mesh_asset,
        unreal.Vector(0, 250, -20),
        unreal.Rotator(0, 0, 0),
    )
    actor.set_actor_label("FROG3D_Sector7F_VisualShell")
    actor.set_actor_scale3d(unreal.Vector(1, 1, 1))
    log("Placed Tripo visual shell in level. Keep blockout cubes as real gameplay collision.")
    return actor


def save_everything():
    try:
        unreal.EditorLevelLibrary.save_current_level()
    except Exception as exc:
        warn("Could not save current level automatically: " + str(exc))
    try:
        unreal.EditorAssetLibrary.save_directory(ROOT, only_if_is_dirty=False, recursive=True)
        unreal.EditorLoadingAndSavingUtils.save_dirty_packages(True, True)
    except Exception as exc:
        warn("Save dirty packages warning: " + str(exc))
    log("Save pass complete.")


def main():
    log("Starting FROG3D FULL AUTO v0.1")
    make_folders()
    create_or_open_level()
    clear_old_frog_blockout()
    build_blockout()
    add_lights_and_player_start()
    import_glb_visual_shell()
    save_everything()
    log("DONE. Press Play in Unreal. If the GLB is ugly, ignore it: the cube blockout is the playable map.")


main()
