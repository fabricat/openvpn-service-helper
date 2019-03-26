# openvpn-service-helper

### Why?
This is the case:
* you are using a Linux distribution shipped with [network-manager](https://wiki.debian.org/NetworkManager)
* your company decides to use OpenVPN, letting you log in with **certificate plus username/password**
* you are excited while discovering that NetworkManager can manage
  [OpenVPN connections](https://launchpad.net/network-manager-openvpn) :)
* your company decides to add a **third factor** for logging into its VPN:
  a challenge or OTP (like Google Authenticator) 
* despite "network-manager-openvpn"
  [seems to support the dynamic challenge-response protocol](https://launchpad.net/ubuntu/+source/network-manager-openvpn/1.2.10-0ubuntu1),
  you experience that it does not work in this case :'(

That's why you wish a little _help_ for starting and stopping this ~~damned~~ VPN ;)

### How it looks like
Choice among several OpenVPN configurations (only if there are many files in `/etc/openvpn/*.conf`).
![selection](https://github.com/fabricat/openvpn-service-helper/blob/screenshots/demo-selection.png?raw=true)

Here is the menu with **status of the VPN** (on the top) and the possible actions.
![actions](https://github.com/fabricat/openvpn-service-helper/blob/screenshots/demo-actions.png?raw=true)

### Requirements and limitations
~~Currently this script works only with **client** configurations of OpenVPN.~~

This script works both with **client** and **generic** configurations of OpenVPN:
 it uses the `openvpn@` and `openvpn-client@`
 [service templates](https://www.digitalocean.com/community/tutorials/understanding-systemd-units-and-unit-files#creating-instance-units-from-template-unit-files)
 and recognizes only config files matching with `*.conf` under `/etc/openvpn/`
 (and sub-directories, except the `server` directory).

Moreover, it requires `systemctl` (to manage `openvpn` services) and `dialog` (to show menus).

### Setup guide
1. put your OpenVPN configuration file in `/etc/openvpn/client/`
 _(if the `client` directory does not exist, you can put it in `/etc/openvpn/`)_
1. the file name must end with `.conf`: rename it, if necessary
1. clone or download this repository
1. execute the Bash script

### Hint for "sudo"
In order to avoid annoyances caused by "sudo with password",
 you can exec `sudo visudo -f /etc/sudoers.d/openvpn` and add the following lines to your configuration:
```
### Allow client OpenVPN service management
Cmnd_Alias  OPENVPN = \
 /bin/systemctl start   openvpn-client@*, \
 /bin/systemctl status  openvpn-client@*, \
 /bin/systemctl stop    openvpn-client@*, \
 /bin/systemctl restart openvpn-client@*, \
 /bin/systemctl start   openvpn@*, \
 /bin/systemctl status  openvpn@*, \
 /bin/systemctl stop    openvpn@*, \
 /bin/systemctl restart openvpn@*

%sudo ALL=(ALL:ALL) NOPASSWD:OPENVPN
```
