FROM ubuntu:16.04

# Install build tools
RUN apt-get update && apt-get install -y build-essential curl unzip software-properties-common

# Install required dependencies for mxnet
# OpenBLAS and OpenCV
# RUN apt-get install -y libopenblas-dev liblapack-dev libopencv-dev

# Install Java.
RUN \
  echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | debconf-set-selections && \
  add-apt-repository -y ppa:webupd8team/java && \
  apt-get update && \
  apt-get install -y oracle-java8-installer && \
  rm -rf /var/lib/apt/lists/* && \
  rm -rf /var/cache/oracle-jdk8-installer

# Define commonly used JAVA_HOME variable
ENV JAVA_HOME /usr/lib/jvm/java-8-oracle

# Install Android SDK
ENV ANDROID_HOME /android-sdk-linux
ENV ANDROID_SDK  /android-sdk-linux
ENV ANDROID_SDK_MANAGER /android-sdk-linux/tools/bin/sdkmanager

ENV ANDROID_SDK_VERSION r25.2.3
ENV ANDROID_SDK_URL https://dl.google.com/android/repository/tools_${ANDROID_SDK_VERSION}-linux.zip
RUN curl -sSL "${ANDROID_SDK_URL}" -o tools_${ANDROID_SDK_VERSION}-linux.zip \
    && unzip tools_${ANDROID_SDK_VERSION}-linux.zip -d ${ANDROID_HOME} \
  && rm -rf tools_${ANDROID_SDK_VERSION}-linux.zip
  
ENV PATH ${ANDROID_HOME}/tools:${ANDROID_HOME}/tools/bin:$ANDROID_HOME/platform-tools:$PATH

# Install Android SDK Components
ENV ANDROID_COMPONENTS "tools" \
                       "platform-tools" \
                       "build-tools;23.0.3" \
                       "platforms;android-23" 

ENV GOOGLE_COMPONENTS "extras;android;m2repository" \
                       "extras;google;m2repository" \
                       "extras;google;google_play_services" 
                       
ENV CONSTRAINT_LAYOUT "extras;m2repository;com;android;support;constraint;constraint-layout;1.0.2"\
                       "extras;m2repository;com;android;support;constraint;constraint-layout-solver;1.0.2"

RUN mkdir -p ${ANDROID_HOME}/licenses/ && \
    echo "8933bad161af4178b1185d1a37fbf41ea5269c55" > ${ANDROID_HOME}/licenses/android-sdk-license && \
    echo "84831b9409646a918e30573bab4c9c91346d8abd" > ${ANDROID_HOME}/licenses/android-sdk-preview-license && \
    ${ANDROID_SDK_MANAGER}  ${ANDROID_COMPONENTS} \
                            ${GOOGLE_COMPONENTS} \
							${CONSTRAINT_LAYOUT} 

# Install Android NDK Components
ENV ANDROID_NDK_COMPONENTS "ndk-bundle" \
                       "lldb" \
                       "cmake"
                       
RUN ${ANDROID_SDK_MANAGER} ${ANDROID_NDK_COMPONENTS}  

ENV ANDROID_NDK_HOME ${ANDROID_SDK}/ndk-bundle
ENV PATH ${ANDROID_NDK_HOME}:$PATH

# Create ARM toolchain
RUN $ANDROID_NDK_HOME/build/tools/make_standalone_toolchain.py \
	--arch aarch64 --api 23 --stl=libc++ -latomic --install-dir /ndk-toolchain-aarch64-api23