//
//  SystemMetrics.swift
//  smc_exporter
//
//  System metrics collection for CPU, Memory, and Network usage
//

import Foundation
import Darwin

// MARK: - CPU Usage
struct CPUUsage {
    let user: Double
    let system: Double
    let idle: Double
    let nice: Double
}

struct PerCoreCPUUsage {
    let coreIndex: Int
    let user: Double
    let system: Double
    let idle: Double
    let nice: Double
}

// MARK: - Memory Usage
struct MemoryUsage {
    let total: UInt64
    let used: UInt64
    let free: UInt64
    let cached: UInt64
    let buffers: UInt64
    let available: UInt64
    let swapTotal: UInt64
    let swapUsed: UInt64
    let swapFree: UInt64
}

// MARK: - Network Interface Usage
struct NetworkInterfaceUsage {
    let interface: String
    let bytesReceived: UInt64
    let bytesSent: UInt64
    let packetsReceived: UInt64
    let packetsSent: UInt64
    let errorsReceived: UInt64
    let errorsSent: UInt64
    let dropsReceived: UInt64
    let dropsSent: UInt64
}

// MARK: - System Metrics Collector
class SystemMetrics {
    static let shared = SystemMetrics()
    private init() {}
    
    // MARK: - CPU Usage Collection
    func getCPUUsage() -> CPUUsage? {
        var cpuInfo: processor_info_array_t!
        var numCpuInfo: mach_msg_type_number_t = 0
        var numCpus: natural_t = 0
        
        let result = host_processor_info(mach_host_self(),
                                       PROCESSOR_CPU_LOAD_INFO,
                                       &numCpus,
                                       &cpuInfo,
                                       &numCpuInfo)
        
        guard result == KERN_SUCCESS else { return nil }
        
        let cpuLoadInfo = UnsafeBufferPointer(start: UnsafeRawPointer(cpuInfo).bindMemory(to: processor_cpu_load_info.self, capacity: Int(numCpus)),
                                            count: Int(numCpus))
        
        var totalUser: UInt32 = 0
        var totalSystem: UInt32 = 0
        var totalIdle: UInt32 = 0
        var totalNice: UInt32 = 0
        
        for cpu in cpuLoadInfo {
            totalUser += cpu.cpu_ticks.0    // CPU_STATE_USER
            totalSystem += cpu.cpu_ticks.1  // CPU_STATE_SYSTEM
            totalIdle += cpu.cpu_ticks.2    // CPU_STATE_IDLE
            totalNice += cpu.cpu_ticks.3    // CPU_STATE_NICE
        }
        
        let total = totalUser + totalSystem + totalIdle + totalNice
        
        vm_deallocate(mach_task_self_, vm_address_t(bitPattern: cpuInfo), vm_size_t(numCpuInfo))
        
        guard total > 0 else { return nil }
        
        return CPUUsage(
            user: Double(totalUser) / Double(total),
            system: Double(totalSystem) / Double(total),
            idle: Double(totalIdle) / Double(total),
            nice: Double(totalNice) / Double(total)
        )
    }
    
    // MARK: - Per-Core CPU Usage Collection
    func getPerCoreCPUUsage() -> [PerCoreCPUUsage] {
        var cpuInfo: processor_info_array_t!
        var numCpuInfo: mach_msg_type_number_t = 0
        var numCpus: natural_t = 0
        
        let result = host_processor_info(mach_host_self(),
                                       PROCESSOR_CPU_LOAD_INFO,
                                       &numCpus,
                                       &cpuInfo,
                                       &numCpuInfo)
        
        guard result == KERN_SUCCESS else { return [] }
        
        let cpuLoadInfo = UnsafeBufferPointer(start: UnsafeRawPointer(cpuInfo).bindMemory(to: processor_cpu_load_info.self, capacity: Int(numCpus)),
                                            count: Int(numCpus))
        
        var perCoreUsage: [PerCoreCPUUsage] = []
        
        for (index, cpu) in cpuLoadInfo.enumerated() {
            let user = cpu.cpu_ticks.0      // CPU_STATE_USER
            let system = cpu.cpu_ticks.1    // CPU_STATE_SYSTEM
            let idle = cpu.cpu_ticks.2      // CPU_STATE_IDLE
            let nice = cpu.cpu_ticks.3      // CPU_STATE_NICE
            
            let total = user + system + idle + nice
            
            if total > 0 {
                perCoreUsage.append(PerCoreCPUUsage(
                    coreIndex: index,
                    user: Double(user) / Double(total),
                    system: Double(system) / Double(total),
                    idle: Double(idle) / Double(total),
                    nice: Double(nice) / Double(total)
                ))
            }
        }
        
        vm_deallocate(mach_task_self_, vm_address_t(bitPattern: cpuInfo), vm_size_t(numCpuInfo))
        
        return perCoreUsage
    }
    
