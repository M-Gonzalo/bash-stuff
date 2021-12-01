# This script finds any subfolder named "homework" that have a file named "package.json" in them and install the dependencies
# Usage: ./installDependencies.sh <dir>

########################
# Utilities:
# Print a message in either blue or green depending on a parameter passed to the script.
pretty_print() {
    if [ $1 == "blue" ]; then
        echo -e "\e[34m$2\e[0m"
    fi
    if [ $1 == "green" ]; then
        echo -e "\e[32m$2\e[0m"
    fi
}
# Print a progress message
progress_message() {
    pretty_print green "Installing dependencies for $1 ($2 of $3)"
}

########################
# Check wether the user has supplied a directory, and use it as the base directory
if [ $# -eq 0 ]; then
    pretty_print blue "No directory supplied, using current directory\n"
    baseDir="."
else
    baseDir=$1
fi

########################
# For statistics:
count=0 # Count the number of directories that have been processed
# Count all the directories named homework that have a package.json file in them
total_count=$(find $baseDir \
				   ! -iwholename '*node_modules*' \
                   -type d -name "homework" \
                   -exec ls -1 {} \; \
                   | grep "package.json" | wc -l \
             )

########################
# Find all the directories that have a package.json file in them
homework_dirs() {
    find $baseDir ! -iwholename '*node_modules*' -name homework -type d | sort
}
# The actual script:
for folder in $(homework_dirs)                                 # Find all folders named "homework"
    do
        if [ -f "$folder/package.json" ]; then                 # If the folder has a package.json file,
            ((count = count + 1))                              # Increment the counter
            pushd $folder >/dev/null                           # change to the folder,
            progress_message $folder $count $total_count       # print the progress message,
            npm install >>dependencies.log 2>>dependencies.err # install the dependencies, and
            popd >/dev/null                                    # change back to the parent folder.
        fi                                                     # End if
    done                                                       # End for
