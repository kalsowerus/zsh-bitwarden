ZSH_BITWARDEN_DELIMITER='\t'

function bw-select() {
	touch /tmp/bw_items && chmod 0600 /tmp/bw_items && bw list items --nointeraction > /tmp/bw_items && cat /tmp/bw_items | jq -r ".[] | [.name, $1] | join(\"$ZSH_BITWARDEN_DELIMITER\")" | fzf -n 1 --with-nth 1 -d "$ZSH_BITWARDEN_DELIMITER"
}

function bw-get() {
	local bw_items
	local res
	local result
	bw_item=$(bw-select $1)
	res=$?
	if [ $res -eq 0 ]; then
		result=$(echo "$bw_item" | awk -F "$ZSH_BITWARDEN_DELIMITER" '{print $2}')
	elif [ $res -eq 1 ]; then
		echo
		zle reset-prompt
	fi
	if [ ! -z "$result" ]; then
		LBUFFER="$LBUFFER$result"
	fi
}

function bw-copy() {
	local copy_cmd=${ZSH_BITWARDEN_COPY_CMD:-xclip -r}
	local bw_items
	local res
	bw_item=$(bw-select $1)
	res=$?
	if [ $res -eq 0 ]; then
		echo "$bw_item" | awk -F $ZSH_BITWARDEN_DELIMITER '{print $2}' | eval "$copy_cmd"
	elif [ $res -eq 1 ]; then
		echo
		zle reset-prompt
	fi
}

ZSH_BITWARDEN_USERNAME_PATH=".login.username"
ZSH_BITWARDEN_PASSWORD_PATH=".login.password"

function bw-get-username() {
	bw-get $ZSH_BITWARDEN_USERNAME_PATH
}

function bw-get-password() {
	bw-get $ZSH_BITWARDEN_PASSWORD_PATH
}

function bw-copy-username() {
	bw-copy $ZSH_BITWARDEN_USERNAME_PATH
}

function bw-copy-password() {
	bw-copy $ZSH_BITWARDEN_PASSWORD_PATH
}

zle -N bw-get-username
zle -N bw-get-password
zle -N bw-copy-username
zle -N bw-copy-password

local GET_USERNAME_KEY=${ZSH_BITWARDEN_GET_USERNAME_KEY:-^[u}
local GET_PASSWORD_KEY=${ZSH_BITWARDEN_GET_PASSWORD_KEY:-^[p}
local COPY_USERNAME_KEY=${ZSH_BITWARDEN_COPY_USERNAME_KEY:-^U}
local COPY_PASSWORD_KEY=${ZSH_BITWARDEN_COPY_PASSWORD_KEY:-^P}

bindkey $GET_USERNAME_KEY bw-get-username
bindkey $GET_PASSWORD_KEY bw-get-password
bindkey $COPY_USERNAME_KEY bw-copy-username
bindkey $COPY_PASSWORD_KEY bw-copy-password

