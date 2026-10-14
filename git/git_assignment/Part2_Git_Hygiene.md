#  Git Assignment — Part II: Git Hygiene


---

### 1. Writing a Good README — Practice

Suppose there is a repository called 'country-capital-api' that houses the code for an API written in Python and Flask that returns the name of the country if a capital city is provided. The ASGI server Uvicorn is used to serve this API. Also, there is a microservice endpoint for this API available at https://example.com/country-capital/<query-params> that can be used by any project in the organization to consume this API.

Write a README for this repository.

```markdown
# country-capital-api

A lightweight Python API built with Flask that returns the name of a country
given the name of its capital city. The API is served using the Uvicorn ASGI
server and is also exposed organization-wide as a microservice endpoint at:

    https://example.com/country-capital/<query-params>

Any internal project can consume this endpoint directly without needing to
deploy or maintain its own copy of the service.

## Prerequisites

- Python 3.9+
- pip
- Flask
- Uvicorn

## Setting up a local development environment

1. Clone the repository:
   git clone https://github.com/datagrokr/country-capital-api.git
   cd country-capital-api

2. Create and activate a virtual environment:
   python -m venv venv
   source venv/bin/activate

3. Install dependencies:
   pip install -r requirements.txt

4. Run the application locally with Uvicorn:
   uvicorn app:app --reload
```

```bash
touch README.md
# paste the content above into README.md
git add README.md
git commit -m "docs: add project README"
```

---

### 2. Using .gitignore to Keep the Repository Clean — Practice

Consult the .gitignore example repository linked above, and write a .gitignore file for a repository to ignore the following repository artifacts:

- All files inside the build directory at the root of the repository
- All files ending with *.env
- All files in the subdirectory test-runs/logs
- All CSV files anywhere in the repository

```gitignore
/build/
*.env
test-runs/logs/
*.csv
```

```bash
cat << 'EOF' > .gitignore
/build/
*.env
test-runs/logs/
*.csv
EOF

git add .gitignore
git commit -m "chore: add .gitignore for build artifacts, env files, logs and csv files"
```

---

### 3. Raising Clean Pull Requests — Practice

Suppose that the repository you are currently working on contains code for a front-end application that allows customers to get notified via email about updates made to product listings. A certain percentage of customers now want the ability to specify there WhatsApp number as a means of getting notified as well in addition to email notifications. You have been assigned a story with ticket ID FEAPP-420.

FEAPP-420 reads like this:

Title: Allow customer notification via WhatsApp

Description:
Customers have been requesting the ability to get notified about product updates via their WhatsApp number. This mode of notification is optional, but if specified, should cause notifications to go out both on their emails as well as WhatsApp numbers.

Suppose that you created a branch off of the main development branch, and are now raising a PR to the main development branch. Write a PR description for this.

```bash
git checkout develop
git pull origin develop
git checkout -b feat/FEAPP-420-whatsapp-notifications

# ... make code changes ...

git add .
git commit -m "feat/FEAPP-420: add WhatsApp number as an optional notification channel"
git push origin feat/FEAPP-420-whatsapp-notifications
```

```markdown
PR Title: feat/FEAPP-420: Allow customer notification via WhatsApp

PR Description:

WHAT:
This PR adds support for an optional WhatsApp number field on the customer
notification settings. When a customer provides a WhatsApp number, product
listing update notifications are sent to both their email and their WhatsApp
number. If no WhatsApp number is provided, notifications continue to go out
via email only, preserving existing behavior.

WHY:
Customers have requested an additional, more immediate channel for receiving
product update notifications. Adding WhatsApp as an optional channel improves
engagement without disrupting the existing email-based flow.

Notes:
This change is backward compatible — existing customers without a WhatsApp
number configured are unaffected.

PR Reviewers:
Add your teammates, including the lead.
```

---

### 4. Review and Approval Best Practices

These are some of the things to expect as review comments from your teammates when they are reviewing your PRs:

- Coding style: make sure the indentation, casing and naming conventions are consistent with what the team agreed to keep.
- Grammar: It is easy to misspell or use incorrect sentences in comments in the code from time to time. If people are pointing this out, it's not a personal insult but just to ensure consistency.
- Programming best practices: This is a very very broad term, but your team might have certain standards and best practices when implementing things. If your implementation does not meet their standards, they might comment on your "design" and "approach". Again, this is not personal, but to ensure quality of the codebase.
- Nitpicking: Sometimes small, obscure things in the code can be called out. Since these are nitpicks, and depending upon the rapport with your team, you can choose to politely disagree.
- Wait time for getting approvals: Your teammates, just like you, have to complete things on their own plate, in addition to reviewing your code, so keep in mind that the feeling that they are making you wait is not to be personally taken. There is a lot of human factor into this, so patiently wait, and occasionally nudge them politely if the changes are time critical.

Just as the above points are true for people reviewing your code, it is true for you reviewing their code as well. Always try to be specific with your comments. Some guidelines:

- Don't be vague. For example, "this block looks messy, can you clean it up?" offers no insight to the developer who raised the PR and they might simply ignore you.
- Agreeing to Disagree: Sometimes you might have a wonderful alternative to what has been implemented in a PR. In that case, bring it to the attention of the person, and if the alternative you propose is indeed better, have a chat with them to discuss it through. If their implementation in no way compromises the quality and performance of the code base, and they don't agree to go ahead with your approach, let them be.
- Use of proper tone: Use "please", "could you", "would you", etc. and be as polite as possible. For example, "Can you please reconsider splitting this function into two?" over "Split this function into two."
- Being nitpicky: Just like you don't like a nitpicky reviewer, don't be one to your team either!

*No git commands required for this section — these are collaboration guidelines to follow while raising and reviewing pull requests on your hosting provider (e.g., GitHub).*
