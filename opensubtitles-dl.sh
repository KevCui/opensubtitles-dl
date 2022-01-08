#!/usr/bin/env bash
#
# Download subtitles from opensubtitles.org
#
#/ Usage:
#/   ./opensubtitles-dl.sh [-n <name>] [-l <lang>] [-d]
#/
#/ Options:
#/   -n <name>               TV series or Movie name
#/   -l <lang>               optional, language
#/                           e.g.: eng, spa, fre...
#/   -d                      enable debug mode
#/   -h | --help             display this help message

set -e
set -u

usage() {
    printf "%b\n" "$(grep '^#/' "$0" | cut -c4-)" && exit 1
}

set_var() {
    _CURL="$(command -v curl)" || command_not_found "curl"
    _PUP="$(command -v pup)" || command_not_found "pup"
    _FZF="$(command -v fzf)" || command_not_found "fzf"
    _UNZIP="$(command -v unzip)" || command_not_found "unzip"

    _HOST="https://www.opensubtitles.org"
    _SEARCH_URL="$_HOST/en/search/sublanguageid-"
    _GOOGLE_SEARCH="https://www.google.com"
    _DOWNLOAD_URL="https://dl.opensubtitles.org/en/download/sub/"

    _SCRIPT_PATH=$(dirname "$(realpath "$0")")
}

set_args() {
    expr "$*" : ".*--help" > /dev/null && usage
    while getopts ":hdl:n:" opt; do
        case $opt in
            n)
                _INPUT_NAME="$OPTARG"
                ;;
            l)
                _LANG="$OPTARG"
                ;;
            d)
                set -x
                ;;
            h)
                usage
                ;;
            \?)
                print_error "Invalid option: -$OPTARG"
                ;;
        esac
    done
}

print_info() {
    # $1: info message
    printf "%b\n" "\033[32m[INFO]\033[0m $1" >&2
}

print_warn() {
    # $1: warning message
    printf "%b\n" "\033[33m[WARNING]\033[0m $1" >&2
}

print_error() {
    # $1: error message
    printf "%b\n" "\033[31m[ERROR]\033[0m $1" >&2
    exit 1
}

command_not_found() {
    # $1: command name
    print_error "$1 command not found!"
}

get_subtitle_list () {
    # $1: id
    local d ul nl len n l
    d="$("$_CURL" -sSL "${_SEARCH_URL}${_LANG:-eng}/imdbid-${1}")"
    ul="$("$_PUP" '.bnone attr{href}' <<< "$d" \
        | sed -E 's/.*\/subtitles\///' \
        | awk -F '/' '{print $1}')"
    if [[ -z "${ul:-}" ]]; then
        "$_PUP" 'link attr{href}' <<< "$d" \
            | grep -E '^/en/subtitles/' \
            | sed -E 's/.*\/subtitles\///' \
            | awk -F '/' '{print $1}'
    else
        nl="$("$_PUP" ':parent-of(strong)' <<< "$d" \
            | sed -n "/<br>/,/<br>/p" \
            | sed -E 's/<br>.*//' \
            | sed -E '/<span /d;/<\/span>/d' \
            | awk '{$1=$1};1' \
            | awk '{if (NF!=0) {prev=$0;getline;print prev,$0}}')"
        len="$(wc -l <<< "$nl")"
        for i in $(seq 1 "$len"); do
            u="$(head -"$i" <<< "$ul" | tail -1)"
            n="$(head -"$i" <<< "$nl" | tail -1)"
            echo "[$u] $n"
        done
    fi
}

get_imdb_id() {
    # $1: media name
    local r c ul nl len u n res
    r="$("$_CURL" -sSL "$_GOOGLE_SEARCH/search?q=${1// /+}+site%3Aimdb.com%2Ftitle" \
        -A 'google')"
    c="$("$_PUP" 'h3 div attr{class}' <<< "$r")"
    ul="$("$_PUP" '#main :parent-of(h3)' <<< "$r" \
        | grep href \
        | sed -E 's/.*.imdb.com\/title\/tt//;s/\/.*//')"
    nl="$("$_PUP" '#main :parent-of(h3)' <<< "$r" \
        | grep "$c" -A 1 \
        | grep -v "$c" \
        | grep -v -- '--' \
        | awk '{$1=$1};1' \
        | sed -E 's/&#34;/"/g;s/&#39;/'\''/g')"

    len="$(wc -l <<< "$nl")"
    res=""
    for i in $(seq 1 "$len"); do
        u="$(head -"$i" <<< "$ul" | tail -1)"
        n="$(head -"$i" <<< "$nl" | tail -1)"
        if [[ "$(grep -c $u <<< "$res")" != "1" ]]; then
            res+="$u"
            echo "[$u] $n"
        fi
    done
}

download_subtitle() {
    # $1: subtitle id
    "$_CURL" "$_DOWNLOAD_URL{$1}" -o "$_SCRIPT_PATH/${1}.zip"
    "$_UNZIP" -o "${1}.zip" -x "*.nfo"
    rm -f "${1}.zip"
}

fzf_prompt() {
    # $1: input
    echo -n "$1" \
        | "$_FZF" -1 -0 \
        | awk -F']' '{print $1}' \
        | sed -E 's/^\[//'
}

main() {
    set_args "$@"
    set_var

    [[ -z "${_INPUT_NAME:-}" ]] && print_error "Missing -n <name>!"
    mlist="$(get_imdb_id "${_INPUT_NAME:-}")"
    mid="$(fzf_prompt "$mlist")"

    slist="$(get_subtitle_list "$mid")"
    sid="$(fzf_prompt "$slist")"

    [[ -z "${sid:-}" ]] && print_error "Subtitle not found!"
    download_subtitle "$sid"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
