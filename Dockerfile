ARG L4T_BASE_VERSION=r32.5.0
FROM nvcr.io/nvidia/l4t-base:${L4T_BASE_VERSION}
ARG PROTOBUF_VERSION=3.17.3


#  1. for protobuf compile
#    autoconf automake libtool curl make g++ unzip cmake
#  2. for protobuf/python installation (need Python.h)
#    python3-dev
#  3. for pip3
#    python3-pip

RUN apt-get update \
 && apt-get upgrade -y \
 && apt-get install -y --no-install-recommends \
      autoconf automake libtool curl make g++ unzip cmake \
      python3-pip python3-dev \
 && apt-get clean \
 && rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/*

RUN pip3 install --upgrade pip setuptools

# compile protobuf and install python package from source.
# need this becase `pip install` gets a python (not cpp) implemented version of the package, which has a problem in performance.

WORKDIR /tmp

RUN wget https://github.com/protocolbuffers/protobuf/releases/download/v${PROTOBUF_VERSION}/protobuf-python-${PROTOBUF_VERSION}.tar.gz \
    && tar -zxvf protobuf-python-${PROTOBUF_VERSION}.tar.gz \
    && cd protobuf-${PROTOBUF_VERSION} \
    && ./configure --prefix=/usr \
    && make -j4 \
    && make install \
    && ldconfig \
    && cd python \
    && python3 setup.py build \
    && python3 setup.py install --cpp_implementation \
    && cd /tmp \
    && rm -rf protobuf-${PROTOBUF_VERSION} protobuf-python-${PROTOBUF_VERSION}.tar.gz

RUN pip3 install onnx
# workaround for https://github.com/numpy/numpy/issues/18131
ENV OPENBLAS_CORETYPE=ARMV8
