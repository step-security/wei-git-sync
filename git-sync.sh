#!/bin/sh

set -e

SOURCE_REPO=$1
SOURCE_BRANCH=$2
DESTINATION_REPO=$3
DESTINATION_BRANCH=$4

# Reject inputs that begin with '-' so they cannot be reinterpreted as git options
for arg in "$SOURCE_REPO" "$SOURCE_BRANCH" "$DESTINATION_REPO" "$DESTINATION_BRANCH"; do
  case "$arg" in
    -*)
      echo "Error: arguments must not begin with '-'" >&2
      exit 1
      ;;
  esac
done

if ! echo $SOURCE_REPO | grep -Eq ':|@|\.git\/?$'; then
  if [[ -n "$SSH_PRIVATE_KEY" || -n "$SOURCE_SSH_PRIVATE_KEY" ]]; then
    SOURCE_REPO="git@github.com:${SOURCE_REPO}.git"
    GIT_SSH_COMMAND="ssh -v"
  else
    SOURCE_REPO="https://github.com/${SOURCE_REPO}.git"
  fi
fi

if ! echo $DESTINATION_REPO | grep -Eq ':|@|\.git\/?$'; then
  if [[ -n "$SSH_PRIVATE_KEY" || -n "$DESTINATION_SSH_PRIVATE_KEY" ]]; then
    DESTINATION_REPO="git@github.com:${DESTINATION_REPO}.git"
    GIT_SSH_COMMAND="ssh -v"
  else
    DESTINATION_REPO="https://github.com/${DESTINATION_REPO}.git"
  fi
fi

# Redact any userinfo (e.g. https://user:token@host/...) before logging
SAFE_SOURCE_REPO=$(printf '%s' "$SOURCE_REPO" | sed -E 's#(://)[^/@[:space:]]+@#\1***@#')
SAFE_DESTINATION_REPO=$(printf '%s' "$DESTINATION_REPO" | sed -E 's#(://)[^/@[:space:]]+@#\1***@#')

echo "SOURCE=$SAFE_SOURCE_REPO:$SOURCE_BRANCH"
echo "DESTINATION=$SAFE_DESTINATION_REPO:$DESTINATION_BRANCH"

if [[ -n "$SOURCE_SSH_PRIVATE_KEY" ]]; then
  # Clone using source ssh key if provided
  git clone -c core.sshCommand="/usr/bin/ssh -i ~/.ssh/src_rsa" "$SOURCE_REPO" /root/source --origin source && cd /root/source
else
  git clone "$SOURCE_REPO" /root/source --origin source && cd /root/source
fi

git remote add destination "$DESTINATION_REPO"

# Pull all branches references down locally so subsequent commands can see them
git fetch source '+refs/heads/*:refs/heads/*' --update-head-ok

# Print out all branches
git --no-pager branch -a -vv

if [[ -n "$DESTINATION_SSH_PRIVATE_KEY" ]]; then
  # Push using destination ssh key if provided
  git config --local core.sshCommand "/usr/bin/ssh -i ~/.ssh/dst_rsa"
fi

git push destination "${SOURCE_BRANCH}:${DESTINATION_BRANCH}" -f
