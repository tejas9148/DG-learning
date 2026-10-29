from flask import Flask, render_template, request, jsonify
import os
import subprocess

app = Flask(__name__)


@app.route("/")
def home():
    return render_template("index.html")


@app.route("/save", methods=["POST"])
def save_file():

    data = request.json

    file_path = data["file_path"]
    content = data["content"]

    # Create folder if it does not exist
    folder = os.path.dirname(file_path)

    if folder:
        os.makedirs(folder, exist_ok=True)

    # Save the file
    with open(file_path, "w", encoding="utf-8") as file:
        file.write(content)

    # Get the folder where the file is saved
    if folder:
        git_folder = folder
    else:
        git_folder = os.getcwd()

    # Initialize git if it is not already a git repository
    if not os.path.exists(os.path.join(git_folder, ".git")):
        subprocess.run(["git", "init"], cwd=git_folder)

    # Add the file
    subprocess.run(
        ["git", "add", os.path.basename(file_path)],
        cwd=git_folder
    )

    # Commit the change
    subprocess.run(
        ["git", "commit", "-m", "Updated note"],
        cwd=git_folder
    )

    return jsonify({"message": "File saved and committed"})


if __name__ == "__main__":
    app.run(debug=True)