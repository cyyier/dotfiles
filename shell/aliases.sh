# --- Standard Aliases  ---
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'
alias cls='clear'
alias mkdir='mkdir -p'
alias h='history'
alias j='jobs'

# --- Git Shortcuts  ---
alias gs='git status'
alias ga='git add .'
alias gc='git commit -m'
alias gco='git checkout'
alias gl='git log --oneline --graph --decorate'
alias gb='git branch'

# --- Modern Tooling Integration  ---

# 1. Zoxide 
eval "$(zoxide init zsh)"
alias j='z'            # 将你的 j 别名赋予更强大的 zoxide
alias ji='zi'          # 交互式跳转

# 2. Search Utils 
alias "??"="navi"
qs() {
    navi --query "$*"
}

alias qe="vim ~/dotfiles/cheats/my_cheats.cheat"

# 3. FZF + fd/rg (极速预览与打开)
# 快速用 vim 打开文件 (Fast Edit)
fe() {
  local file=$(fd -t f . | fzf --preview 'bat --color=always --line-range :50 {}')
  [ -n "$file" ] && vim "$file"
}

# 4. Suffix Aliases (Zsh 专属：直接输入文件名即可操作)
if [[ -n "$ZSH_VERSION" ]]; then
    # 输入 script.py 直接用 vim 打开
    alias -s {py,js,sh,txt,sql,php}='vim'  
    # 输入 image.png 直接打开预览
    alias -s {png,jpg,pdf}='open' # macOS 用 open, Linux 用 xdg-open
fi

# --- 2>/dev/null 技巧 ---
# 有时搜索权限不足会刷屏，可以定义一个静默搜索别名
alias rgs='rg 2>/dev/null'