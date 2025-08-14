FROM registry.access.redhat.com/ubi9/ubi-init:latest

LABEL maintainer="luzuccar@redhat.com"

# gcc for cgo
RUN dnf install -y git gcc make diffutils && rm -rf /var/lib/apt/lists/*

ENV GOLANG_VERSION 1.24.5
ENV GOLANG_DOWNLOAD_URL https://golang.org/dl/go$GOLANG_VERSION.linux-amd64.tar.gz
ENV GOLANG_DOWNLOAD_SHA256 10ad9e86233e74c0f6590fe5426895de6bf388964210eac34a6d83f38918ecdc

ENV KUSTOMIZE_VERSION v5.7.0
ENV OS linux
ENV ARCH amd64
ENV GOLANGCI_LINT_VERSION v1.64.5

RUN curl -fsSLo kustomize.tar.gz "https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize/${KUSTOMIZE_VERSION}/kustomize_${KUSTOMIZE_VERSION}_${OS}_${ARCH}.tar.gz"  \
    && tar -C /usr/bin -xzf kustomize.tar.gz \
    && rm kustomize.tar.gz

RUN curl -fsSL "$GOLANG_DOWNLOAD_URL" -o golang.tar.gz \
    && echo "$GOLANG_DOWNLOAD_SHA256  golang.tar.gz" | sha256sum -c - \
    && tar -C /usr/local -xzf golang.tar.gz \
    && rm golang.tar.gz

RUN curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s ${GOLANGCI_LINT_VERSION}

ENV PATH $PATH:/bin:/usr/local/go/bin:/usr/bin/
ENV GOPATH /home/1001
ENV GOCACHE /root/.cache/go-build
ENV GOENV /root/.config/go/env

RUN mkdir -p /home/1001/src /home/1001/bin /home/1001/pkg /go/build \
    && chmod -R 0777 /go  \
    && chmod -R 0777 /home/1001/ 

RUN chown -R 1001:1001 /home/1001 \
    && chown -R 1001:1001 /go

COPY uid_entrypoint.sh /go/

WORKDIR /go

USER 1001

ENTRYPOINT [ "./uid_entrypoint.sh" ]
