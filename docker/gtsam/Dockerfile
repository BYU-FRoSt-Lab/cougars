FROM ros:humble-ros-base

ARG LABNAME=frostlab
ARG DEBIAN_FRONTEND=noninteractive
USER root

# Set up a new user
RUN useradd -ms /bin/bash ${LABNAME} \
    && usermod -aG sudo ${LABNAME} \
    && usermod -aG dialout ${LABNAME} \
    && echo "${LABNAME}:${LABNAME}" | chpasswd \
    && echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

RUN apt update && apt install -y \
    wget \
    unzip \
    build-essential \
    git \
    libboost-all-dev \
    cmake \
    python3-pip

RUN pip3 install pybind11_stubgen

# Install Eigen system-wide
RUN wget -O Eigen.zip https://gitlab.com/libeigen/eigen/-/archive/3.4.0/eigen-3.4.0.zip \
    && unzip Eigen.zip \
    && mv eigen-3.4.0/Eigen /usr/local/include \
    && rm -rf eigen-3.4.0 Eigen.zip
    
# INSTALL GTSAM
USER ${LABNAME}
WORKDIR /home/${LABNAME}/
RUN git clone --depth 1 https://github.com/borglab/gtsam.git && \
    mkdir /home/${LABNAME}/gtsam/build 
    

WORKDIR /home/${LABNAME}/gtsam/build
RUN cmake .. -DGTSAM_BUILD_PYTHON=ON -DGTSAM_PYTHON_VERSION=3.10.12 \
    && make -j"$(nproc)" python-install
