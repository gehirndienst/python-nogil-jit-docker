# build: docker build -t python-nogil-jit:3.13.0rc2 .
# run: docker run -it --rm --name python-nogil-test python-nogil-jit:3.13.0rc2 bash -c "cd /home && python test.py && python -X gil=1 test.py && exec bash"

FROM debian:bookworm-slim

ARG PYTHON_VERSION=3.13.0rc2

ENV PATH=/usr/local/bin:${PATH}

WORKDIR /root/

RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
    ca-certificates \
    netbase \
    python3 \
    curl \
    tzdata

RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
    dpkg-dev \
    gcc \
    git \
    gnupg \
    libbluetooth-dev \
    libbz2-dev \
    libc6-dev \
    libdb-dev \
    libexpat1-dev \
    libffi-dev \
    libgdbm-dev \
    liblzma-dev \
    libncursesw5-dev \
    libreadline-dev \
    libsqlite3-dev \
    libssl-dev \
    lsb-release \
    make \
    software-properties-common \
    tk-dev \
    uuid-dev \
    wget \
    xz-utils \
    zlib1g-dev

# clang18 is needed for jit
RUN set -eux; \
    wget -O - https://apt.llvm.org/llvm.sh | bash -; \
    apt-get update; \
    apt-get install -y --no-install-recommends clang llvm

RUN git clone --depth=1 https://github.com/pyenv/pyenv.git .pyenv
ENV PYENV_ROOT="/root/.pyenv"
ENV PATH="${PYENV_ROOT}/shims:${PYENV_ROOT}/bin:${PATH}"

# ok here we go
ENV PYTHON_CONFIGURE_OPTS="--disable-gil --enable-experimental-jit --enable-loadable-sqlite-extensions --enable-optimizations --enable-option-checking=fatal --enable-shared --with-lto --with-system-expat --without-ensurepip"
ENV PYTHON_CFLAGS="-march=native -mtune=native"
RUN pyenv install --verbose ${PYTHON_VERSION} && pyenv global ${PYTHON_VERSION}

RUN wget https://bootstrap.pypa.io/get-pip.py && \
    python3 get-pip.py && \
    rm get-pip.py

COPY ./test.py /home/test.py

RUN apt-get clean && apt-get autoclean && apt-get autoremove && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

