ARG GO_VERSION

FROM golang:${GO_VERSION}-alpine

ARG VERSION
# Build deps
RUN apk add --update python3.6 --repository=http://dl-cdn.alpinelinux.org/alpine/v3.15/main \
    git wget py3-pip \
    gcc python3-dev make musl-dev linux-headers libffi-dev openssl-dev \
    py-setuptools openssl procps ca-certificates openvpn ipset \
    && pip install --upgrade pip \
    && rm -rf /root/.cache/* \
    && rm -rf /tmp/* /var/cache/apk/*

# Pritunl Build
RUN export GOPATH=/go \
    && export GO111MODULE=on \
    && go install github.com/pritunl/pritunl-dns@latest \
    && go install github.com/pritunl/pritunl-web@latest \
    && cp /go/bin/* /usr/bin/ \
    && rm -rf /root/.cache/* \
    && rm -rf /tmp/* /var/cache/apk/*

RUN wget https://github.com/pritunl/pritunl/archive/refs/tags/${VERSION}.tar.gz \
    && tar zxvf ${VERSION}.tar.gz \
    && export CRYPTOGRAPHY_DONT_BUILD_RUST=1 \
    && cd pritunl-${VERSION} \
    && pip install -r requirements.txt \
    && python3 setup.py build \
    && python3 setup.py install \
    && cd .. \
    && rm -rf *${VERSION}* \
    && rm -rf /root/.cache/* \
    && rm -rf /tmp/* /var/cache/apk/*

ADD rootfs /

EXPOSE 80
EXPOSE 443
EXPOSE 1194
ENTRYPOINT ["/init"]
