# Find the subfolders named "homework" that have a file named "package.json" in them and test the exercises
# Usage: ./testEverything.sh


for folder in $(find . -name "homework" -type d); do              # Find all folders named "homework"
    if [ -f "$folder/package.json" ]; then                        # If the folder has a package.json file,
        pushd $folder >/dev/null                                  # change to the folder,
        echo -e "\e[34m\nTesting the exercises from $folder\e[0m" # print the folder name to show progress,
        npm test                                                  # test the homework, and
        popd >/dev/null                                           # change back to the parent folder.
    fi                                                            # End if
done                                                              # End for
