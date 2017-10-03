#!/bin/bash

# This script:
# 1. Creates a clean git repository for your new React app
# 2. Create a new remote repository on github.com
# 3. Push the local repo from the current directory to the new remote
# 4. Creates a new Heroku project, opens the deployment page

# Setup New Git from exisiting repo
git init
git remote rm origin
git checkout --orphan temp-branch
git branch -D master
git branch -m master
git gc --aggressive --prune=all
echo "COMPLETE: Fresh git repository created"

# Get current directory name
CURRENTDIR=${PWD##*/}

# Get user input for project name, username, description, and choice for a
# private repository
echo "Enter username for new GitHub repo"
read USERNAME
echo "Enter name for new repo, or just <return> to make it $CURRENTDIR"
read REPONAME
echo "Enter description for your new repo, on one line, then <return>"
read DESCRIPTION
echo "Enter <return> to make the new repo public, 'x' for private"
read PRIVATE_ANSWER

if [ "$PRIVATE_ANSWER" == "x" ]; then
  PRIVACYWORD=private
  PRIVATE_TF=true
else
  PRIVACYWORD=public
  PRIVATE_TF=false
fi

REPONAME=${REPONAME:-${CURRENTDIR}}
USERNAME=${USERNAME}

echo "Will create a new $PRIVACYWORD repo named $REPONAME"
echo "on github.com in user account $USERNAME, with this description:"
echo $DESCRIPTION
echo "Type 'y' to proceed, any other character to cancel."
read OK
if [ "$OK" != "y" ]; then
  echo "User cancelled"
  exit
fi

# Create GitHub repo using the REST API
curl -u $USERNAME https://api.github.com/user/repos -d "{\"name\": \"$REPONAME\", \"description\": \"${DESCRIPTION}\", \"private\": $PRIVATE_TF}"
echo "COMPLETE: New GitHub repository created"

# Replace README file with project specific README, update App Name
cp -f "$PWD/internals/README.md" "$PWD/README.md"
rm -rf "$PWD/internals/README.md"
sed -i "" -e "s/USERNAME/$USERNAME/g" "$PWD/README.md"
sed -i "" -e "s/APP_NAME/$REPONAME/g" "$PWD/README.md"
sed -i "" -e "s/APP_DESCRIPTION/$DESCRIPTION/g" "$PWD/README.md"

# Update Package.json with repo name and description
sed -i "" -e "s/APP_NAME/$REPONAME/g" "$PWD/package.json"
sed -i "" -e "s/APP_DESCRIPTION/$DESCRIPTION/g" "$PWD/package.json"

# Update HTML template with repo name and description
sed -i "" -e "s/APP_NAME/$REPONAME/g" "$PWD/src/index.html"
sed -i "" -e "s/APP_DESCRIPTION/$DESCRIPTION/g" "$PWD/src/index.html"

# Update App Root code with username
sed -i "" -e "s/USERNAME/$USERNAME/g" "$PWD/src/js/containers/App.jsx"

echo "COMPLETE: All files have been updated with the Application name, description, and username"

# Install Javascript modules required for both development and production
npm install
echo "COMPLETE: installed modules"

# Build & Bundle the Javascript and other assets into compresses static assets
npm run build
echo "COMPLETE: built and bundled code"

# Commit all changes
git add .
git commit -m "initial setup"

# Set the newly created remote repo to the origin and push
git remote add origin https://github.com/$USERNAME/$REPONAME.git
git push -u origin master
echo "COMPLETE: project committed and pushed to GitHub"

# Initialize the Heroku project
heroku apps:create $REPONAME --buildpack https://github.com/heroku/heroku-buildpack-nodejs.git --no-remote
echo "COMPLETE: heroku app created"

# Open newley created Heroku app, to the deployment page.
# User action required: Setup GitHub deployment hooks
echo "Opening heroku deployment page..."
open https://dashboard.heroku.com/apps/$1/deploy/github

# User Interaction Dialougue
echo "Have you setup the Heroku Github Deployment?"
echo "Type 'y' to proceed, any other character to cancel."
read OK
if [ "$OK" != "y" ]; then
  echo "User cancelled"
  exit
fi

# Open Heroku App default domain for newly created app.
# Expected: App should be deployed and running
echo "Opening deployed app"
open https://$REPONAME.herokuapp.com/

echo "'./internals/start.sh' has completed all setup functions."
echo "Please delete this file immediatley."
echo "It will break many things if you attempt to use it again."
