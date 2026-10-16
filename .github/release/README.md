# Release automation

Pushing a version tag builds the three release zips and publishes a GitHub Release.
No Unity or DLL compile happens here - the DLLs are committed, so the workflow only
packages tracked files from the tagged commit.

## Cutting a release

1. (Recommended) Write the changelog bullets for the new version in
   `.github/release/notes/<tag>.md` - e.g. `notes/v6.4.md`. These bullets become the top
   of the release body. If the file is absent, the workflow falls back to the commit
   subjects since the previous tag.
2. Commit everything for the release (including any DLL updates and the notes file).
3. Tag and push:
   ```bash
   git tag v6.4
   git push origin v6.4
   ```
4. The **Release** workflow (`.github/workflows/release.yml`) runs and creates a **draft**
   release with the three zips attached. Review the notes, then click **Publish**.
   (To build a release for a tag that already exists, run the workflow manually from the
   Actions tab; untick *draft* there to publish immediately.)

## The three assets

| Asset | Contents | How it's built |
| --- | --- | --- |
| `GT_CustomMapExample_<tag>.zip` | The full Unity project. | `git archive` of the tag (every tracked file). |
| `GT_CustomMapExample_<tag>_Minimal.zip` | SDK + placeholder prefabs + their asset dependencies + shaders + the `MinimalExample` scene. | The explicit path list in `minimal-files.txt`. |
| `GT_CustomMapExample_<tag>_UpdatesOnly.zip` | Files changed since the previous tag. | `git diff --name-only <prev> <tag>`. |

The previous tag is auto-detected (`git describe --tags --abbrev=0 <tag>^`).

## Running it locally

`pack.sh` and `release-body.sh` need only `git` + `zip` and run fine in Git Bash:

```bash
# from the repo root, on the tag you want to package
bash .github/release/pack.sh v6.4            # -> dist/*.zip
bash .github/release/release-body.sh v6.4    # -> prints the release body
```

## The Minimal manifest (`minimal-files.txt`)

The Minimal zip is a **Unity-computed asset dependency closure** (the `MinimalExample`
scene + all `MapPrefabs` + the project config they need). CI cannot recompute that without
a Unity license, so the exact path list is checked in as `minimal-files.txt` (paths are
project-root-relative, one per line).

**When Minimal content changes** - you add/remove a placeholder prefab, change the
`MinimalExample` scene, or pull in new shared assets - the manifest must be regenerated,
or the new files will be missing from the Minimal zip. To regenerate it from Unity:

1. Collect the dependency closure of the minimal roots with
   `AssetDatabase.GetDependencies` over `Assets/Scenes/MinimalExample.unity` and every
   prefab under `Assets/MapPrefabs/`, add each asset's `.meta`, and add the non-`Assets`
   project files (`ProjectSettings/*`, `Packages/manifest.json`, `Packages/packages-lock.json`,
   `Plugins/*`, `Luau/*`, `README.md`, `LICENSE`, `.gitignore`, `Exports/placeholder.txt`).
2. Write the sorted, root-relative list to `.github/release/minimal-files.txt` and commit it.

(If you'd like this as a one-click `Tools/Regenerate Minimal Release Manifest` editor menu
item, that can be added to the SDK editor DLL.)
