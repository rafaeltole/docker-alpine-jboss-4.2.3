FROM alpine:3.6

# Here we install GNU libc (aka glibc) and set C.UTF-8 locale as default. Credits by Vlad Frolov (https://github.com/frol/docker-alpine-glibc) 
RUN ALPINE_GLIBC_BASE_URL="https://github.com/sgerrand/alpine-pkg-glibc/releases/download" && \
    ALPINE_GLIBC_PACKAGE_VERSION="2.25-r0" && \
    ALPINE_GLIBC_BASE_PACKAGE_FILENAME="glibc-$ALPINE_GLIBC_PACKAGE_VERSION.apk" && \
    ALPINE_GLIBC_BIN_PACKAGE_FILENAME="glibc-bin-$ALPINE_GLIBC_PACKAGE_VERSION.apk" && \
    ALPINE_GLIBC_I18N_PACKAGE_FILENAME="glibc-i18n-$ALPINE_GLIBC_PACKAGE_VERSION.apk" && \
    apk add --no-cache --virtual=.build-dependencies wget ca-certificates && \
    wget \
        "https://raw.githubusercontent.com/andyshinn/alpine-pkg-glibc/master/sgerrand.rsa.pub" \
        -O "/etc/apk/keys/sgerrand.rsa.pub" && \
    wget \
        "$ALPINE_GLIBC_BASE_URL/$ALPINE_GLIBC_PACKAGE_VERSION/$ALPINE_GLIBC_BASE_PACKAGE_FILENAME" \
        "$ALPINE_GLIBC_BASE_URL/$ALPINE_GLIBC_PACKAGE_VERSION/$ALPINE_GLIBC_BIN_PACKAGE_FILENAME" \
        "$ALPINE_GLIBC_BASE_URL/$ALPINE_GLIBC_PACKAGE_VERSION/$ALPINE_GLIBC_I18N_PACKAGE_FILENAME" && \
    apk add --no-cache \
        "$ALPINE_GLIBC_BASE_PACKAGE_FILENAME" \
        "$ALPINE_GLIBC_BIN_PACKAGE_FILENAME" \
        "$ALPINE_GLIBC_I18N_PACKAGE_FILENAME" && \
    \
    rm "/etc/apk/keys/sgerrand.rsa.pub" && \
    /usr/glibc-compat/bin/localedef --force --inputfile POSIX --charmap UTF-8 C.UTF-8 || true && \
    echo "export LANG=C.UTF-8" > /etc/profile.d/locale.sh && \
    \
    apk del glibc-i18n && \
    rm \
        "$ALPINE_GLIBC_BASE_PACKAGE_FILENAME" \
        "$ALPINE_GLIBC_BIN_PACKAGE_FILENAME" \
        "$ALPINE_GLIBC_I18N_PACKAGE_FILENAME"

# Here we config enviroment with JBoss-4.2.3
WORKDIR home/jboss

RUN wget \
        "https://www.dropbox.com/s/duq3iducq31ioso/jre-6u45-linux-x64.bin?dl=0" \
        -O "jre-6u45-linux-x64.bin" && \
    wget \
        "https://www.dropbox.com/s/2w8jjf2zi3jxx6w/jboss-4.2.3.GA.tar.gz?dl=0" \
        -O "jboss-4.2.3.GA.tar.gz" && \
    \
    sh jre-6u45-linux-x64.bin && \
    \
    tar -xvf "jboss-4.2.3.GA.tar.gz" && \ 
    \
    rm \
        "jre-6u45-linux-x64.bin" \
        "jboss-4.2.3.GA.tar.gz" \
        "/root/.wget-hsts" && \
    \
    apk del .build-dependencies

ENV LANG=C.UTF-8
ENV JAVA_HOME /home/jboss/jre1.6.0_45
ENV PATH $PATH:$JAVA_HOME/bin

ENV JBOSS_DEPLOY /home/jboss/jboss-4.2.3.GA/server/default/deploy

EXPOSE 8080

ENTRYPOINT ["jboss-4.2.3.GA/bin/run.sh", "-b", "0.0.0.0"]