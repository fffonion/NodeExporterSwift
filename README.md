# NodeExporterSwift
### Swift SMC and system metrics monitor for Prometheus

Example output:

```
# HELP node_cpu_seconds_total Seconds the cpus spent in each mode.
# TYPE node_cpu_seconds_total counter
node_cpu_seconds_total{computername="macbook",cpu="0",mode="user"} 0.229758
node_cpu_seconds_total{computername="macbook",cpu="0",mode="system"} 0.150229
node_cpu_seconds_total{computername="macbook",cpu="0",mode="idle"} 0.620013
node_cpu_seconds_total{computername="macbook",cpu="0",mode="nice"} 0.000000
node_cpu_seconds_total{computername="macbook",cpu="1",mode="user"} 0.214513
node_cpu_seconds_total{computername="macbook",cpu="1",mode="system"} 0.125363
node_cpu_seconds_total{computername="macbook",cpu="1",mode="idle"} 0.660124
node_cpu_seconds_total{computername="macbook",cpu="1",mode="nice"} 0.000000
# HELP node_memory_MemTotal_bytes Memory information field MemTotal_bytes.
# TYPE node_memory_MemTotal_bytes gauge
node_memory_MemTotal_bytes{computername="macbook"} 38654705664
# HELP node_memory_MemFree_bytes Memory information field MemFree_bytes.
# TYPE node_memory_MemFree_bytes gauge
node_memory_MemFree_bytes{computername="macbook"} 157876224
# HELP node_memory_MemAvailable_bytes Memory information field MemAvailable_bytes.
# TYPE node_memory_MemAvailable_bytes gauge
node_memory_MemAvailable_bytes{computername="macbook"} 6143295488
# HELP node_memory_Cached_bytes Memory information field Cached_bytes.
# TYPE node_memory_Cached_bytes gauge
node_memory_Cached_bytes{computername="macbook"} 5985419264
# HELP node_memory_SwapTotal_bytes Memory information field SwapTotal_bytes.
# TYPE node_memory_SwapTotal_bytes gauge
node_memory_SwapTotal_bytes{computername="macbook"} 5368709120
# HELP node_memory_SwapFree_bytes Memory information field SwapFree_bytes.
# TYPE node_memory_SwapFree_bytes gauge
node_memory_SwapFree_bytes{computername="macbook"} 1428029440
# HELP node_network_receive_bytes_total Network device statistic receive_bytes.
# TYPE node_network_receive_bytes_total counter
node_network_receive_bytes_total{computername="macbook",device="en0"} 2291641344
# HELP node_network_transmit_bytes_total Network device statistic transmit_bytes.
# TYPE node_network_transmit_bytes_total counter
node_network_transmit_bytes_total{computername="macbook",device="en0"} 359959552
# HELP node_network_receive_packets_total Network device statistic receive_packets.
# TYPE node_network_receive_packets_total counter
node_network_receive_packets_total{computername="macbook",device="en0"} 2481024
# HELP node_network_transmit_packets_total Network device statistic transmit_packets.
# TYPE node_network_transmit_packets_total counter
node_network_transmit_packets_total{computername="macbook",device="en0"} 1691358
# HELP node_network_receive_errs_total Network device statistic receive_errs.
# TYPE node_network_receive_errs_total counter
node_network_receive_errs_total{computername="macbook",device="en0"} 0
# HELP node_network_transmit_errs_total Network device statistic transmit_errs.
# TYPE node_network_transmit_errs_total counter
node_network_transmit_errs_total{computername="macbook",device="en0"} 0
# HELP node_network_receive_drop_total Network device statistic receive_drop.
# TYPE node_network_receive_drop_total counter
node_network_receive_drop_total{computername="macbook",device="en0"} 0
# HELP node_network_transmit_drop_total Network device statistic transmit_drop.
# TYPE node_network_transmit_drop_total counter
node_network_transmit_drop_total{computername="macbook",device="en0"} 0
# HELP node_hwmon_chip_names Chip names detected by the exporter
# TYPE node_hwmon_chip_names gauge
node_hwmon_chip_names{computername="macbook",chip="TB1T",chip_name="Battery"} 1
node_hwmon_chip_names{computername="macbook",chip="TB2T",chip_name="Battery 2"} 1
node_hwmon_chip_names{computername="macbook",chip="TG0H",chip_name="GPU heatsink"} 1
node_hwmon_chip_names{computername="macbook",chip="TH0x",chip_name="NAND"} 1
node_hwmon_chip_names{computername="macbook",chip="TW0P",chip_name="Airport"} 1
node_hwmon_chip_names{computername="macbook",chip="TaLP",chip_name="Airflow left"} 1
node_hwmon_chip_names{computername="macbook",chip="TaRF",chip_name="Airflow right"} 1
node_hwmon_chip_names{computername="macbook",chip="Te05",chip_name="CPU efficiency core 1"} 1
node_hwmon_chip_names{computername="macbook",chip="Te0S",chip_name="CPU efficiency core 4"} 1
node_hwmon_chip_names{computername="macbook",chip="Tf04",chip_name="CPU performance core 1"} 1
node_hwmon_chip_names{computername="macbook",chip="Tf09",chip_name="CPU performance core 2"} 1
node_hwmon_chip_names{computername="macbook",chip="Tf0A",chip_name="CPU performance core 3"} 1
node_hwmon_chip_names{computername="macbook",chip="Tf0B",chip_name="CPU performance core 4"} 1
node_hwmon_chip_names{computername="macbook",chip="Tf14",chip_name="GPU 1"} 1
node_hwmon_chip_names{computername="macbook",chip="Tf18",chip_name="GPU 2"} 1
node_hwmon_chip_names{computername="macbook",chip="Tf19",chip_name="GPU 3"} 1
node_hwmon_chip_names{computername="macbook",chip="Tf1A",chip_name="GPU 4"} 1
node_hwmon_chip_names{computername="macbook",chip="Tf24",chip_name="GPU 5"} 1
node_hwmon_chip_names{computername="macbook",chip="Tf28",chip_name="GPU 6"} 1
node_hwmon_chip_names{computername="macbook",chip="Tf29",chip_name="GPU 7"} 1
node_hwmon_chip_names{computername="macbook",chip="Tf2A",chip_name="GPU 8"} 1
node_hwmon_chip_names{computername="macbook",chip="Tf44",chip_name="CPU performance core 7"} 1
node_hwmon_chip_names{computername="macbook",chip="Tf49",chip_name="CPU performance core 8"} 1
node_hwmon_chip_names{computername="macbook",chip="Tf4A",chip_name="CPU performance core 9"} 1
node_hwmon_chip_names{computername="macbook",chip="Tf4B",chip_name="CPU performance core 10"} 1
node_hwmon_chip_names{computername="macbook",chip="Tg05",chip_name="GPU 1"} 1
node_hwmon_chip_names{computername="macbook",chip="Tg0L",chip_name="GPU 3"} 1
node_hwmon_chip_names{computername="macbook",chip="Tg0j",chip_name="GPU 2"} 1
node_hwmon_chip_names{computername="macbook",chip="Tp01",chip_name="CPU performance core 1"} 1
node_hwmon_chip_names{computername="macbook",chip="Tp05",chip_name="CPU performance core 2"} 1
node_hwmon_chip_names{computername="macbook",chip="Tp09",chip_name="CPU efficiency core 1"} 1
node_hwmon_chip_names{computername="macbook",chip="Tp0D",chip_name="CPU performance core 3"} 1
node_hwmon_chip_names{computername="macbook",chip="Tp0H",chip_name="CPU performance core 4"} 1
node_hwmon_chip_names{computername="macbook",chip="Tp0L",chip_name="CPU performance core 5"} 1
node_hwmon_chip_names{computername="macbook",chip="Tp0P",chip_name="Powerboard"} 1
node_hwmon_chip_names{computername="macbook",chip="Tp0T",chip_name="CPU efficiency core 2"} 1
node_hwmon_chip_names{computername="macbook",chip="Tp0X",chip_name="CPU performance core 7"} 1
node_hwmon_chip_names{computername="macbook",chip="Tp0b",chip_name="CPU performance core 8"} 1
node_hwmon_chip_names{computername="macbook",chip="Tp0f",chip_name="CPU performance core 7"} 1
node_hwmon_chip_names{computername="macbook",chip="Tp1t",chip_name="CPU efficiency core 2"} 1
node_hwmon_chip_names{computername="macbook",chip="VD0R",chip_name="DC In"} 1
node_hwmon_chip_names{computername="macbook",chip="VP0R",chip_name="12V rail"} 1
node_hwmon_chip_names{computername="macbook",chip="ID0R",chip_name="DC In"} 1
node_hwmon_chip_names{computername="macbook",chip="PDBR",chip_name="Power Delivery Brightness"} 1
node_hwmon_chip_names{computername="macbook",chip="PDTR",chip_name="DC In"} 1
node_hwmon_chip_names{computername="macbook",chip="PPBR",chip_name="Battery"} 1
node_hwmon_chip_names{computername="macbook",chip="PSTR",chip_name="System Total"} 1
node_hwmon_chip_names{computername="macbook",chip="F0ID",chip_name="Left fan"} 1
node_hwmon_chip_names{computername="macbook",chip="F1ID",chip_name="Right fan"} 1
# HELP node_hwmon_curr_amps Hardware monitor for current (amps)
# TYPE node_hwmon_curr_amps gauge
node_hwmon_curr_amps{computername="macbook",chip="ID0R"} 0.42
# HELP node_hwmon_fan_rpm Hardware monitor for fan speed (RPM)
# TYPE node_hwmon_fan_rpm gauge
node_hwmon_fan_rpm{computername="macbook",chip="F0ID",min_speed="2317.0",max_speed="7826.0"} 0
node_hwmon_fan_rpm{computername="macbook",chip="F1ID",min_speed="2317.0",max_speed="7826.0"} 0
# HELP node_hwmon_in_volts Hardware monitor for voltage (volts)
# TYPE node_hwmon_in_volts gauge
node_hwmon_in_volts{computername="macbook",chip="VD0R"} 19.60
node_hwmon_in_volts{computername="macbook",chip="VP0R"} 12.54
# HELP node_hwmon_power_watts Hardware monitor for power consumption (watts)
# TYPE node_hwmon_power_watts gauge
node_hwmon_power_watts{computername="macbook",chip="PDBR"} 1.72
node_hwmon_power_watts{computername="macbook",chip="PDTR"} 8.21
node_hwmon_power_watts{computername="macbook",chip="PPBR"} 0.37
node_hwmon_power_watts{computername="macbook",chip="PSTR"} 11.62
# HELP node_hwmon_temp_celsius Hardware monitor for temperature (celsius)
# TYPE node_hwmon_temp_celsius gauge
node_hwmon_temp_celsius{computername="macbook",chip="TB1T"} 32.50
node_hwmon_temp_celsius{computername="macbook",chip="TB2T"} 32.30
node_hwmon_temp_celsius{computername="macbook",chip="TG0H"} 0.00
node_hwmon_temp_celsius{computername="macbook",chip="TH0x"} 36.79
node_hwmon_temp_celsius{computername="macbook",chip="TW0P"} 41.20
node_hwmon_temp_celsius{computername="macbook",chip="TaLP"} 39.64
node_hwmon_temp_celsius{computername="macbook",chip="TaRF"} 39.77
node_hwmon_temp_celsius{computername="macbook",chip="Te05"} 51.32
node_hwmon_temp_celsius{computername="macbook",chip="Te0S"} 50.93
node_hwmon_temp_celsius{computername="macbook",chip="Tf04"} 45.38
node_hwmon_temp_celsius{computername="macbook",chip="Tf09"} 44.93
node_hwmon_temp_celsius{computername="macbook",chip="Tf0A"} 44.59
node_hwmon_temp_celsius{computername="macbook",chip="Tf0B"} 45.25
node_hwmon_temp_celsius{computername="macbook",chip="Tf14"} 44.35
node_hwmon_temp_celsius{computername="macbook",chip="Tf18"} 43.80
node_hwmon_temp_celsius{computername="macbook",chip="Tf19"} 44.22
node_hwmon_temp_celsius{computername="macbook",chip="Tf1A"} 44.20
node_hwmon_temp_celsius{computername="macbook",chip="Tf24"} 44.34
node_hwmon_temp_celsius{computername="macbook",chip="Tf28"} 43.97
node_hwmon_temp_celsius{computername="macbook",chip="Tf29"} 44.34
node_hwmon_temp_celsius{computername="macbook",chip="Tf2A"} 43.83
node_hwmon_temp_celsius{computername="macbook",chip="Tf44"} 45.40
node_hwmon_temp_celsius{computername="macbook",chip="Tf49"} 45.11
node_hwmon_temp_celsius{computername="macbook",chip="Tf4A"} 45.25
node_hwmon_temp_celsius{computername="macbook",chip="Tf4B"} 45.39
node_hwmon_temp_celsius{computername="macbook",chip="Tg05"} 49.87
node_hwmon_temp_celsius{computername="macbook",chip="Tg0L"} 44.30
node_hwmon_temp_celsius{computername="macbook",chip="Tg0j"} 44.11
node_hwmon_temp_celsius{computername="macbook",chip="Tp01"} 40.00
node_hwmon_temp_celsius{computername="macbook",chip="Tp05"} 40.00
node_hwmon_temp_celsius{computername="macbook",chip="Tp09"} 40.00
node_hwmon_temp_celsius{computername="macbook",chip="Tp0D"} 40.00
node_hwmon_temp_celsius{computername="macbook",chip="Tp0H"} 40.00
node_hwmon_temp_celsius{computername="macbook",chip="Tp0L"} 40.00
node_hwmon_temp_celsius{computername="macbook",chip="Tp0P"} 40.00
node_hwmon_temp_celsius{computername="macbook",chip="Tp0T"} 40.00
node_hwmon_temp_celsius{computername="macbook",chip="Tp0X"} 40.00
node_hwmon_temp_celsius{computername="macbook",chip="Tp0b"} 40.00
node_hwmon_temp_celsius{computername="macbook",chip="Tp0f"} 40.00
node_hwmon_temp_celsius{computername="macbook",chip="Tp1t"} 1.50
```

