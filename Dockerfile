FROM ppc64le/centos:7

# runtime support to enable npm build capabilities
RUN yum -y install libstdc++ make gcc-c++ numactl-devel

# XLC runtime support - required by ibm_db node package
RUN curl -sL http://public.dhe.ibm.com/software/server/POWER/Linux/xl-compiler/eval/ppc64le/rhel7/libm-xl-compiler-eval.repo > /etc/yum.repos.d/xl-compilers.repo \
        && yum -y install libxlc
        
#install most up-to-date LTS node for ppc64le
RUN cd /usr/local \
        && curl -sL https://nodejs.org/dist/v8.16.1/node-v8.16.1-linux-ppc64le.tar.xz > node-v8.16.1-linux-ppc64le.tar.xz \
        && tar --strip-components 1 -xf node-v8.16.1-linux-ppc64le.tar.xz
        
# Add node-red user so we aren't running as root.
RUN mkdir /data
RUN adduser --home-dir /usr/src/node-red -U node-red \
    && chown -R node-red:node-red /data \
    && chown -R node-red:node-red /usr/src/node-red
USER node-red
WORKDIR /usr/src/node-red

# Db2 client support 
RUN npm install ibm_db

# install local node-red
RUN npm install --unsafe-perm node-red

#install Watson service nodes and dashdb clinet for Db2
RUN npm install node-red-node-watson \
        node-red-nodes-cf-sqldb-dashdb
        
# User configuration directory volume instead of ~/.node-red
VOLUME ["/data"]

# default tcp port for node-red
EXPOSE 1880

# Environment variable holding file path for flows configuration
ENV FLOWS=flows.json

CMD ["node", "./node_modules/node-red/red.js", "--userDir", "/data"]
