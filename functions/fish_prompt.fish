function fish_prompt
    set -l normal_color (set_color normal)
    set -l host_color (set_color $fish_color_host ^/dev/null; or set_color green)
    set -l directory_color (set_color $fish_color_cwd ^/dev/null; or set_color blue)
    
    set -l modified_color (set_color red)
    set -l staged_color (set_color green)
    set -l untracked_color (set_color -o blue)
    set -l revision_color (set_color -o black)

    set -l hostname (hostname)
    set -l cwd (basename (prompt_pwd))
    set -l prompt_char ">"

    set -l vcs_info ""
    set -l ahead "↑"
    set -l behind "↓"
    set -l diverged "⥄ "

    set -l git_dir (git rev-parse --git-dir 2>/dev/null)
    if test -n "$git_dir"
        set -l revision (string sub --length 7 (git rev-parse HEAD 2>/dev/null))

        set -l branch (git_branch_name)
        if test $branch = "master"
             set branch "T"
        end

        set -l operation ""
        if test -d "$git_dir/.dotest"
            if test -f "$git_dir/.dotest/rebasing"
                set operation "rebase"
            else if test -f "$git_dir/.dotest/applying"
                set operation "am"
            else
                set operation "am/rebase"
            end
        else if test -f "$git_dir/.dotest-merge/interactive"
            set operation "rebase -i"
        else if test -d "$git_dir/.dotest-merge"
            set operation "rebase -m"
        # lvv: not always works. Should ./.dotest be used instead?
        else if test -f "$git_dir/MERGE_HEAD"
            set operation "merge"
        else if test -f "$git_dir/index.lock"
             set operation "locked"
        else if test -f "$git_dir/BISECT_LOG"
             set operation "bisect"
        end
        
        if not grep -q "^ref:" "$git_dir/HEAD" 2>/dev/null
           set branch "<detached:" (git name-rev --name-only HEAD 2>/dev/null)
        else if test -n $operation
            set branch "$operation:$branch"
            if test "$operation" = "merge"
                set branch $branch "<--" (git name-rev --name-only (cat $git_dir/MERGE_HEAD))
            end
        end

        set -l vcs_color $directory_color
        eval (env LANG=C git status --porcelain 2>/dev/null | sed -n '
             s,^[MARC]. .*,set vcs_color $staged_color;,p
             s,^.[MAU] .*,set vcs_color $modified_color;,p
             s,^?? .*,set vcs_color $untracked_color;,p')

        set -l freshness "="
        eval (env LANG=C git status 2>/dev/null | sed -n '
             s/^\(# \)*Initial commi.*/set branch "(init)"; set freshness ""; set revision "";/p
             s/^\(# \)*Your branch is ahead of.*/set freshness $ahead;/p
             s/^\(# \)*Your branch is behind.*/set freshness $behind;/p
             s/^\(# \)*Your branch and.*have diverged.*/set freshness $diverged;/p')
        
        set vcs_info $vcs_color "|" $branch $normal_color $freshness $revision_color $revision $directory_color
    else
        set -l hg_root (hg root 2>/dev/null)
        if test -n "$hg_root"
            set -l revision (hg id --id)
            set -l freshness "="  # not supported by hg
            set -l branch (hg branch 2>/dev/null)
            if test $branch = "default"
                 set branch "T"
            end

            set -l vcs_color $directory_color
            eval (hg status 2>/dev/null | sed -n '
                s/^[M!] .*/set vcs_color $modified_color;/p
                s/^[AR] .*/set vcs_color $staged_color;/p
                s/^? .*/set vcs_color $untracked_color;/p')

            if test -f $hg_root/.hg/bookmarks.current
               set branch $branch "/" (cat "$hg_root/.hg/bookmarks.current")
            end

            set vcs_info $vcs_color "|" $branch $normal_color $freshness $revision_color $revision $directory_color
        end
    end

    echo -n -s $host_color $hostname ":" $directory_color $cwd $vcs_info $prompt_char $normal_color
end
