function fish_right_prompt
  if test $status -eq 0
    set_color $fish_color_autosuggestion; or set_color 555
  else
    set_color $fish_color_error; or set_color red
  end

  date "+%H:%M:%S"
  set_color normal
end
