FROM frostlab/cougars:vehicle

ARG LABNAME=frostlab
ARG DEBIAN_FRONTEND=noninteractive
# Install development dependencies (rqt, plotjuggler, documentation, etc.)
USER root
RUN apt update && apt install -y \
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
    ros-humble-rviz2 \
    python3-rosdoc2 \
    libxcb-cursor0 \
    fonts-noto-color-emoji \
    iputils-ping \
    ros-$ROS_DISTRO-mapviz \
    ros-$ROS_DISTRO-mapviz-plugins \
    ros-$ROS_DISTRO-tile-map \
    ros-$ROS_DISTRO-multires-image \
    ros-$ROS_DISTRO-plotjuggler-ros \
    && apt update && apt upgrade -y && apt clean \
    && rm -rf /var/lib/apt/lists/*
    
    
# Install development Python dependencies
RUN pip3 install --no-cache-dir \
    PyQt6 \
    graphviz \
    transforms3d \
    tkintermapview \
    paramiko \
    digi-xbee \
    pathlib


USER ${LABNAME}