Usage:
This exporter is designed to be run by a LauchDaemon, i.e.

```xml
<?xml version="1.0" encoding="UTF-8"?>  
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">  
<plist version="1.0">  
<dict>  
    <key>Label</key>  
    <string>io.prometheus.node_exporter_swift</string>  
    <key>RunAtLoad</key>  
    <true/>  
    <key>KeepAlive</key>  
    <true/>  
    <key>ProgramArguments</key>  
    <array>  
        <string>/usr/local/bin/node_exporter_swift</string>  
        <string>9119</string>  
        <string>temperature</string>  
        <string>fans</string>  
        <string>power</string>  
    </array>  
</dict>  
</plist>  
```

The arguments allowed are port number (defaults to 9101),  
then a list of sensor types you want from (they can all be singular or plural)  
* 	`temperature(s)`    
* 	`voltage(s)`  
* 	`current(s)`   
* 	`power(s)`  
* 	`fan(s)`  
*   `cpu(s)`
*   `network(s)`
*   `ram(s)`

you can also put `all` for all of them.  
the default with no sensors listed is `temperature` only  

Sensors and smc.swift adapted from https://github.com/exelban/stats

smc_exporter_installer.pkgproj is a [Packages](http://s.sudre.free.fr/Software/Packages/about.html) project file to install the binary into `/usr/loca/bin/smc_exporter` and the io.prometheus.node_exporter_swift.plist LaunchDaemon into /Library/LaunchDaemons, with a postinstall to bootout an existing LaunchDaemon and bootstrap the new one.

## Credits

- SMC code adapted from [RSKGroup/smc_exporter](https://github.com/RSKGroup/smc_exporter)