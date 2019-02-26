# openvpn-service-helper
OpenVPN service helper

Currently this script works only with **client** configurations of OpenVPN.

### Hint
You can exec `sudo visudo -f /etc/sudoers.d/openvpn` and add the following configuration:
```
### Allow client OpenVPN service management
Cmnd_Alias  OPENVPN = /bin/systemctl start openvpn-client@*, /bin/systemctl status openvpn-client@*, /bin/systemctl stop openvpn-cl$

%sudo ALL=(ALL:ALL) NOPASSWD:OPENVPN
```
