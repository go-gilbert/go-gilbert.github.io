workflow "Publish to GitHub Pages" {
  on = "push"
  resolves = ["gh-pages-deploy"]
}

action "master branch only" {
  uses = "actions/bin/filter@master"
  args = "branch master"
}

action "gh-pages-deploy" {
  uses = "x1unix/github-pages-deploy-action@master"
  env = {
    BRANCH = "gh-pages"
    BUILD_SCRIPT = "npm install && npm run-script build:gh-pages"
    FOLDER = "dist/fallout77"
  }
  needs = ["master branch only"]
  secrets = ["GITHUB_TOKEN"]
}
