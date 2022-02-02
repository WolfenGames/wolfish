# MIT license

function _prompt_wtc_lms -a color -d "Get the currently installed wtc-lms version"
  switch (uname)
    case Linux
      set -l does_exist (ls ~/.config/wtc/ 2>/dev/null | grep config.yml)
      [ -n $does_exist ]; or return
    case Darwin
      if test -e /home/$USER/Library/Application\ Support/wtc/config.yml
        return
      end
    case '*'
      return
  end
  type -q wtc-lms; or return
  set -gx WTC_LMS_VERSION (wtc-lms --version | awk -F ' ' '{print $3}')
  [ -n $WTC_LMS_VERSION ]; and echo -n -s $color $WTC_LMS_VERSION
end

function _prompt_java_version -a color -d "Get java version"
  type -q java; or return
  set -gx JAVA_VERSION (java -version 2>&1 | head -n 1 | awk -F '"' '{print $2}')
  [ -n $JAVA_VERSION ]; and echo -n -s $color $JAVA_VERSION
end

function _prompt_maven_version -a color -d "Get Maven version"
  type -q mvn; or return
  set -gx MAVEN_VERSION (mvn -version 2>&1 | head -n 1 | awk -F ' ' '{print $3}')
  [ -n $MAVEN_VERSION ]; and echo -n -s $color $MAVEN_VERSION
end

function _prompt_rust_version -a color -d "Get Rust version"
  type -q rustc; or return
  set -U RUST_VERSION (rustc --version | cut -d\  -f2)
  [ -n $RUST_VERSION ]; and echo -n -s $color $RUST_VERSION
end

function _prompt_docker_compose_version -a color -d "Get Docker compose version"
  type -q docker-compose; or return
  set -U DOCKER_COMPOSE_VERSION (docker-compose --version | awk -F 'v' '{print $3}')
  [ -n $DOCKER_COMPOSE_VERSION ]; and echo -n -s $color $DOCKER_COMPOSE_VERSION
end

function _prompt_docker_version -a color -d "Get Docker version"
  type -q docker; or return
  set -U DOCKER_VERSION (docker --version | awk -F ' ' '{print $3}' | sed -r 's/,//g')
  [ -n $DOCKER_VERSION ]; and echo -n -s $color $DOCKER_VERSION
end

function _prompt_rubies -a color -d 'Display current Ruby (rvm/rbenv)'
  type -q ruby; or return
  set -gx RUBY_VERSION (ruby --version | cut -d\  -f2 | awk -F 'p' '{print $1}')
  [ -n $RUBY_VERSION ]; and echo -n -s $color $RUBY_VERSION
end

function _prompt_versions -a blue gray green orange red purple append
  set -l prompt_wtc_lms (_prompt_wtc_lms $red)
  set -l prompt_venv (_prompt_virtualenv $orange)
  set -l prompt_java_version (_prompt_java_version $blue)
  set -l prompt_maven_version (_prompt_maven_version $purple)
  set -l prompt_rust_version (_prompt_rust_version $red)
  set -l prompt_docker_compose_version (_prompt_docker_compose_version $blue)
  set -l prompt_docker_version (_prompt_docker_version $orange)
  set -l prompt_rubies (_prompt_rubies $red)

  echo -n -e -s "$prompt_wtc_lms $prompt_venv $prompt_java_version $prompt_maven_version $prompt_rust_version $prompt_docker_compose_version $prompt_docker_version $prompt_rubies" | string trim | string replace -ar " +" "$gray|" | tr -d '\n'
end

function _prompt_pwd
  set_color -o blue
  printf '%s' (prompt_pwd)
end

function _prompt_virtualenv -a color -d "Display currently activated Python virtual environment"
  type -q python; or return
  if [ "$VIRTUAL_ENV" != "$LAST_VIRTUAL_ENV" -o -z "$PYTHON_VERSION" ]
    set -gx PYTHON_VERSION (python --version 2>&1 | cut -d\  -f2)
    set -gx LAST_VIRTUAL_ENV $VIRTUAL_ENV
  end
  echo -n -s $color $PYTHON_VERSION
  [ -n "$VIRTUAL_ENV" ]; and echo -n -s '@'(basename "$VIRTUAL_ENV")
