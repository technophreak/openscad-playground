# Get OpensCAD on your PC

The cloud agent **cannot** create a lasting git repo for you (token isn’t scoped for `origin repo create`). You need one click, then clone locally.

## Option A — real git repo (recommended)

1. Open the agent run: https://cursor.com/agents/bc-772aab9d-0876-5064-a2ed-19cee4988876  
2. Click **Create repo** (promotes the temp project to a normal Origin/GitHub repo).  
3. On your PC:

```bash
git clone <url-from-create-repo>
cd <repo-folder>
git checkout cursor/openscad-playground-8876
```

4. Open any file under `parts/` in your local OpenSCAD → **Window → Customizer** → **F5**.  
5. Export STLs: `make stls` (or `make part PART=cell_holder_18650_x3`).

## Option B — zip (no git yet)

A snapshot of the current branch is in the Project store:

- [`/cursor/stores/self/artifacts/openscad-playground.zip`](/cursor/stores/self/artifacts/openscad-playground.zip)

Download it from the agent/Context artifacts UI, unzip on your PC, open in Cursor + OpenSCAD. You can `git init` later if you want history.

## Note

Blueprint / project notes stay in the Agent Context store (`docs/`), not inside that zip. The zip is the printable OpenSCAD sources + Makefile/README.
