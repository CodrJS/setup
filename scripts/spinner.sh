#!/bin/bash
# Shows a spinner while another command is running. Randomly picks one of 12 spinner styles.
# @args command to run (with any parameters) while showing a spinner.
#       E.g. ‹spinner sleep 10›

function resetcursor() {
  tput cnorm # reset cursor
}
trap resetcursor EXIT

function cursorBack() {
  echo -en "\e[$1D"
}

function clearLine() {
  echo -en "\e[K"
}

function spinner() {
  # make sure we use non-unicode character type locale
  # (that way it works for any locale as long as the font supports the characters)
  local LC_CTYPE=C

  local pid=$1 # Process Id of the previous running command

  local spin='-\|/'
  local charwidth=1

  local i=0
  tput civis # cursor invisible
  tput sc
  while : ; do
    local i=$(((i + $charwidth) % ${#spin}))
    #clearLine
    tput rc
    tput ed
    printf "%s $cmd" "${spin:$i:$charwidth}"

    #cursorBack $((${#cmd} + $charwidth + 1))
    sleep .1
    [[ $(kill -0 $pid 2>/dev/null) ]] || break
  done
  tput rc
  tput ed
  wait $pid # capture exit code
  tput cnorm
  return $?
}

### Run command; save cmd to var; run spinner
cmd=$@
("$@") &
spinner $!
