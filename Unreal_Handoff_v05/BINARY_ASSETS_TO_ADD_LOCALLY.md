# Binary assets to add locally

The uploaded zip contained one binary GLB asset that could not be safely streamed through this connector in the same commit. Add it from the original zip with GitHub Desktop, git, or Git LFS.

- `Unreal_Handoff_v05/SpaceFrogs_Unreal_Master_Handoff_v05/Content/FROG_GAME/Sector7F/Concept/GLB/SF_Sector7F_Arena_Concept_TripoSource_v01.glb`
  - size: 5258544 bytes
  - sha256: `b2fe822e9d41bdda9aae3e63848e09c9245f5d00431dcaadbcb87d5868dc2b2a`

Recommended command after extracting the original zip:

```bash
git checkout unreal-master-handoff-v05
git add Unreal_Handoff_v05/SpaceFrogs_Unreal_Master_Handoff_v05/Content/FROG_GAME/Sector7F/Concept/GLB/SF_Sector7F_Arena_Concept_TripoSource_v01.glb
git commit -m "Add Sector 7F GLB concept source"
git push
```
