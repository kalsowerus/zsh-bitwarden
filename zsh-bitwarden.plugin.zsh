ZSH_BITWARDEN_DELIMITER='\t'

function .bw_ensure_unlocked() {
    local session
    session=$(cat "${HOME}/.bwsession" 2>/dev/null)
    local bw_status
    bw_status=$(bw status --session "${session}" 2>/dev/null | jq -r '.status')

    if [[ "${bw_status}" == 'locked' ]]; then
        # workaround for https://github.com/bitwarden/cli/issues/480
        if bw list folders --nointeraction --session "${session}" >/dev/null 2>&1; then
            return 0
        fi
        # end workaround

        local reply
        zle -I
        read -rs 'reply?? Master password: [input is hidden] ' < /dev/tty
        echo
        local key
        key=$(bw unlock "${reply}" --raw)
        echo "${key}" > "${HOME}/.bwsession"
        chmod 0600 "${HOME}/.bwsession"
    elif [[ "${bw_status}" == 'unauthenticated' ]]; then
        zle -I
        echo 'You are not logged in.'
        return 1
    fi
}

function .bw_select() {
    local session
    session=$(cat "${HOME}/.bwsession" 2>/dev/null)
    jq -r ".[] | [.name, ${1}] | join(\"${ZSH_BITWARDEN_DELIMITER}\")" <(bw list items --session "${session}" --nointeraction 2>&/dev/null) | fzf -0 --with-nth 1 -d "${ZSH_BITWARDEN_DELIMITER}"
}

function .bw_get() {
    if ! .bw_ensure_unlocked; then
        return
    fi
    local bw_item
    local rc
    local result
    bw_item=$(.bw_select "${1}")
    rc=$?
    if [[ ${rc} == 0 ]]; then
        result=$(echo "${bw_item}" | awk -F "${ZSH_BITWARDEN_DELIMITER}" '{print $2}')
    elif [[ ${rc} == 1 ]]; then
        printf "\nVault is locked.\n\n" >&2
        zle reset-prompt
    fi
    if [[ -n "${result}" ]]; then
        LBUFFER="${LBUFFER}${result}"
    fi
}

function .bw_copy() {
    if ! .bw_ensure_unlocked; then
        return
    fi
    local copy_cmd
    copy_cmd="${ZSH_BITWARDEN_COPY_CMD:-clipcopy}"
    local bw_item
    local rc
    bw_item=$(.bw_select "${1}")
    rc=$?
    if [[ ${rc} == 0 ]]; then
        echo -n "${bw_item}" | awk -F "${ZSH_BITWARDEN_DELIMITER}" '{printf "%s",$2}' | eval "${copy_cmd}"
    elif [[ ${rc} == 1 ]]; then
        printf "\nVault is locked.\n\n" >&2
        zle reset-prompt
    fi
}

ZSH_BITWARDEN_USERNAME_PATH=".login.username"
ZSH_BITWARDEN_PASSWORD_PATH=".login.password"

function bw_get_username() {
    setopt local_options warn_create_global
    .bw_get "${ZSH_BITWARDEN_USERNAME_PATH}"
}

function bw_get_password() {
    setopt local_options warn_create_global
    .bw_get "${ZSH_BITWARDEN_PASSWORD_PATH}"
}

function bw_copy_username() {
    setopt local_options warn_create_global
    .bw_copy "${ZSH_BITWARDEN_USERNAME_PATH}"
}

function bw_copy_password() {
    setopt local_options warn_create_global
    .bw_copy "${ZSH_BITWARDEN_PASSWORD_PATH}"
}

function bind_keys() {
    setopt local_options warn_create_global

    zle -N bw_get_username
    zle -N bw_get_password
    zle -N bw_copy_username
    zle -N bw_copy_password

    local GET_USERNAME_KEY="${ZSH_BITWARDEN_GET_USERNAME_KEY:-^[u}"
    local GET_PASSWORD_KEY="${ZSH_BITWARDEN_GET_PASSWORD_KEY:-^[p}"
    local COPY_USERNAME_KEY="${ZSH_BITWARDEN_COPY_USERNAME_KEY:-^U}"
    local COPY_PASSWORD_KEY="${ZSH_BITWARDEN_COPY_PASSWORD_KEY:-^P}"

    bindkey "${GET_USERNAME_KEY}" bw_get_username
    bindkey "${GET_PASSWORD_KEY}" bw_get_password
    bindkey "${COPY_USERNAME_KEY}" bw_copy_username
    bindkey "${COPY_PASSWORD_KEY}" bw_copy_password
}

