# Mac Seedbox
A complete macOS-based seedbox setup using Docker, Radarr, Sonarr, NZBGet, Prowlarr, Plex, and Gluetun - all managed through Portainer with secure remote access via Tailscale.

## Table of Contents

* [Overview](#overview)  
* [System Configuration](#system-configuration)  
* [Software Installation](#software-installation)  
* [Seedbox Stack Architecture](#seedbox-stack-architecture)  
  * [Network Privacy Layer](#network-privacy-layer)  
  * [Media Managers](#media-managers)  
  * [Download Client](#download-client)  
  * [Media Server](#media-server)  
* [File Structure](#file-structure)  
* [Portainer Setup](#portainer-setup)  
  * [Step 1: Modify the YAML File](#step-1-modify-the-yaml-file)  
  * [Step 2: Install Portainer](#step-2-install-portainer)  
  * [Step 3: Deploy the Stack](#step-3-deploy-the-stack)  
* [Setup Instructions](#setup-instructions)  
  * [NZBGet Setup](#nzbget-setup)  
  * [Radarr Setup](#radarr-setup)  
  * [Sonarr Setup](#sonarr-setup)  
  * [Prowlarr Setup](#prowlarr-setup)  
  * [Plex Setup](#plex-setup)  
* [Using Usenet](#using-usenet)  
  * [Radarr Usage](#radarr-usage)  
  * [Sonarr Usage](#sonarr-usage)  
* [Subler](#subler)  
* [Setting Up Tailscale](#setting-up-tailscale)

## Overview

This documentation outlines the setup and configuration of a macOS-based seedbox system using Docker Compose. It includes VPN tunneling, automated movie and TV show management, Usenet downloading, and media serving via Plex.

## System Configuration

Before setting up the stack, ensure macOS is configured for server use:

1. **Networking**: Disable Wi-Fi if connected via Ethernet.
2. **Energy Settings**:
   * Enable "Wake for network access"
   * Enable "Start up automatically after a power failure"
3. **Sharing Preferences**:
   * Enable File Sharing (optional if using Remote Management)
   * Enable Remote Management with access for specific users
   * Adjust local hostname if desired
4. **Lock Screen Settings**:
   * Disable screen saver and display sleep
   * Disable password requirement after inactivity
5. **Login Settings**:
   * Enable automatic login for the configured user

## Software Installation
[Homebrew](https://brew.sh) is a package manager for macOS (and Linux) that makes it easy to install, update, and manage software and command-line tools directly from the terminal.

Installing Homebrew:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

[Docker](https://www.docker.com) is a platform for isolating applications into separate containers, which ensures each service runs independently and securely. 

[Tailscale](https://tailscale.com) enables secure remote access to the seedbox without the need to manually configure port forwarding or expose your local network.

[Subler](https://subler.org) is a helpful application that enables the use of combining video, audio, subtitle, and metadata tracks into a single MP4 container without the need for full transcoding.

[Visual Studio Code](https://code.visualstudio.com) is a text editor for editing configuration files and code within this stack. 

Install the required applications using Homebrew:

```bash
brew install --cask docker
brew install --cask tailscale
brew install --cask subler
brew install --cask visual-studio-code
```

## Seedbox Stack Architecture

### Network Privacy Layer

* Gluetun: Acts as the VPN gateway for all other containers in the stack. This means that Radarr, Sonarr, NZBGet, and Prowlarr share Gluetun's network stack using `network_mode: "service:gluetun"`. This setup ensures:
    - All traffic is securely tunneled through the VPN (in this case, Private Internet Access).
    - These containers do not expose their own ports directly.
    - If the VPN connection goes down, none of the services will inadvertently leak traffic.

### Media Managers
* **Radarr**: Handles movie management and downloads.
* **Sonarr**: Handles TV series management and downloads.
* **Prowlarr**: Centralized indexer manager to integrate Usenet indexers with Radarr and Sonarr.

### Download Client
* **NZBGet**: Usenet download client that communicates with Radarr and Sonarr.

### Media Server
* **Plex**: Serves media to various devices. Configured separately from the VPN network for accessibility.

## File Structure
These directories are automatically created the first time the Docker Compose stack is deployed through Portainer or the command line.

```
/Users/username/seedbox/
├── configs/
│   ├── gluetun/
│   ├── radarr/
│   ├── sonarr/
│   └── prowlarr/
├── nzbget/
│   └── downloads/
│       └── completed/
├── radarr/
    └── movies/
├── sonarr/
    └── tv/
```

## Portainer Setup
### Step 1: Modify the YAML File
Before deploying the [seedbox-portainer-stack.yaml file](./seedbox-portainer-stack.yaml), ensure that all file paths are correct for your system.

By default, volume paths are set to `/Users/username/seedbox/...` We want to replace 'username' with your actual macOS user account name, otherwise Docker will attempt to mount directories that don’t exist:
1. Open the file in Visual Studio Code.
2. Highlight an instance of username and press `CMD + F`.
3. Click the dropdown arrow in the search bar.
4. Enter your actual username in the "Replace" field.
5. Click Replace All.
6. In the Plex section, replace `[enter-claim-code]` with your own [Plex Claim Token](https://plex.tv/claim) to automatically connect the server to your Plex account.
7. Also in the Plex section, replace the volume paths for movies and tv shows with your own. 
8. Save the file.

### Step 2: Install Portainer
After Docker is installed, run the following setup script to install Portainer:
1. Download the [portainer-setup.sh file](./portainer-setup.sh) and place it in your desired folder.
2. Open Terminal, navigate to that folder, and make the script executable: `chmod +x portainer-setup.sh`
3. Run the script: `./portainer-setup.sh`

### Step 3: Deploy the Stack
1. Visit https://localhost:9443 in your browser.
2. Create an admin account to log in.
3. Click on "local" under environments, then go to "Stacks".
4. Click "+ Stack", either paste in the contents of `seedbox-portainer-stack.yaml` or directly upload the file.
5. Scroll down and click "Deploy the stack"


## Setup Instructions

### NZBGet Setup

1. Access NZBGet web UI at `http://localhost:6789`.
2. Go to `Settings → News-Servers` and enter your newshosting account details.
3. Save and test the connection to confirm it works properly.

### Radarr Setup
1. Access Radarr at http://localhost:7878.
2. Set login form username and password
3. Settings → Media Management → Show Advanced Settings:
    - Movie Naming → Enable 'Rename Movies'
    - Movie Naming → Standard Movie Format → Remove '{Quality Full}'
    - File Management → Check 'Unmonitor Deleted Movies'
    - Root Folders → Add Root Folder → `/downloads-movies`
    - Save Changes
4. Settings → General:
    - Copy the API key from General settings and save it somewhere accessible, it will be needed when configuring Prowlarr.
5. Settings → Download Clients:
    - Click on +
    - Select NZBGet
    - Change password to the one you created in the YAML file
    - Click on 'Test Server' and then click 'Save'

### Sonarr Setup
1. Access Sonarr at http://localhost:8989.
2. Set login form username and password
3. Settings → Media Management → Show Advanced Settings:
    - Episode Naming → Enable 'Rename Episodes'
    - Episode Naming → Standard Episode Format → Remove '{Quality Full}'
    - File Management → Check 'Unmonitor Deleted Episodes'
    - Root Folders → Add Root Folder → `/downloads-shows`
    - Save Changes
4. Settings → General:
    - Copy the API key from General settings and save it somewhere accessible, it will be needed when configuring Prowlarr.
5. Settings → Download Clients:
    - Click on +
    - Select NZBGet
    - Change password to the one you created in the YAML file
    - Click on 'Test Server' and then click 'Save'

### Prowlarr Setup

1. Access the web UI at `http://localhost:9696`.
2. Set login credentials.
3. Add indexers:
   * Go to Settings → Indexers
   * Click '+ Add Indexer'
   * Select your Usenet indexer (e.g., NZBGeek)
   * Input API key and URL from your indexer provider
4. Add applications (Radarr, Sonarr):
   * Go to Settings → Apps
   * Click '+ Add Application'
   * Select 'Radarr' or 'Sonarr' accordingly
   * Paste their respective API keys and test connection
5. Confirm that indexers and apps are syncing correctly.

### Plex Setup

1. Access the web UI at `http://localhost:32400/web`.
2. Log in to your Plex account and complete the setup wizard.
3. Add libraries:
   * Movies: `/movies`
   * TV Shows: `/tv`
5. Ensure external media directories (e.g., `/Volumes/Media`) are mounted and readable.
6. Test playback from another device on your network.

## Using Usenet
### Radarr Usage
Searching and adding movies to download:
1. Click on 'Movies' in the left sidebar
2. Use the search bar to find a movie
3. Before clicking 'Add Movie', uncheck 'Start search for missing movie'
4. After adding, click on the movie title and choose 'Interactive Search'
5. Click the download icon next to your desired file
6. Monitor the download progress in the NZBGet web UI

### Sonarr Usage

Searching and adding tv shows to download:
1. Click on 'Series' in the left sidebar
2. Use the search bar to find a show
3. Before clicking 'Add Series', uncheck 'Start search for missing series'
4. After adding, click on the series title
5. Click 'Interactive Search' next to the desired season
6. Click the download icon next to your preferred episode files
7. Monitor the download progress in the NZBGet web UI

## Subler

After your movies or shows have been downloaded and organized by Radarr or Sonarr, Subler can be used to add metadata, artwork, and subtitles to the files for better presentation.

1. Open video file
2. Import metadata (CMD+SHIFT+M)
3. Add artwork
4. Send to queue and export (CMD+B) - check 'Optimize'

## Setting Up Tailscale
### Log in to Tailscale
1. Open the Tailscale app from your Applications folder or menu bar.
2. Click “Log in”.
3. After login, you may be prompted to:
    - Add the Tailscale Login Extension to macOS. This allows Tailscale to reconnect automatically when your machine starts.
    - Install a VPN Profile. Approve the system prompt to allow Tailscale to configure your device’s VPN settings.
### Verify Connection
1. Visit https://login.tailscale.com/admin/machines to confirm your Mac appears in the list.
2. Copy the assigned Tailscale IP address (usually in the 100.x.x.x range).
### Access the Seedbox Remotely
You can now access any services running on your seedbox using your Tailscale IP. For example:
- Radarr: http://100.x.x.x:7878
- Sonarr: http://100.x.x.x:8989
- NZBGet: http://100.x.x.x:6789
- Plex: http://100.x.x.x:32400/web
- Portainer: https://100.x.x.x:9443