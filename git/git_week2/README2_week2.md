# Git Advanced Workflows — Bisect, Reflog, Hooks/Worktree/Submodules, Gitflow & CI

# Q1 — git bisect: Binary Search for Bug-Introducing Commits

## Original Question

Topic: git bisect: Binary Search for Bug-Introducing Commits

Your application worked 2 weeks ago but has a bug today with 200 commits in between:

(a) Write all git commands to start a bisect session: mark HEAD as bad, mark known-good commit (hash: abc1234) as good.

(b) As you bisect, git checks out a commit. The bug is present -- write the command to mark it bad. Continue until bisect identifies the culprit.

(c) If there are 128 commits between good and bad, how many steps does git bisect need at most? Explain why (binary search).

(d) Write git bisect run using a test script (test.sh that exits 0 for good and 1 for bad). Explain what bisect run does vs manual bisect.

(e) Predict: -- 16 commits between known-good and HEAD (bad) git bisect start git bisect bad HEAD git bisect good v1.0 -- How many steps (max) until git identifies the guilty commit?

---

## (a) Write all git commands to start a bisect session: mark HEAD as bad, mark known-good commit (hash: abc1234) as good.

```bash
git bisect start
git bisect bad HEAD
git bisect good abc1234
```

Git will respond with something like `Bisecting: X revisions left to test after this (roughly Y steps)` and automatically check out a commit roughly halfway between the two.

## (b) As you bisect, git checks out a commit. The bug is present -- write the command to mark it bad. Continue until bisect identifies the culprit.

```bash
# Test the currently checked-out commit (run the app, reproduce the bug)

# If the bug IS present on this commit:
git bisect bad

# If the bug is NOT present on this commit:
git bisect good

# Git checks out the next midpoint commit automatically after each mark.
# Repeat testing + marking (bad/good) at each step until Git reports:
#   <hash> is the first bad commit

# Once identified, clean up and return to your original branch:
git bisect reset
```

## (c) If there are 128 commits between good and bad, how many steps does git bisect need at most? Explain why (binary search).

**At most 7 steps** (⌈log₂(128)⌉ = 7).

**Explanation:** `git bisect` performs a binary search rather than a linear scan. At each step it checks out the commit in the middle of the remaining candidate range and, based on your good/bad answer, discards half of the remaining commits. Starting from 128 candidates: 128 → 64 → 32 → 16 → 8 → 4 → 2 → 1, which takes 7 halving steps to narrow down to a single commit — dramatically fewer than testing all 128 commits one by one.

## (d) Write git bisect run using a test script (test.sh that exits 0 for good and 1 for bad). Explain what bisect run does vs manual bisect.

```bash
git bisect start
git bisect bad HEAD
git bisect good abc1234
git bisect run ./test.sh
```

(Make sure `test.sh` is executable: `chmod +x test.sh`, and that it truly exits with status `0` for a passing/good commit and a non-zero status, typically `1`, for a failing/bad commit — bisect run interprets exit code 125 specially, as "skip this commit, can't test it.")

**`bisect run` vs manual bisect:** In manual bisect, you (a human) check out each candidate commit yourself, manually test it (e.g., run the app, reproduce the bug by hand), and type `git bisect good` or `git bisect bad` at each step. `git bisect run <script>` automates this entire loop — Git checks out each candidate commit, executes the given script against it, reads the script's exit code to automatically determine good/bad, and keeps repeating without any human input until it finds and reports the first bad commit. It's much faster and less error-prone whenever the bug's presence can be checked programmatically (e.g., a failing unit test, a script that crashes, a specific error code).

## (e) Predict: -- 16 commits between known-good and HEAD (bad) git bisect start git bisect bad HEAD git bisect good v1.0 -- How many steps (max) until git identifies the guilty commit?

**At most 4 steps** (⌈log₂(16)⌉ = 4).

**Explanation:** Same binary-search logic as (c): 16 → 8 → 4 → 2 → 1, which is 4 halving steps to isolate the single guilty commit out of 16 candidates.

---

# Q2 — git reflog & Recovering Lost Work

## Original Question

Topic: git reflog & Recovering Lost Work

You accidentally ran git reset --hard HEAD~5 and lost 5 commits of work:

(a) Write the git reflog command and describe the output: what information does each entry show (hash, action, message)?

