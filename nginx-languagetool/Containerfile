FROM registry.access.redhat.com/ubi8/ubi-init
ARG LT_VER=5.4
ENV DOMAIN=centosnas.lan

RUN dnf -y install git maven unzip nginx java-1.8.0-openjdk-headless; yum clean all; 
RUN git clone --depth 1 https://github.com/languagetool-org/languagetool.git -b v${LT_VER} /opt/languagetool/
WORKDIR /opt/languagetool/
RUN ./build.sh languagetool-standalone package -DskipTests
RUN useradd -r languagetool
RUN [ ! -d "/etc/systemd/system/nginx.service.d" ] && mkdir /etc/systemd/system/nginx.service.d; echo -e '[Service]\nRestart=always' > /etc/systemd/system/nginx.service.d/override.conf
COPY --chmod=644 ./languagetool.service /etc/systemd/system/languagetool.service
COPY --chmod=644 ./languagetool.conf /etc/nginx/conf.d/languagetool.conf
RUN systemctl enable nginx.service languagetool.service
EXPOSE 443/tcp
RUN cat /etc/nginx/conf.d/languagetool.conf
RUN cat /etc/systemd/system/nginx.service.d/override.conf
RUN cat /etc/systemd/system/languagetool.service
CMD [ "/sbin/init" ]
