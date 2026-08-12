from pathlib import Path
import argparse


def print_tree(directory, level=0):
    directory = Path(directory)

    print(" " * level + directory.name)

    for item in directory.iterdir():

        if item.is_dir():
            print_tree(item, level + 1)

        else:
            print(" " * (level + 1) + item.name)


if __name__ == "__main__":

    parser = argparse.ArgumentParser(
        description="Print the directory tree"
    )

    parser.add_argument(
        "directory",
        help="Directory to display"
    )

    args = parser.parse_args()

    directory = Path(args.directory)

    if directory.is_dir():
        print_tree(directory)
    else:
        print("invalid directory")