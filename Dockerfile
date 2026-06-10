FROM alpine:3.24.0@sha256:a2d49ea686c2adfe3c992e47dc3b5e7fa6e6b5055609400dc2acaeb241c829f4

LABEL "repository"="https://github.com/step-security/wei-git-sync"
LABEL "homepage"="https://github.com/step-security/wei-git-sync"
LABEL "maintainer"="step-security"

RUN apk add --no-cache git openssh-client jq curl && \
  echo "StrictHostKeyChecking no" >> /etc/ssh/ssh_config

ADD *.sh /

ENTRYPOINT ["/entrypoint.sh"]
