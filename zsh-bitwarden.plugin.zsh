ZSH_BITWARDEN_DELIMITER='\t'

function .bw_ensure_unlocked() {
	local bw_status=$(bw status | jq -r '.status')
	if [ $bw_status = 'locked' ]; then
		zle -I
		read -s 'reply?? Master password: [input is hidden] ' < /dev/tty
		echo
		local key=$(bw unlock "$reply" --raw)
		export BW_SESSION="$key"
	elif [ $bw_status = 'unauthenticated' ]; then
		zle -I
		echo 'You are not logged in.'
		return 1
	fi
}

function .bw_select() {
	jq -r ".[] | [.name, $1] | join(\"$ZSH_BITWARDEN_DELIMITER\")" <(bw list items --nointeraction 2>&/dev/null) | fzf -0 -n 1 --with-nth 1 -d "$ZSH_BITWARDEN_DELIMITER"
}

function .bw_get() {
	if ! .bw_ensure_unlocked; then
		return
	fi
	local bw_items
	local rc
	local result
	bw_item=$(.bw_select $1)
	rc=$?
	if [ $rc -eq 0 ]; then
		result=$(echo "$bw_item" | awk -F "$ZSH_BITWARDEN_DELIMITER" '{print $2}')
	elif [ $rc -eq 1 ]; then
		echo "\nVault is locked.\n" >&2
		zle reset-prompt
	fi
	if [ ! -z "$result" ]; then
		LBUFFER="$LBUFFER$result"
	fi
}

function .bw_copy() {
	if ! .bw_ensure_unlocked; then
		return
	fi
	local copy_cmd=${ZSH_BITWARDEN_COPY_CMD:-xclip -r}
	local bw_items
	local rc
	bw_item=$(.bw_select $1)
	rc=$?
	if [ $rc -eq 0 ]; then
		echo "$bw_item" | awk -F $ZSH_BITWARDEN_DELIMITER '{print $2}' | eval "$copy_cmd"
	elif [ $rc -eq 1 ]; then
		echo "\nVault is locked.\n" >&2
		zle reset-prompt
	fi
}

ZSH_BITWARDEN_USERNAME_PATH=".login.username"
ZSH_BITWARDEN_PASSWORD_PATH=".login.password"

function bw_get_username() {
	.bw_get $ZSH_BITWARDEN_USERNAME_PATH
}

function bw_get_password() {
	.bw_get $ZSH_BITWARDEN_PASSWORD_PATH
}

function bw_copy_username() {
	.bw_copy $ZSH_BITWARDEN_USERNAME_PATH
}

function bw_copy_password() {
	.bw_copy $ZSH_BITWARDEN_PASSWORD_PATH
}

zle -N bw_get_username
zle -N bw_get_password
zle -N bw_copy_username
zle -N bw_copy_password

local GET_USERNAME_KEY=${ZSH_BITWARDEN_GET_USERNAME_KEY:-^[u}
local GET_PASSWORD_KEY=${ZSH_BITWARDEN_GET_PASSWORD_KEY:-^[p}
local COPY_USERNAME_KEY=${ZSH_BITWARDEN_COPY_USERNAME_KEY:-^U}
local COPY_PASSWORD_KEY=${ZSH_BITWARDEN_COPY_PASSWORD_KEY:-^P}

bindkey $GET_USERNAME_KEY bw_get_username
bindkey $GET_PASSWORD_KEY bw_get_password
bindkey $COPY_USERNAME_KEY bw_copy_username
bindkey $COPY_PASSWORD_KEY bw_copy_password

