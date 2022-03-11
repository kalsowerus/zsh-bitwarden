ZSH_BITWARDEN_DELIMITER='\t'

function .bw_select() {
	local result=$(bw list items --nointeraction | jq -r ".[] | [.name, $1] | join(\"$ZSH_BITWARDEN_DELIMITER\")")
	echo "$result" | fzf -n 1 --with-nth 1 -d "$ZSH_BITWARDEN_DELIMITER"
}

function .bw_get() {
	local bw_items
	local res
	local result
	bw_item=$(.bw_select $1)
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

function .bw_copy() {
	local copy_cmd=${ZSH_BITWARDEN_COPY_CMD:-xclip -r}
	local bw_items
	local res
	bw_item=$(.bw_select $1)
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

