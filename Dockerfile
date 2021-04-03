FROM alpine:3.12
LABEL maintainer="avpnusr"

EXPOSE 4040

RUN apk update --no-cache && apk upgrade -a --no-cache && apk --update --no-cache add openjdk8-jre-base flac lame curl wget vim ffmpeg \
&& mkdir -p /opt/subsonic /var/subsonic/transcode \
&& addgroup -S subsonic \
&& adduser -S subsonic -G subsonic \
&& chown -R subsonic:subsonic /opt/subsonic /var/subsonic /var/subsonic/* \
&& echo "## Downloading subsonic standalone installer ##" \
&& INTLINK=$(curl -s "http://www.subsonic.org/pages/download.jsp" | grep -E "standalone.*tar.gz" | grep -E "standalone.*.tar.gz" | awk -F '"' '{print $2}') \
&& curl -s  $(curl -s "http://www.subsonic.org/pages/$INTLINK" | grep -E "href.*tar.gz" | awk -F 'href="' '{print $2}' | awk -F '">' '{print $1}' ) > /opt/subsonic/sub.tar.gz \
&& cd /opt/subsonic && ln -s "$(which ffmpeg)" && tar -xzf sub.tar.gz && rm -f sub.tar.gz \
&& sed -i '/subsonic-booter-jar-with-dependencies.jar/c\  -jar subsonic-booter-jar-with-dependencies.jar' /opt/subsonic/subsonic.sh

HEALTHCHECK --interval=120s --timeout=15s --start-period=240s --retries=3 \
            CMD curl --fail -k -sS 'http://localhost:4040' && echo "SubSonic is healthy..." || exit 1

USER subsonic

VOLUME ["/music", "/var/subsonic"]

CMD [ "/opt/subsonic/subsonic.sh" ]
