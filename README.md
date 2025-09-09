# CoUGARs Project

This repository contains the core files and helper scripts needed to deploy or develop for the BYU FRoSt Lab's **Cooperative Underwater Group of Autonomous Robots (CoUGARs)**.

It provides tools to configure new systems, manage Docker containers, and keep the development environment up to date.

If you're looking to do remote development directly on the Coug-UV vehicle, please see these repositories instead:

* [cougars-ros2](https://github.com/BYU-FRoSt-Lab/cougars-ros2.git)
* [cougars-teensy](https://github.com/BYU-FRoSt-Lab/cougars-teensy.git)
* [cougars-gpio](https://github.com/BYU-FRoSt-Lab/cougars-gpio.git)

---

## Getting Started

Clone this repository onto your development machine or Raspberry Pi 5. Most setup tasks are automated by the included scripts.

### Scripts Overview

#### 1. `setup.sh`

Initializes a new environment, either on a **Raspberry Pi 5** or a **local development machine**.

* **On Raspberry Pi 5:**

  * Updates the OS and installs Docker.
  * Installs dependencies like `chrony` and configures system files (`chrony.conf`, udev rules).
  * Prepares directories (`bag`, `ros2_ws`, etc.).
* **On development machine:**

  * Imports repositories listed in `.vcs/dev.repos`.
  * Sets permissions for `base-station` and `.ssh_keys`.
* **General setup tasks (both):**

  * Adds a `coug` alias for entering the Docker container.
  * Lets you configure a vehicle namespace (`NAMESPACE`).
  * Installs common developer tools (`vim`, `tmux`, `git`, `mosh`, and `vcstool`).
  * Optionally installs a tmux config and template files.
  * Pulls the latest CoUGARs Docker images.
  * Optionally starts the docker containers
  * Optionally builds the ros2 workspaces

**Usage:**

```bash
bash setup.sh
```

---

#### 3. `tmux.sh`

Creates and manages a tmux session for CoUGARs development. This script sets up multiple windows and panes with common workflows.

* **Default behavior:** Starts a `cougars` tmux session with two panes running inside the CoUGARs Docker container.
* **Options:**

  * `-a` – Add both **base station** and **simulation** windows.
  * `-b` – Add a **base station** window only.
  * `-s` – Add a **simulation** window only.
  * `-i <ip_address>` – Connect to a simulation over SSH at the provided IP address.
  * `kill` – Kill the running tmux session.

**Usage examples:**

```bash
# Start tmux with default setup
bash tmux.sh

# Start tmux with base station window
bash tmux.sh -b

# Start tmux with base station and simulation windows
bash tmux.sh -a

# Start tmux with sim window connected over SSH
bash tmux.sh -s -i 192.168.1.42

# Kill the tmux session
bash tmux.sh kill
```

---

## Directory Structure

* `scripts/` – Utility scripts for setup and maintenance.
* `config/` – Local configuration files (e.g., udev rules, chrony).
* `templates/` – Default template files (e.g., tmux config).
* `.vcs/` – Lists of repositories to clone via `vcstool`.

---

## Notes

* Always run scripts from the **root of the repository**.
* After setup, make sure to update the vehicle-specific configuration files inside the `config/` directory.
* You may need to restart your shell session after `setup.sh` to apply the new `coug` alias.

---
