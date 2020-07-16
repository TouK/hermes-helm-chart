FROM openjdk:12 AS build
ARG REPO="https://github.com/allegro/hermes.git"
ARG BRANCH=master
RUN yum install -y -q git wget && rm -r /var/cache/yum/*
RUN git clone --branch "$BRANCH" "$REPO"
WORKDIR hermes
RUN ./gradlew distTar -Pdistribution -x test && find -iname *.tar -exec gzip {} \;

FROM openjdk:12-alpine as consumers
RUN apk update && apk add bash unzip && rm -r /var/cache/apk/*
COPY --from=build /hermes/hermes-consumers/build/distributions/* .
RUN mkdir -p /opt/hermes-consumers && tar -xf *.tar.gz --strip-components 1 -C /opt/hermes-consumers
CMD /opt/hermes-consumers/bin/hermes-consumers