(b) Identify the commit to recover from reflog output. Write the exact command to restore your branch to that commit.

(c) You deleted branch feature/payment that had 3 unique commits not on any other branch. How do you recover it using reflog? Write all commands.

(d) How long does git keep reflog entries by default? Write the git config command to extend to 90 days. Explain gc.reflogExpire.

(e) Predict the output: git reflog # HEAD@{0}: reset: moving to HEAD~3 # HEAD@{1}: commit: add payment # HEAD@{2}: commit: fix nav # HEAD@{3}: commit: init git checkout HEAD@{1} git log --oneline -- How many commits does git log show?

---

## (a) Write the git reflog command and describe the output: what information does each entry show (hash, action, message)?

```bash
git reflog
```

Example output:

```
a1b2c3d (HEAD -> main) HEAD@{0}: reset: moving to HEAD~5
f9e8d7c HEAD@{1}: commit: Add payment validation
e6d5c4b HEAD@{2}: commit: Fix navbar overflow bug
d3c2b1a HEAD@{3}: commit: Add checkout summary
c0b1a2f HEAD@{4}: commit: Wire up payment API
b9a8c7d HEAD@{5}: commit: Add payment form UI
```

Each reflog line shows:
- **Commit hash** (abbreviated) — the state HEAD pointed to at that moment.
- **Reference notation `HEAD@{n}`** — how many steps back in HEAD's movement history this entry is (`HEAD@{0}` is the most recent).
- **Action** — the operation that moved HEAD (`commit`, `reset`, `checkout`, `rebase`, `pull`, `merge`, `cherry-pick`, etc.).
- **Message** — a short description, usually the commit message for `commit` entries, or details of the operation (e.g., "moving to HEAD~5") for other actions.

## (b) Identify the commit to recover from reflog output. Write the exact command to restore your branch to that commit.

From the sample reflog above, the commit right before the destructive reset is `HEAD@{1}` (hash `f9e8d7c`, "Add payment validation") — that's the tip of your work before `reset --hard` discarded it.

```bash
git reset --hard HEAD@{1}
# or equivalently, using the actual hash:
git reset --hard f9e8d7c
```

This moves your branch pointer, index, and working directory back to that commit, restoring all 5 lost commits.

## (c) You deleted branch feature/payment that had 3 unique commits not on any other branch. How do you recover it using reflog? Write all commands.

```bash
# Find the deleted branch's last commit in the reflog
git reflog
# Look for an entry like:
#   f9e8d7c HEAD@{2}: checkout: moving from feature/payment to main
# or search specifically:
git reflog | grep feature/payment

# Once you find the hash the branch pointed to before deletion, recreate the branch there
git branch feature/payment f9e8d7c

# Verify the 3 commits are back
git checkout feature/payment
git log --oneline
```

(If the branch tip commit doesn't appear directly in `HEAD`'s reflog because it was never checked out on this reflog, you can also search `git fsck --unreachable` / `git fsck --lost-found` to find dangling commits, but for a branch that was checked out locally, the `checkout`/`commit` reflog entries are usually enough to find its last hash.)

## (d) How long does git keep reflog entries by default? Write the git config command to extend to 90 days. Explain gc.reflogExpire.

By default, Git keeps reflog entries for **90 days** for entries that are still reachable, and **30 days** for entries that have become unreachable (e.g., after a reset/rebase orphaned them) — these are controlled by `gc.reflogExpire` (default `90 days`) and `gc.reflogExpireUnreachable` (default `30 days`) respectively. Entries older than these thresholds are pruned the next time `git gc` runs (either manually or automatically).

To explicitly extend the reachable-entry expiry to 90 days (matching or reinforcing the default, or to set a custom value):

```bash
git config --global gc.reflogExpire "90 days"
git config --global gc.reflogExpireUnreachable "90 days"
```

**`gc.reflogExpire` explained:** it's a Git config setting that determines how long reflog entries remain before Git's garbage collector (`git gc`) considers them eligible for pruning. It acts as your safety net's expiration date — once an entry ages past this threshold and `gc` runs, the corresponding commit (if not referenced elsewhere) can be permanently garbage-collected and become unrecoverable via reflog.

## (e) Predict the output: git reflog # HEAD@{0}: reset: moving to HEAD~3 # HEAD@{1}: commit: add payment # HEAD@{2}: commit: fix nav # HEAD@{3}: commit: init git checkout HEAD@{1} git log --oneline

