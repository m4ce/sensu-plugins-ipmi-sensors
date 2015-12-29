# Sensu plugin for monitoring IPMI sensors

A sensu plugin to monitor IPMI sensors.

The plugin generates multiple OK/WARN/CRIT/UNKNOWN events via the sensu client socket (https://sensuapp.org/docs/latest/clients#client-socket-input)
so that you do not miss state changes when monitoring multiple sensors.

## Usage

The plugin accepts the following command line options:

```
Usage: check-ipmi-sensors.rb (options)
        --driver <driver>            IPMI driver (default: auto)
    -H, --host <HOST>                IPMI host (default: localhost)
        --ignore-sensor <SENSOR>     Comma separated list of IPMI sensors to ignore
        --ignore-sensor-regex <SENSOR>
                                     Comma separated list of IPMI sensors to ignore (regex)
    -p, --password <PASSWORD>        IPMI password (required)
        --provider <PROVIDER>        IPMI provider (default: auto)
        --sensor <SENSOR>            Comma separated list of IPMI sensors (default: ALL)
        --sensor-regex <SENSOR>      Comma separated list of IPMI sensors (regex)
    -u, --user <USER>                IPMI username (required)
    -w, --warn                       Warn instead of throwing a critical failure
```

## Author
Matteo Cerutti - <matteo.cerutti@hotmail.co.uk>
