# -------------------------
# Stage 1: Builder
# -------------------------
FROM frostlab/cougars:base_station AS builder

ARG LABNAME=frostlab
WORKDIR /home/${LABNAME}

# Install build tools
RUN pip3 install vcstool --no-cache-dir

# Copy vcs files only (needed for build)
COPY ./.vcs ./.vcs

# Create workspaces
RUN mkdir -p ros2_ws/src

# Import ROS2 packages
RUN vcs import < .vcs/cougars_ros2_https.repos ros2_ws/src
WORKDIR /home/${LABNAME}/ros2_ws/src/dvl-a50
RUN git submodule update --init --recursive

WORKDIR /home/${LABNAME}
RUN vcs import < .vcs/dev_https.repos

# Build ROS2 workspace
WORKDIR /home/${LABNAME}/ros2_ws
RUN bash -c "source /opt/ros/humble/setup.bash && colcon build"

# Build base_station inside the same workspace and overlay into ros2_ws/install
WORKDIR /home/${LABNAME}/base_station/base-station-ros2
RUN bash -c "source /opt/ros/humble/setup.bash && source /home/${LABNAME}/ros2_ws/install/setup.bash && colcon build --install-base /home/${LABNAME}/ros2_ws/install"

# -------------------------
# Stage 2: Runtime
# -------------------------
FROM frostlab/cougars:base_station

ARG LABNAME=frostlab
WORKDIR /home/${LABNAME}

# Copy runtime scripts and entrypoint
COPY ./docker/base_station/entrypoint.sh ./entrypoint.sh
COPY ./scripts/ ./scripts/

# Copy base station files over from builder
COPY --from=builder /home/${LABNAME}/base_station/scripts ./base_station/scripts
COPY --from=builder /home/${LABNAME}/base_station/images ./base_station/images

# Copy only built workspaces from builder
COPY --from=builder /home/${LABNAME}/ros2_ws/install ./ros2_ws/install

# Set entrypoint
ENTRYPOINT ["/home/${LABNAME}/entrypoint.sh"]