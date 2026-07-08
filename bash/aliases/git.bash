alias gt='git'
alias gti='git init'
alias gtb='git branch'
alias gtbc='git branch --show-current'
alias gtbd='git branch --delete'
alias gtbdf='git branch --delete --force'
alias gtsw='git switch'
alias gtswc='git switch -c'
alias gtst='git status'
alias gta='git add'
alias gtap='git add -p'
alias gtrt='git remote'
alias gtrta='git remote add'
alias gtph='git push'
alias gtphf='git push --force'
alias gtpl='git pull'
alias gtf='git fetch'
alias gtm='git merge'
alias gtrb='git rebase'
alias gtd='git diff'
alias gtds='git diff --staged'
alias gtl='git log'
alias gtsh='git show'
alias gtc='git commit'
alias gtca='git commit --amend'
alias gtsm='git submodule'
alias gtsmi='git submodule init'
alias gtsmdi='git submodule deinit'
alias gtsma='git submodule add'
alias gtsmu='git submodule update'
alias gtsmur='git submodule update --remote'

# delete all branch except "main/master" and current branch
git_b_delete_all() {
    git branch --delete $(\
        git branch --format '%(refname:lstrip=2)' \
        | rg -v -F -e 'main' -e 'master' -e $(git branch --show-current)\
    )
}
alias gtbda='git_b_delete_all'

git_push_current() {
    git push $(git branch --show-current)
}
alias gtphc='git_push_current'

git_push_current_upstream() {
    git push --set-upstream origin $(git branch --show-current)
}
alias gtphuc='git_push_current_upstream'

git_b_cur_rename() {
    git branch -m $(git branch --show-current) $1
}
alias gtbcr='git_b_cur_rename'
