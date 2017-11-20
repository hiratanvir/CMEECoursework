import subprocess
import os

home = subprocess.os.path.expanduser("~")


FilesDirsStartingWithC = []

for dirpath, subdir, filenames in os.walk(home):
    root, ext = os.pathwalk(dir)
    for d in dirpath:
        if d.startswith("c"):
            FilesDirsStartingWithC.append(os.path.join(d))
        if d.startswith("C"):
            FilesDirsStartingWithC.append(os.path.join(d))
            print FilesDirsStartingWithC



for filename in os.listdir(home):
    root, ext = os.listdir(home)
    if root.startswith('C'):
        print filename



import os
files = os.listdir('home')
for file in files:
    if d.startswith("c"):
        FilesDirsStartingWithC.append(os.path.join(file))
    if d.startswith("C"):
        FilesDirsStartingWithC.append(os.path.join(file))
    print(file)
