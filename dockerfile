FROM alpine:edge

RUN apk upgrade --update && \
	apk add --no-cache mongodb
VOLUME /data/db

USER mongodb
EXPOSE 27017
CMD [ "mongod", "--bind_ip_all", "--auth" ]