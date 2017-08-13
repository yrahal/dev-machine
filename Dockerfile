FROM ubuntu:latest

MAINTAINER Youcef Rahal

RUN apt-get update --fix-missing

# Install Lubuntu desktop
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y lubuntu-desktop

# Install some goodies
RUN apt-get install -y xvfb \
                       terminator \
                       vim nano \
                       git gitk git-gui \
                       cmake \
                       qt5-default qtcreator

# Fetch and install Visual Studio Code
RUN wget https://az764295.vo.msecnd.net/stable/cb82febafda0c8c199b9201ad274e25d9a76874e/code_1.14.2-1500506907_amd64.deb -O code.deb && \
    dpkg -i code.deb && \
    rm code.deb

# Fetch and install NodeJS
RUN wget https://nodejs.org/dist/v7.10.0/node-v7.10.0-linux-x64.tar.xz -O node.tar.xz && \
    tar xvf node.tar.xz && \
    mv node-* /opt/node && \
    rm node.tar.xz

# Fetch and install VirtualGL
RUN wget https://sourceforge.net/projects/virtualgl/files/2.5.2/virtualgl_2.5.2_amd64.deb/download -O vgl.deb && \
    dpkg -i vgl.deb && \
    rm vgl.deb

# Fetch and install TurboVNC
RUN wget https://sourceforge.net/projects/turbovnc/files/2.1.1/turbovnc_2.1.1_amd64.deb/download -O tvnc.deb && \
    dpkg -i tvnc.deb && \
    rm tvnc.deb

# Clean
RUN apt-get clean && \
    apt-get autoremove && \
    rm -r /var/lib/apt/lists/*

# Add NodeJS to the PATH
ENV PATH /opt/node/bin:$PATH

# Prepare for nvidia-docker - See https://github.com/plumbee/nvidia-virtualgl
LABEL com.nvidia.volumes.needed="nvidia_driver"
ENV PATH /usr/local/nvidia/bin:/opt/VirtualGL/bin:${PATH}
ENV LD_LIBRARY_PATH /usr/local/nvidia/lib:/usr/local/nvidia/lib64:${LD_LIBRARY_PATH}

# Set this variable so that Gazebo properly loads its UI when using VirtualGL - See https://github.com/P0cL4bs/WiFi-Pumpkin/issues/53
ENV QT_X11_NO_MITSHM 1

# Configure VirtualGL
# RUN /opt/VirtualGL/bin/vglserver_config -config +s +f -t

# Add a user
RUN useradd -m -s /bin/bash orion

# Add a group, assign the user to it and give the group sudo rights.
# It's useful to give sudo rights to the group, instead of to the user, so that
# sudo will continue to work in case the user is renamed. 
RUN groupadd sudonopass
RUN usermod -a -G sudonopass orion
RUN echo "%sudonopass ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# The next commands will be run as the new user
USER orion

# Seems to be needed here instead of above...
# RUN echo "sudo /opt/VirtualGL/bin/vglserver_config -config +s +f -t" >> ~/.bashrc

# Configure VirtualGL
RUN sudo /opt/VirtualGL/bin/vglserver_config -config +s +f -t

# Create some useful default aliases
RUN bash -c 'echo "alias cp=\"cp -i\"" >> ~/.bash_aliases' && \
    bash -c 'echo "alias mv=\"mv -i\"" >> ~/.bash_aliases' && \
    bash -c 'echo "alias rm=\"rm -i\"" >> ~/.bash_aliases'

# Set the working directory
WORKDIR /src

# The port where the vnc server will be running
EXPOSE 5901

# Create a screen and launch the VNC server
CMD Xvfb :0 -screen 0 1920x1200x24 & \
    /opt/TurboVNC/bin/vncserver -fg
