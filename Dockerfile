FROM alpine

LABEL "repository"="https://github.com/step-security/wei-git-sync"
LABEL "homepage"="https://github.com/step-security/wei-git-sync"
LABEL "maintainer"="step-security"

RUN apk add --no-cache git openssh-client jq curl && \
  echo "StrictHostKeyChecking no" >> /etc/ssh/ssh_config

ADD *.sh /

ENTRYPOINT ["/entrypoint.sh"]
