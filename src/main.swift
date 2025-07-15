//
//  main.swift
//  smc_exporter
//
//  Created by Eric Hemmeter on 4/8/24.
//
  
//  This exporter is designed to be run by a LauchDaemon
//
//  <?xml version="1.0" encoding="UTF-8"?>
//  <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
//  <plist version="1.0">
//  <dict>
//      <key>Label</key>
//      <string>org.rskgroup.smc_exporter</string>
//      <key>RunAtLoad</key>
//      <true/>
//      <key>KeepAlive</key>
//      <true/>
//      <key>ProgramArguments</key>
//      <array>
//          <string>/usr/local/bin/smc_exporter</string>
//          <string>9119</string>
//          <string>temperature</string>
//          <string>fans</string>
//          <string>power</string>
//      </array>
//  </dict>
//  </plist>
  
//  The arguments allowed are port number (defaults to 9101),
//  then a list of sensor types you want from
//  'temperature', 'voltage', 'current', 'power', and 'fans' (they can all be singular or plural)
//  you can also put 'all' for all of them
//  the default with no sensors listed is 'temperature' only
  
//  Sensors and smc.swift adapted from https://github.com/exelban/stats
  
import Foundation
import NIO
import NIOHTTP1
  
let currentHost = Host.current().localizedName ?? ""
let defaultPort = 9101
let arguments = CommandLine.arguments
//let execName = URL(filePath: arguments.first!).lastPathComponent
let arg1 = arguments.dropFirst().first
if arg1 == "-h" || arg1 == "help" || arg1 == "--help" {
    print(
"""
Usage:
This exporter is designed to be run by a LauchDaemon, i.e.
  
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>org.rskgroup.smc_exporter</string>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
    <key>ProgramArguments</key>
    <array>
        <string>/usr/local/bin/smc_exporter</string>
        <string>9119</string>
        <string>temperature</string>
        <string>fans</string>
        <string>power</string>
    </array>
</dict>
</plist>
  
The arguments allowed are port number (defaults to 9101),
then a list of sensor types you want from
'temperature', 'voltage', 'current', 'power', and 'fans' (they can all be singular or plural)
you can also put 'all' for all of them
the default with no sensors listed is 'temperature' only
  
Sensors and smc.swift adapted from https://github.com/exelban/stats
"""
    )
    exit(0)
}
let port = Int(arg1 ?? "\(defaultPort)")
var modules = arguments.dropFirst(2)
  
  
let app = Exporter()
app.listen(port ?? defaultPort)

// Structure to hold metric data
struct MetricData {
    let name: String
    let help: String
    let type: String
    var values: [(labels: String, value: String)] = []
}

