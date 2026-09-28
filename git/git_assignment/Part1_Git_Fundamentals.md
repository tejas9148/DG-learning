# DataGrokr Git Assignment — Part I: Git Fundamentals

*After completing this part, host the Git repository publicly on GitHub and submit the link to your learning coordinator.*

---

### 1. Create a Git repository

Create a Git repository named `my-exciting-project`.

```bash
mkdir my-exciting-project
cd my-exciting-project
git init
```

---

### 2. Create standard branches as per GitFlow

By default this newly created repo has only a single branch called master. Create a new branch off of master and name it develop.

```bash
git checkout -b develop master
```

---

### 3. Creating feature branches to add changes

Now we want to add some stuff to our empty codebase. Switch to develop branch and then create a new branch called feature/initial-setup. Create a file called README and add the following line as its content: This is a sample README. Similarly, create a new file called LICENSE and add the following line as its content: This is a sample LICENSE.

Also create a Python script with the following contents and name it as my-awesome-script.py:

```python
#!/bin/python
print('Hello, World!')
```

Now stage the changes and commit it to the current branch.

```bash
git checkout develop
git checkout -b feature/initial-setup

echo "This is a sample README" > README
echo "This is a sample LICENSE" > LICENSE

cat << 'EOF' > my-awesome-script.py
#!/bin/python
print('Hello, World!')
EOF

git add README LICENSE my-awesome-script.py
git commit -m "Initial setup: add README, LICENSE and awesome script"
```

---

### 4. Merging changes from working branches to main branches

At this point if you were to list all active branches in the repository, we have the following:

```
$ git branch
* feature/initial-setup
master
develop
```

We want to merge changes from our feature branch feature/initial-setup (working branch), to the main development branches (develop and master) like this:

- Merge feature/initial-setup to develop
- Merge develop to master

Perform the merge as described above and once done, master and develop should have the changes made on feature/initial-setup.

```bash
git checkout develop
git merge feature/initial-setup

git checkout master
git merge develop
```

---

### 5. Resolving merge conflicts

Switch to the develop branch and create a branch called feature/enhancement-1 off of it. Modify the print statement in my-awesome-script.py to say Howdy, World!. Stage and commit your changes.

Switch back to develop again.

Create a new branch called feature/my-enhacement-2 from develop. Modify the print statement in my-awesome-scipt.py to say Hajimemashite sekai! (this also means hello world, but in Japanese).

Now, first merge feature/enhacement-1 to develop. And THEN merge feature/enhancement-2 to develop.

```bash
git checkout develop
git checkout -b feature/enhancement-1
# edit my-awesome-script.py -> print('Howdy, World!')
git add my-awesome-script.py
git commit -m "Update greeting to Howdy, World!"

git checkout develop
git checkout -b feature/my-enhancement-2
# edit my-awesome-script.py -> print('Hajimemashite sekai!')
git add my-awesome-script.py
git commit -m "Update greeting to Hajimemashite sekai!"

git checkout develop
git merge feature/enhancement-1

git merge feature/my-enhancement-2
# CONFLICT (content): Merge conflict in my-awesome-script.py
# open the file, resolve the <<<<<<< ======= >>>>>>> markers manually
git add my-awesome-script.py
git commit -m "Resolve merge conflict between enhancement-1 and enhancement-2"
```

---

### 6. Amending commits

Checkout develop and create a new branch called feature/next-awesome-thing. Then add the comment # This is an awesome Python script to my-awesome-script.py, in the line below the shebang (the #!.bin/python). Stage and commit your change with the message Added a comment. Now, amend this last commit so that the commit message reads Added an awesome comment.

```bash
git checkout develop
git checkout -b feature/next-awesome-thing

# edit my-awesome-script.py to add the comment line below the shebang
git add my-awesome-script.py
git commit -m "Added a comment"

git commit --amend -m "Added an awesome comment"
```

---

### 7. Dropping commits

While still on branch feature/next-awesome-thing, drop the last commit that you added.

```bash
# Non-destructive way
git reset --soft HEAD~1

# The destructive way
git reset --hard HEAD~1
```

---

### 8. Squashing commits

Go back to develop and checkout a new branch feature/part-1-finale.

Modify the print statement in my-awesome-script.py to say Hello! World, how is it going?. Stage and commit your change.

Modify the print statement again in my-awesome-script.py to say Hello! World, hope you're doing well!. Stage and commit your change.

Modify the print one last time my-awesome-script.py to say Hello! World, we are one!. Stage and commit your change.

Now, squash the last three commits into a single one.

```bash
git checkout develop
git checkout -b feature/part-1-finale

# edit -> print("Hello! World, how is it going?")
git add my-awesome-script.py
git commit -m "Update greeting - v1"

# edit -> print("Hello! World, hope you're doing well!")
git add my-awesome-script.py
git commit -m "Update greeting - v2"

# edit -> print("Hello! World, we are one!")
git add my-awesome-script.py
git commit -m "Update greeting - v3"

git rebase -i HEAD~3
# change 'pick' to 'squash' for the 2nd and 3rd commits, keep 'pick' for the first
# save, then write the combined commit message in the editor that opens next
```