    // MARK: - Memory Usage Collection
    func getMemoryUsage() -> MemoryUsage? {
        var vmStat = vm_statistics64()
        var count = mach_msg_type_number_t(MemoryLayout<vm_statistics64>.size / MemoryLayout<integer_t>.size)
        
        let result = withUnsafeMutablePointer(to: &vmStat) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                host_statistics64(mach_host_self(), HOST_VM_INFO64, $0, &count)
            }
        }
        
        guard result == KERN_SUCCESS else { return nil }
        
        let pageSize = UInt64(vm_kernel_page_size)
        
        // Get physical memory
        var physicalMemory: UInt64 = 0
        var size = MemoryLayout<UInt64>.size
        sysctlbyname("hw.memsize", &physicalMemory, &size, nil, 0)
        
        // Get swap usage
        var swapUsage = xsw_usage()
        var swapSize = MemoryLayout<xsw_usage>.size
        sysctlbyname("vm.swapusage", &swapUsage, &swapSize, nil, 0)
        
        let totalPages = physicalMemory / pageSize
        let freePages = UInt64(vmStat.free_count)
        let activePages = UInt64(vmStat.active_count)
        let inactivePages = UInt64(vmStat.inactive_count)
        let wiredPages = UInt64(vmStat.wire_count)
        let compressedPages = UInt64(vmStat.compressor_page_count)
        let purgeable = UInt64(vmStat.purgeable_count)
        let external = UInt64(vmStat.external_page_count)
        
        let usedPages = activePages + inactivePages + wiredPages + compressedPages - purgeable - external
        let cachedPages = inactivePages
        let availablePages = freePages + inactivePages
        
        return MemoryUsage(
            total: totalPages * pageSize,
            used: usedPages * pageSize,
            free: freePages * pageSize,
            cached: cachedPages * pageSize,
            buffers: 0, // Not directly available on macOS
            available: availablePages * pageSize,
            swapTotal: swapUsage.xsu_total,
            swapUsed: swapUsage.xsu_used,
            swapFree: swapUsage.xsu_total - swapUsage.xsu_used
        )
    }
    
    // MARK: - Network Interface Usage Collection
    func getNetworkUsage() -> [NetworkInterfaceUsage] {
        var interfaces: [NetworkInterfaceUsage] = []
        var ifap: UnsafeMutablePointer<ifaddrs>?
        
        guard getifaddrs(&ifap) == 0 else { return interfaces }
        defer { freeifaddrs(ifap) }
        
        var ptr = ifap
        var interfaceStats: [String: (UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64)] = [:]
        
        while ptr != nil {
            defer { ptr = ptr?.pointee.ifa_next }
            
            guard let addr = ptr?.pointee.ifa_addr else { continue }
            guard addr.pointee.sa_family == UInt8(AF_LINK) else { continue }
            
            let name = String(cString: ptr!.pointee.ifa_name)
            
            // Skip loopback and other virtual interfaces for cleaner output
            if name.hasPrefix("lo") || name.hasPrefix("gif") || name.hasPrefix("stf") ||
               name.hasPrefix("awdl") || name.hasPrefix("llw") || name.hasPrefix("utun") {
                continue
            }
            
            let data = UnsafeRawPointer(addr).bindMemory(to: sockaddr_dl.self, capacity: 1)
            if data.pointee.sdl_type == IFT_ETHER {
                let networkData = ptr!.pointee.ifa_data.bindMemory(to: if_data.self, capacity: 1)
                
                let rxBytes = UInt64(networkData.pointee.ifi_ibytes)
                let txBytes = UInt64(networkData.pointee.ifi_obytes)
                let rxPackets = UInt64(networkData.pointee.ifi_ipackets)
                let txPackets = UInt64(networkData.pointee.ifi_opackets)
                let rxErrors = UInt64(networkData.pointee.ifi_ierrors)
                let txErrors = UInt64(networkData.pointee.ifi_oerrors)
                let rxDrops = UInt64(networkData.pointee.ifi_iqdrops)
                let txDrops: UInt64 = 0 // ifi_oqdrops not available on macOS
                
                interfaceStats[name] = (rxBytes, txBytes, rxPackets, txPackets, rxErrors, txErrors, rxDrops, txDrops)
            }
        }
        
        for (name, stats) in interfaceStats {
            interfaces.append(NetworkInterfaceUsage(
                interface: name,
                bytesReceived: stats.0,
                bytesSent: stats.1,
                packetsReceived: stats.2,
                packetsSent: stats.3,
                errorsReceived: stats.4,
                errorsSent: stats.5,
                dropsReceived: stats.6,
                dropsSent: stats.7
            ))
        }
        
        return interfaces.sorted { $0.interface < $1.interface }
    }
}

