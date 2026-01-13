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

# [??] Interactive Search (Powered by Navi)
alias "??"="navi"

# [qs] Quick Search (Navi query)
qs() {
    navi --query "$*"
}

# [qe] Quick Edit (Edit your custom cheats)
alias qe="vim ~/dotfiles/cheats/my_cheats.cheat"

# --- Suffix Aliases (Zsh Only) ---
if [[ -n "$ZSH_VERSION" ]]; then
    alias -s {py,js,sh,txt}='vim'  
    alias -s {png,jpg,pdf}='xdg-open' 
fi