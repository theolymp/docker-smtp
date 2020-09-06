FROM debian:buster

LABEL name="theolymp/docker-smtp" \
      maintainer="robin.parker@theolymp.net" \
      vendor="Namshi / the olymp" \
      version="1.0" \
      release="1" \
      summary="Exim4 Mailproxy via ENV (for OpenShift)" \
      description="Mailrelay/proxy via enviroment variables" \
      io.openshift.tags="sidecar,smtp,mail"

USER root

RUN apt-get update && \
    apt-get install -y exim4-daemon-light && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    find /var/log -type f | while read f; do echo -ne '' > $f; done;

COPY entrypoint.sh /bin/
COPY set-exim4-update-conf /bin/
COPY uid_entrypoint /bin/

RUN chmod -cfR u+x /etc/passwd /bin/ && \
    chgrp -R 0 /etc/passwd /bin/ /etc/exim4 /etc/passwd /var/lib/exim4/ && \
    chmod -cfR g=u /etc/passwd /bin/ /etc/exim4 /etc/passwd && \
    chmod -R 0777 /var/lib/exim4/ 

USER 1001


EXPOSE 25
ENTRYPOINT [ "/bin/uid_entrypoint" ]
CMD ["/bin/entrypoint.sh", "exim", "-bd", "-q15m", "-v"]