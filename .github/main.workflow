workflow "Publish to GitHub Pages" {
  on = "push"
  resolves = ["gh-pages-deploy"]
}

action "master branch only" {
  uses = "actions/bin/filter@master"
  args = "branch master"
}

action "gh-pages-deploy" {
  uses = "go-gilbert/go-gilbert.github.io@action"
  env = {
    BRANCH = "gh-pages"
    BUILD_SCRIPT = "hugo -d ./dist"
    FOLDER = "dist"
  }
  needs = ["master branch only"]
  secrets = ["GITHUB_TOKEN"]
}
