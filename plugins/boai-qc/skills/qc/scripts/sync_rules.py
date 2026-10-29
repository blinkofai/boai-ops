"""Keep the shared QC rules (brand/) in sync with git.

Usage:
  python -I sync_rules.py              pull the latest rules
  python -I sync_rules.py --hook       same, but never fails (used by the SessionStart hook)
  python -I sync_rules.py --push MSG   commit changes in brand/, pull, then push

The ops repo is found from --repo, then the BOAI_OPS_REPO environment variable,
then the current folder and its parents (the first one with brand/qc-checklist.md).
Rules live on the main branch.
"""
import argparse
import os
import subprocess
import sys
from pathlib import Path

RULES = "brand"
MAIN = "main"


def git(repo, *args, timeout=30):
    r = subprocess.run(["git", "-C", str(repo), *args], capture_output=True, text=True,
                       encoding="utf-8", errors="replace", timeout=timeout)
    return r.returncode, (r.stdout + r.stderr).strip()


def find_repo(arg):
    for candidate in (arg, os.environ.get("BOAI_OPS_REPO")):
        if candidate and (Path(candidate) / RULES / "qc-checklist.md").exists():
            return Path(candidate)
    here = Path.cwd()
    for folder in (here, *here.parents):
        if (folder / RULES / "qc-checklist.md").exists():
            return folder
    return None


def short_head(repo):
    _, out = git(repo, "log", "-1", "--format=%h %cs %an: %s", "--", RULES)
    return out


def pull(repo):
    """Return (ok, message)."""
    code, branch = git(repo, "rev-parse", "--abbrev-ref", "HEAD")
    if code != 0:
        return False, f"{repo} is not a git repo."
    code, _ = git(repo, "remote", "get-url", "origin")
    if code != 0:
        return False, "The ops repo has no 'origin' remote, so the rules are not shared yet."

    code, out = git(repo, "fetch", "origin", MAIN)
    if code != 0:
        return False, f"Could not fetch the rules (offline?). Using the local copy. {out}"

    if branch != MAIN:
        _, changed = git(repo, "diff", "--name-only", "HEAD", f"origin/{MAIN}", "--", RULES)
        if changed:
            files = ", ".join(changed.splitlines())
            return False, (f"You are on branch '{branch}', and origin/{MAIN} has different rules: {files}. "
                           f"Merge {MAIN} into this branch, or switch to {MAIN}, to use them.")
        return True, f"Rules match origin/{MAIN} (on branch '{branch}')."

    before = git(repo, "rev-parse", "HEAD")[1]
    code, out = git(repo, "pull", "--ff-only", "--autostash", "origin", MAIN)
    if code != 0:
        return False, f"Could not update the rules: {out}. Run sync_rules.py by hand and fix the conflict."
    if git(repo, "rev-parse", "HEAD")[1] == before:
        return True, f"Rules are up to date. Last rule change: {short_head(repo)}"
    _, changed = git(repo, "diff", "--name-only", before, "HEAD", "--", RULES)
    files = ", ".join(changed.splitlines()) or "no rule files"
    return True, f"Rules updated ({files}). Last rule change: {short_head(repo)}"


def check_yaml(repo):
    try:
        import yaml
    except ImportError:
        return None
    for path in (repo / RULES).glob("*.yaml"):
        try:
            yaml.safe_load(path.read_text(encoding="utf-8"))
        except yaml.YAMLError as e:
            return f"{path.name} is not valid YAML: {e}"
    return None


def push(repo, message):
    code, branch = git(repo, "rev-parse", "--abbrev-ref", "HEAD")
    if branch != MAIN:
        sys.exit(f"Rule changes go to '{MAIN}'. You are on '{branch}'. Switch to {MAIN} first.")
    error = check_yaml(repo)
    if error:
        sys.exit(error)

    git(repo, "add", "--", RULES)
    code, _ = git(repo, "diff", "--cached", "--quiet", "--", RULES)
    if code != 0:
        code, out = git(repo, "commit", "-m", message, "--", RULES)
        if code != 0:
            sys.exit(f"Commit failed: {out}")
        print(f"Committed: {message}")
    else:
        print("No rule changes to commit.")

    code, out = git(repo, "pull", "--rebase", "--autostash", "origin", MAIN, timeout=60)
    if code != 0:
        sys.exit(f"Someone else changed the same rules. Fix the conflict, then run this again.\n{out}")
    code, out = git(repo, "push", "origin", MAIN, timeout=60)
    if code != 0:
        sys.exit(f"Push failed: {out}")
    print(f"Pushed. Last rule change: {short_head(repo)}")


def main():
    p = argparse.ArgumentParser()
    p.add_argument("--repo")
    p.add_argument("--hook", action="store_true")
    p.add_argument("--push", metavar="MESSAGE")
    a = p.parse_args()

    repo = find_repo(a.repo)
    if repo is None:
        if a.hook:
            return  # not in the ops repo: say nothing
        sys.exit("Ops repo not found. Open the Boai ops repo, or set BOAI_OPS_REPO to its folder.")

    if a.push:
        push(repo, a.push)
        return

    try:
        ok, message = pull(repo)
    except subprocess.TimeoutExpired:
        ok, message = False, "Git timed out. Using the local copy of the rules."
    print(f"[boai-qc] {message}")
    if not ok and not a.hook:
        sys.exit(1)


if __name__ == "__main__":
    main()
