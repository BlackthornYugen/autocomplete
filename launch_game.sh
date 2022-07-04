#!/usr/bin/env bash
set -e
STEAM_FOLDER_SEARCH_PATH=("${HOME}/.steam/steam/SteamApps" "${HOME}/Library/Application Support/Steam/steamapps")
for FOLDER in "${STEAM_FOLDER_SEARCH_PATH[@]}"; do
    if [ -d "$FOLDER" ] ; then 
        STEAM_FOLDER="$FOLDER"
        break
    fi
done

if [ ! -d "$STEAM_FOLDER" ]; then
    printf "Steam folder \"%s\" does not exist.\n" "${STEAM_FOLDER}"
    false
elif [ -z "$1" ]; then
    echo "Usage: $0 <game id or name>"
    echo "Usage: . $0 autocomplete"
    false
fi

launch_game() {
    if [ ! "${BASH_VERSINFO:-0}" -ge 4 ] ; then
        printf "bash %s is not supported\n" "${BASH_VERSINFO:-0}"
        false # fail script before syntax errors about associative arrays
    fi

    declare -A game_by_id
    declare -A id_by_game

    while read -r id game ; do
        declare "game_by_id[$id]=$game"
        declare "id_by_game[${game//\'/\\\'}]=$id"
    done < <(find "$STEAM_FOLDER" -maxdepth 1 -type f -name '*.acf' -exec awk -F '"' '/"appid|name/{ printf $4 " " } END { print "" }' {} \;)

    if [[ "$*" =~ ^[0-9]+$ ]]; then
        # Argument is a game id
        game_name=${game_by_id[$*]}
        game_id="$*"
    else
        # Argument is a game name
        game_name="$*"
        game_id="${id_by_game[$game_name]}"
    fi

    game_id="${id_by_game[$game_name]}"
    if [ "$game_id" != "" ]; then
        printf "Found \"%s\"! Launching game id %d...\n" "$game_name" "$game_id"
        /Applications/Steam.app/Contents/MacOS/steam_osx -applaunch "$game_id" > /dev/null
    else
        printf "\"%s\" does not appear to be installed.\n" "$*"
    fi
}

#https://stackoverflow.com/a/11536437/2535649
compute_complete() {
    # Filter our candidates
    while read -r id game ; do
        if [[ "$game" =~ ^"${COMP_WORDS[COMP_CWORD]}" ]]; then
            COMPREPLY+=("${game//\'/\\\'}")
        fi
    done < <(find "$STEAM_FOLDER" -maxdepth 1 -type f -name '*.acf' -exec awk -F '"' '/"appid|name/{ printf $4 " " } END { print "" }' {} \;)
}

if [[ "$*" =~ ^autocomplete$ ]] ; then
    if [ "$0" = "${BASH_SOURCE[*]}" ] ; then
        echo "Autocomplete script will not work correctly if you don't source this command."
    fi
    complete -F compute_complete -o nospace "$(basename "${BASH_SOURCE[0]:-./launch_game.sh}")"
else
    launch_game "$@"
fi