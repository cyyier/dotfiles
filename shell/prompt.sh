# git branch helper
git_branch() {
  git branch 2>/dev/null | sed -n '/\* /s///p'
}
