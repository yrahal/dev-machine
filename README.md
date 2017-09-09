[![Docker Stars](https://img.shields.io/docker/stars/yrahal/dev-machine.svg)](https://hub.docker.com/r/yrahal/dev-machine/)
[![Docker Pulls](https://img.shields.io/docker/pulls/yrahal/dev-machine.svg)](https://hub.docker.com/r/yrahal/dev-machine/)

# dev-machine

Creates a Docker image built on the latest Lubuntu that hosts a ready-to-use development environment
with UI (g++, git, gitk, cmake, Qt 5, Qt Creator, VS Code, Node.js, etc).

The default command of the container launches a TurboVNC server on `PORT 5901`. The default user is
`orion`, which has sudo rights. It provides a fully working development environment running on LXDE
that contains useful software such as g++. git, Terminator, Qt Creator, Visual Studio Code, gitk. You
can start the container with:

`$ docker run -it -p 5901:5901 yrahal/dev-machine`

Which you can connect to using your preferred VNC client. The container will ask you to set and confirm
a password of your choice that you'll re-enter when connecting from the VNC client.

But like any other Docker image, the default command can be overridden and you can launch the container
in CLI or in order to execute a single command (like a compilation for example). This method does not
need port mapping and does not launch a VNC server:

`$ docker run -it yrahal/dev-machine bash`

to launch a `bash` shell. Or:

`$ docker run -it -v $PWD:/src yrahal/dev-machine g++ myfile.cpp`

to compile `myfile.cpp` (the default working directory on the container is `/src`).

## 3D

This image is fully capable of running 3D accelerated applications when run on Nvidia hardware with drivers
installed with the help of the nvidia-docker plugin. See my
[ec2-setup GitHub repo](https://github.com/yrahal/ec2-setup) for more information.

## Other Images

This image is used as a basis for two other images I built for the Udacity
[Self-Driving Car](https://www.udacity.com/course/self-driving-car-engineer-nanodegree--nd013)
and [Robotics](https://www.udacity.com/robotics) Nanodegrees:

* Self-Driving Car Docker image: on [GitHub](https://github.com/yrahal/udacity-carnd) and on
[Docker Hub](https://hub.docker.com/r/yrahal/udacity-carnd/).
* Robotics Docker image: on [GitHub](https://github.com/yrahal/udacity-robond) and on
[Docker Hub](https://hub.docker.com/r/yrahal/udacity-robond/).

## Files
* `run.sh`: Script provided for convenience to run the image with some useful mappings:
  * Runs the image with a TurboVNC server and maps the container's `5901` port to the same one on
  the host.
  * Maps the current directory on the host to `/src` on the container (which is the default working
  directory).
  * Maps the Docker volume `orion-home` to the `orion` home directory on the container. This volume
  exists on the host and is created on the first run. This is useful to persist the preferences
  between sessions, but is not required.
* `build.sh`: Script to build the image from the `Dockerfile`.
* `Dockerfile`: File used to build the image. This image is hosted on Docker Hub as
[`yrahal/dev-machine`](https://hub.docker.com/r/yrahal/dev-machine).
