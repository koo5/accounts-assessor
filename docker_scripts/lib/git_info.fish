#!/usr/bin/env fish

set DIR (dirname (readlink -m (status --current-filename)))
cd "$DIR"/../../


pwd > sources/static/git_info.txt
git status -vv >> sources/static/git_info.txt
git submodule foreach --recursive git status -vv >> sources/static/git_info.txt
echo -e "\n\n" >> sources/static/git_info.txt

pwd >> sources/static/git_info.txt
git log --graph --decorate  --abbrev-commit >> sources/static/git_info.txt
git submodule foreach --recursive git log --graph --decorate  --abbrev-commit >> sources/static/git_info.txt
