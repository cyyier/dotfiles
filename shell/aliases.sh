# --- Standard Aliases ---

# safer defaults
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# ls family
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# git shortcuts
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gco='git checkout'
alias gl='git log --oneline --graph --decorate'
alias gb='git branch'

# navigation
alias ..='cd ..'
alias ...='cd ../..'

# misc
alias cls='clear'

# other
alias mkdir='mkdir -p'
alias h='history'
alias j='jobs'

# --- Search Utils ---

# [??] Interactive Search (The soul search)
alias "??"="cat ~/.my_cheats | fzf --height 40% --layout=reverse --border --prompt='🤔 How to: '"

# [qs] Quick Search
qs() {
    grep -i "@$1" ~/.my_cheats
}

# [note] Quick Record (No quotes needed)
note() {
    echo "# @$*" >> ~/.my_cheats
    echo "✅ Knowledge captured: $*"
}

# [qe] Quick Edit
alias qe="vim ~/.my_cheats"

# --- Suffix Aliases (Zsh Only) ---
if [[ -n "$ZSH_VERSION" ]]; then
    alias -s {py,js,sh,txt}='vim'  
    alias -s {png,jpg,pdf}='xdg-open' 
fi