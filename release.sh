#!/bin/bash

#######################################################
#
# Change Version here.
#
LVersionMajor=1
LVersionMinor=0
# Autoinc with x
LVersionRevision=x
#
#######################################################


# Create needed Vars
LWorkDir=$(dirname -- "$(readlink -f -- "${BASH_SOURCE[@]}")")
LScriptFile=$(readlink -f -- "${BASH_SOURCE[@]}")
#LSciptFilename=$(basename -- "$(readlink -f -- "${BASH_SOURCE[@]}")")

LDate="$(date "+%Y-%m-%d %T")"
LDevBranch=master
LReleaseBranch=build

# Move to folder
cd "${LWorkDir}" || exit

# file in which to update version number
LVersionFile="${LWorkDir}/version.txt"

# Create version text file
if [ ! -f "${LVersionFile}" ]; then
    # File does not exists
    echo "1.0.0" > "${LVersionFile}"

    if [[ ${LVersionRevision} == "x" ]]; then
        LVersionRevision=0
    fi
fi

# Read and Autoinc if needed
if [[ ${LVersionRevision} == "x" ]]; then
    # Do Auto inc
    LVersionOld=$(<"${LVersionFile}")
    # LVersionMajor=$(echo "${LVersionOld}" | cut -d. -f1)
    # LVersionMinor=$(echo "${LVersionOld}" | cut -d. -f2)
    LVersionRevision=$(echo "${LVersionOld}" | cut -d. -f3)
    LNewVersionRevision=$(("${LVersionRevision}" + 1))
else
    # No Auto Inc
    LNewVersionRevision="${LVersionRevision}"
fi

# Build new version
LVersionLabel="${LVersionMajor}.${LVersionMinor}.${LNewVersionRevision}"

# Write new Version to file
echo "${LVersionLabel}" > "${LVersionFile}"

# Build commit text
LCommitText="New Release ${LVersionLabel} Date ${LDate}"

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
