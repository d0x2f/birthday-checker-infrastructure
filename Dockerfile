FROM alpine:3.17

ENV CLOUD_SDK_VERSION=414.0.0
ENV TERRAFORM_VERSION=1.3.7

RUN set -eux; \
  apk --no-cache add curl==7.87.0-r1 python3==3.10.9-r1 bash==5.2.15-r0; \
  \
  # Install gcloud
  curl -L \
  https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-${CLOUD_SDK_VERSION}-linux-x86_64.tar.gz \
  | tar xz; \
  /google-cloud-sdk/bin/gcloud components install alpha; \
  /google-cloud-sdk/bin/gcloud components install beta; \
  /google-cloud-sdk/install.sh; \
  echo ". '/google-cloud-sdk/path.bash.inc'" > /etc/profile.d/gcloud.path.sh; \
  \
  # Install terraform
  cd /usr/local/bin; \
  wget https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
  -O terraform_linux_amd64.zip; \
  unzip terraform_linux_amd64.zip; \
  rm terraform_linux_amd64.zip;

WORKDIR /app

ENTRYPOINT [ "/bin/bash" ]