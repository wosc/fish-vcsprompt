function fish_title
    set -l myhostname (hostname)
    set -l cwd (basename (prompt_pwd))
    set -l title "$myhostname:$cwd/"
    # tmux rename-window $title
    echo "$title"
end
