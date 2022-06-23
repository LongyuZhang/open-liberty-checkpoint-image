FROM open-liberty:beta-checkpoint-ubi

ARG VERBOSE=false

COPY --chown=1001:0 src/main/liberty/config/server.xml /config/server.xml
COPY --chown=1001:0 target/guide-rest-intro.war /config/apps/guide-rest-intro.war

RUN configure.sh

