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


### Requirements and limitations
Currently this script works only with **client** configurations of OpenVPN: 
it recognizes only config files matching with `/etc/openvpn/client/*.conf`

Moreover, it requires `systemctl` (to manage `openvpn` services) and `dialog` (to show menus).

### Hint
In order to avoid interruptions by "sudo with password", 
you can exec `sudo visudo -f /etc/sudoers.d/openvpn` and add the following configuration:
```
### Allow client OpenVPN service management
Cmnd_Alias  OPENVPN = /bin/systemctl start openvpn-client@*, /bin/systemctl status openvpn-client@*, /bin/systemctl stop openvpn-cl$

%sudo ALL=(ALL:ALL) NOPASSWD:OPENVPN
```
