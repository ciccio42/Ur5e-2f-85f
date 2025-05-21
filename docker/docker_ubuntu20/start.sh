#! /bin/bash
# Permission for teleoperator node
sudo chmod 777 /dev/hidraw0
sudo chmod 777 /dev/input/event7

# Build Zed-Camera ros-package
source /opt/ros/noetic/setup.bash

sudo chown -R mivia:mivia /usr/local/zed/lib

cd $HOME
echo "export PATH='/usr/local/cuda-11.7/bin:$PATH'" >> .bashrc && echo "export LD_LIBRARY_PATH='/usr/local/zed/lib:/usr/local/cuda-11.7/lib64:$LD_LIBRARY_PATH'" >> .bashrc
source .bashrc

# dataset_collector - for human demonstration
# cp /home/file_to_copy/dataset_collector/config/dataset_collector.yaml /home/mivia/catkin_ws/src/Learning-from-Demonstration-Dataset-Collector/dataset_collector/config/dataset_collector.yaml
# cp /home/file_to_copy/dataset_collector/src/dataset_collector_node.py /home/mivia/catkin_ws/src/Learning-from-Demonstration-Dataset-Collector/dataset_collector/src/dataset_collector_node.py
# cp /home/file_to_copy/dataset_collector/src/trajectory_collector.py /home/mivia/catkin_ws/src/Learning-from-Demonstration-Dataset-Collector/dataset_collector/src/trajectory_collector.py
# 
# # ur5e_2f_85_teleoperation
# cp /home/file_to_copy/ur5e_2f_85_teleoperation/config/teleoperation_controller.yaml /home/mivia/catkin_ws/src/Ur5e-2f-85f/ur5e_2f_85_teleoperation/config/teleoperation_controller.yaml
# cp /home/file_to_copy/ur5e_2f_85_teleoperation/launch/ur5e_teleoperation_human.launch /home/mivia/catkin_ws/src/Ur5e-2f-85f/ur5e_2f_85_teleoperation/launch/ur5e_teleoperation_human.launch
# cp /home/file_to_copy/ur5e_2f_85_teleoperation/src/ur5e_2f_85_teleoperation/teleoperation_node.py /home/mivia/catkin_ws/src/Ur5e-2f-85f/ur5e_2f_85_teleoperation/src/ur5e_2f_85_teleoperation/teleoperation_node.py
# cp /home/file_to_copy/ur5e_2f_85_teleoperation/src/ur5e_2f_85_teleoperation/ur5e_teleoperator.py /home/mivia/catkin_ws/src/Ur5e-2f-85f/ur5e_2f_85_teleoperation/src/ur5e_2f_85_teleoperation/ur5e_teleoperator.py
# 
# # ur5e_2f_85_controller
# cp /home/file_to_copy/ur5e_2f_85_controller/launch/controller.launch /home/mivia/catkin_ws/src/Ur5e-2f-85f/ur5e_2f_85_controller/launch/controller.launch
# 
# # zed_camera_controller
# cp /home/file_to_copy/zed_camera_controller/src/mockup_camera_controller.py /home/mivia/catkin_ws/src/ZED-Controller/zed_camera_controller/src/ckup_camera_controller.py
# chmod +x /home/mivia/catkin_ws/src/ZED-Controller/zed_camera_controller/src/mockup_camera_controller.py

# readme
cp /home/file_to_copy/README.md /home/mivia/catkin_ws/README.md

sudo pip3 install debugpy

# Open terminal
/bin/bash