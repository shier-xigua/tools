FROM alpine:3.19
LABEL maintainer="linzheng"
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.tuna.tsinghua.edu.cn/g' /etc/apk/repositories && \
    apk update && \
    apk add  --no-cache openrc docker git curl tar gcc g++ make \
    bash shadow openjdk17 py-pip python3-dev openssl-dev libffi-dev \
    libstdc++ harfbuzz nss freetype ttf-freefont && \
    mkdir -p /root/.kube && \
    usermod -a -G docker root
RUN rm -rf /var/cache/apk/* 
COPY kubectl /usr/local/bin
RUN chmod +x /usr/local/bin/kubectl 

