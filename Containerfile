ARG LT_VER=5.5
FROM registry.access.redhat.com/ubi8/ubi-minimal as stage1
ARG LT_VER

RUN microdnf -y install git maven unzip nginx java-1.8.0-openjdk-headless; microdnf clean all; 
RUN git clone --depth 1 https://github.com/languagetool-org/languagetool.git -b v${LT_VER} /opt/languagetool/
WORKDIR /opt/languagetool/
#RUN ./build.sh languagetool-standalone package -DskipTests
# Don't use the shell script, just run the maven command with quiet to silence the wall of text
RUN mvn -q --projects languagetool-standalone --also-make package -DskipTests

FROM registry.access.redhat.com/redhat-openjdk-18/openjdk18-openshift as stage2
ARG LT_VER

COPY --from=stage1 /opt/languagetool/languagetool-standalone/target/LanguageTool-${LT_VER}/LanguageTool-${LT_VER}/ /opt/languagetool/
ADD --chmod=755 startup.sh /opt/languagetool/startup.sh

EXPOSE 8080/tcp
CMD /opt/languagetool/startup.sh

