# openvpn-service-helper

### Why?
This is the case:
* you are using a Linux distribution shipped with [network-manager](https://wiki.debian.org/NetworkManager)
* your company decides to use OpenVPN, letting you log in with **certificate and password**
* you are excited while discovering that NetworkManager can manage [OpenVPN connections](https://launchpad.net/network-manager-openvpn) :)
* your company decides to add a **third factor** for logging into its VPN: a challenge (like Google Authenticator) 
* despite "network-manager-openvpn" [seems to support the dynamic challenge-response protocol](https://launchpad.net/ubuntu/+source/network-manager-openvpn/1.2.10-0ubuntu1),
you experience that it does not work in this case :'(

That's why you wish a little _help_ for starting and stopping this ~~damned~~ VPN ;)

### How it looks like
Choice among several VPN configurations (only if there are many files in `/etc/openvpn/client/*.conf`).
![selection](https://github.com/fabricat/openvpn-service-helper/blob/screenshots/demo-selection.png?raw=true)

Here is the menu with **status of the VPN** (on the top) and the possible actions.
![actions](https://github.com/fabricat/openvpn-service-helper/blob/screenshots/demo-actions.png?raw=true)

### Requirements and limitations
Currently this script works only with **client** configurations of OpenVPN: 
it recognizes only config files matching with `/etc/openvpn/client/*.conf`

Moreover, it requires `systemctl` (to manage `openvpn` services) and `dialog` (to show menus).

### Guide
1. put your OpenVPN configuration file in `/etc/openvpn/client/`
1. the file name must end with `.conf`: rename it, if necessary
1. clone or download this repository
1. execute the script `openvpn.sh`

### Hint
In order to avoid annoyances caused by "sudo with password", 
you can exec `sudo visudo -f /etc/sudoers.d/openvpn` and add the following lines to your configuration:
```
### Allow client OpenVPN service management
Cmnd_Alias  OPENVPN = /bin/systemctl start openvpn-client@*, /bin/systemctl status openvpn-client@*, /bin/systemctl stop openvpn-client@*, /bin/systemctl restart openvpn-client@*

%sudo ALL=(ALL:ALL) NOPASSWD:OPENVPN
```
