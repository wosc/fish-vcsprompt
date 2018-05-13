function fish_title
    set -l hostname (hostname)
    set -l cwd (basename (prompt_pwd))
    set -l title "$hostname:$cwd/"
    tmux rename-window $title
    echo "$title"
end
