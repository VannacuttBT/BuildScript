#!/bin/bash

#######################################################
#
# Change Version here
#
LVersionMajor=1
LVersionMinor=0
LVersionPatch=11
#
#######################################################


# Create needed Vars
LWorkDir=$(dirname -- "$(readlink -f -- "${BASH_SOURCE[@]}")")
LScriptFile=$(readlink -f -- "${BASH_SOURCE[@]}")
#LSciptFilename=$(basename -- "$(readlink -f -- "${BASH_SOURCE[@]}")")

LDate="$(date "+%Y-%m-%d %T")"
LVersionLabel="${LVersionMajor}.${LVersionMinor}.${LVersionPatch}"
LCommitText="New Release ${LVersionLabel} Date ${LDate}"
LDevBranch=master
LReleaseBranch=build

# Move to folder
cd "${LWorkDir}" || exit

# file in which to update version number
LVersionFile="${LWorkDir}/version.txt"

# find version number assignment ("= v1.5.5" for example)
# and replace it with newly specified version number
if [ ! -f "${LVersionFile}" ]; then
    echo "${LVersionLabel}" > "${LVersionFile}"
fi
sed -i.backup -E "s/\= [0-9.]+/\= ${LVersionLabel}/" "${LVersionFile}" "${LVersionFile}"

# remove backup file created by sed command
rm "${LVersionFile}.backup"

# Check if branch exists
if [ -z "$(git branch --list ${LReleaseBranch})" ]; then
    git checkout -b ${LReleaseBranch} ${LDevBranch}
fi

# commit version number increment
git add "${LScriptFile}"
git add "${LVersionFile}"
git commit -am "${LCommitText}"
git push origin "${LDevBranch}"

# Checkout and Merge build branch
git checkout "${LReleaseBranch}"
git merge --no-ff "${LDevBranch}"
git push origin "${LReleaseBranch}"

# create tag for new version
git tag -a "${LVersionLabel}" -m "${LCommitText}"
git push origin "${LVersionLabel}"

# Switch back to dev branch
git checkout "${LDevBranch}"
