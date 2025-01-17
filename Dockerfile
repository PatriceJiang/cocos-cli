FROM ubuntu:latest

ARG DEBIAN_FRONTEND=noninteractive

ENV TZ=Asia/Shanghai
ENV ANDROID_NDK_HOME /opt/android-ndk
ENV ANDROID_NDK_VERSION r21
ENV PATH ${PATH}:${ANDROID_NDK_HOME}
ENV ANDROID_SDK /opt/android-sdk
# ENV JAVA_HOME /opt/jvm/jdk-10.0.2

STOPSIGNAL SIGTERM

VOLUME ["/data"]

# ------------------------------------------------------
# --- Install required tools

RUN apt-get update 
# install python
RUN apt-get install -y python3 python3-pip wget unzip git ninja-build cmake llvm clang
RUN python3 -m pip install Cheetah3 PyYaml
RUN apt-get clean
# ------------------------------------------------------
# --- Android NDK

# download
RUN mkdir /opt/android-ndk-tmp && \
    cd /opt/android-ndk-tmp && \
    wget -q https://dl.google.com/android/repository/android-ndk-${ANDROID_NDK_VERSION}-linux-x86_64.zip && \
# uncompress
    unzip -q android-ndk-${ANDROID_NDK_VERSION}-linux-x86_64.zip && \
# move to its final location
    mv ./android-ndk-${ANDROID_NDK_VERSION} ${ANDROID_NDK_HOME} && \
# remove temp dir
    cd ${ANDROID_NDK_HOME} && \
    rm -rf /opt/android-ndk-tmp

# --- Oracle JDK 11

# RUN mkdir -p /opt/java-tmp 
# COPY jdk-11.0.11_linux-x64_bin.deb /opt/java-tmp
# RUN apt install -y alsa-topology-conf alsa-ucm-conf libasound2 libasound2-data
# RUN cd /opt/java-tmp  && \
#     dpkg -i jdk-11.0.11_linux-x64_bin.deb       && \
#     apt --fix-broken install -y                 && \
#     cd /opt                                     && \
#     rm -rf /opt/java-tmp

# ENV JAVA_HOME /usr/lib/jvm/jdk-11.0.11
# ENV PATH ${JAVA_HOME}/bin:${PATH}

# ---- openjdk ----
RUN mkdir /opt/java-tmp && \
    mkdir /opt/jvm && \
    cd /opt/java-tmp && \
    wget https://download.java.net/java/GA/jdk16.0.1/7147401fd7354114ac51ef3e1328291f/9/GPL/openjdk-16.0.1_linux-x64_bin.tar.gz -O openjdk.tar.gz && \
    tar xfv openjdk.tar.gz --directory /opt/jvm && \
    cd /opt && \
    rm -rf /opt/java-tmp

ENV JAVA_HOME /opt/jvm/jdk-16.0.1
ENV PATH ${JAVA_HOME}/bin:${PATH}

# --- Android SDK

RUN mkdir /opt/android-sdk-tmp && \
    cd /opt/android-sdk-tmp && \
    wget -t 5 -q https://dl.google.com/android/repository/commandlinetools-linux-6200805_latest.zip  && \
    unzip *.zip && \
    yes | ./tools/bin/sdkmanager  --sdk_root="$ANDROID_SDK" \
            "platforms;android-27" \
            "build-tools;28.0.3" \
            "platform-tools" \
            "tools"  \
            "cmake;3.10.2.4988404" && \
   cd /opt && rm -rf /opt/android-sdk-tmp



WORKDIR /data
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3 1

# RUN apt install -y 

RUN apt clean
CMD python -v