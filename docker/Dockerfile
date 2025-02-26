# Created by Nelson Durrant, Sep 2024
#
# DOCKER FILE FOR BOTH VEHICLE AND DEVELOPMENT IMAGES
# - The cloud-hosted images will rebuild each time you push changes to this file
# - This Dockerfile will check the architecture of the target device and build the appropriate image

FROM ubuntu:22.04

ARG LABNAME=frostlab
ARG DEBIAN_FRONTEND=noninteractive
ARG TARGETARCH

# Update and upgrade
RUN apt update && apt upgrade -y

# Add tytools (as root)
RUN mkdir -p -m0755 /etc/apt/keyrings
RUN apt update && apt install -y \
    curl \
    wget \
    unzip
RUN curl https://download.koromix.dev/debian/koromix-archive-keyring.gpg -o /etc/apt/keyrings/koromix-archive-keyring.gpg
RUN echo "deb [signed-by=/etc/apt/keyrings/koromix-archive-keyring.gpg] https://download.koromix.dev/debian stable main" > /etc/apt/sources.list.d/koromix.dev-stable.list
RUN apt update && apt install -y tytools

# Set up a new user
RUN useradd -ms /bin/bash ${LABNAME}
RUN usermod -aG sudo ${LABNAME}
RUN usermod -aG dialout ${LABNAME}
RUN echo "${LABNAME}:${LABNAME}" | chpasswd
USER ${LABNAME}
WORKDIR /home/${LABNAME}

# Install ROS 2
USER root
RUN apt update && apt install -y \
    build-essential \
    git \
    locales \
    software-properties-common
RUN locale-gen en_US en_US.UTF-8
RUN update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
USER ${LABNAME}

RUN export LANG=en_US.UTF-8

USER root
RUN add-apt-repository universe
RUN apt update
RUN curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg
RUN echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(. /etc/os-release && echo $UBUNTU_CODENAME) main" | tee /etc/apt/sources.list.d/ros2.list > /dev/null
RUN apt update && apt upgrade -y
RUN apt install -y ros-humble-ros-base
USER ${LABNAME}

# Build and install gtsam (from source)
USER root
RUN apt update && apt install -y \
    libboost-all-dev \
    python3-pip
USER ${LABNAME}

RUN git clone --depth 1 --branch 4.2 https://github.com/borglab/gtsam.git
RUN mkdir /home/${LABNAME}/gtsam/build

WORKDIR /home/${LABNAME}/gtsam/build
RUN cmake .. -DGTSAM_BUILD_PYTHON=ON -DGTSAM_PYTHON_VERSION=3.10.12
RUN make python-install
WORKDIR /home/${LABNAME}

# Install Eigen
RUN wget -O Eigen.zip https://gitlab.com/libeigen/eigen/-/archive/3.4.0/eigen-3.4.0.zip
RUN unzip Eigen.zip

USER root
RUN cp -r eigen-3.4.0/Eigen /usr/local/include
RUN rm -r eigen-3.4.0
USER ${LABNAME}

RUN rm Eigen.zip

# Install PlatformIO
USER root
RUN apt install -y python3-venv
USER ${LABNAME}

RUN curl -fsSL -o get-platformio.py https://raw.githubusercontent.com/platformio/platformio-core-installer/master/get-platformio.py
RUN python3 get-platformio.py
RUN rm get-platformio.py

# Set up PlatformIO shell commands
RUN mkdir -p /usr/local/bin

USER root
RUN ln -s /home/${LABNAME}/.platformio/penv/bin/platformio /usr/local/bin/platformio
RUN ln -s /home/${LABNAME}/.platformio/penv/bin/pio /usr/local/bin/pio
RUN ln -s /home/${LABNAME}/.platformio/penv/bin/piodebuggdb /usr/local/bin/piodebuggdb
USER ${LABNAME}

# Set up ROS sourcing
RUN echo "source /opt/ros/humble/setup.bash" >> /home/${LABNAME}/.bashrc

# Install the micro-ROS agent
RUN mkdir microros_ws

USER root
RUN apt-get install -y python3-rosdep
RUN rosdep init
RUN rosdep fix-permissions
USER ${LABNAME}

WORKDIR /home/${LABNAME}/microros_ws
RUN git clone -b humble https://github.com/micro-ROS/micro_ros_setup.git src/micro_ros_setup

USER root
RUN rosdep update
RUN rosdep install --from-paths src --ignore-src --rosdistro humble -y
RUN apt install -y python3-colcon-common-extensions
USER ${LABNAME}

SHELL ["/bin/bash", "-c"] 
RUN rosdep update
RUN source /opt/ros/humble/setup.bash && colcon build
RUN source /opt/ros/humble/setup.bash && source install/setup.bash && ros2 run micro_ros_setup create_agent_ws.sh
RUN source /opt/ros/humble/setup.bash && source install/setup.bash && ros2 run micro_ros_setup build_agent.sh
SHELL ["/bin/sh", "-c"]

WORKDIR /home/${LABNAME}

# Install MOOS-IvP
USER root
RUN apt install -y cmake \
    xterm \
    subversion \
    libfltk1.3-dev \
    libtiff5-dev
USER ${LABNAME}

ARG SVN_REV=HEAD
ENV LC_CTYPE="C.UTF-8"
RUN svn co https://oceanai.mit.edu/svn/moos-ivp-aro/trunk moos-ivp

WORKDIR /home/${LABNAME}/moos-ivp
RUN ./build-moos.sh
RUN ./build-ivp.sh
WORKDIR /home/${LABNAME}

# Install development dependencies (rqt, plotjuggler, documentation, etc.)
USER root
RUN if [ "$TARGETARCH" = "amd64" ]; then \
    apt update && apt install -y \
    libx11-dev \
    libxext-dev \
    libxrender-dev \
    libxrandr-dev \
    qtbase5-dev \
    libqt5x11extras5 \
    python3-gi \
    gir1.2-gtk-3.0 \
    x11-apps \
    ros-humble-rqt* \
    ros-humble-plotjuggler-ros \
    python3-rosdoc2 \
    && apt clean \
    && rm -rf /var/lib/apt/lists/*; \
    fi
USER ${LABNAME}

# Install development Python dependencies
RUN if [ "$TARGETARCH" = "amd64" ]; then \
    pip3 install --no-cache-dir PyQt5; \
    fi

# Install dependencies
USER root
RUN apt update && apt install -y \
    vim \
    psmisc \
    network-manager \
    systemd \
    libgps-dev \
    python3-libgpiod \
    ros-humble-rosbag2-storage-mcap \
    netcat-openbsd \
    rsync \
    libserialport-dev \ 
    gpsd-clients
USER ${LABNAME}

# Install Python dependencies
RUN pip3 install numpy==1.24.0 \
    scipy \
    matplotlib \
    pyproj \
    pymavlink \
    ruamel
RUN echo "export PATH=$PATH:/home/${LABNAME}/.local/bin:/home/${LABNAME}/moos-ivp/bin" >> /home/${LABNAME}/.bashrc

# Update and upgrade
USER root
RUN apt update && apt upgrade -y
USER ${LABNAME}

# Set up bash variable sourcing (Make sure this exists as a volume when you run the container!)
RUN echo "source /home/${LABNAME}/config/bash_vars.sh" >> ~/.bashrc
