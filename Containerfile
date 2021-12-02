ARG LT_VER=5.5
FROM registry.access.redhat.com/ubi8/ubi-minimal as stage1
ARG LT_VER

RUN microdnf -y install git maven unzip nginx java-1.8.0-openjdk-headless; microdnf clean all; 
RUN git clone --depth 1 https://github.com/languagetool-org/languagetool.git -b v${LT_VER} /opt/languagetool/
WORKDIR /opt/languagetool/

# Don't use the shell script, just run the maven command with quiet to silence the wall of text
RUN mvn -q --projects languagetool-standalone --also-make package -DskipTests

FROM registry.hub.docker.com/library/openjdk:slim as stage2
ARG LT_VER

COPY --from=stage1 /opt/languagetool/languagetool-standalone/target/LanguageTool-${LT_VER}/LanguageTool-${LT_VER}/ /opt/languagetool/
ADD --chmod=755 startup.sh /opt/languagetool/startup.sh

# Install curl into image for health check
RUN apt-get update; apt-get install curl -y; apt-get clean
RUN useradd -r lang
USER lang

EXPOSE 8080/tcp
HEALTHCHECK --interval=5m --timeout=5s CMD curl -f http://localhost:8080/v2/languages || exit 1
CMD /opt/languagetool/startup.sh
