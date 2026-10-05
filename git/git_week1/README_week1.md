# Git Feature Workflow Walkthrough

## Original Question

Walk through a complete new feature workflow using exact git commands:

(a) From a cloned repo: create branch feature/login-page, make 2 commits (show git add and git commit -m), push to origin.

(b) Teammate pushed to main while you were working. Write commands to pull their changes and bring them into your branch without a merge commit.

(c) What is the difference between git fetch and git pull? Write a scenario where you prefer fetch over pull.

(d) Write the pull request body (3-5 sentences) for feature/login-page: what changed, why, testing notes.

(e) Predict the output:
git init myrepo && cd myrepo
echo 'hello' > file.txt && git add . && git commit -m 'first'
git checkout -b feature/test
echo 'world' >> file.txt && git add . && git commit -m 'add world'
git log --oneline

---

## (a) From a cloned repo: create branch feature/login-page, make 2 commits (show git add and git commit -m), push to origin.

```bash
# From inside the cloned repo
git checkout -b feature/login-page

# --- First commit ---
# (create/edit files for the login page, e.g. login.html, login.css)
git add login.html login.css
git commit -m "Add initial login page markup and styling"

# --- Second commit ---
# (add more work, e.g. form validation logic)
git add login.js
git commit -m "Add client-side validation to login form"

# Push the new branch to origin and set upstream tracking
git push -u origin feature/login-page
```

## (b) Teammate pushed to main while you were working. Write commands to pull their changes and bring them into your branch without a merge commit.

Use `rebase` instead of `merge` to keep history linear (no merge commit):

```bash
# Make sure your local main ref is up to date
git fetch origin

# While on your feature branch, rebase it onto the latest main
git checkout feature/login-page
git rebase origin/main

# If there are conflicts, fix them, then:
git add <resolved-files>
git rebase --continue

# Since the branch history changed (commits were rewritten),
# force-push with lease (safer than plain --force)
git push --force-with-lease origin feature/login-page
```

## (c) What is the difference between git fetch and git pull? Write a scenario where you prefer fetch over pull.

- **`git fetch`**: downloads commits, refs, and objects from the remote into your local copy of the remote-tracking branches (e.g. `origin/main`), but does **not** touch your current working branch or working directory. It just updates your knowledge of what's on the remote.
- **`git pull`**: is essentially `git fetch` followed immediately by a `git merge` (or `git rebase` with `--rebase`) into your current branch. It changes your working branch right away.

**Scenario where `fetch` is preferred over `pull`:**

You're in the middle of writing a commit message or have uncommitted work-in-progress changes, and a teammate says they just pushed something to `main` that you want to *look at* before deciding how to integrate it. You run `git fetch origin` to safely pull down the new commits into `origin/main` without altering your working directory or branch. You can then inspect the changes with `git log origin/main` or `git diff main origin/main`, and decide whether to merge, rebase, or cherry-pick — instead of `git pull` immediately merging/rebasing changes into your branch before you've had a chance to review them (which is riskier if you have uncommitted work or want to avoid surprise conflicts mid-task).

## (d) Write the pull request body (3-5 sentences) for feature/login-page: what changed, why, testing notes.

> **Summary**
> This PR adds a new login page, including the HTML/CSS markup and client-side form validation for the email and password fields. It introduces the base UI teammates can build on for authentication-related work. The change was needed to replace the placeholder auth screen with a functional, styled login flow ahead of the upcoming release. Testing: manually verified the form renders correctly in Chrome and Firefox, confirmed validation messages appear for empty/invalid inputs, and checked that a valid submission triggers the expected callback with no console errors. No automated tests were added yet; recommend follow-up unit tests for the validation logic.

## (e) Predict the output:
git init myrepo && cd myrepo echo 'hello' > file.txt && git add . && git commit -m 'first' git checkout -b feature/test echo 'world' >> file.txt && git add . && git commit -m 'add world' git log --oneline

```bash
git init myrepo && cd myrepo
echo 'hello' > file.txt && git add . && git commit -m 'first'
git checkout -b feature/test
echo 'world' >> file.txt && git add . && git commit -m 'add world'
git log --oneline
```

**Predicted output of `git log --oneline`:**

```
b2c3d4e (HEAD -> feature/test) add world
a1b2c3d (main) first
```

Notes on this prediction:
- Two commits exist: `first` (on `main`, and also an ancestor of `feature/test`) and `add world` (only on `feature/test`).
- The actual commit hashes will be random/unique to your machine — the 7-character hex prefixes shown here are just placeholders.
- `HEAD -> feature/test` shows you're currently on the `feature/test` branch, and `main` still points at the first commit since `feature/test` was branched off after that commit and the second commit was made only on `feature/test`.
- Newest commit is listed first (top), oldest last (bottom).

