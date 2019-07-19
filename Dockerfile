FROM nginx:1.17-alpine

MAINTAINER Vlado Djerek <djerek.vlado@nsoft.com>

COPY nginx.conf.template nginx.conf.template
COPY start.sh start.sh
RUN apk update && apk add wget curl bash
CMD ["./start.sh"]