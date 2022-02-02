
function fish_right_prompt
  set -l exit_code $status
  if test $exit_code -ne 0
    set_color red
    printf '😱 '
  else
    set_color green
    printf '😎 '
  end
  printf '%d' $exit_code
  printf ' ❤️ '
  set_color normal
end
