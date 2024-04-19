#!/usr/bin/env fish


function install_packages_if_missing
    # Split the input string into an array of packages
    set -l packages $argv

    for package in $packages
        # Check if the package is not installed
        if not type -q $package
            echo $package
            switch $package
                case omf
                    echo "Installing $package..."
                    mkdir -p .config/omf
                    curl -L https://get.oh-my.fish | fish
                    omf init
                case fisher
                    echo "Installing $package..."
                    mkdir -p .config/fisher
                    curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher
                    fisher init
                case starship
                    echo "Installing $package..."
                    mkdir -p .config/starship
                    curl -sS https://starship.rs/install.sh | sh
                case eza
                    echo "Installing $package..."
                    yay -S eza

                case '*'
                    echo "No installation instructions for $package"
            end
        else
            echo "$package is already installed."
        end
    end
end

# Set the applications to install
set apps omf fisher eza-git starship

# Call the function with the list of apps
install_packages_if_missing $apps