func getOutput() throws -> [String] {
    var result: [String] = []
    var metricsMap: [String: MetricData] = [:]
    var relevantKeys: [String] = []
  
    if modules.isEmpty {
        modules.append("temperatures")
    } else if modules.first == "all" {
        modules.append("temperatures")
        modules.append("voltages")
        modules.append("current")
        modules.append("power")
        modules.append("fans")
        modules.append("cpu")
        modules.append("memory")
        modules.append("network")
    }
    
    // System metrics (CPU, Memory, Network)
    let systemMetricsEnabled = modules.contains("cpu") || modules.contains("memory") || modules.contains("network")
    if systemMetricsEnabled {
        let systemMetrics = SystemMetrics.shared.getPrometheusMetrics()
        result.append(contentsOf: systemMetrics)
    }
    
    let allKeys = SMC.shared.getAllKeys()
  
    if modules.contains("temperature") || modules.contains("temperatures") {
        relevantKeys.append(contentsOf: allKeys.filter({ key in
            let type = SensorsList.filter({$0.key == key}).first?.type
            return type == .temperature
        }))
    }
    if modules.contains("voltages") || modules.contains("voltage") {
        relevantKeys.append(contentsOf: allKeys.filter({ key in
            let type = SensorsList.filter({$0.key == key}).first?.type
            return type == .voltage
        }))
    }
    if modules.contains("currents") || modules.contains("current") {
        relevantKeys.append(contentsOf: allKeys.filter({ key in
            let type = SensorsList.filter({$0.key == key}).first?.type
            return type == .current
        }))
    }
    if modules.contains("powers") || modules.contains("power") {
        relevantKeys.append(contentsOf: allKeys.filter({ key in
            let type = SensorsList.filter({$0.key == key}).first?.type
            return type == .power
        }))
    }
    
    // Add chip names metric
    if !metricsMap.keys.contains("node_hwmon_chip_names") {
        metricsMap["node_hwmon_chip_names"] = MetricData(
            name: "node_hwmon_chip_names",
            help: "Chip names detected by the exporter",
            type: "gauge"
        )
    }
  
    relevantKeys.forEach { (key: String) in
        if SensorsList.contains(where: {$0.key == key} ) {
            let value = SMC.shared.getValue(key)
            let name = SensorsList.filter({$0.key == key}).first?.name ?? ""
            let displayValue = String(format: "%.2f", value ?? 0)
            let type = SensorsList.filter({$0.key == key}).first?.type.rawValue ?? ""
            var metricsName = ""
            var help = ""
            
            switch type {
            case "Temperature":
                metricsName = "node_hwmon_temp_celsius"
                help = "Hardware monitor for temperature (celsius)"
            case "Power":
                metricsName = "node_hwmon_power_watts"
                help = "Hardware monitor for power consumption (watts)"
            case "Voltage":
                metricsName = "node_hwmon_in_volts"
                help = "Hardware monitor for voltage (volts)"
            case "Current":
                metricsName = "node_hwmon_curr_amps"
                help = "Hardware monitor for current (amps)"
            default:
                metricsName = "node_hwmon_" + type
                help = "Hardware monitor for \(type)"
            }
            
            // Add chip name entry
            metricsMap["node_hwmon_chip_names"]?.values.append((
                labels: "computername=\"\(currentHost)\",chip=\"\(key)\",chip_name=\"\(name)\"",
                value: "1"
            ))
            
            // Add metric entry
            if !metricsMap.keys.contains(metricsName) {
                metricsMap[metricsName] = MetricData(
                    name: metricsName,
                    help: help,
                    type: "gauge"
                )
            }
            metricsMap[metricsName]?.values.append((
                labels: "computername=\"\(currentHost)\",chip=\"\(key)\"",
                value: displayValue
            ))
        }
    }
  
    if modules.contains("fans") || modules.contains("fan") {
        let count = SMC.shared.getValue("FNum")
        
        // Initialize fan metric if needed
        if !metricsMap.keys.contains("node_hwmon_fan_rpm") {
            metricsMap["node_hwmon_fan_rpm"] = MetricData(
                name: "node_hwmon_fan_rpm",
                help: "Hardware monitor for fan speed (RPM)",
                type: "gauge"
            )
        }
        
        for i in 0..<Int(count!) {
            var name = SMC.shared.getStringValue("F\(i)ID")
            if name == nil && count == 2 {
                switch i {
                case 0:
                    name = "Left fan"
                case 1:
                    name = "Right fan"
                default: break
                }
            }
            let minSpeed = SMC.shared.getValue("F\(i)Mn") ?? 1
            let maxSpeed = SMC.shared.getValue("F\(i)Mx") ?? 1
            let value = SMC.shared.getValue("F\(i)Ac") ?? 0
            
            // Add chip name entry
            metricsMap["node_hwmon_chip_names"]?.values.append((
                labels: "computername=\"\(currentHost)\",chip=\"F\(i)ID\",chip_name=\"\(name!)\"",
                value: "1"
            ))
            
            // Add fan metric entry
            metricsMap["node_hwmon_fan_rpm"]?.values.append((
                labels: "computername=\"\(currentHost)\",chip=\"F\(i)ID\",min_speed=\"\(minSpeed)\",max_speed=\"\(maxSpeed)\"",
                value: String(format: "%.0f", value)
            ))
        }
    }
    
    // Convert metrics map to output format
    let sortedMetrics = metricsMap.keys.sorted()
    for metricName in sortedMetrics {
        if let metric = metricsMap[metricName] {
            result.append("# HELP \(metric.name) \(metric.help)")
            result.append("# TYPE \(metric.name) \(metric.type)")
            for (labels, value) in metric.values {
                result.append("\(metric.name){\(labels)} \(value)")
            }
        }
    }
    
    return result
}
  
open class Exporter {
    let loopGroup =
    MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount)
    open func listen(_ port: Int) {
        let reuseAddrOpt = ChannelOptions.socket(
            SocketOptionLevel(SOL_SOCKET),
            SO_REUSEADDR)
        let bootstrap = ServerBootstrap(group: loopGroup)
            .serverChannelOption(ChannelOptions.backlog, value: 256)
            .serverChannelOption(reuseAddrOpt, value: 1)
            .childChannelInitializer { channel in
                channel.pipeline.configureHTTPServerPipeline().flatMap {
                    channel.pipeline.addHandler(HTTPHandler())
                  }
            }
            .childChannelOption(ChannelOptions.socket(
                IPPROTO_TCP, TCP_NODELAY), value: 1)
            .childChannelOption(reuseAddrOpt, value: 1)
            .childChannelOption(ChannelOptions.maxMessagesPerRead,
                                value: 1)
        do {
            let serverChannel =
            try bootstrap.bind(host: "0.0.0.0", port: port)
                .wait()
            print("Server running on:", serverChannel.localAddress!)
            try serverChannel.closeFuture.wait() // runs forever
        }
        catch {
            fatalError("failed to start server: \(error)")
        }
    }
    final class HTTPHandler : ChannelInboundHandler {
        typealias InboundIn = HTTPServerRequestPart
        func channelRead(context: ChannelHandlerContext, data: NIOAny) {
            let reqPart = unwrapInboundIn(data)
            switch reqPart {
            case .head(let header):
                let channel = context.channel
                
                var output = [""]
                do {
                    output = try getOutput()
                } catch {
                    print("Getting TM Status failed - \(error)")
                    output = ["# Getting TM Status failed - \(error)","# Needs Full Disk Access"]
                }
                
                let content = output.joined(separator: "\n") + "\n"
                let buf = ByteBuffer(string: content)
                
                var headers = HTTPHeaders()
                headers.add(name: "Content-Type", value: "text/plain; version=0.0.4")
                headers.add(name: "Content-Length", value: String(buf.readableBytes))
                
                let head = HTTPResponseHead(
                    version: header.version,
                    status: .ok,
                    headers: headers
                )
                
                let part = HTTPServerResponsePart.head(head)
                _ = channel.write(part)
                
                let bodypart = HTTPServerResponsePart.body(.byteBuffer(buf))
                _ = channel.write(bodypart)
                
                let endpart = HTTPServerResponsePart.end(nil)
                _ = channel.writeAndFlush(endpart).flatMap {
                    channel.close()
                }
            case .body, .end: break
            }
        }
    }
}
