#!/usr/bin/env bash
#
# Download subtitles from opensubtitles.org
#
#/ Usage:
#/   ./opensubtitles-dl.sh [-n <name>] [-l <lang>] [-a] [-d]
#/
#/ Options:
#/   -n <name>               TV series or Movie name
#/   -l <lang>               optional, language
#/                           e.g.: eng, spa, fre...
#/                           default: eng
#/   -a                      optional, download all available subtitles
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
    _JQ="$(command -v jq)" || command_not_found "jq"

    _HOST="https://www.opensubtitles.org"
    _SEARCH_URL="$_HOST/en/search/sublanguageid-"
    _IMDB_SEARCH="https://v3.sg.media-imdb.com/suggestion/x"
    _DOWNLOAD_URL="https://dl.opensubtitles.org/en/download/sub/"
}

set_args() {
    expr "$*" : ".*--help" > /dev/null && usage
    while getopts ":hdal:i:n:" opt; do
        case $opt in
            i)
                _INPUT_ID="$OPTARG"
                ;;
            n)
                _INPUT_NAME="$OPTARG"
                ;;
            l)
                _LANG="$OPTARG"
                ;;
            a)
                _DOWNLOAD_ALL=true
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

get_imdb_tt() {
    # $1: TV series or movie name
    "$_CURL" -sS 'https://www.perplexity.ai/rest/sse/perplexity_ask' -X POST \
        -A x -b '__cf_bm=x' \
        -H 'Accept: text/event-stream' \
        -H 'Accept-Language: en-US,en;q=0.5' \
        -H 'content-type: application/json' \
        --data-raw '{"params":{"last_backend_uuid":"","read_write_token":"","attachments":[],"language":"","timezone":"","search_focus":"internet","sources":["web"],"frontend_uuid":"","mode":"concise","model_preference":"turbo","is_related_query":false,"is_sponsored":false,"prompt_source":"user","query_source":"","is_incognito":true,"time_from_first_type":1,"local_search_enabled":false,"use_schematized_api":true,"send_back_text_in_streaming_api":false,"supported_block_use_cases":["answer_modes","media_items","knowledge_cards","inline_entity_cards","place_widgets","finance_widgets","prediction_market_widgets","sports_widgets","flight_status_widgets","news_widgets","shopping_widgets","jobs_widgets","search_result_widgets","inline_images","inline_assets","placeholder_cards","diff_blocks","inline_knowledge_cards","entity_group_v2","refinement_filters","canvas_mode","maps_preview","answer_tabs","price_comparison_widgets","preserve_latex","generic_onboarding_widgets","in_context_suggestions"],"client_coordinates":null,"mentions":[],"skip_search_enabled":true,"is_nav_suggestions_disabled":false,"followup_source":"link","source":"default","always_search_override":false,"override_no_search":false,"should_ask_for_mcp_tool_confirmation":true,"force_enable_browser_agent":false,"supported_features":[""],"version":""},"query_str":"imdb link id for:'"$1"'. tt part, only return its value in plain text"}' \
        | grep --line-buffered '"diff_block": {"field": "markdown_block"' \
        | sed 's/^data: //' \
        | "$_JQ" -j -r --unbuffered '.blocks[0].diff_block.patches[0].value | (.chunks?[0] // .)'
}

get_subtitle_list () {
    # $1: id
    local d ul nl len n l
    d="$("$_CURL" -A x -sSL "${_SEARCH_URL}${_LANG:-eng}/imdbid-${1}")"
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

download_subtitle() {
    # $1: subtitle id
    while read -r id; do
        "$_CURL" "$_DOWNLOAD_URL${id}" -o "./${id}.zip"
        "$_UNZIP" -o "${id}.zip" -x "*.nfo"
        rm -f "${id}.zip"
    done <<< "$1"
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

    [[ -z "${_INPUT_NAME:-}" ]] \
        && print_error "Missing TV series or Movie name!"

    mid="$(get_imdb_tt "$_INPUT_NAME")"
    print_info "IMDb ID: $mid"
    slist="$(get_subtitle_list "$mid")"
    if [[ -z "${_DOWNLOAD_ALL:-}" ]]; then
        sid="$(fzf_prompt "$slist")"
    else
        sid="$(awk -F ']' '{print $1}' <<< "$slist" | awk -F '[' '{print $2}')"
    fi

    [[ -z "${sid:-}" ]] && print_error "Subtitle not found!"
    download_subtitle "$sid"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
