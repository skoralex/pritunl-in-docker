ARG GO_VERSION

FROM golang:${GO_VERSION}

ARG VERSION
ENV DEBIAN_FRONTEND=noninteractive
# Build deps
RUN apt-get update && apt-get install --no-install-recommends -y apt-utils python3 python3-dev git wget py3-pip \
    gcc make musl-dev linux-headers libffi-dev openssl-dev \
    py-setuptools openssl procps ca-certificates openvpn ipset
RUN pip install --upgrade pip
RUN rm -rf /root/.cache/*
RUN apt autoremove -y
RUN rm -rf /var/lib/apt/lists/*
    #&& rm -rf /tmp/* /var/cache/apk/*

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
    #&& sed -i '/dataclasses/d' requirements.txt \
    #&& sed -i '/0201d89fa866f68c8ebd9d08ee6ff50c0b255f8ec63a71c16fda7af8/d' requirements.txt \
    #&& sed -i '/8479067f342acf957dc82ec415d355ab5edb7e7646b90dc6e2fd1d96/d' requirements.txt \
    #&& cat requirements.txt \
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