**Predicted output of `git log --oneline`:**

```
f9e8d7c (HEAD) Add payment
e6d5c4b Fix nav
d3c2b1a Init
```

**How many commits: 3.**

**Explanation:** `HEAD@{1}` refers to where HEAD pointed one move ago in the reflog — the commit "add payment," which sits on top of "fix nav" and "init." Checking it out via `git checkout HEAD@{1}` puts you in a detached HEAD state at that commit. Since "add payment" was made on top of "fix nav" and "init" (per the reflog order), `git log --oneline` walks that commit's own ancestry chain, showing all 3 commits: add payment, fix nav, and init (newest first). The later `reset: moving to HEAD~3` entry that undid this is irrelevant here since we've checked out a specific historical commit directly, bypassing wherever the reset left the branch.

---

# Q3 — Git Hooks, git worktree & Submodules

## Original Question

Topic: Git Hooks, git worktree & Submodules

Automate your team's workflow using Git's built-in hooks and worktree features:

(a) Write a pre-commit hook (bash) that runs python -m py_compile on every staged .py file and aborts the commit if any has a syntax error. Show where to place the file and how to make it executable.

(b) Write a commit-msg hook enforcing format '<type>: <description>' (e.g., 'feat: add login page'). Abort the commit if format does not match.

(c) Write git worktree commands to: add a second working tree for the hotfix branch, do work, and remove the worktree when done.

(d) Add an external library as a Git submodule. Write commands to: add the submodule, clone a repo containing submodules, update all submodules to their latest tracked commit.

(e) Predict what happens: # .git/hooks/pre-commit runs: python -m py_compile "$1" || exit 1 # broken.py has a syntax error git add broken.py git commit -m 'add broken file' -- What is the result?

---

## (a) Write a pre-commit hook (bash) that runs python -m py_compile on every staged .py file and aborts the commit if any has a syntax error. Show where to place the file and how to make it executable.

**File location:** `.git/hooks/pre-commit`

```bash
#!/bin/bash
# .git/hooks/pre-commit

# Get all staged .py files (added/copied/modified), excluding deleted ones
STAGED_PY_FILES=$(git diff --cached --name-only --diff-filter=ACM | grep '\.py$')

if [ -z "$STAGED_PY_FILES" ]; then
  exit 0
fi

echo "Running py_compile on staged Python files..."

FAILED=0
for FILE in $STAGED_PY_FILES; do
  python -m py_compile "$FILE"
  if [ $? -ne 0 ]; then
    echo "Syntax error in: $FILE"
    FAILED=1
  fi
done

if [ $FAILED -ne 0 ]; then
  echo "Commit aborted: fix the syntax errors above before committing."
  exit 1
fi

exit 0
```

Make it executable:

```bash
chmod +x .git/hooks/pre-commit
```

## (b) Write a commit-msg hook enforcing format '<type>: <description>' (e.g., 'feat: add login page'). Abort the commit if format does not match.

**File location:** `.git/hooks/commit-msg`

```bash
#!/bin/bash
# .git/hooks/commit-msg

COMMIT_MSG_FILE=$1
COMMIT_MSG=$(cat "$COMMIT_MSG_FILE")

# Enforce format: type: description  (e.g., feat: add login page)
PATTERN="^(feat|fix|docs|style|refactor|test|chore)(\(.+\))?: .+"

if ! echo "$COMMIT_MSG" | grep -Eq "$PATTERN"; then
  echo "Commit aborted: commit message must match format '<type>: <description>'"
  echo "Allowed types: feat, fix, docs, style, refactor, test, chore"
  echo "Example: feat: add login page"
  exit 1
fi

exit 0
```

```bash
chmod +x .git/hooks/commit-msg
```

## (c) Write git worktree commands to: add a second working tree for the hotfix branch, do work, and remove the worktree when done.

```bash
# Add a new worktree at ../hotfix-wt, checking out (or creating) branch hotfix/urgent-fix
git worktree add ../hotfix-wt -b hotfix/urgent-fix

# Move into the new worktree and do your work there — it's a fully independent
# checkout that shares the same repository/history, so your main working tree
# (and whatever branch it's on) stays untouched
cd ../hotfix-wt
# ... make changes, commit, push ...
git add .
git commit -m "Fix urgent production bug"
git push -u origin hotfix/urgent-fix

# Once done, go back to the main working tree
cd -

# Remove the worktree when finished
git worktree remove ../hotfix-wt

# (Optionally delete the branch too, if fully merged/no longer needed)
git branch -d hotfix/urgent-fix
```

