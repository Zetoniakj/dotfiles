#!/bin/bash

# Paths to package files
REPOS_FILE="$HOME/dotfiles/packages/repositories.txt"
PACKAGES_FILE="$HOME/dotfiles/packages/packages.txt"

# Check if the file exists
if [[ ! -f "$REPOS_FILE" ]]; then
    echo "❌ Package list file not found!"
    exit 1
fi
if [[ ! -f "$PACKAGES_FILE" ]]; then
    echo "❌ Package list file not found!"
    exit 1
fi

# Read packages into an array
mapfile -t PACKAGES < <(grep -E "^[^#]+" $PACKAGES_FILE)

# Detect OS and package manager
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    if command -v apt &> /dev/null; then
        PKG_MANAGER="apt"
        UPDATE_CMD="sudo apt update -y"
        INSTALL_CMD="sudo apt install -y"
        CHECK_CMD="dpkg -l"
    elif command -v dnf &> /dev/null; then
        PKG_MANAGER="dnf"
        UPDATE_CMD="sudo dnf update -y"
        INSTALL_CMD="sudo dnf install -y"
        CHECK_CMD="rpm -q"
    elif command -v yum &> /dev/null; then
        PKG_MANAGER="yum"
        UPDATE_CMD="sudo yum update -y"
        INSTALL_CMD="sudo yum install -y"
        CHECK_CMD="rpm -q"
    elif command -v pacman &> /dev/null; then
        PKG_MANAGER="pacman"
        UPDATE_CMD="sudo pacman -Sy"
        INSTALL_CMD="sudo pacman -S --noconfirm"
        CHECK_CMD="pacman -Q"
    else
        echo "❌ No compatible package manager found."
        exit 1
    fi
elif [[ "$OSTYPE" == "darwin"* ]]; then
    if ! command -v brew &> /dev/null; then
        echo "🍏 Homebrew is not installed. Installing it now..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
    PKG_MANAGER="brew"
    UPDATE_CMD="brew update"
    INSTALL_CMD="brew install"
    CHECK_CMD="brew list"
else
    echo "❌ Unsupported operating system."
    exit 1
fi

echo "🔄 Updating package manager: $PKG_MANAGER"
$UPDATE_CMD

# Install necessary repositories before packages
if [[ -f "$REPOS_FILE" ]]; then
    echo "📂 Checking necessary repositories..."
    
    while IFS=':' read -r manager repo; do
        [[ "$manager" =~ ^#.*$ || -z "$manager" ]] && continue  # Ignore comments and empty lines
        
        if [[ "$manager" == "$PKG_MANAGER" ]]; then
            # echo "🔹 Processing repository: $repo"

            if eval "$CHECK_CMD $repo" &> /dev/null; then
                echo "✅ Repository already installed: $repo"
            else
                echo "📦 Installing repository: $repo"

                case "$PKG_MANAGER" in
                    apt)
                        sudo add-apt-repository -y "$repo"
                        ;;
                    yum|dnf)
                        $INSTALL_CMD "$repo"
                        ;;
                    *)
                        echo "ℹ️ Manual intervention needed for repository: $repo"
                        ;;
                esac
                $UPDATE_CMD
            fi
        fi
    done < "$REPOS_FILE"
fi

# Categorize installed and missing packages
INSTALLED=()
TO_INSTALL=()

for pkg in "${PACKAGES[@]}"; do
    if [[ "$pkg" == *":"* ]]; then
        PKG_PREFIX="${pkg%%:*}"
        PKG_NAME="${pkg#*:}"

        if [[ "$PKG_PREFIX" == "$PKG_MANAGER" ]]; then
            TARGET_PKG="$PKG_NAME"
        else
            continue
        fi
    else
        TARGET_PKG="$pkg"  # Universal package (no prefix)
    fi

    if command -v "$TARGET_PKG" &> /dev/null; then
        INSTALLED+=("$TARGET_PKG")
    elif $CHECK_CMD "$TARGET_PKG" &> /dev/null; then
        INSTALLED+=("$TARGET_PKG")
    else
        TO_INSTALL+=("$TARGET_PKG")
    fi
done

## for pkg in "${PACKAGES[@]}"; do
##     if command -v "$pkg" &> /dev/null; then
##         INSTALLED+=("$pkg")
##     elif $CHECK_CMD "$pkg" &> /dev/null; then
##         INSTALLED+=("$pkg")
##     else
##         TO_INSTALL+=("$pkg")
##     fi
## done

# Print the categorized packages
echo "✅ Already installed packages:"
printf "   - %s\n" "${INSTALLED[@]}"

# Install missing packages only if there are any
TO_INSTALL_LIST="${TO_INSTALL[*]}"
if [[ -n "$TO_INSTALL_LIST" ]]; then
    echo "📦 Packages to install:"
    printf "   - %s\n" "${TO_INSTALL[@]}"
    echo "📦 Installing: $TO_INSTALL_LIST..."
    $INSTALL_CMD $TO_INSTALL_LIST
else
    echo "✅ All packages are already installed."
fi
