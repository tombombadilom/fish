#!/usr/bin/env fish.
# Set Ibus environment variables if you need them
set -gx GTK_IM_MODULE ibus
set -gx XMODIFIERS @im=dbus
set -gx QT_IM_MODULE ibus
set -gx QT_QPA_PLATFORMTHEME qt6ct
set -x XDG_RUNTIME_DIR /run/user/(id -u)
set -g theme_nerd_fonts yes
set -g theme display_user yes
set -g default_user tom

starship_transient_prompt_func
fish_add_path /opt/bin /usr/bin /usr/sbin /usr/local/bin /usr/local/sbin ~/.local/bin ~/.local/sbin

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
                    curl https://raw.githubusercontent.com/oh-my-fish/oh-my-fish/master/bin/install | fish
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
set apps omf fisher eza starship

# Call the function with the list of apps
install_packages_if_missing $apps


function get_weather
    # config weather -s temperature-units < celsius | fahrenheit | kelvin >
    # Vérifie si le plugin 'weather' est installé avec omf
    if ! omf list | grep -iq '\bweather\b'
        then
        echo "Le plugin weather n'est pas installé. Installation en cours..."
        # Installe le plugin 'weather' avec omf
        omf install weather
    end

    # config weather -s temperature-units celsius
    set -g __weather_system_dns 1
    # Charger les variables d'environnement
    source ~/.config/fish/.env

    # Obtenir la clé API OpenWeather
    set OPENWEATHER_API_KEY (echo $OPENWEATHER_API_KEY)
    # Faire la requête et obtenir le statut HTTP
    set response $(curl -s -o response.txt -w "%{http_code}" ipinfo.io)
    if test $response -eq 200
        # Si la requête a réussi, pars le contenu
        set loc (jq -r '.loc' response.txt | string split ",")
        set lat $loc[1]
        set lon $loc[2]
        set lang fr
        set appid $OPENWEATHER_API_KEY
        echo "https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$appid&lang=$lang"
        set weather_data (curl -s "https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$appid&lang=$lang")
        echo $weather_data
        set weather $weater_data | jq '.weather'
        echo $weather
        #export {$weather}
        #weather {$weather}
    else
        # Gestion des erreurs basée sur le code de statut ou le contenu du message d'erreur
        set error_message (jq -r '.error.message' response.txt)
        echo "Error: $error_message"
    end
    # Afficher la réponse de l'API météo
    echo $weather_data
end

# Function to check for new git repository
function check_directory_for_new_repository
    # Get the current git repository directory (if any)
    set current_repository (command git rev-parse --show-toplevel 2> /dev/null)

    # Check if there's a current repository and if it's different from the last one
    if test -n "$current_repository" -a "$current_repository" != "$last_repository"
        # Perform the onefetch action (assuming it's a function or command compatible with fish)
        onefetch
    end

    # Update the last_repository variable globally
    set -e last_repository # Unset the global variable if it exists
    set -U last_repository $current_repository # Then set the universal variable
end

# Function to change directory and check for new repository
function cd
    builtin cd $argv
    check_directory_for_new_repository
end

# function ls
#     eza --icons $argv
# end

# funcsave ls
function init-omf-plugins
    set -l omf_plugins agnoster default ocean technopagan ays edan pie bobthefish emoji-powerline sushi

    for plugin in $omf_plugins
        if not omf list | grep -q $plugin
            echo "Installing $plugin theme..."
            omf install $plugin
        end
    end
end

function init-fundle-plugins
    set -l fundle_plugins edc/bass joseluisq/gitnow danhper/fish-fastdir
    for plugin in $fundle_plugins
        if not fundle list | grep -q $plugin
            fundle plugin $plugin
        end
    end
end


function init-fisher-plugins
    # Définir un tableau avec les noms des plugins que vous souhaitez vérifier
    set -l wanted_plugins fabioantunes/fish-nvm edc/bass ilancosman/tide "jorgebucaran/nvm.fish"
    for plugin in $wanted_plugins
        if not fisher list | grep -q $plugin
            fisher install $plugin
            echo "$plugin installé"
        end
    end
end

function init-starship
    if not type -q starship
        curl -sS https://starship.rs/install.sh | sh
    end
end

function init_plugins
    init-omf-plugins
    init-fisher-plugins
    init-fundle-plugins
    init-starship
    # get_weather
end


# init plugins
init_plugins

# Optional greeting on startup (call this after sourcing the file)
check_directory_for_new_repository

# Set environment variables for Java and Android SDK
set -gx JAVA_HOME /home/tom/Android/Sdk
set -gx HISTCONTROL ignoreboth:erasedups
set -gx _JAVA_AWT_WM_NONREPARENTING 1
set -gx STUDIO_JDK /home/tom/Android/Sdk

# Set case-insensitive completion in Fish
set -U fish_complete_path $fish_complete_path /usr/share/fish/vendor_completions.d

# Check if .bashrc-personal exists and source it if it does.
# Note: Sourcing a Bash-specific file can still cause issues due to syntax differences
if test -f ~/.bashrc-personal
    source ~/.bashrc-personal
end

if status --is-interactive

    # Commands to run in interactive sessions can go here
    set fish_greeting "Welcome to fish shell!"
end

function fish_prompt
    set_color $fish_color_cwd
    echo -n (prompt_pwd)
    echo -n (git-radar --fish --fetch)
    set_color normal
    echo -n ' > '
end

if test -f ~/.cache/ags/user/generated/terminal/sequences.txt
    cat ~/.cache/ags/user/generated/terminal/sequences.txt
end

function parse_git_branch
    set -l branch_name (git branch --show-current 2>/dev/null)
    if test -n "$branch_name"
        echo " ($branch_name)"
    end
end

function fish_prompt
    set -l user_color cyan
    set -l host_color yellow
    set -l path_color green
    set -l git_branch (parse_git_branch)

    echo -n (set_color $user_color)(whoami)@(set_color $host_color)(hostname):(set_color $path_color)(prompt_pwd)(set_color normal)$git_branch '$ '
end

function starship_transient_prompt_func
    starship module character
end

starship init fish | source


enable_transience
