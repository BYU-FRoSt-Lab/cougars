# FROM ubuntu:22.04
# FROM ros:humble-ros-base
FROM frostlab/cougars:gtsam

ARG LABNAME=frostlab
ARG DEBIAN_FRONTEND=noninteractive

# TODO remove apt lists afer every RUN
# DO WE NEED THIS?
# RUN mkdir -p -m0755 /etc/apt/keyrings
USER root

# TEMP Workaround for libc-bin segfault in QEMU
RUN apt-get update && apt-get install -y --fix-missing libc-bin

# ty tools
RUN apt update && apt install -y \
    curl \
    locales \
    software-properties-common \
    python3-venv \
    vim \
    psmisc \
    network-manager \
    systemd \
    libgps-dev \
    python3-libgpiod \
    netcat-openbsd \
    rsync \
    libserialport-dev \
    gpsd-clients \
    tmux \
    ros-humble-gps-msgs \
    ros-humble-gpsd-client \
    ros-humble-gps-tools \ 
    ros-humble-diagnostics \
    && rm -rf /var/lib/apt/lists/*


# Install tytools for the teensy
RUN curl https://download.koromix.dev/debian/koromix-archive-keyring.gpg -o /etc/apt/keyrings/koromix-archive-keyring.gpg \
    && echo "deb [signed-by=/etc/apt/keyrings/koromix-archive-keyring.gpg] https://download.koromix.dev/debian stable main" > /etc/apt/sources.list.d/koromix.dev-stable.list \
    && apt update && apt install -y tytools


    # Install Python dependencies
RUN pip3 install numpy==1.24.0 \
    scipy \
    matplotlib \
    pyproj \
    pymavlink \
    ruamel.yaml \
    tmuxp 
    
    
USER ${LABNAME}
WORKDIR /home/${LABNAME}
# Install PlatformIO
RUN curl -fsSL -o get-platformio.py https://raw.githubusercontent.com/platformio/platformio-core-installer/master/get-platformio.py \
    && python3 get-platformio.py \
    && rm -f get-platformio.py \
    && mkdir -p /usr/local/bin

USER root
# Set up PlatformIO shell commands
RUN install -d /usr/local/bin && \
    ln -s /home/${LABNAME}/.platformio/penv/bin/platformio /usr/local/bin/platformio && \
    ln -s /home/${LABNAME}/.platformio/penv/bin/pio /usr/local/bin/pio && \
    ln -s /home/${LABNAME}/.platformio/penv/bin/piodebuggdb /usr/local/bin/piodebuggdb

USER ${LABNAME}

# Set up bash variable sourcing (Make sure this exists as a volume when you run the container!)
RUN echo "source /home/${LABNAME}/config/cougarsrc.sh" >> /home/${LABNAME}/.bashrc \
    && echo "source /opt/ros/humble/setup.bash" >> /home/${LABNAME}/.bashrc \
    && echo "export RCUTILS_COLORIZED_OUTPUT=1" >> /home/${LABNAME}/.bashrc \
    && touch /home/${LABNAME}/.hushlogin \
    && mkdir -p /home/${LABNAME}/.ssh \
    && chmod 700 /home/${LABNAME}/.ssh

USER ${LABNAME}
WORKDIR /home/${LABNAME}
