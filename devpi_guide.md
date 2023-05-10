# Devpi Setup Tutorial
* This tutorial is based on [this guide](https://devpi.net/docs/devpi/devpi/stable/+doc/quickstart-releaseprocess.html). For more information, please refer to it.

## Installation requirements:
* **Optional (but highly recommended):** you can create a virtual python environment to isolate your devpi packages from your system's python environment with the following commands. If you are famililar with additional python virtual environments, use your preferred environment:
    1. Create the environment: `python3 -m venv <virtual environment path>`
    2. Activate the environment: `<virtual environment path>`

## Setup:
* **Open a terminal and run the following commands:**
    1. Install devpi client and server:
    `pip install -U devpi-web devpi-client supervisor`
    2. Initialize devpi-server:
    `devpi-init`
    3. Start devpi server in the background using supervisor 
        * Create the config file: 
        `devpi-init`
        * Bind the Devpi server network interface to either a specific IP address or to all network interfaces:
            - For a specific IP address, add `--host <your ip address>` to the end of the `command=devpi-server` line in the gen-config/supervisor-devpi.conf file.
            - For all network interfaces, add `--host 0.0.0.0` to the end of the `command=devpi-server` line in the gen-config/supervisor-devpi.conf file.
        * Start supervisord using a config:
            - `supervisord -c gen-config/supervisord.conf`
            
    4. Point the devpi client to the server: 
    `devpi use http://localhost:3141`
    
    5. Create a user. Replace `<username>` and `<password>` with your desired username and password: 
    `devpi user -c <username> password=<password>`
        
    6. Log in as the user. Replace `<username>` and `<password>` with your chosen username and password:
    `devpi login <username> --password=<password>`
        
    7. Create a "dev" index, telling it to use the root/pypi cache as a base so that all packages from pypi.org will appear on that index:
    `devpi index -c dev bases=root/pypi`
      
    8. Configure devpi to use the new index "dev". Replace `<username>` with your chosen username: 
    `devpi use <username>/dev`
  
    9. Configure the firewall. This step is specific to your operating system. The following commands will work on Ubuntu Linux:
        * Allow traffic on port 3141 using the TCP protocol:
            - `sudo ufw allow 3141/tcp`
        * Restart the firewall:
            - `sudo ufw disable`
            - `sudo ufw enable`

## Server control
* Start the server: `supervisord -c gen-config/supervisord.conf`
* Stop the server: `supervisorctl -c gen-config/supervisord.conf shutdown`

## Upload a package:
1. Verify you're logged in to the correct user and index: 
    * Run: `devpi use`
    * Expected output:
        ```
        $ devpi use
        current devpi index: http://localhost:3141/testuser/dev (logged in as testuser)
        supported features: server-keyvalue-parsing
        venv for install/set commands: /tmp/docenv
        only setting venv pip cfg, no global configuration changed
        /tmp/docenv/pip.conf: no config file exists
        always-set-cfg: no
        ```
    * On the first line, you should see that you're logged into the correct user, testuser, and using the correct index, testuser/dev.

2. Open a terminal and `cd` into the package directory where the *`setup.py`* or *`pyproject.toml`* file(s) exist.
3. Run the command: `devpi upload`. The package should upload.
4. You can verify your upload by visiting the devpi website hosted by the server. The url should be: `http://<your ip address>:3141/testuser/dev/`.

## Install a package:
1. Find the ip address of the host computer in your local network. 
    * *On Ubuntu linux, you can run either of the commands `ip a` or `ifconfig`*.
2. Assemble the url to access your devpi server:
    * `python3 -m pip install <PACKAGE NAME> --extra-index-url http://<DEVPI SERVER IP>:3141/<DEVPI USERNAME>/<DEVPI INDEX>/ --trusted-host <DEVPI SERVER IP>`
        * `<PACKAGE NAME>` : The package name 
        * `<DEVPI SERVER IP>` : Your ip address
        * `<DEVPI USERNAME>` : The user you created earlier
        * `<DEVPI INDEX>` : The index you created earlier
    * For example with package as `thorlabsltstage`, user name as `testuser`, IP as `10.0.0.19` and index as `dev` : 
        - `python3 -m pip install thorlabsltstage --extra-index-url http://10.0.0.19:3141/testuser/dev/ --trusted-host 10.0.0.19`
3. Open a terminal and ensure you're using the appropriate Python environment, then run the assembled command:
    * `python3 -m pip install thorlabsltstage --extra-index-url http://10.0.0.19:3141/testuser/dev/ --trusted-host 10.0.0.19`
    * This command will install the thorlabsltstage package from your devpi server.
    * Make sure to follow the instructions carefully and replace the placeholders `(<PACKAGE NAME>, <DEVPI SERVER IP>, <DEVPI USERNAME>, <DEVPI INDEX>)` with your actual values.

## Useful resources:
* [Devpi Quickstart: uploading, testing, pushing releases](https://devpi.net/docs/devpi/devpi/stable/+doc/quickstart-releaseprocess.html)
* [Devpi commands reference](https://devpi.net/docs/devpi/devpi/stable/+doc/userman/devpi_commands.html#devpi-command-reference-server)
* https://gist.github.com/kyhau/0b54386fe220877310b9