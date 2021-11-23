FROM registry.access.redhat.com/ubi8/ubi-init
ARG LT_VER=5.4
ENV DOMAIN=centosnas.lan

RUN dnf -y install git maven unzip nginx java-1.8.0-openjdk-headless; yum clean all;
RUN git clone --depth 1 https://github.com/languagetool-org/languagetool.git -b v${LT_VER} /opt/languagetool/
WORKDIR /opt/languagetool/
RUN ./build.sh languagetool-standalone package -DskipTests
RUN useradd -r languagetool
RUN printf "[Unit] \nDescription=Language Tool Server Service \n[Service] \nRestart=always \nExecStart=java -cp /opt/languagetool/languagetool-standalone/target/LanguageTool-${LT_VER}/LanguageTool-${LT_VER}/languagetool-server.jar org.languagetool.server.HTTPServer --languageModel /languagetool/ngram --port 8080 --allow-origin \"*\" \nType=simple \nUser=languagetool \n[Install] \nWantedBy=default.target" > /etc/systemd/system/languagetool.service
RUN mkdir /etc/systemd/system/nginx.service.d/; echo -e '[Service]\nRestart=always' > /etc/systemd/system/nginx.service.d/override.conf
RUN printf "server {\n    listen 80;\n    return 301 https://$host$request_uri;\n}\nserver {\n    listen 443;\n    server_name ${DOMAIN};\n    ssl_certificate           /languagetool/certs/cert.crt;\n    ssl_certificate_key       /languagetool/certs/cert.key;\n    ssl on;\n    ssl_session_cache  builtin:1000  shared:SSL:10m;\n    ssl_protocols TLSv1.3;\n    ssl_stapling on;\n    ssl_stapling_verify on;\n    ssl_prefer_server_ciphers off;\n    error_log /languagetool/error.log warn;\n    location / {\n      proxy_set_header        Host \$host;\n      proxy_set_header        X-Real-IP \$remote_addr;\n      proxy_set_header        X-Forwarded-For \$proxy_add_x_forwarded_for;\n      proxy_set_header        X-Forwarded-Proto \$scheme;\n      proxy_pass          http://localhost:8080;\n      proxy_read_timeout  90;\n      proxy_redirect      http://localhost:8080 https://${DOMAIN};\n    }\n}\n" > /etc/nginx/conf.d/languagetool.conf
RUN systemctl enable nginx.service languagetool.service
EXPOSE 443/tcp
RUN cat /etc/nginx/conf.d/languagetool.conf
RUN cat /etc/systemd/system/nginx.service.d/override.conf
RUN cat /etc/systemd/system/languagetool.service
CMD [ "/sbin/init" ]
