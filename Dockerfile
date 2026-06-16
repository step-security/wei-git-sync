FROM alpine:3.24.1@sha256:28bd5fe8b56d1bd048e5babf5b10710ebe0bae67db86916198a6eec434943f8b

LABEL "repository"="https://github.com/step-security/wei-git-sync"
LABEL "homepage"="https://github.com/step-security/wei-git-sync"
LABEL "maintainer"="step-security"

RUN apk add --no-cache git openssh-client jq curl && \
  echo "StrictHostKeyChecking no" >> /etc/ssh/ssh_config

ADD *.sh /

ENTRYPOINT ["/entrypoint.sh"]
