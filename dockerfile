FROM  alpine:edge

RUN apk update
RUN mkdir /run/openrc
RUN touch /run/openrc/softlevel

COPY start_haproxy_openvpn /start_haproxy_openvpn

RUN chmod +x /start_haproxy_openvpn

RUN addgroup -S haproxy && adduser -S haproxy -G haproxy
RUN addgroup -S openvpn && adduser -S openvpn -G openvpn

RUN touch /var/log/openvpn.log

RUN apk add --no-cache --update \
linux-headers

RUN apk add --no-cache bash openssl openrc build-base
RUN apk add openvpn haproxy

RUN rc-update add haproxy default
RUN rc-update add openvpn default

VOLUME ["/etc/openvpn"]
VOLUME ["/etc/haproxy"]

# forward request and error logs to docker log collector
RUN ln -sf /dev/stdout /var/log/openvpn.log \
	&& ln -sf /dev/stderr /var/log/openvpn.log

EXPOSE 8404
EXPOSE 8482

COPY  opt/sysctl.conf /etc/sysctl.conf
COPY  opt/limits.conf /etc/security/limits.conf

STOPSIGNAL  SIGQUIT

CMD ["/start_haproxy_openvpn"]
