#!/bin/bash

# Base directory of the dotfiles repository
DOTFILES="$HOME/dotfiles"

# Function to create symlinks with backups
create_symlink() {
    local src="$1"
    local dest="$2"

    # Create the parent directory if it doesn't exist
    mkdir -p "$(dirname "$dest")"

    # If the file already exists or is a symlink, create a backup
    if [ -e "$dest" ] || [ -L "$dest" ]; then
        backup="$dest.backup-$(date +%Y%m%d%H%M%S)"
        echo "⚠️  Backup created: $backup"
        mv "$dest" "$backup"
    fi

    # Create the symlink
    ln -s "$src" "$dest"
    echo "✅ Linked $src → $dest"
}

echo "🔗 Creating symlinks..."

# Link every file in config/ (except shell)
for file in "$DOTFILES/config/"*; do
    [ -d "$file" ] && continue  # Skip directories
    create_symlink "$file" "$HOME/.$(basename "$file")"
done

# Link every file in config/shell/
for file in "$DOTFILES/config/shell/"*; do
    [ -d "$file" ] && continue  # Skip directories
    create_symlink "$file" "$HOME/.config/shell/$(basename "$file")"
done

# Ensure bin directory is linked
create_symlink "$DOTFILES/config/bin" "$HOME/.config/bin"

echo "🎉 All symlinks created!"
