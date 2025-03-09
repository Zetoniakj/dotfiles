#!/bin/bash

# Base directory of the dotfiles repository
DOTFILES="$HOME/dotfiles"

# Function to create symlinks with backups (keeps only the latest N backups)
create_symlink() {
    local src="$1"
    local dest="$2"
    local max_backups=2  # Number of backups to keep

    # Create the parent directory if it doesn't exist
    mkdir -p "$(dirname "$dest")"

    # If the file already exists or is a symlink, create a backup
    if [ -e "$dest" ] || [ -L "$dest" ]; then
        backup="$dest.backup-$(date +%Y%m%d%H%M%S)"
        mv "$dest" "$backup"
        echo "⚠️  Backup created: $backup"

        # Get a list of existing backups sorted by date (newest first)
        backups=($(ls -t "$dest.backup-"* 2>/dev/null))

        # Check if there are more than max_backups
        if [ "${#backups[@]}" -gt "$max_backups" ]; then
            # Determine which backups to delete (all but the latest max_backups)
            to_delete=("${backups[@]:$max_backups}")
            to_keep=("${backups[@]:0:$max_backups}")

            # Delete old backups
            echo "🗑️  Deleting old backups:"
            for old_backup in "${to_delete[@]}"; do
                echo "   ❌ $old_backup"
                rm -f "$old_backup"
            done

            # Display backups that are kept
            echo "✅ Keeping latest $max_backups backups:"
            for kept_backup in "${to_keep[@]}"; do
                echo "   📌 $kept_backup"
            done
        fi
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
create_symlink "$DOTFILES/custombin" "$HOME/.custombin"

echo "🎉 All symlinks created!"
