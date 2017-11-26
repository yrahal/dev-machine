FROM ubuntu:latest

MAINTAINER Youcef Rahal

# Install Lubuntu desktop
# Install some goodies
# net-tools for noVNC below
# libopencv-dev
# Clean
RUN apt-get update --fix-missing && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
        lubuntu-desktop \
        xvfb \
        terminator \
        vim nano \
        git gitk git-gui \
        cmake \
        qt5-default qtcreator \
        net-tools \
        libopencv-dev && \
    apt-get clean && \
    apt-get autoremove && \
    rm -r /var/lib/apt/lists/*

# Fetch and install Anaconda3 and dependencies
ARG conda_dir=/opt/anaconda3
ARG conda_bin_dir=${conda_dir}/bin
RUN wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/anaconda.sh && \
    /bin/bash ~/anaconda.sh -b -p ${conda_dir} && \
    rm ~/anaconda.sh

# Add Anaconda3 to the PATH
ENV PATH ${conda_bin_dir}:$PATH

# Update pip
# TODO conda is not properly cloning as it should here (files are copied instead of linked...)
RUN /bin/bash -c "\
    pip install --upgrade pip && \
    conda create -y -n cpu && \
    source activate cpu && \
    conda install -y sympy scikit-learn scikit-image pillow flask-socketio plotly nb_conda pyqtgraph seaborn pandas h5py && \
    conda install -y -c menpo opencv3 && \
    conda install -y -c conda-forge eventlet ffmpeg && \
    pip install moviepy peakutils jupyterthemes && \
    pip install socketIO-client transforms3d PyQt5 && \
    conda clean -y -a && \
    source deactivate cpu && \
    
    conda create -y -n gpu --clone cpu && \
    
    conda install -y -n cpu tensorflow && \
    conda clean -y -a && \

    conda install -y -n gpu tensorflow-gpu && \
    conda clean -y -a"

# Fetch and install NodeJS
RUN wget https://nodejs.org/dist/v7.10.0/node-v7.10.0-linux-x64.tar.xz -O node.tar.xz && \
    tar xvf node.tar.xz && \
    mv node-* /opt/node && \
    rm node.tar.xz

# Fetch and install Chrome
RUN wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb -O chrome.deb && \
    dpkg -i chrome.deb && \
    rm chrome.deb

# Fetch and install Visual Studio Code
RUN wget https://az764295.vo.msecnd.net/stable/b813d12980308015bcd2b3a2f6efa5c810c33ba5/code_1.17.2-1508162334_amd64.deb -O code.deb && \
    dpkg -i code.deb && \
    rm code.deb

# Fetch and install VirtualGL
RUN wget https://sourceforge.net/projects/virtualgl/files/2.5.2/virtualgl_2.5.2_amd64.deb/download -O vgl.deb && \
    dpkg -i vgl.deb && \
    rm vgl.deb

# Fetch and install TurboVNC
RUN wget https://sourceforge.net/projects/turbovnc/files/2.1.1/turbovnc_2.1.1_amd64.deb/download -O tvnc.deb && \
    dpkg -i tvnc.deb && \
    rm tvnc.deb

# Fetch and install noVNC
RUN git clone https://github.com/novnc/noVNC /opt/noVNC && \
    git clone https://github.com/novnc/websockify /opt/noVNC/utils/websockify

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

# Create a utils/ dir and add it to the PATH.
ARG utils_bin_dir=/opt/utils/bin
RUN sudo mkdir -p ${utils_bin_dir}
ENV PATH ${utils_bin_dir}:$PATH

# Create a command to run Jupyter notebooks
ARG jupyter_run=${utils_bin_dir}/jupyter-server-run
RUN echo "#!/bin/bash\n\n" \
         "jupyter notebook --no-browser --ip='*'" > ${jupyter_run} && \
    chmod a+x ${jupyter_run}

# Create a command to set the jupyter theme
ARG jupyter_theme=${utils_bin_dir}/jupyter-theme-set
RUN echo "#!/bin/bash\n\n" \
         "jt -T -cellw 1400 -t chesterish -fs 8 -nfs 6 -tfs 6" > ${jupyter_theme} && \
    chmod a+x ${jupyter_theme}

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
# Configure VirtualGL
RUN sudo /opt/VirtualGL/bin/vglserver_config -config +s +f -t

# Create some useful default aliases
RUN bash -c 'echo "alias cp=\"cp -i\"" >> ~/.bash_aliases' && \
    bash -c 'echo "alias mv=\"mv -i\"" >> ~/.bash_aliases' && \
    bash -c 'echo "alias rm=\"rm -i\"" >> ~/.bash_aliases'

# Set Keras to use Tensorflow
RUN mkdir ~/.keras && echo "{ \"image_dim_ordering\": \"tf\", \"epsilon\": 1e-07, \"backend\": \"tensorflow\", \"floatx\": \"float32\" }" >  ~/.keras/keras.json

# Set the cpu env as default
RUN echo "source activate cpu" >> ~/.bashrc

# Run these import once so they don't happen every time the container is run
# Matplotlib needs to build the font cache
RUN /bin/bash -c "source activate cpu && python -c 'import matplotlib.pyplot as plt'"
# Download ffmpeg
#RUN /bin/bash -c "source activate cpu && (echo 'import imageio'; echo 'imageio.plugins.ffmpeg.download()') | python"
#RUN (echo "import imageio"; echo "imageio.plugins.ffmpeg.download()") | python

# Set the working directory
WORKDIR /src

# The port where the vnc server will be running
EXPOSE 5901
# The port where the noVNC server will be running
EXPOSE 6080
# The port where jupyter will be running
EXPOSE 8888

# Create a screen and launch the VNC server
CMD Xvfb :0 -screen 0 1920x1200x24 & \
    /opt/TurboVNC/bin/vncserver -fg

# For noVNC
# /opt/noVNC/utils/launch.sh --vnc localhost:5901
