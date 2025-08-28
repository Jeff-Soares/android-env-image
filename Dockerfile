FROM ubuntu:24.04

ARG JDK_VERSION=17.0.16-zulu
ARG KOTLIN_VERSION=2.2.0
ARG ANDROID_SDK_VERSION=13114758
ARG NODE_VERSION=v22.18.0
ARG RUBY_VERSION=3.3.9

ENV DEBIAN_FRONTEND=noninteractive
ENV SDKMAN_DIR="/root/.sdkman"
ENV JAVA_HOME="/root/.sdkman/candidates/java/current"
ENV ANDROID_HOME="/opt/android-sdk"
ENV NVM_DIR="/root/.nvm"
ENV RBENV_ROOT="/usr/local/rbenv"

ENV PATH="$PATH:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools"
ENV PATH="$PATH:$NVM_DIR/versions/node/$NODE_VERSION/bin"
ENV PATH="$PATH:$RBENV_ROOT/bin:$RBENV_ROOT/shims"

RUN apt-get update && \
    apt-get install -y \
    git wget curl zip unzip ca-certificates \
    build-essential libssl-dev libyaml-dev libreadline-dev zlib1g-dev libffi-dev bison autoconf && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get clean && \
    apt-get autoclean

# SDKMAN - JAVA - KOTLIN
RUN curl -s "https://get.sdkman.io?ci=true" | bash && \
    bash -c "source $SDKMAN_DIR/bin/sdkman-init.sh && \
    sdk install java $JDK_VERSION && \
    sdk install kotlin $KOTLIN_VERSION && \
	sdk flush archives && \
	sdk flush temp"

# ANDROID SDK
RUN mkdir -p ${ANDROID_HOME}/cmdline-tools && \
    cd /tmp && \
    wget -q https://dl.google.com/android/repository/commandlinetools-linux-${ANDROID_SDK_VERSION}_latest.zip -O android-tools.zip && \
    unzip -q android-tools.zip -d ${ANDROID_HOME}/cmdline-tools && \
    mv ${ANDROID_HOME}/cmdline-tools/cmdline-tools ${ANDROID_HOME}/cmdline-tools/latest && \
    rm android-tools.zip && \
    yes | sdkmanager --licenses && \
    sdkmanager --install "platform-tools"

# NODE - need for execute actions
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.6/install.sh | bash && \
    . "$NVM_DIR/nvm.sh" && \
    nvm install $NODE_VERSION && \
    nvm alias default $NODE_VERSION && \
    nvm use default

# RUBY - need for fastlane tool
RUN git clone --depth 1 https://github.com/rbenv/rbenv.git $RBENV_ROOT && \
    git clone --depth 1 https://github.com/rbenv/ruby-build.git "$RBENV_ROOT/plugins/ruby-build" && \
    rbenv install $RUBY_VERSION && \
    rbenv global $RUBY_VERSION && \
    gem install --no-document bundler

WORKDIR /workspace

CMD ["/bin/bash"]
