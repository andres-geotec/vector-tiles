FROM osgeo/gdal:alpine-small-3.6.3

RUN apk add --no-cache bash python3 py3-pip postgresql-client \
  && pip3 install --no-cache-dir gdown

WORKDIR /work
COPY import.sh /work/import.sh
RUN chmod +x /work/import.sh

ENTRYPOINT ["/work/import.sh"]
