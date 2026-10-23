# Gitflow Release Cycle Mini Project

## Question

Simulate a complete team software release cycle using Gitflow, from feature development through a release to a production hotfix, including automation via a pre-commit hook and a basic GitHub Actions CI pipeline.

**Learning objectives**
- Apply all 5 Gitflow branch types: main, develop, feature, release, hotfix
- Create and resolve a merge conflict using rebase
- Use interactive rebase to clean up commit history
- Write and install a git pre-commit hook enforcing code style
- Write a GitHub Actions workflow running tests on push to feature branches

**Deliverables**
- Git repository (zipped) with full git log intact
- `git_log.txt` (output of `git log --oneline --graph --all`)
- `conflict_resolution.txt` (conflict markers and resolution explanation)
- pre-commit hook file with comments
- `.github/workflows/ci.yml`
- README section explaining Gitflow branch types (5-6 sentences)

---

## 1. Repository Setup

Create git repo with `app.py` (`greet()`, `add()`, `validate_email()`), `requirements.txt`, `README.md`. Initial commit on `main`. Create `develop` from `main`.

```bash
mkdir gitflow-project && cd gitflow-project
git init -b main

cat > app.py << 'EOF'
# App utilities
VERSION = "0.1.0"

def greet(name):
    return "Hello, " + name

def validate_email(email):
    return "@" in email

def add(a, b):
    return a + b
EOF

echo "pytest" > requirements.txt

cat > README.md << 'EOF'
# Gitflow Project
A small Python app to demonstarte the Gitflow workflow.
EOF

git add .
git commit -m "Initial commit: app.py, requirements.txt, README.md"
git branch develop
```

---

## 2. Feature 1 - User Greeting

Branch `feature/user-greeting` from `develop`. Add `get_user_input()`. Make 2 commits. Merge into `develop` via PR.

```bash
git checkout develop
git checkout -b feature/user-greeting

# Commit 1
cat >> app.py << 'EOF'

def get_user_input():
    return input("Enter your name: ")
EOF
git add app.py
git commit -m "Add get_user_input function"

# Commit 2 (changes line 1 - used later for the conflict)
sed -i '1s/.*/# App utilities - user greeting/' app.py
cat >> app.py << 'EOF'

if __name__ == "__main__":
    print(greet(get_user_input()))
EOF
git add app.py
git commit -m "Use get_user_input in main block and update header"

# Merge into develop (PR simulation)
git checkout develop
git merge --no-ff feature/user-greeting -m "Merge PR: feature/user-greeting into develop"

# Optional: with GitHub CLI instead of local merge
# git push -u origin feature/user-greeting
# gh pr create --base develop --head feature/user-greeting --title "User greeting" --body "Adds get_user_input"
# gh pr merge --merge
```

---

## 3. Feature 2 - Email Validation

Branch `feature/email-validation` from `develop`. Implement `validate_email` with regex. Make 3 commits. Squash to 1 using interactive rebase before merging.

> Branch from the `develop` commit that existed before Feature 1 was merged, so both features change the same line 1 and a conflict occurs later.

```bash
git checkout -b feature/email-validation develop~1

# Commit 1 (changes line 1 - same line as feature 1)
sed -i '1s/.*/# App utilities - email validation/' app.py
git add app.py
git commit -m "Update header for email validation"

# Commit 2
sed -i 's/    return "@" in email/    import re\n    pattern = r"^[\\w.+-]+@[\\w-]+\\.[\\w.-]+$"\n    return re.match(pattern, email) is not None/' app.py
git add app.py
git commit -m "Implement validate_email using regex"

# Commit 3
sed -i 's/^def validate_email(email):/&\n    """Return True if email is valid."""/' app.py
git add app.py
git commit -m "Add docstring to validate_email"

# Interactive rebase: squash 3 commits into 1
git rebase -i HEAD~3
# In the editor keep first line as "pick", change the other two from "pick" to "squash" (or "fixup"), save and close.
# Edit the final commit message to: "Implement validate_email with regex"

# Non-interactive alternative for the same result
# GIT_SEQUENCE_EDITOR="sed -i '2,3s/^pick/fixup/'" git rebase -i HEAD~3
# git commit --amend -m "Implement validate_email with regex"

git log --oneline -3
```

---

## 4. Simulate Conflict and Resolve with Rebase

Both features modified the same line (line 1). Resolve using `git rebase`. Document in `conflict_resolution.txt`.

```bash
git checkout feature/email-validation
git rebase develop
# CONFLICT in app.py

git status
cat app.py

# Save conflict markers to the document
echo "===== CONFLICT MARKERS (app.py) =====" > conflict_resolution.txt
head -8 app.py >> conflict_resolution.txt

# Resolve: remove markers and write the combined line
sed -i '/^<<<<<<< /d;/^=======$/d;/^>>>>>>> /d' app.py
sed -i '/^# App utilities - /d' app.py
sed -i '1i # App utilities - user greeting and email validation' app.py
head -3 app.py

git add app.py
GIT_EDITOR=true git rebase --continue

# Add resolution explanation
cat >> conflict_resolution.txt << 'EOF'

===== RESOLUTION EXPLANATION =====
Both feature/user-greeting and feature/email-validation changed line 1 of app.py.
feature/user-greeting was merged into develop first, so when
feature/email-validation was rebased onto develop, git stopped with a conflict:
  HEAD (develop):  # App utilities - user greeting
  Incoming branch: # App utilities - email validation
Resolution: both changes were kept by combining them into one line:
  # App utilities - user greeting and email validation
The markers (<<<<<<<, =======, >>>>>>>) were removed, the file was staged with
"git add app.py", and the rebase was finished with "git rebase --continue".
EOF

# Merge feature 2 into develop (PR simulation)
git checkout develop
git merge --no-ff feature/email-validation -m "Merge PR: feature/email-validation into develop"
git add conflict_resolution.txt
git commit -m "Add conflict resolution documentation"
```

