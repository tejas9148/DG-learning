## 1. Repository Setup: Create git repo with app.py (greet(), add(), validate_email()), requirements.txt, README.md. Initial commit on main. Create develop from main.

```bash
mkdir gitflow-project
cd gitflow-project
git init -b main
```

Create file `app.py` with content:

```python
# App utilities
VERSION = "0.1.0"

def greet(name):
    return "Hello, " + name

def validate_email(email):
    return "@" in email

def add(a, b):
    return a + b
```

Create file `requirements.txt` with content:

```
pytest
```

Create file `README.md` with content:

```markdown
# Gitflow Project
A small Python app to demonstarte the Gitflow workflow.
```

```bash
git add .
git commit -m "Initial commit: app.py, requirements.txt, README.md"
git branch develop
```

---

## 2. Feature 1 -- User Greeting: Branch feature/user-greeting from develop. Add get_user_input(). Make 2 commits. Merge into develop via PR.

```bash
git checkout develop
git checkout -b feature/user-greeting
```

**Commit 1** - add to the end of `app.py`:

```python

def get_user_input():
    return input("Enter your name: ")
```

```bash
git add app.py
git commit -m "Add get_user_input function"
```

**Commit 2** - in `app.py`, change line 1 to:

```python
# App utilities - user greeting
```

and add to the end of `app.py`:

```python

if __name__ == "__main__":
    print(greet(get_user_input()))
```

```bash
git add app.py
git commit -m "Use get_user_input in main block and update header"
```

Merge into develop (PR simulation):

```bash
git checkout develop
git merge --no-ff feature/user-greeting -m "Merge PR: feature/user-greeting into develop"
```

---

## 3. Feature 2 -- Email Validation: Branch feature/email-validation from develop. Implement validate_email with regex. Make 3 commits. Squash to 1 using interactive rebase before merging.

Branch from the `develop` commit before Feature 1 was merged (so both features change the same line 1):

```bash
git checkout -b feature/email-validation develop~1
```

**Commit 1** - in `app.py`, change line 1 to:

```python
# App utilities - email validation
```

```bash
git add app.py
git commit -m "Update header for email validation"
```

**Commit 2** - in `app.py`, replace the `validate_email` function with:

```python
def validate_email(email):
    import re
    pattern = r"^[\w.+-]+@[\w-]+\.[\w.-]+$"
    return re.match(pattern, email) is not None
```

```bash
git add app.py
git commit -m "Implement validate_email using regex"
```

**Commit 3** - in `app.py`, add a docstring to `validate_email`:

```python
def validate_email(email):
    """Return True if email is valid."""
    import re
    pattern = r"^[\w.+-]+@[\w-]+\.[\w.-]+$"
    return re.match(pattern, email) is not None
```

```bash
git add app.py
git commit -m "Add docstring to validate_email"
```

Squash the 3 commits into 1 using interactive rebase:

```bash
git rebase -i HEAD~3
```

In the editor that opens, change the file from:

```
pick a1b2c3d Update header for email validation
pick e4f5a6b Implement validate_email using regex
pick c7d8e9f Add docstring to validate_email
```

to:

```
pick a1b2c3d Update header for email validation
squash e4f5a6b Implement validate_email using regex
squash c7d8e9f Add docstring to validate_email
```

Save and close. In the commit message editor that opens next, replace all text with:

```
Implement validate_email with regex
```

Save and close, then verify:

```bash
git log --oneline -3
```

---

## 4. Simulate Conflict: Both features modified the same line. Resolve using git rebase. Document in conflict_resolution.txt.

```bash
git checkout feature/email-validation
git rebase develop
```

Git stops with `CONFLICT (content): Merge conflict in app.py`. Open `app.py`; the top of the file looks like:

```
<<<<<<< HEAD
# App utilities - user greeting
=======
# App utilities - email validation
>>>>>>> Implement validate_email with regex
VERSION = "0.1.0"
```

Resolve it: delete the markers and both conflicting lines, and replace them with one combined line:

```python
# App utilities - user greeting and email validation
VERSION = "0.1.0"
```

Create file `conflict_resolution.txt` with content:

```
===== CONFLICT MARKERS (app.py) =====
<<<<<<< HEAD
# App utilities - user greeting
=======
# App utilities - email validation
>>>>>>> Implement validate_email with regex

===== RESOLUTION EXPLANATION =====
Both feature/user-greeting and feature/email-validation changed line 1 of app.py.
feature/user-greeting was merged into develop first, so when
feature/email-validation was rebased onto develop, git stopped with a conflict:
  HEAD (develop):  # App utilities - user greeting
  Incoming branch: # App utilities - email validation
Resolution: both changes were kept by combining them into one line:
  # App utilities - user greeting and email validation
The markers were removed, the file was staged with "git add app.py",
and the rebase was finished with "git rebase --continue".
```

```bash
git add app.py
git rebase --continue
```

Merge feature 2 into develop and commit the documentation:

```bash
git checkout develop
git merge --no-ff feature/email-validation -m "Merge PR: feature/email-validation into develop"
git add conflict_resolution.txt
git commit -m "Add conflict resolution documentation"
```

---

## 5. Release Branch: Create release/v1.0.0 from develop. Bump version to '1.0.0' and fix a typo. Merge into both main and develop. Tag as v1.0.0.

```bash
git checkout -b release/v1.0.0 develop
```

In `app.py`, change:

```python
VERSION = "0.1.0"
```

to:

```python
VERSION = "1.0.0"
```

```bash
git add app.py
git commit -m "Bump version to 1.0.0"
```

In `README.md`, fix the typo `demonstarte` to `demonstrate`:

```markdown
A small Python app to demonstrate the Gitflow workflow.
```

```bash
git add README.md
git commit -m "Fix typo in README"
```

Merge into main and tag, then merge into develop:

```bash
git checkout main
git merge --no-ff release/v1.0.0 -m "Merge release/v1.0.0 into main"
git tag -a v1.0.0 -m "Release version 1.0.0"

git checkout develop
git merge --no-ff release/v1.0.0 -m "Merge release/v1.0.0 into develop"
```

---

## 6. Production Hotfix: Create hotfix/fix-greet-bug from main. Fix greet() to capitalize name. Merge into both main and develop. Tag as v1.0.1.

```bash
git checkout main
git checkout -b hotfix/fix-greet-bug
```

In `app.py`, change the `greet` function to:

```python
def greet(name):
    return "Hello, " + name.capitalize()
```

and change the version line to:

```python
VERSION = "1.0.1"
```

```bash
git add app.py
git commit -m "Fix greet() to capitalize name"
```

Merge into main and tag, then merge into develop:

```bash
git checkout main
git merge --no-ff hotfix/fix-greet-bug -m "Merge hotfix/fix-greet-bug into main"
git tag -a v1.0.1 -m "Hotfix version 1.0.1"

git checkout develop
git merge --no-ff hotfix/fix-greet-bug -m "Merge hotfix/fix-greet-bug into develop"

git tag
```

---

## 7. Pre-commit Hook: Write .git/hooks/pre-commit running py_compile on staged .py files. Test with a broken file.

Create file `.git/hooks/pre-commit` with content:

```sh
#!/bin/sh
# Pre-commit hook: blocks commits that contain Python syntax errors.

# Get the list of staged Python files (added, copied, modified)
FILES=$(git diff --cached --name-only --diff-filter=ACM | grep '\.py$')

# Nothing to check if no .py files are staged
[ -z "$FILES" ] && exit 0

STATUS=0
for f in $FILES; do
    # py_compile returns non-zero on a syntax error
    if ! python3 -m py_compile "$f"; then
        echo "pre-commit: syntax error in $f - commit aborted."
        STATUS=1
    fi
done

# Non-zero exit code makes git abort the commit
exit $STATUS
```

Make the hook executable:

```bash
chmod +x .git/hooks/pre-commit
```

Create a copy of the same content in the repo as file `hooks/pre-commit` (deliverable).

Test with a broken file. Create file `broken.py` with content:

```python
def broken(:
    print("syntax error")
```

```bash
git add broken.py
git commit -m "Test broken file"
```

Expected result: the commit is rejected with `pre-commit: syntax error in broken.py - commit aborted.`

Clean up (delete the file `broken.py`):

```bash
git reset HEAD broken.py
```

---

## 8. GitHub Actions: Write .github/workflows/ci.yml triggering on push to feature/* branches and running pytest

Create file `.github/workflows/ci.yml` with content:

```yaml
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
```

Create file `tests/test_app.py` with content:

```python
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
```

```bash
git add .github tests hooks
git commit -m "Add GitHub Actions CI, tests and pre-commit hook copy"
```
