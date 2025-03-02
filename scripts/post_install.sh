#!/bin/bash

echo "🔧 Running post-install setup..."

# Ensure Git is configured
# Ensure Git is installed
if  command -v git &>/dev/null; then
    echo "❌ Git is not installed. Please add it to dotfiles/packages/packages.txt and retry ./install.sh:"
fi

# Change shell to Zsh if it's not already the default
if [[ "$SHELL" != "$(command -v zsh)" ]]; then
    echo "⚡ Changing default shell to Zsh..."
    chsh -s "$(command -v zsh)"
fi

# Ensure bin scripts are executable
if [ -d "$HOME/.config/bin" ]; then
    chmod +x "$HOME/.config/bin/"*
fi

# Reload shell configuration
if [[ "$SHELL" == *"zsh" ]]; then
    source "$HOME/.zshrc"
else
    source "$HOME/.bashrc"
fi

echo "✅ Post-install setup complete!"