---

# Q2 — Merge Conflicts & Rebase

## Original Question

Topic: Merge Conflicts & Rebase

Two developers modified the same line in config.py. Describe the full conflict resolution process:

(a) Show what conflict markers look like: include <<<<<<<, =======, >>>>>>> with realistic code on both sides.

(b) Bob's branch needs to be rebased onto main. Write every command: from git rebase to resolving the conflict to completing.

(c) After resolving, Bob's remote branch has different history. Write the push command and explain why regular git push would fail.

(d) When would you use git merge instead of git rebase? Give one concrete team scenario for each.

(e) Predict the state after: git checkout main  # main has commit A git checkout -b feature  # feature has commit B on top of A git checkout main && git rebase feature git log --oneline main

---

## (a) Show what conflict markers look like: include <<<<<<<, =======, >>>>>>> with realistic code on both sides.

```python
DEBUG = True
<<<<<<< HEAD
DATABASE_TIMEOUT = 30
=======
DATABASE_TIMEOUT = 60
>>>>>>> bob/feature-config-update
LOG_LEVEL = "INFO"
```

- Everything between `<<<<<<< HEAD` and `=======` is **your current branch's** version of the line.
- Everything between `=======` and `>>>>>>> bob/feature-config-update` is the **incoming branch's** (Bob's) version.
- You edit the file to keep the correct value (or a combination), then remove all three marker lines entirely before staging.

## (b) Bob's branch needs to be rebased onto main. Write every command: from git rebase to resolving the conflict to completing.

```bash
# Make sure Bob has the latest main
git checkout main
git pull origin main

# Switch to Bob's branch and start the rebase
git checkout bobs-feature-branch
git rebase main

# --- Conflict occurs on config.py ---
# Git pauses and reports:
#   CONFLICT (content): Merge conflict in config.py

# Open config.py, resolve the conflict manually (remove markers, pick correct value)
# Then stage the resolved file:
git add config.py

# Continue the rebase (repeats for each conflicting commit, if more than one)
git rebase --continue

# If at any point Bob wants to bail out and go back to pre-rebase state:
# git rebase --abort

# Once rebase completes successfully, verify history looks correct
git log --oneline
```

## (c) After resolving, Bob's remote branch has different history. Write the push command and explain why regular git push would fail.

```bash
git push --force-with-lease origin bobs-feature-branch
```

**Why a regular `git push` fails:** Rebasing rewrites commit history — it creates brand-new commits (with new hashes) on top of `main` instead of keeping the old ones. Bob's local branch and the remote branch now have diverged histories: the remote still has the old, pre-rebase commits. A plain `git push` performs a fast-forward-only update by default, and since the local branch's history no longer contains the remote's tip commit as an ancestor, Git rejects it with a "non-fast-forward" / "updates were rejected" error. `--force-with-lease` overwrites the remote branch with Bob's rewritten history, but safely — it first checks that no one else has pushed new commits to that branch since Bob last fetched, refusing to clobber someone else's work (unlike plain `--force`, which overwrites blindly).

## (d) When would you use git merge instead of git rebase? Give one concrete team scenario for each.

**Use `git merge` when:**
Scenario: A team is finishing up `feature/checkout-flow`, which has already been reviewed and tested by QA on its own commit history, and multiple developers have pulled and based work off of it. Merging into `main` preserves the exact commit history (including the merge commit marking "checkout-flow was merged here"), giving a clear, honest record of when and how the feature entered `main` — important for auditing/release notes and because rewriting history that others have already pulled would break their local copies.

**Use `git rebase` when:**
Scenario: A single developer, Alice, is working solo on a short-lived branch `feature/tooltip-fix` that no one else has pulled. Before opening a PR, she rebases onto the latest `main` to replay her 4 commits on top, avoiding a noisy merge commit and giving reviewers a clean, linear history that reads like she started from today's `main` — since she's the only one with this branch, rewriting its history is safe.

## (e) Predict the state after:
git checkout main  # main has commit A
git checkout -b feature  # feature has commit B on top of A
git checkout main && git rebase feature
git log --oneline main

**Predicted output:**

```
b2c3d4e (HEAD -> main, feature) B
a1b2c3d A
```

**Explanation:** This is a subtle trick — `git rebase feature` while on `main` means "replay main's commits on top of feature," not the more common "replay my branch on top of feature." Since `main` has no commits that `feature` doesn't already have (main is just A, an ancestor of feature which is A + B), there is nothing unique to `main` to replay. Git simply fast-forwards `main` to point at the same commit as `feature` (commit B). So after this, both `main` and `feature` point to the same commit (B), and `git log --oneline main` shows both commits A and B, with `HEAD -> main` and `feature` both labeled at the tip.

