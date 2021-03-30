FROM amazonlinux:latest

ARG libgit2_version=1.1.0
ARG pygit2_version=1.5.0
ARG libssh2_version=1.9.0
ARG libssh2_daily=20210330
ARG cmake_version=3.20.0

RUN yum install -y python3-pip python3-devel gcc cmake tar gzip make openssl-devel gcc-c++

# Build cmake libgit2 wants 3+ and amazonlinux be ancient
RUN curl -L --output cmake.tgz https://github.com/Kitware/CMake/releases/download/v${cmake_version}/cmake-${cmake_version}.tar.gz && \
    tar xzvf cmake.tgz && \
    cd cmake-${cmake_version} && \
    ./bootstrap --parallel=4 && make && make install


# Build libssh2 (1.9 amazonlinux ships 1.4) we want latest for ed25519 key support
RUN curl -L --output libssh2.tgz https://www.libssh2.org/snapshots/libssh2-${libssh2_version}-${libssh2_daily}.tar.gz && \
    tar xzvf libssh2.tgz && \
    cd libssh2-${libssh2_version}-${libssh2_daily} && \
    ./configure --prefix=/opt && \
    make && \
    make install

# Build LibGit2
RUN curl -L --output libgit2.tgz  https://github.com/libgit2/libgit2/archive/v${libgit2_version}.tar.gz && \
    tar xzvf libgit2.tgz  && \
    cd libgit2-${libgit2_version} && \
    mkdir build && cd build && \
    cmake -DTHREADSAFE=true -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/opt .. && \
    cmake --build . && \
    cmake --build . --target install && \
    echo "/opt/lib" >> /etc/ld.so.conf.d/libgit2.conf && \
    ldconfig -v

# Build Python Extension
# LD_RUN_PATH lets us bake the lib path into the ext to avoid setting ld lib path at runtime.
# Unfortunately for cffi and pygit2 to find libgit, we'll still need LIBGIT2 env var.
RUN LIBGIT2=/opt LD_RUN_PATH=/opt/lib pip3 install --prefix=/opt pygit2==${pygit2_version}


# Assemble Layer
RUN cd /opt/ && \
    mkdir /opt/python && \
    mv /opt/lib64 /opt/python/lib && \
    mv /opt/lib/python3.7/site-packages/* /opt/python/lib/python3.7/site-packages && \
    rm -Rf lib/python3.7 && \
    mkdir /output && \
    # pycache gen for py3.7 \
    LIBGIT2=/opt/ PYTHONPATH=/opt/python/lib/python3.7/site-packages python3 -c "import pygit2" && \
    zip /layer.zip -r include lib python
    

    
    



