function fish_title
    set -l hostname (hostname)
    set -l cwd (basename (prompt_pwd))
    echo "$hostname:$cwd/"
end