// MARK: - Prometheus Formatter Extension
extension SystemMetrics {
    func getPrometheusMetrics() -> [String] {
        var result: [String] = []
        let hostname = Host.current().localizedName ?? "unknown"
        
        // CPU Metrics
        result.append("# HELP node_cpu_seconds_total Seconds the cpus spent in each mode.")
        result.append("# TYPE node_cpu_seconds_total counter")
        
        let perCoreUsage = getPerCoreCPUUsage()
        for coreUsage in perCoreUsage {
            result.append("node_cpu_seconds_total{computername=\"\(hostname)\",cpu=\"\(coreUsage.coreIndex)\",mode=\"user\"} \(String(format: "%.6f", coreUsage.user))")
            result.append("node_cpu_seconds_total{computername=\"\(hostname)\",cpu=\"\(coreUsage.coreIndex)\",mode=\"system\"} \(String(format: "%.6f", coreUsage.system))")
            result.append("node_cpu_seconds_total{computername=\"\(hostname)\",cpu=\"\(coreUsage.coreIndex)\",mode=\"idle\"} \(String(format: "%.6f", coreUsage.idle))")
            result.append("node_cpu_seconds_total{computername=\"\(hostname)\",cpu=\"\(coreUsage.coreIndex)\",mode=\"nice\"} \(String(format: "%.6f", coreUsage.nice))")
        }
        
        // Memory Metrics
        if let memUsage = getMemoryUsage() {
            result.append("# HELP node_memory_MemTotal_bytes Memory information field MemTotal_bytes.")
            result.append("# TYPE node_memory_MemTotal_bytes gauge")
            result.append("node_memory_MemTotal_bytes{computername=\"\(hostname)\"} \(memUsage.total)")
            
            result.append("# HELP node_memory_MemFree_bytes Memory information field MemFree_bytes.")
            result.append("# TYPE node_memory_MemFree_bytes gauge")
            result.append("node_memory_MemFree_bytes{computername=\"\(hostname)\"} \(memUsage.free)")
            
            result.append("# HELP node_memory_MemAvailable_bytes Memory information field MemAvailable_bytes.")
            result.append("# TYPE node_memory_MemAvailable_bytes gauge")
            result.append("node_memory_MemAvailable_bytes{computername=\"\(hostname)\"} \(memUsage.available)")
            
            result.append("# HELP node_memory_MemUsed_bytes Memory information field MemAvailable_bytes.")
            result.append("# TYPE node_memory_MemUsed_bytes gauge")
            result.append("node_memory_MemUsed_bytes{computername=\"\(hostname)\"} \(memUsage.used)")
            
            result.append("# HELP node_memory_Cached_bytes Memory information field Cached_bytes.")
            result.append("# TYPE node_memory_Cached_bytes gauge")
            result.append("node_memory_Cached_bytes{computername=\"\(hostname)\"} \(memUsage.cached)")
            
            result.append("# HELP node_memory_SwapTotal_bytes Memory information field SwapTotal_bytes.")
            result.append("# TYPE node_memory_SwapTotal_bytes gauge")
            result.append("node_memory_SwapTotal_bytes{computername=\"\(hostname)\"} \(memUsage.swapTotal)")
            
            result.append("# HELP node_memory_SwapFree_bytes Memory information field SwapFree_bytes.")
            result.append("# TYPE node_memory_SwapFree_bytes gauge")
            result.append("node_memory_SwapFree_bytes{computername=\"\(hostname)\"} \(memUsage.swapFree)")
        }
        
        // Network Metrics
        let networkUsages = getNetworkUsage()
        
        if !networkUsages.isEmpty {
            result.append("# HELP node_network_receive_bytes_total Network device statistic receive_bytes.")
            result.append("# TYPE node_network_receive_bytes_total counter")
            for netUsage in networkUsages {
                result.append("node_network_receive_bytes_total{computername=\"\(hostname)\",device=\"\(netUsage.interface)\"} \(netUsage.bytesReceived)")
            }
            
            result.append("# HELP node_network_transmit_bytes_total Network device statistic transmit_bytes.")
            result.append("# TYPE node_network_transmit_bytes_total counter")
            for netUsage in networkUsages {
                result.append("node_network_transmit_bytes_total{computername=\"\(hostname)\",device=\"\(netUsage.interface)\"} \(netUsage.bytesSent)")
            }
            
            result.append("# HELP node_network_receive_packets_total Network device statistic receive_packets.")
            result.append("# TYPE node_network_receive_packets_total counter")
            for netUsage in networkUsages {
                result.append("node_network_receive_packets_total{computername=\"\(hostname)\",device=\"\(netUsage.interface)\"} \(netUsage.packetsReceived)")
            }
            
            result.append("# HELP node_network_transmit_packets_total Network device statistic transmit_packets.")
            result.append("# TYPE node_network_transmit_packets_total counter")
            for netUsage in networkUsages {
                result.append("node_network_transmit_packets_total{computername=\"\(hostname)\",device=\"\(netUsage.interface)\"} \(netUsage.packetsSent)")
            }
            
            result.append("# HELP node_network_receive_errs_total Network device statistic receive_errs.")
            result.append("# TYPE node_network_receive_errs_total counter")
            for netUsage in networkUsages {
                result.append("node_network_receive_errs_total{computername=\"\(hostname)\",device=\"\(netUsage.interface)\"} \(netUsage.errorsReceived)")
            }
            
            result.append("# HELP node_network_transmit_errs_total Network device statistic transmit_errs.")
            result.append("# TYPE node_network_transmit_errs_total counter")
            for netUsage in networkUsages {
                result.append("node_network_transmit_errs_total{computername=\"\(hostname)\",device=\"\(netUsage.interface)\"} \(netUsage.errorsSent)")
            }
            
            result.append("# HELP node_network_receive_drop_total Network device statistic receive_drop.")
            result.append("# TYPE node_network_receive_drop_total counter")
            for netUsage in networkUsages {
                result.append("node_network_receive_drop_total{computername=\"\(hostname)\",device=\"\(netUsage.interface)\"} \(netUsage.dropsReceived)")
            }
            
            result.append("# HELP node_network_transmit_drop_total Network device statistic transmit_drop.")
            result.append("# TYPE node_network_transmit_drop_total counter")
            for netUsage in networkUsages {
                result.append("node_network_transmit_drop_total{computername=\"\(hostname)\",device=\"\(netUsage.interface)\"} \(netUsage.dropsSent)")
            }
        }
        
        return result
    }
}
