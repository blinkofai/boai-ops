# QC plugin (`boai-qc`)

The QC plugin checks an asset against the client rulebook and the source copy, and writes a QC run report in `qc-runs/`. The rules are in this repo, so every person on the team uses the same rules.

| Part | Path |
|---|---|
| Plugin marketplace | `.claude-plugin/marketplace.json` (marketplace name `boai`) |
| Plugin | `plugins/boai-qc/` |
| QC skill (`/boai-qc:qc`) | `plugins/boai-qc/skills/qc/SKILL.md` |
| Scripts | `plugins/boai-qc/skills/qc/scripts/` |
| Rules sync hook | `plugins/boai-qc/hooks/hooks.json` |
| Rules (shared) | `brand/qc-checklist.md`, `brand/{client}.yaml` |
| Rules check (CI) | `.github/workflows/rules-check.yml` |

## How the rules stay in sync

| When | What happens |
|---|---|
| You start a Claude Code session in the repo | The hook runs `sync_rules.py --hook`. It pulls the latest `main`. Claude sees a line such as "Rules updated (brand/hdfc.yaml)" or "Rules are up to date" |
| You are offline, or on another branch | The hook does not stop the session. It tells Claude that the rules can be out of date |
| Someone changes a rule | They run `sync_rules.py --push "message"`. The script checks the YAML, commits only `brand/`, pulls, then pushes to `main` |
| Two people change the same rule | The push stops with a conflict. Claude helps merge it and keeps both rules |
| A push breaks a rulebook | The "Rules check" GitHub Action fails on that commit |

## Set up a new team member (one time)

1. Install the tools. In a terminal, run:
   ```bash
   winget install ffmpeg
   ```
   ```bash
   python -m pip install pymupdf pyyaml
   ```
2. Clone the repo:
   ```bash
   git clone https://github.com/blinkofai/boai-ops.git
   ```
3. In Claude Code desktop, open the cloned folder as the session folder.
4. Add the plugin. In the session, type:
   ```
   /plugin marketplace add blinkofai/boai-ops
   ```
   ```
   /plugin install boai-qc@boai
   ```
5. Start a new session in the folder. Check that the first message from the hook says "Rules are up to date".

## Use it

- Attach the asset and the source, then type `/boai-qc:qc` or "QC this video".
- To send client feedback, paste it in the same session. The skill marks each comment as a QC miss or a client change, updates the report and proposes a rule.
- After a rule change, tell Claude to push it, or run:
  ```bash
  python -I plugins/boai-qc/skills/qc/scripts/sync_rules.py --push "HDFC: SEBI line first 5 s"
  ```

## Who changes the rules

Founders and AMs push rule changes to `main`. Put the date (dd/mm) and the source of the rule in a comment next to the rule. Mark unsure values with `TODO(confirm)`. FILL: who approves a rule change before it is pushed, if anyone.
