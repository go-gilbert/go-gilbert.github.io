#!/bin/bash
COMMIT=$(git log --format=%H -n 1)
DIST="./dist"
REPO="git@github.com:go-gilbert/go-gilbert.github.io.git"
BRANCH="master"

echo "Cloning destination branch..."
git clone ${REPO} --branch ${BRANCH} --single-branch ${DIST}

echo "Clean..."
cd ${DIST}
ls -A | grep -v -E '^(.git|.nojekyll|README.md)$' | xargs rm -rf
cd ..

echo "Building docs..."
hugo -d ${DIST}

echo "Deploying docs..."
cd ${DIST}
git add .
git commit -m "Update docs (${COMMIT})"
git push -f origin ${BRANCH}

echo "Clean..."
cd ..
rm -rf ${DIST}
echo "DONE!"