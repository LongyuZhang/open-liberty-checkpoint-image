FROM open-liberty:beta-checkpoint-ubi

ARG VERBOSE=false

COPY --chown=1001:0 server.xml /config/server.xml
COPY --chown=1001:0 pingperf.war /config/dropins/pingperf.war

RUN configure.sh

