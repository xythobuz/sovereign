# Design Description for IoT Role

This role works differently compared to the others.
It installs the basics for a home automation setup:

 * InfluxDB time series database
 * Grafana visualizations
 * Mosquitto MQTT broker
 * Node-Red scripting language

It does not work with subdomains, everything runs under one domain.
The top level routes to grafana.
Going to the /nodered subdirectory leads to Node-Red.
Going to /mqtt gets an MQTT-Admin UI.

The ports for MQTT (with and without ssl, 1883 and 8883 respectively), as well as for MQTT SSL WebSockets (8083) will be opened in the firewall.

This should be used together with the sslselfsigned role!
When monitoring role is used as well, it can be accessed under /monit.
