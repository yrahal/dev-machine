# dev-machine

Creates a Docker image built on the latest Ubuntu that hosts a ready-to-use development environment
with UI (g++, git, gitk, Qt 5, Qt Creator, VS Code, etc).

The default command of the container launches an x11vnc server on `PORT 5900`. The default user is
`orion`. It provides a fully working development environment running on icewm that contains useful 
software such as g++. git, Konsole, Qt Creator, Visual Studio Code, gitk. You can start the container
with:

`$ docker run -it -p 5900:5900 yrahal/dev-machine`

Which you can connect to using your preferred VNC client. The container will ask you to set and confirm
a password of your choice that you'll re-enter when connecting from the VNC client.

But like any other Docker image, the default command can be overridden and you can launch the container
in CLI or in order to execute a single command (like a compilation for example). This method does not
need port mapping and does not launch an x11vnc server:

`$ docker run -it yrahal/dev-machine bash`

to launch a `bash` shell. Or:

`$ docker run -it -v $PWD:/src yrahal/dev-machine g++ myfile.cpp`

to compile `myfile.cpp` (the default working directory on the container is `/src`).

## Files
* `run.sh`: Script provided for convenience to run the image with some useful mappings:
  * Runs the image with an `x11vnc` server and maps the container's `5900` port to the same one on
  the host.
  * Maps the current directory on the host to `/src` on the container (which is the default working
  directory).
  * Maps the Docker volume `orion-home` to the `orion` home directory on the container. This volume
  exists on the host and is created on the first run. This is useful to persist the preferences
  between sessions, but is not required.
* `build.sh`: Script to build the image from the `Dockerfile`.
* `Dockerfile`: File used to build the image. This image is hosted on Docker Hub as
[`yrahal/dev-machine`](https://hub.docker.com/r/yrahal/dev-machine).
