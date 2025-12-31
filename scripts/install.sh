#!/usr/bin/env bash
set -e

echo "🐭 Installing dotfiles for soso..."

DOTFILES="$HOME/dotfiles"

# tmux
if [ -f "$DOTFILES/tmux/tmux.conf" ]; then
  echo "→ tmux detected"
  ln -sf "$DOTFILES/tmux/tmux.conf" "$HOME/.tmux.conf"
fi

# bash
if [ -f "$HOME/.bashrc" ]; then
  echo "→ bash detected"
  ln -sf "$DOTFILES/bash/bashrc" "$HOME/.bashrc"
fi

# zsh
if [ -f "$HOME/.zshrc" ] || [ "$SHELL" = "/bin/zsh" ]; then
  echo "→ zsh detected"
  ln -sf "$DOTFILES/zsh/zshrc" "$HOME/.zshrc"
fi

# cheats
if [ -f "$DOTFILES/cheats/my_cheats" ]; then
  echo "→ cheats detected"
  ln -sf "$DOTFILES/cheats/my_cheats" "$HOME/.my_cheats"
fi

echo "✨ Done! Restart your terminal."
