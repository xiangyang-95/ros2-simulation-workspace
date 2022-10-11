# ros2-simulation-workspace
A ROS2 simulation workspaces for algorithm testing and development.

## Install
Run the setup.sh script to setup the whole environment.
```bash
# Production
sudo -E ./setup.sh -i

# Development
sudo -E DEV=1 ./setup.sh -i
```

## Uninstall
Run the setup.sh script to uninstall the whole environment.
```bash
# Production
sudo -E ./setup.sh -u

# Development
sudo -E DEV=1 ./setup.sh -u
```