end

# Borrowed from scorphish
function _prompt_git -a gray normal orange red yellow
  test "$theme_display_git" = no; and return
  set -l git_branch (_git_branch_name)
  test -z $git_branch; and return
  if test "$theme_display_git_dirty" = no
    echo -n -s $gray '‹' $yellow $git_branch $gray '› '
    return
  end
  set dirty_remotes (_git_dirty_remotes $red $orange)
  if [ (_is_git_dirty) ]
    echo -n -s $gray '‹' $yellow $git_branch $red '*' $dirty_remotes $gray '› '
  else
    echo -n -s $gray '‹' $yellow $git_branch $red $dirty_remotes $gray '› '
  end
end

function _git_branch_name
  echo (command git symbolic-ref HEAD 2> /dev/null | sed -e 's|^refs/heads/||')
end

function _is_git_dirty
  echo (command git status -s --ignore-submodules=dirty 2> /dev/null)
end

function _git_ahead_count -a remote -a branch_name
  echo (command git log $remote/$branch_name..HEAD 2> /dev/null | \
    grep '^commit' | wc -l | tr -d ' ')
end

function _git_dirty_remotes -a remote_color -a ahead_color
  set current_branch (command git rev-parse --abbrev-ref HEAD 2> /dev/null)
  set current_ref (command git rev-parse HEAD 2> /dev/null)

  for remote in (git remote | grep 'origin\|upstream')

    set -l git_ahead_count (_git_ahead_count $remote $current_branch)

    set remote_branch "refs/remotes/$remote/$current_branch"
    set remote_ref (git for-each-ref --format='%(objectname)' $remote_branch)
    if test "$remote_ref" != ''
      if test "$remote_ref" != $current_ref
        if [ $git_ahead_count != 0 ]
          echo -n "$remote_color!"
          echo -n "$ahead_color+$git_ahead_count$normal"
        end
      end
    end
  end
end
#End borrow scorphish

function get_user -a color -d "Get current user"
  echo -n -s $color (uname -a | awk -F ' ' '{print $2}')
end

function is_lms_project -d "Check if project is a LMS project"
  set -l first_commit_message (git log --pretty=oneline --reverse 2> /dev/null| head -1 | awk -F ' ' '{$1=""; print $0}' | string trim)
  [ -n "$first_commit_message" ]; or return 1
  [ "$first_commit_message" = 'Submission Repo Created' ]; or return 1
  return 0
end

function is_lms_project_timeout -a color -d "Do lms specific things"
  if test (math $CMD_DURATION / 1000) -gt 60
    return 0
  end
  return 1
end

function lms_project_timeout -a color -d "Print out if there is potential lms failure"
  echo -s -n $color 'Potential timeout during verification'
end

function lms_project_notification -a color -d "Checks if this is a LMS project"
  echo -n -s $color '[🔥 LMS PROJECT]'
end

function fish_prompt
  set -l exit_code $status

  set -l gray (set_color 666)
  set -l blue (set_color blue)
  set -l red (set_color red)
  set -l normal (set_color normal)
  set -l yellow (set_color yellow)
  set -l orange (set_color ff9900)
  set -l green (set_color green)
  set -l purple (set_color 62A)

  printf $gray'<'

  _prompt_versions $blue $gray $green $orange $red

  printf '%s> 🐺 %0.3fs' $gray (math $CMD_DURATION / 1000)
  printf '\n'(get_user $blue)
  printf '%s@%s' $gray (_prompt_pwd)
  printf ' %s' (_prompt_git $gray $normal $orange $red $yellow $purple)
  if is_lms_project
    printf '%s' (lms_project_notification $blue)
    if is_lms_project_timeout
      printf '\n'
      printf '%s' (lms_project_timeout $orange)
    end
  end
  printf '\n'

  set_color green
  printf '> '

  set_color normal
end
