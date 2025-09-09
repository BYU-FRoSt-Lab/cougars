FROM frostlab/cougars:vehicle

ARG LABNAME=frostlab

WORKDIR /home/${LABNAME}
COPY ./docker/vehicle/entrypoint.sh /home/${LABNAME}/entrypoint.sh
COPY ./scripts/ /home/${LABNAME}/scripts/

RUN pip3 install vcstool --no-cache-dir

COPY ./.vcs /home/${LABNAME}/.vcs

RUN mkdir -p /home/${LABNAME}/ros2_ws/src 

RUN vcs import < .vcs/cougars_ros2_https.repos ros2_ws/src 

WORKDIR /home/${LABNAME}/ros2_ws/src/dvl-a50

RUN git submodule update --init --recursive

WORKDIR /home/${LABNAME}

RUN vcs import < .vcs/runtime_https.repos

WORKDIR /home/${LABNAME}/ros2_ws

RUN bash -c "source /opt/ros/humble/setup.bash && colcon build"

WORKDIR /home/${LABNAME}
# TODO in the future make this a multistage build and it copies over the built into the new image


ENTRYPOINT [ "/home/${LABNAME}/entrypoint.sh" ]