#!/bin/bash

# Ensure _deploy doesn't already exist
rm -rf _deploy

echo -e "\033[0;32mCloning the publish site...\033[0m"
git clone git@github.com:cchesser/cchesser.github.io.git _deploy

echo -e "\033[0;32mDeploying updates to GitHub...\033[0m"
hugo
cd _deploy

git add .

# Commit changes.
msg="Rebuilding site `date`"
if [ $# -eq 1 ]
  then msg="$1"
fi
git commit -m "$msg"  

echo -e "\033[0;32mDeploying updates to GitHub...\033[0m"
git push origin master

# Clean-up
cd ..
rm -rf _deploy