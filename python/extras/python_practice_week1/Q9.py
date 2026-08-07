import os
import sys
def print_tree(directory , level=0):
    print(" "*level+os.path.basename(directory))
    for item in os.listdir(directory):
        full_path = os.path.join(directory,item)
        if os.path.isdir(full_path):
            print_tree(full_path , level+1)
        else:
            print(" "*(level+1)+item)

if __name__=="__main__":
    if len(sys.argv)!=2:
        print("use python name.py <directory")
    else:
        directory = sys.argv[1]

        if os.path.isdir(directory):
            print_tree(directory)
        else:
            print("invalid directory")