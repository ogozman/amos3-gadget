# Main gadget image

# BCC built from:
# https://github.com/kinvolk/bcc/commit/5fed2a94da19501c3088161db0c412b5623050ca
# See:
# - https://github.com/kinvolk/bcc/actions
# - https://hub.docker.com/r/kinvolk/bcc/tags

FROM golang:1.15-buster as builder
RUN echo "deb http://apt.llvm.org/buster/ llvm-toolchain-buster-9 main" >> /etc/apt/sources.list && apt-key adv --keyserver hkps://keyserver.ubuntu.com --recv-keys 15CF4D18AF4F7421 && \
    DEBIAN_FRONTEND=noninteractive apt-get update -y && apt-get install -y --no-install-recommends libelf-dev llvm-9-dev clang-9 && \ 
    (for tool in "clang" "llc" "llvm-strip"; do path=$(which $tool-9) && ln -s $path ${path%-*}; done)
RUN git clone https://github.com/ogozman/tracee /tracee
WORKDIR /tracee
RUN make build


FROM docker.io/kinvolk/bcc:202006031708335fed2a

RUN set -ex; \
	export DEBIAN_FRONTEND=noninteractive; \
	apt-get update && \
	apt-get install -y --no-install-recommends \
		ca-certificates curl && \
        rmdir /usr/src && ln -sf /host/usr/src /usr/src
	
RUN apt-get update && apt-get install -y gnupg gcc make wget; echo "deb http://apt.llvm.org/buster/ llvm-toolchain-buster-9 main" >> /etc/apt/sources.list && apt-key adv --keyserver hkps://keyserver.ubuntu.com --recv-keys 15CF4D18AF4F7421 && \
    DEBIAN_FRONTEND=noninteractive apt-get update -y && apt-get install -y --no-install-recommends libelf-dev llvm-9-dev clang-9 && \
    (for tool in "clang" "llc" "llvm-strip"; do path=$(which $tool-9) && ln -s $path ${path%-*}; done)

COPY entrypoint.sh /entrypoint.sh
COPY cleanup.sh /cleanup.sh

COPY ocihookgadget/runc-hook-prestart.sh /bin/runc-hook-prestart.sh
COPY ocihookgadget/runc-hook-poststop.sh /bin/runc-hook-poststop.sh
COPY bin/ocihookgadget /bin/ocihookgadget

COPY bin/gadgettracermanager /bin/gadgettracermanager

COPY gadgets/bcck8s /opt/bcck8s
COPY bin/networkpolicyadvisor /bin/networkpolicyadvisor

COPY bin/runchooks.so /opt/runchooks/runchooks.so
COPY runchooks/add-hooks.jq /opt/runchooks/add-hooks.jq

COPY crio-hooks/gadget-prestart.json /opt/crio-hooks/gadget-prestart.json
COPY crio-hooks/gadget-poststop.json /opt/crio-hooks/gadget-poststop.json

COPY bin/traceloop /bin/traceloop