## (d) Add an external library as a Git submodule. Write commands to: add the submodule, clone a repo containing submodules, update all submodules to their latest tracked commit.

```bash
# Add an external library as a submodule at vendor/some-library
git submodule add https://github.com/example/some-library.git vendor/some-library
git commit -m "Add some-library as a submodule"

# --- Cloning a repo that already contains submodules ---
git clone --recurse-submodules https://github.com/example/main-repo.git
# (If already cloned without that flag, initialize/fetch them after the fact:)
# git submodule update --init --recursive

# --- Update all submodules to the latest commit on their tracked remote branch ---
git submodule update --remote --merge
git add .
git commit -m "Update submodules to latest tracked commits"
```

## (e) Predict what happens: # .git/hooks/pre-commit runs: python -m py_compile "$1" || exit 1 # broken.py has a syntax error git add broken.py git commit -m 'add broken file'

**Result: the commit is aborted / fails.**

**Explanation:** As written in the question, the hook runs `python -m py_compile "$1" || exit 1` — but note that a real `pre-commit` hook receives **no positional arguments** (`$1` would be empty here; that argument-passing pattern actually belongs to a `pre-commit` framework plugin or a different hook like `commit-msg`, which does receive `$1` as the path to the commit message file). Taking the question's intent at face value — that the hook compiles the staged Python file(s) and `broken.py` has a syntax error — `python -m py_compile` exits with a non-zero status when it hits the `SyntaxError`, so `|| exit 1` causes the hook script itself to exit `1`. When a `pre-commit` hook exits non-zero, Git aborts the commit entirely: no commit object is created, the changes remain staged, and Git prints the hook's output (the Python syntax error traceback) followed by something like:

```
git commit -m 'add broken file'
  File "broken.py", line X
    <syntax error details>
SyntaxError: ...
```

The commit does not go through until `broken.py`'s syntax error is fixed and staged again.

---

# Q4 — Gitflow Strategy, Signed Commits & GitHub Actions CI

## Original Question

Topic: Gitflow Strategy, Signed Commits & GitHub Actions CI

Your team uses Gitflow and wants to add automation and security:

(a) Complete Gitflow hotfix lifecycle for v2.1.0: name every branch, write every command from creation to merging into both main and develop, tag as v2.1.1.

