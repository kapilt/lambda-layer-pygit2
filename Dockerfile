FROM amazonlinux:latest

ARG libgit2_version=0.27.7

RUN yum install -y python3-pip python3-devel gcc cmake tar gzip make openssl-devel

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
RUN LIBGIT2=/opt LD_RUN_PATH=/opt/lib pip3 install --prefix=/opt pygit2 && \
    mkdir /opt/python && \
    mv /opt/lib64 /opt/python/lib 

# Build Layer
RUN cd /opt/ && \
    zip /layer.zip -r lib python
    

    
    



