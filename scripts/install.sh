#!/usr/bin/env bash
set -e

echo "🐭 Installing dotfiles for soso..."

DOTFILES="$HOME/dotfiles"

# bash
if [ -f "$HOME/.bashrc" ]; then
  echo "→ bash detected"
  ln -sf "$DOTFILES/bash/bashrc" "$HOME/.bashrc"
fi

# zsh (macOS default)
if [ -f "$HOME/.zshrc" ] || [ "$SHELL" = "/bin/zsh" ]; then
  echo "→ zsh detected"
  ln -sf "$DOTFILES/zsh/zshrc" "$HOME/.zshrc"
fi

echo "✨ Done! Restart your terminal."