(b) Write a GitHub Actions workflow (.yml) that: triggers on push to feature/* branches, runs pip install -r requirements.txt, then pytest. Fail if any test fails.

(c) Explain GPG signed commits: what problem do they solve, how to configure git to sign all commits automatically, and how GitHub verifies them.

(d) Monorepo with api/, frontend/, data-pipeline/. Write a GitHub Actions workflow that only runs tests for data-pipeline/ when files in that folder change. Use the paths filter.

(e) Predict the result: # GitHub Actions workflow: # on: push # branches: ['feature/*'] # jobs: test: steps: [pytest tests/] # You push to feature/payment. 1 out of 5 tests fails. -- What is the status of the GitHub Actions run?

---

## (a) Complete Gitflow hotfix lifecycle for v2.1.0: name every branch, write every command from creation to merging into both main and develop, tag as v2.1.1.

Branches involved: `main` (production, currently at `v2.1.0`), `develop` (integration branch), and the new hotfix branch `hotfix/2.1.1`.

```bash
# 1. Start the hotfix branch from main (which is at v2.1.0)
git checkout main
git pull origin main
git checkout -b hotfix/2.1.1

# 2. Fix the bug, commit
git add .
git commit -m "fix: resolve critical payment bug"

# 3. Merge the hotfix into main
git checkout main
git pull origin main
git merge --no-ff hotfix/2.1.1 -m "Merge hotfix/2.1.1 into main"

# 4. Tag the new release on main
git tag -a v2.1.1 -m "Release v2.1.1: hotfix for payment bug"
git push origin main --tags

# 5. Merge the hotfix into develop too, so the fix isn't lost in future releases
git checkout develop
git pull origin develop
git merge --no-ff hotfix/2.1.1 -m "Merge hotfix/2.1.1 into develop"
git push origin develop

# 6. Clean up — delete the hotfix branch locally and remotely
git branch -d hotfix/2.1.1
git push origin --delete hotfix/2.1.1
```

## (b) Write a GitHub Actions workflow (.yml) that: triggers on push to feature/* branches, runs pip install -r requirements.txt, then pytest. Fail if any test fails.

`.github/workflows/feature-tests.yml`:

```yaml
name: Feature Branch Tests

on:
  push:
    branches:
      - 'feature/*'

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Set up Python
        uses: actions/setup-python@v5
        with:
          python-version: '3.11'

      - name: Install dependencies
        run: pip install -r requirements.txt

      - name: Run tests
        run: pytest
```

Nothing extra is needed to "fail if any test fails" — `pytest` itself exits with a non-zero status code if any test fails, and any non-zero exit from a workflow step automatically fails that step and the overall job/run in GitHub Actions.

## (c) Explain GPG signed commits: what problem do they solve, how to configure git to sign all commits automatically, and how GitHub verifies them.

**Problem they solve:** By default, Git commit authorship (the `author`/`committer` name and email) is just plain metadata that anyone can set to anything — it's trivial to spoof a commit that looks like it came from someone else. GPG-signed commits cryptographically prove that a commit was actually created by the holder of a specific private key, giving strong assurance of authenticity/non-repudiation, which matters for security-sensitive projects, compliance requirements, or simply trusting that "verified" commits truly came from who they claim to.

**Configuring Git to sign all commits automatically:**

```bash
# Generate a GPG key if you don't have one, then find its ID:
gpg --list-secret-keys --keyid-format=long

# Tell Git which key to use
git config --global user.signingkey <YOUR_GPG_KEY_ID>

# Tell Git to sign every commit automatically (no need for -S each time)
git config --global commit.gpgsign true

# (Optional) also sign tags automatically
git config --global tag.gpgsign true
```

You'd also need to upload the corresponding **public** GPG key to GitHub (Settings → SSH and GPG keys) so GitHub can verify signatures.

**How GitHub verifies them:** When you push a signed commit, GitHub checks the commit's signature against the public GPG keys registered on your GitHub account. If the signature is valid and matches a key tied to your verified email, GitHub marks the commit with a "Verified" badge in the UI. If the signature is missing, invalid, or doesn't match a registered key, it's shown as "Unverified" (or no badge at all for unsigned commits).

## (d) Monorepo with api/, frontend/, data-pipeline/. Write a GitHub Actions workflow that only runs tests for data-pipeline/ when files in that folder change. Use the paths filter.

`.github/workflows/data-pipeline-tests.yml`:

```yaml
name: Data Pipeline Tests

on:
  push:
    paths:
      - 'data-pipeline/**'
  pull_request:
    paths:
      - 'data-pipeline/**'

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Set up Python
        uses: actions/setup-python@v5
        with:
          python-version: '3.11'

      - name: Install dependencies
        working-directory: data-pipeline
        run: pip install -r requirements.txt

      - name: Run tests
        working-directory: data-pipeline
        run: pytest
```

The `paths:` filter under `on.push` (and `on.pull_request`) ensures this workflow is only triggered when at least one changed file's path matches `data-pipeline/**` — commits that only touch `api/` or `frontend/` won't trigger this workflow at all, saving CI time/cost on a monorepo.

## (e) Predict the result: # GitHub Actions workflow: # on: push # branches: ['feature/*'] # jobs: test: steps: [pytest tests/] # You push to feature/payment. 1 out of 5 tests fails.

**Result: the workflow run fails (status: ❌ Failure).**

**Explanation:** Pushing to `feature/payment` matches the `branches: ['feature/*']` trigger pattern, so the workflow runs. The single step `pytest tests/` executes all 5 tests; since 1 test fails, `pytest` exits with a non-zero status code (pytest returns exit code `1` when there are test failures). GitHub Actions treats any non-zero exit code from a step as that step failing, which in turn marks the entire job — and the overall workflow run — as **failed**, even though 4 out of 5 tests passed. GitHub Actions doesn't do partial-pass/partial-fail statuses at the run level; it's all-or-nothing per step unless you explicitly configure `continue-on-error` or similar.
