# Mininet DevContainer

This is a VS Code DevContainer configuration for the NET101 Mininet network lab environment.

## Features

- **Mininet**: Network emulator for rapid prototyping
- **FRR**: Free Range Routing protocol suite
- **Python 3**: For network automation scripts
- **Network Tools**: tcpdump, iperf3, traceroute, tshark, and more
- **VS Code Extensions**: Pre-configured for Python, Docker, and Markdown development

## Getting Started

### Prerequisites

- Docker Desktop installed and running
- VS Code with the "Dev Containers" extension installed

### Opening the DevContainer

1. Open this folder in VS Code
2. When prompted, click "Reopen in Container" (or use Command Palette: "Dev Containers: Reopen in Container")
3. Wait for the container to build and start
4. Once ready, you'll have a fully configured Mininet environment!

### Verifying the Setup

After the container starts, run these commands in the terminal:

```bash
# Check Mininet installation
mn --version

# Check Open vSwitch
sudo ovs-vsctl show

# Test a simple topology
sudo mn --test pingall
```

## Running Network Labs

### Static Routing Lab

```bash
sudo python3 static_routing_2rtr.py
```

### OSPF Lab

```bash
sudo python3 ospf-lab.py
```

## Network Tools Available

- **Mininet**: Network emulator
- **FRR**: OSPF, BGP, and other routing protocols
- **tcpdump**: Packet capture and analysis
- **tshark**: Wireshark CLI
- **iperf3**: Network performance testing
- **traceroute**: Path tracing
- **net-tools**: ifconfig, netstat, etc.
- **iproute2**: ip command suite

## Troubleshooting

### Open vSwitch not running

If OVS is not running, start it manually:

```bash
sudo service openvswitch-switch start
```

### Permission issues

The devcontainer runs as root by default to allow Mininet operations. If you need to switch users:

```bash
su - vscode
```

## File Structure

- `.devcontainer/devcontainer.json`: Main DevContainer configuration
- `.devcontainer/docker-compose.yml`: Docker Compose setup for DevContainer
- `.devcontainer/Dockerfile`: Custom Dockerfile for the development environment
- `frr-config/`: FRR routing configurations
- `Template/`: Router configuration templates

## Notes

- The container runs in **privileged mode** and **host network mode** to support Mininet's network virtualization
- The `/lib/modules` directory is mounted read-only from the host for kernel module access
- All workspace files are mounted at `/workspaces/net101`
