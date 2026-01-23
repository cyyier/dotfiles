# Dotfiles

My personal configuration files and setup scripts, designed for flexibility across **Personal** (WSL2/Linux) and **Company** (Restricted) environments.

## 🚀 Installation

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/cyyier/dotfiles.git ~/dotfiles
    cd ~/dotfiles
    ```

2.  **Run the installer:**
    ```bash
    ./install.sh
    ```

3.  **Select Environment Mode:**
    The script will prompt you to choose a mode:
    *   **🏢 Company Environment**: Restricted mode. Only symlinks configurations (dotfiles). Skips binary downloads and installations to comply with corporate policies.
    *   **🏠 Personal/WSL2**: Full setup. Automatically installs Zsh, Neovim, Starship, and productivity tools.

## 🛠️ Tools & Ecosystem

### Core Components
*   **Shell**: Zsh (managed via Oh My Zsh).
*   **Prompt**: [Starship](https://starship.rs/) - Fast, customizable, cross-shell prompt.
*   **Editor**: [Neovim](https://neovim.io/) (bootstrapped with [LazyVim](https://www.lazyvim.org/)).
*   **Terminal Multiplexer**: Tmux.

### Productivity Suite ("The Holy Trinity")
These are installed via `scripts/30-productivity.sh`:
*   **FZF**: General-purpose command-line fuzzy finder.
*   **Zoxide**: A smarter `cd` command that remembers which directories you use most frequently.
*   **Ripgrep (rg)**: Line-oriented search tool that recursively searches the current directory (faster than grep).
*   **FD**: A simple, fast, and user-friendly alternative to `find`.
*   **Navi**: An interactive cheatsheet tool for the command-line.

### Neovim Plugins (LazyVim)
Managed via `lazy.nvim`. Key plugins include:
*   **LSP Support**: TypeScript, Python, JSON.
*   **Formatting**: Prettier.
*   **UI**: TokyoNight / Gruvbox themes, Lualine, Telescope.
*   **Treesitter**: Advanced syntax highlighting.

## ⌨️ Key Aliases & Workflows

Custom workflows defined in `shell/aliases.sh`:

### Knowledge Management
| Command | Description |
| :--- | :--- |
| `??` | **Interactive Search**: Launches `navi` to browse and execute cheats. |
| `qs <query>` | **Quick Search**: Queries `navi` directly with the provided text. |
| `qe` | **Quick Edit**: Opens your custom cheatsheet (`.cheat`) in Vim. |

### Navigation & Git
| Alias | Command | Description |
| :--- | :--- | :--- |
| `..` | `cd ..` | Go up one level. |
| `...` | `cd ../..` | Go up two levels. |
| `gs` | `git status` | Check git status. |
| `gl` | `git log ...` | View pretty git log graph. |
| `gco` | `git checkout` | Checkout branch. |

## 📂 Project Structure

The setup is modular to keep things clean:

```text
~/dotfiles/
├── install.sh              # Main entry point (The Commander)
├── scripts/                # Modular logic
│   ├── lib_utils.sh        # Shared colors & helpers
│   ├── env_setup.sh        # Identity & mode selection
│   ├── link_configs.sh     # Symlink logic
│   ├── install_binaries.sh # Core app downloads (Personal mode)
│   └── 30-productivity.sh  # FZF, Zoxide, Ripgrep setup
├── nvim/                   # Neovim configuration
├── zsh/                    # Zsh configuration
├── starship/               # Starship prompt config
└── shell/                  # Aliases and shell functions
```

## 📝 Post-Install

If you are in **Personal Mode** and just installed Zsh for the first time:
1.  Change your default shell:
    ```bash
    chsh -s $(which zsh)
    ```
2.  Log out and log back in (or restart your terminal) to see the changes.
