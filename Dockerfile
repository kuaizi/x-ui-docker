FROM golang:latest AS builder
WORKDIR /root
COPY . .
#RUN go build main.go 
RUN last_version=$(curl -Ls "https://api.github.com/repos/FranzKafkaYu/x-ui/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/') \
    && wget -N --no-check-certificate -O /tmp/x-ui-linux-amd64.tar.gz https://github.com/FranzKafkaYu/x-ui/releases/download/${last_version}/x-ui-linux-amd64.tar.gz \
    && tar zxvf /tmp/x-ui-linux-amd64.tar.gz -C /tmp \
    && cp -r /tmp/x-ui/* ./ \
    && chmod +x x-ui bin/xray-linux-amd64


FROM debian:11-slim
RUN apt-get update && apt-get install -y --no-install-recommends -y ca-certificates \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
WORKDIR /root
COPY --from=builder  /root/x-ui /root/x-ui
COPY bin/. /root/bin/.
VOLUME [ "/etc/x-ui" ]
CMD [ "./x-ui" ]
