# UR5e-2f-85
This folder contains the custom packages for controlling the UR-Robot

## Real-Time Kernel
Guide [link](https://github.com/UniversalRobots/Universal_Robots_ROS_Driver/blob/master/ur_robot_driver/doc/real_time.md)

1. Preliminaries
``` bash
sudo apt-get install build-essential bc ca-certificates gnupg2 libssl-dev wget gawk flex bison libncurses-dev bison openssl dkms libelf-dev libudev-dev libpci-dev libiberty-dev autoconf fakeroot dwarves zstd

```
https://cdn.kernel.org/pub/linux/kernel/projects/rt/5.14/patches-5.14.2-rt21.tar.xz

2. Follow the step below
``` bash
wget https://cdn.kernel.org/pub/linux/kernel/projects/rt/5.14/patch-5.14.2-rt21.patch.xz
wget https://cdn.kernel.org/pub/linux/kernel/projects/rt/5.14/patch-5.14.2-rt21.patch.sign
wget https://cdn.kernel.org/pub/linux/kernel/v5.x/linux-5.14.2.tar.xz
wget https://cdn.kernel.org/pub/linux/kernel/v5.x/linux-5.14.2.tar.sign
xz -d *.xz

```
3. For the verification
``` bash
gpg2 --locate-keys torvalds@kernel.org gregkh@kernel.org
gpg2 --verify linux-*.tar.sign
gpg2 --verify patch-*.patch.sign

```
If an error arises run:
``` bash
gpg2  --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys [RSA KEY output from the error]

```
4. Compile
``` bash
tar xf linux-*.tar
cd linux-*
# apply patch
patch -p1 < ../patch-*.patch
# copy the current kernel configuration
cp -v /boot/config-$(uname -r) .config

make olddefconfig
make menuconfig
# 1. General Setup > Preemption Model and select Fully Preemptible Kernel (Real-Time)
# 2. Cryptographic API > Certificates for signature checking (at the very bottom of the list) > Provide system-wide ring of trusted keys > Additional X.509 keys for default system keyring
# 3. Remove the “debian/canonical-certs.pem” from the prompt and press Ok. Save this configuration to .config and  the TUI.
nano .config # comment CONFIG_SYSTEM_TRUSTED_KEYS="", CONFIG_SYSTEM_REVOCATION_KEYS="", 
make -j 1 deb-pkg

```


# Dependencies

## Clone repositories

1. UR-drivers repositories
```bash
cd [PATH_TO_WS]/catkin_ws/src
git clone https://github.com/UniversalRobots/Universal_Robots_ROS_Driver.git
git clone -b boost  https://github.com/UniversalRobots/Universal_Robots_Client_Library.git
git clone https://github.com/ros-industrial/universal_robot.git
```
2. Custom modules
```bash
git clone git@github.com:ciccio42/robotiq.git
git clone git@github.com:ciccio42/Ur5e-85f.git
```
3. Joystick
```bash
# PS4 Joystick ROS Drivers
# Install ds4drv drivers
mkdir ps4_joy_drivers
cd ps4_joy_drivers
git clone https://github.com/chrippa/ds4drv.git
cd ds4drv
sudo python3 setup.py install
git clone --branch noetic-devel  https://github.com/naoki-mizun o/ds4_driver.git
```
4. ZED Camera

## Installation
1. Robotiq dependencies.
```bash
rosdep install --from-paths src --ignore-src -y
sudo apt-get install ros-noetic-soem
```

3. Follow the instructions in README.md file

## Compile
1. Blacklist for useless robotiq packages
```bash
catkin config --skiplist robotiq_2f_140_gripper_visualization robotiq_2f_c2_gripper_visualization robotiq_3f_gripper_articulated_msgs robotiq_3f_gripper_articulated_gazebo robotiq_3f_gripper_articulated_gazebo_plugins robotiq_3f_gripper_control robotiq_3f_gripper_joint_state_publisher robotiq_3f_gripper_visualization robotiq_3f_rviz robotiq_ft_sensor 
```
2. Build
```bash
catkin build
```

# How to run

## Run teleoperation code
``` bash
# Run ur5e calibration
roslaunch ur_calibration calibration_correction.launch robot_ip:=192.168.1.102 target_filename:="/home/ciccio/.ros/real_robot_calibration.yaml"

# 1. Bringup [Real robot]
roslaunch ur_robot_driver ur5e_bringup.launch robot_ip:=192.168.1.102 kinematics_config:="/home/ciccio/.ros/real_robot_calibration.yaml" use_tool_communication:=true tool_voltage:=24 tool_parity:=0 tool_baud_rate:=115200 tool_stop_bits:=1 tool_rx_idle_chars:=1.5 tool_tx_idle_chars:=3.5 tool_device_name:=/tmp/ttyUR robot_description_file:="/home/ciccio/Desktop/catkin_ws/src/Ur5e-2f-85f/ur5e_2f_85_description/launch/load_ur5e_2f_85.launch"
# 1. Bringup [Sim robot]
roslaunch ur_robot_driver ur5e_bringup.launch robot_ip:=192.168.56.101 kinematics_config:="/home/ciccio/.ros/sim_robot_calibration.yaml" robot_description_file:="/home/ciccio/Desktop/catkin_ws/src/Ur5e-2f-85f/ur5e_2f_85_description/launch/load_ur5e_2f_85.launch"
# 1.1. Run external controller on teach pendant

# 2. Run moveit interface 
roslaunch ur5e_2f_85_controller controller.launch 

# 2. Camera 
roslaunch zed_camera_controller zed_camera_controller.launch 

# 3. Run dataset teleoperation node
roslaunch ur5e_2f_85_teleoperation ur5e_teleoperation.launch 

# 4. Run dataset collector
roslaunch dataset_collector dataset_collector.launch 


```

## Simulation
1. Docker

``` bash
# Stop containers
docker stop ursim_container

# Remove previously docker with the same name
docker image rm ursim_docker

# Build Docker
docker build -t ursim_docker .

# Create docker subnetwork
docker network create --subnet=192.168.56.0/24 ursim_net

# Run Docker
docker run --rm --name ursim_container -it --net ursim_net --ip 192.168.56.101 -e ROBOT_MODEL=UR5 ursim_docker

```

# How to run AI Controller module

# Dependencies
# 1. Create a conda-environment
```bash
conda create -n ros_multi_task_lfd python=3.8
conda activate multi_task_lfd
```
# 2. Install dependencies
```bash
# 1. Torch
pip install --user torch==1.13.1+cu117 torchvision==0.9.1 -f https://download.pytorch.org/whl/torch_stable.html

# 2. Repositories
# cd to Multi-Task-LFD-Framework
echo export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/home/$USER/.mujoco/mujoco210/bin:/usr/local/cuda-12.1/lib64/:/usr/lib/nvidia-000 >>/home/$USER/.bashrc
source /home/$USER/.bashrc
pip install  mujoco-py
cd repo/robosuite
pip install  -e .
cd repo/Multi-Task-LFD-Training-Framework/training
pip install  -e .
## 2. Install tasks
cd repo/Multi-Task-LFD-Training-Framework/tasks
pip install  -e .
pip install  -e .
pip install einops hydra-core
```

# 1. Run ur-drivers
```bash
roslaunch ur_robot_driver ur5e_bringup.launch robot_ip:=192.168.1.100 kinematics_config:="/home/ciccio/.ros/real_robot_calibration.yaml" use_tool_communication:=true tool_voltage:=24 tool_parity:=0 tool_baud_rate:=115200 tool_stop_bits:=1 tool_rx_idle_chars:=1.5 tool_tx_idle_chars:=3.5 tool_device_name:=/tmp/ttyUR robot_description_file:="/home/ciccio/Desktop/catkin_ws/src/Ur5e-2f-85f/ur5e_2f_85_description/launch/load_ur5e_2f_85.launch"
```

# 2. Run controller
```bash
roslaunch ur5e_2f_85_controller controller.launch 
```

```bash
roslaunch ur5e_2f_85_camera_table_moveit_config moveit_rviz.launch 
``` 

# 2.1. Run gripper driver
```bash
rosrun robotiq_2f_gripper_control Robotiq2FGripperRtuNode.py /tmp/ttyUR
```

# 2.2. Run camera controller
```bash
roslaunch zed_camera_controller zed_camera_controller.launch
```

# Procedure for camera calibration
```bash
roslaunch zed_camera_controller zed_camera_controller.launch
```

```bash
# run aruco detector
roslaunch 
```

```bash
# run calibration node
roslaunch 
```

# In docker

Important link:
* Real-time consideration [link](https://github.com/UniversalRobots/Universal_Robots_ROS_Driver/blob/master/ur_robot_driver/doc/real_time.md)
* RT-for-jetson [link](https://github.com/hmxf/RTJetson/tree/R35.3.1)

```bash
sudo docker run -it --gpus all --runtime=nvidia --rm --network="host" --privileged --name ur_controller -v /home/mivia/Desktop/frosa/Ur5e-2f-85f/docker/docker_jetson_xavier_nx:/home/mivia/docker_jetson_xavier_nx -v /dev:/dev jetson_xavier_nx 

sudo docker exec -it ur_controller /bin/bash 
```

```bash
sudo -i 
source /opt/ros/noetic/setup.bash 
cd /home/mivia/catkin_ws 
source devel/setup.bash
```

```bash
# only at first boot
roslaunch ur_calibration calibration_correction.launch robot_ip:=172.16.174.13 target_filename:="/home/mivia/docker_jetson_xavier_nx/robot_calibration.yaml"

# Run robot ros driver
roslaunch ur_robot_driver ur5e_bringup.launch robot_ip:=192.168.1.100 kinematics_config:="/home/mivia/docker_jetson_xavier_nx/robot_calibration.yaml" use_tool_communication:=true tool_voltage:=24 tool_parity:=0 tool_baud_rate:=115200 tool_stop_bits:=1 tool_rx_idle_chars:=1.5 tool_tx_idle_chars:=3.5 tool_device_name:=/tmp/ttyUR robot_description_file:="/home/mivia/catkin_ws/src/Ur5e-2f-85f/ur5e_2f_85_description/launch/load_ur5e_2f_85.launch"

# Run moveit interface 
roslaunch ur5e_2f_85_controller controller.launch 

# Camera 
roslaunch zed_camera_controller zed_camera_controller.launch 

# Run dataset teleoperation node
roslaunch ur5e_2f_85_teleoperation ur5e_teleoperation.launch 

# Run dataset collector
roslaunch dataset_collector dataset_collector.launch 

```