---

# Q3 — Advanced Git: cherry-pick, revert, reset & Interactive Rebase

## Original Question

Topic: Advanced Git: cherry-pick, revert, reset & Interactive Rebase

Working on a large feature branch with a messy commit history:

(a) Bug fix on commit hash a1b2c3d urgently needed on main. Write the exact commands to apply only that commit to main.

(b) Accidentally committed API keys 3 commits ago. Write the command to remove those 3 commits but keep your working files unchanged. Explain --soft vs --mixed vs --hard.

(c) 6 commits to squash into 2 before merging. Write git rebase -i, describe the interactive editor, and what changes you make.

(d) A commit that removed a feature was pushed to main. You cannot use reset. Write git revert and explain what it does vs reset.

(e) Predict the output: git log --oneline # abc Fix bug # def Add feature # ghi Init git revert abc --no-commit git status -- What does git status show?

---

## (a) Bug fix on commit hash a1b2c3d urgently needed on main. Write the exact commands to apply only that commit to main.

```bash
git checkout main
git pull origin main
git cherry-pick a1b2c3d

# If there are no conflicts, cherry-pick auto-commits.
# Push the result:
git push origin main
```

## (b) Accidentally committed API keys 3 commits ago. Write the command to remove those 3 commits but keep your working files unchanged. Explain --soft vs --mixed vs --hard.

```bash
git reset --mixed HEAD~3
```

- `--soft`: moves the branch pointer back 3 commits, but leaves the **index (staging area) and working directory untouched** — all the changes from those 3 commits appear as already-staged changes, ready to be re-committed differently.
- `--mixed` (the default): moves the branch pointer back 3 commits **and** resets the index to match, but leaves the **working directory files unchanged** — changes show up as unstaged modifications. This matches the requirement of "keep your working files unchanged" while un-committing the 3 commits, since you'd then edit out the API keys, re-add, and re-commit clean.
- `--hard`: moves the branch pointer back 3 commits and resets **both the index and the working directory** to match that commit — all changes from those 3 commits are permanently discarded from disk. This is dangerous here because it would silently delete any legitimate work done alongside the leaked keys.

Since API keys were committed, after resetting you should also remove/rotate the exposed keys and consider them compromised (revoke and reissue), since they still exist in reflog/other clones' history until fully purged.

## (c) 6 commits to squash into 2 before merging. Write git rebase -i, describe the interactive editor, and what changes you make.

```bash
git rebase -i HEAD~6
```

This opens an interactive editor listing the 6 commits, oldest at top, each prefixed with `pick`, e.g.:

```
pick 1a1a1a1 Init auth module
pick 2b2b2b2 Add login form
pick 3c3c3c3 Fix typo
pick 4d4d4d4 Add validation
pick 5e5e5e5 Fix validation bug
pick 6f6f6f6 Add tests
```

To squash these 6 into 2 logical commits (e.g., group the first 3 into one "Add login form" commit, and the last 3 into one "Add validation and tests" commit), change the file to:

```
pick 1a1a1a1 Init auth module
squash 2b2b2b2 Add login form
squash 3c3c3c3 Fix typo
pick 4d4d4d4 Add validation
squash 5e5e5e5 Fix validation bug
squash 6f6f6f6 Add tests
```

(`s` is shorthand for `squash` — it folds the commit into the **previous** `pick`ed commit.) Save and close the editor. Git will then open a second editor (once per squash group) to let you write a combined commit message for each squashed group — keep the meaningful summary and delete the redundant "Fix typo" style messages. Saving those completes the rebase, leaving exactly 2 commits.

## (d) A commit that removed a feature was pushed to main. You cannot use reset. Write git revert and explain what it does vs reset.

```bash
git revert <commit-hash-that-removed-the-feature>
```

This opens an editor with a default commit message like `Revert "Remove login feature"` — save and close to complete it (or pass `-m` inline: `git revert <hash> -m "Revert removal of login feature"`).

**`revert` vs `reset`:**
- `git revert` creates a **new commit** that applies the inverse of the changes introduced by the target commit, leaving the original commit intact in history. It's safe for shared/public branches like `main` because it doesn't rewrite existing history — anyone who already pulled the old commits is unaffected.
- `git reset` **moves the branch pointer** backward (and optionally alters the index/working directory), effectively erasing commits from that branch's history. If those commits were already pushed and others have pulled them, `reset` followed by a force-push rewrites shared history and breaks everyone else's clones — which is exactly why it's unsafe here and revert is required instead.

## (e) Predict the output:
git log --oneline
\# abc Fix bug
\# def Add feature
\# ghi Init
git revert abc --no-commit
git status

