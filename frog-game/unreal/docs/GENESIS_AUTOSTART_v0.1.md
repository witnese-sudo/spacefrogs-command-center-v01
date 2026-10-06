# Genesis startup at Windows login

Truth state: GENERATED / NOT YET LOCAL-RUNTIME-VERIFIED.

## Scope

An opt-in, current-user Startup shortcut invokes `GENESIS_AUTOSTART_v01.ps1` at login (not before login). No administrator rights, service, scheduled task, machine-wide registry edit, credentials, or execution-policy bypass are added. Remove the shortcut with the same installer to undo the hook. Existing manual BAT launcher remains unchanged.

The runner executes existing discovery in a child process. No project (exit 2), multiple preferred projects (3), or multiple fallback projects (4) stops before editor launch. Discovery still prefers FROG3D_v01 and allows the existing single-project fallback. Arrays are explicitly retained so one result is a complete path rather than its first character. A fresh per-run result is read only after exit 0; an old manifest cannot authorize a launch.

The exact editor executable must be supplied by the operator. Missing editor, failed discovery, or any already running UnrealEditor blocks launch. A per-session mutex prevents simultaneous runner instances. The runner opens the selected project only; it does not build content, run full-auto Python, execute HUB precheck, start Play, or establish a conversational AI/voice service. This repository does not document such an AI service entry point. A launched process is not proof of a loaded/working editor or Genesis AI.

## Install and undo

Use a stable checkout of `review/genesis-autostart-v01`. In Windows PowerShell, from the repository root, set `$editor` to the **actual absolute path** to your intended `UnrealEditor.exe` (confirm the engine/project match locally). Then:

```powershell
./frog-game/unreal/scripts/SET_GENESIS_AUTOSTART_v01.ps1 -EditorPath $editor -WhatIf
./frog-game/unreal/scripts/SET_GENESIS_AUTOSTART_v01.ps1 -EditorPath $editor
```

Installation is explicit and does not launch Unreal immediately. Re-running installation updates only the owned shortcut. An unrelated shortcut at the same name is refused. The checkout must remain at that location; if moved, reinstall. Windows policy may block scripts; do not weaken policy globally. Resolve any policy block through the machine's approved signing/policy process.

Undo (also works if the editor has been removed):

```powershell
./frog-game/unreal/scripts/SET_GENESIS_AUTOSTART_v01.ps1 -Action Remove
```

The hook is `%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\SpaceFrogs Genesis v01.lnk` (actual location comes from Windows' Startup special folder). Logs are in `%LOCALAPPDATA%\SpaceFrogs\GenesisAutostart\startup-*.log`. Exit 0 means launch requested, 2/3/4 discovery blocked, 5 concurrent runner, 1 other block/error. Local logs contain local paths; review before sharing. Discovery continues to write its GENERATED manifest beside the selected project.

## Checks and proof still required

Run `frog-game/unreal/scripts/tests/GENESIS_AUTOSTART_TEST_v01.ps1`. It parses scripts and exercises empty, single preferred, single fallback, preferred among alternatives, duplicate preferred, and ambiguous project fixtures. This is script evidence, not Unreal runtime evidence. Windows CI repeats it under Windows PowerShell 5.1.

Local acceptance must record checkout commit, Windows/PowerShell version, exact editor version/path and project path, installation/shortcut properties, then:

1. Run the runner manually with `-EditorPath $editor`; retain its log and verify that the intended project actually loads.
2. Test no project and ambiguous project conditions using temporary discovery fixtures; confirm exits 2/3/4 and no launch. Never rename production project folders for a test.
3. With Unreal already open, run the runner and confirm no duplicate editor or project switch.
4. Sign out and sign in (or reboot and log in). Confirm one intended editor opens; retain startup log and editor log/screenshot.
5. In that editor run `HUB_PROOF_001_PRECHECK.py` manually. Its scaffold is not gameplay proof; retain unresolved blockers.
6. Remove the hook and repeat login: no Genesis autostart. Confirm unrelated startup entries unchanged.

Only mark the tested startup behavior VERIFIED after those local checks pass. Conversational AI, voice, gameplay, save/redeploy and hub systems each still require their own implementation and runtime proof. No merge is part of this change.

## Explicit selection and existing local LUXA assistant

After a human selects the project, pass `-ProjectPath` to installer/runner. Discovery still scans approved roots, requires that exact file to be among its candidates, and returns exit 6 if it is outside them. Without an explicit path, all original 2/3/4 stops remain unchanged. This is recorded human selection, never a latest-file heuristic. A missing selected file blocks with an error.

For the existing LUXA workspace, pass `-AssistantRoot` to the installer. The runner first validates its known npm dev command and files, checks that any listener on 8080 belongs to that workspace's Node/Vite process, starts `npm run dev` only if needed, waits for the identified page, then opens it in the default browser. Foreign listeners and changed commands block. It does not trigger microphone, paid AI requests, memory snapshots or Sentinel missions. An existing Unreal editor still blocks a second editor while the independently validated assistant can open.

On DISSART the selected game is `Documents/Unreal Projects/SF_GenesisSwamp 5.8/SF_GenesisSwamp.uproject`, engine 5.8; the local assistant is `Downloads/W007JSjminO4Y7ei-grok-workspace`. Its old `LUXA_HEART_OF_GENESIS.cmd` startup hook must be moved to a backup outside Startup before enabling the combined hook, to avoid duplicate startup paths. This old hook exists locally, not in PR #3. Restore the backup and remove the combined shortcut to undo the replacement. Do not change Ollama or unrelated startup entries.

Installation example (use verified actual paths in `$editor`, `$project`, `$assistant`):

```powershell
./frog-game/unreal/scripts/SET_GENESIS_AUTOSTART_v01.ps1 -EditorPath $editor -ProjectPath $project -AssistantRoot $assistant
```

Opening the page and its HTTP status are not proof of an AI answer, microphone, Suno voice or audio output. A browser may require a user click for microphone/audio. Actual Windows-login proof remains pending until a real login test is observed.
