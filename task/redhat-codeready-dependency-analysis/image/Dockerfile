FROM registry.access.redhat.com/ubi8/ubi

LABEL org.opencontainers.image.source https://github.com/fabric8-analytics/crda-images

RUN yum install -y maven golang npm python3; yum clean all && ln -s /usr/bin/python3 /usr/bin/python

RUN rpm -i https://github.com/fabric8-analytics/cli-tools/releases/download/v0.2.5/crda_0.2.5_Linux-64bit.rpm

RUN yum install jq -y

ENV AUTH_TOKEN=''
ENV CRDA_KEY=''
ENV HOST=''
ENV TELEMETRY=''

COPY image/crda.sh /
RUN chmod +x /crda.sh