**Predicted output of `git status`:**

```
On branch main
You are currently reverting commit abc1234.
  (all conflicts fixed: run "git revert --continue")
  (use "git revert --skip" to skip this patch)
  (use "git revert --abort" to cancel the revert operation)

Changes to be committed:
  (use "git restore --staged <file>..." to unstage)
        modified:   <file(s) changed by "Fix bug">
```

**Explanation:** The `--no-commit` (`-n`) flag tells Git to apply the inverse of commit `abc`'s changes to the working directory and stage them, but **stop before creating the revert commit**. So `git status` shows the repo mid-revert: the inverse changes are staged ("Changes to be committed"), no new commit has been made yet, and Git reminds you that you're in the middle of a revert operation — you'd need to run `git revert --continue` (or a plain `git commit`) to finalize it, or `git revert --abort` to cancel.

---

# Q4 — git stash & cherry-pick Workflows

## Original Question

Topic: git stash & cherry-pick Workflows

You are mid-way through a feature when an urgent task arrives on a different branch:

(a) 3 unstaged and 2 staged changes. Write commands to stash all with message 'WIP: user auth', switch to hotfix branch, do work, then restore stash.

(b) 2 stash entries. Write commands to list them, apply the second (index 1) without dropping it, then drop it manually.

(c) Apply commits abc123, def456, ghi789 from feature branch onto main in that exact order without bringing other commits.

(d) git cherry-pick abc123 results in a conflict. Walk through the exact steps to resolve and complete the cherry-pick.

(e) Predict the output: git stash list # stash@{0}: WIP on feature: abc login # stash@{1}: WIP on main: def nav git stash apply stash@{1} git stash list -- How many entries remain in the stash list?

---

## (a) 3 unstaged and 2 staged changes. Write commands to stash all with message 'WIP: user auth', switch to hotfix branch, do work, then restore stash.

```bash
# Stash everything (staged + unstaged) with a descriptive message
git stash push -m "WIP: user auth"

# Switch to the hotfix branch and do the urgent work
git checkout hotfix-branch
# ... make changes, commit, push, etc. ...

# When ready to resume the feature work, switch back
git checkout feature-branch

# Restore the stashed changes
git stash pop
```

`git stash pop` applies the most recent stash and removes it from the stash list. (Use `git stash apply` instead if you want to keep the stash entry around as a backup after restoring it.)

## (b) 2 stash entries. Write commands to list them, apply the second (index 1) without dropping it, then drop it manually.

```bash
# List all stash entries
git stash list

# Apply stash@{1} without removing it from the list
git stash apply stash@{1}

# Manually drop it once you're done with it
git stash drop stash@{1}
```

## (c) Apply commits abc123, def456, ghi789 from feature branch onto main in that exact order without bringing other commits.

```bash
git checkout main
git pull origin main
git cherry-pick abc123 def456 ghi789
```

Passing multiple commit hashes to `git cherry-pick` applies them one at a time in the exact order listed (not the order they appear in the feature branch's history), each becoming its own new commit on `main`. Only these 3 specific commits are applied — any other commits on the feature branch are left behind.

## (d) git cherry-pick abc123 results in a conflict. Walk through the exact steps to resolve and complete the cherry-pick.

```bash
git cherry-pick abc123
# CONFLICT (content): Merge conflict in <file>

# Open the conflicting file(s), find the conflict markers,
# manually edit to the correct resolved content, then remove the markers.

# Stage the resolved file(s)
git add <resolved-file>

# Complete the cherry-pick with the staged resolution
git cherry-pick --continue

# (If you decide the cherry-pick isn't worth resolving, you can instead run:)
# git cherry-pick --abort    # cancels and restores pre-cherry-pick state
# git cherry-pick --skip     # skips this commit, continues if more were queued
```

`git cherry-pick --continue` will prompt an editor for the commit message (pre-filled from the original commit) unless you've already staged everything and it can proceed automatically in some Git versions — either way, saving/closing finalizes the new commit on your current branch.

## (e) Predict the output:
git stash list
\# stash@{0}: WIP on feature: abc login
\# stash@{1}: WIP on main: def nav
git stash apply stash@{1}
git stash list

**Predicted output:**

```
stash@{0}: WIP on feature: abc login
stash@{1}: WIP on main: def nav
```

**How many entries remain: 2.**

**Explanation:** `git stash apply` (unlike `git stash pop`) only applies the stashed changes to the working directory — it does **not** remove the entry from the stash list. So after applying `stash@{1}`, both stash entries are still present when you run `git stash list` again. (Also note: indices don't shift here since nothing was dropped, but a heads-up for related traps — dropping/popping `stash@{0}` would cause `stash@{1}` to become the new `stash@{0}`.)
