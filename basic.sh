#/usr/bin/env bash
complete -W "now tomorrow never" echo

# complete -A directory echo

# _dothis_completions()
# {
#   COMPREPLY+=("now")
#   COMPREPLY+=("tomorrow")
#   COMPREPLY+=("never")
# }
# complete -F _dothis_completions echo

# _dothis_completions()
# {
#   COMPREPLY=($(compgen -W "now tomorrow never" "${COMP_WORDS[1]}"))
#   echo
#   cowsay ${COMP_WORDS[@]}
# }
# complete -F _dothis_completions echo