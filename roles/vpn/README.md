# OpenVPN

This is the standard 'upstream' sovereign OpenVPN stuff.
The files that you need are now in secret/sovereign-openvpn-files.
Make sure LZO compression is enabled and that you provide the ta.key file for the TLS-Auth option with a direction of '1'.

The one major change is the option of enabling 'openvpn_enable_sub_routing' in your config.
See the defaults in here for the available settings.

This then looks something like:

       ----------
      | VPS      |
      | 10.8.0.1 |
       ----------
         |
         | Internet
         | VPN
         |            -----------
         |-----------| Phone     |
         |           | 10.8.0.42 |
         |            -----------
         |
       --|------------------------------------------
      |  |                                     Home |
      |  |                                          |
      |  |      -------------       -------------   |
      |  |     | Router      |     | Bridge      |  |
      |   -----| 192.168.0.1 |-----| 192.168.0.2 |  |
      |        |             |     | 10.8.0.2    |  |
      |         -------------       -------------   |
      |               |                             |
      |               |                             |
      |         -------------                       |
      |        | Server      |                      |
      |        | 192.168.0.3 |                      |
      |         -------------                       |
       ---------------------------------------------

In this scenario, your devices 'on the go', like the Phone above, want to connect to devices in your home network, like the Server, via the VPN connection over our sovereign VPS.
This can easily accomplished with these configs.
For the devices in your home network to be able to reach the devices on the VPN network, you need to add a static route to the Router above, that routes all traffic for 10.8.0.0/24 via 192.168.0.2, the Bridge.

On the Bridge, do something like this, after installing eg. Ubuntu Server on the machine:

    ssh-copy-id -i ~/.ssh/id_ecdsa thomas@vpn-bridge
    scp sovereign/secret/sovereign-openvpn-files/eddie.xythobuz.de/etc/openvpn/nas/xythobuz.de.ovpn bridge:~/client.ovpn
    ssh bridge
    sudo apt-get install openvpn
    sudo cp client.ovpn /etc/openvpn/client_vpn.conf
    
    sudo vim /etc/sysctl.conf
    # uncomment line net.ipv4.ip_forward=1
    
    sudo reboot

This will then allow devices connected to the VPN to just reach the 192.168.0.X devices without any further configuration.
