#!/bin/bash
COMMIT=$(git log --format=%H -n 1)
DIST="./dist"
REPO="git@github.com:go-gilbert/go-gilbert.github.io.git"
BRANCH="gh-pages"

echo "Cloning destination branch..."
git clone ${REPO} --branch ${BRANCH} --single-branch ${DIST}

echo "Clean..."
cd ${DIST}
ls | grep -v .nojekyll | xargs rm -rf
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