---

## 5. Release Branch

Create `release/v1.0.0` from `develop`. Bump version to `1.0.0` and fix a typo. Merge into both `main` and `develop`. Tag as `v1.0.0`.

```bash
git checkout -b release/v1.0.0 develop

# Bump version
sed -i 's/VERSION = "0.1.0"/VERSION = "1.0.0"/' app.py
git add app.py
git commit -m "Bump version to 1.0.0"

# Fix typo in README
sed -i 's/demonstarte/demonstrate/' README.md
git add README.md
git commit -m "Fix typo in README"

# Merge into main and tag
git checkout main
git merge --no-ff release/v1.0.0 -m "Merge release/v1.0.0 into main"
git tag -a v1.0.0 -m "Release version 1.0.0"

# Merge back into develop
git checkout develop
git merge --no-ff release/v1.0.0 -m "Merge release/v1.0.0 into develop"
```

---

## 6. Production Hotfix

Create `hotfix/fix-greet-bug` from `main`. Fix `greet()` to capitalize name. Merge into both `main` and `develop`. Tag as `v1.0.1`.

```bash
git checkout main
git checkout -b hotfix/fix-greet-bug

sed -i 's/return "Hello, " + name/return "Hello, " + name.capitalize()/' app.py
sed -i 's/VERSION = "1.0.0"/VERSION = "1.0.1"/' app.py
git add app.py
git commit -m "Fix greet() to capitalize name"

# Merge into main and tag
git checkout main
git merge --no-ff hotfix/fix-greet-bug -m "Merge hotfix/fix-greet-bug into main"
git tag -a v1.0.1 -m "Hotfix version 1.0.1"

# Merge into develop
git checkout develop
git merge --no-ff hotfix/fix-greet-bug -m "Merge hotfix/fix-greet-bug into develop"

git tag
```

---

## 7. Pre-commit Hook

Write `.git/hooks/pre-commit` running `py_compile` on staged `.py` files. Test with a broken file.

```bash
cat > .git/hooks/pre-commit << 'EOF'
#!/bin/sh
# Pre-commit hook: blocks commits that contain Python syntax errors.

# Get the list of staged Python files (added, copied, modified)
FILES=$(git diff --cached --name-only --diff-filter=ACM | grep '\.py$')

# Nothing to check if no .py files are staged
[ -z "$FILES" ] && exit 0

STATUS=0
for f in $FILES; do
    # Compile each staged file; py_compile returns non-zero on syntax error
    if ! python3 -m py_compile "$f"; then
        echo "pre-commit: syntax error in $f - commit aborted."
        STATUS=1
    fi
done

# Non-zero exit code makes git abort the commit
exit $STATUS
EOF

chmod +x .git/hooks/pre-commit

# Keep a copy inside the repo as a deliverable
mkdir -p hooks
cp .git/hooks/pre-commit hooks/pre-commit

# Test with a broken file
cat > broken.py << 'EOF'
def broken(:
    print("syntax error")
EOF
git add broken.py
git commit -m "Test broken file"
# Expected: commit is rejected

# Clean up
git reset HEAD broken.py
rm broken.py
```

---

## 8. GitHub Actions

Write `.github/workflows/ci.yml` triggering on push to `feature/*` branches and running `pytest`.

```bash
mkdir -p .github/workflows tests

cat > .github/workflows/ci.yml << 'EOF'
name: CI

on:
  push:
    branches:
      - 'feature/**'

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
EOF

cat > tests/test_app.py << 'EOF'
import os, sys
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from app import greet, add, validate_email

def test_greet():
    assert greet("alice") == "Hello, Alice"

def test_add():
    assert add(2, 3) == 5

def test_validate_email():
    assert validate_email("user@example.com")
    assert not validate_email("invalid-email")
EOF

pip install -r requirements.txt
pytest

# Validate YAML
python3 -c "import yaml; yaml.safe_load(open('.github/workflows/ci.yml')); print('valid yaml')"

git add .github tests hooks
git commit -m "Add GitHub Actions CI, tests and pre-commit hook copy"
```

---

## 9. README Gitflow Section

```bash
cat >> README.md << 'EOF'

## Gitflow Branch Types

Gitflow is a branching model that gives every kind of work its own branch. The `main` branch always holds stable production code, and every release on it is tagged with a version number. The `develop` branch is the integration branch where completed features are combined and tested together. Feature branches (`feature/*`) are created from `develop` for each new piece of work and are merged back through a pull request. Release branches (`release/*`) are cut from `develop` to prepare a version, allowing only version bumps and small fixes before merging into both `main` and `develop`. Hotfix branches (`hotfix/*`) are created from `main` to patch urgent production bugs and are merged into both `main` and `develop` so the fix is never lost.
EOF

git add README.md
git commit -m "Add Gitflow branch types explanation to README"
```

---

## 10. Generate Deliverables

```bash
# Git log
git log --oneline --graph --all > git_log.txt
cat git_log.txt

# Verification checks
git branch -a
git tag
git log main --oneline --decorate | head
git branch --contains hotfix/fix-greet-bug
git log feature/email-validation --oneline

# Commit deliverable files
git add git_log.txt
git commit -m "Add git_log.txt"
git log --oneline --graph --all > git_log.txt

# Zip the repository with full .git history
cd ..
zip -r gitflow-project.zip gitflow-project
```
