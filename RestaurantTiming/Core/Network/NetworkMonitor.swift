//
//  NetworkMonitor.swift
//  RestaurantTiming
//
//  Created by Ganesh reddy on 6/1/24.
//

import Foundation
import Network

final class NetworkMonitor: ObservableObject {
    static var shared = NetworkMonitor()
    private let networkMonitor = NWPathMonitor()
    private let workerQueue = DispatchQueue(label: "Monitor")

    enum ConnectedNetworkType: String {
        /// No network
        case noConnection
        /// A virtual or otherwise unknown interface type
        case other
        /// A Wi-Fi link
        case wifi
        /// A Cellular link
        case cellular
        /// A Wired Ethernet link
        case wiredEthernet
        /// The Loopback Interface
        case loopback
    }
    var connectedNetworkType: ConnectedNetworkType = .noConnection
    @Published var isConnectedObserver = false
    var isConnected = false
    var lastInternetState = false

    private init() {

        networkMonitor.pathUpdateHandler = { path in
            DispatchQueue.main.async {
                let currentNetworkState = path.status == .satisfied
                if self.lastInternetState != currentNetworkState {
                    self.lastInternetState = currentNetworkState
                    self.isConnected = currentNetworkState
                    self.isConnectedObserver = currentNetworkState
                }
                self.updateInternetType(forPath: path)
                if !self.isConnected {
                    self.connectedNetworkType = .noConnection
                }
                Task {
                    await MainActor.run {
                        self.objectWillChange.send()
                    }
                }
            }
        }
        networkMonitor.start(queue: workerQueue)
    }

    private func updateInternetType(forPath networkPath: NWPath) {
        print("networkPath \(networkPath)")
        if networkPath.usesInterfaceType(.cellular) {
            connectedNetworkType = .cellular
        } else if networkPath.usesInterfaceType(.wifi) {
            connectedNetworkType = .wifi
        } else if networkPath.usesInterfaceType(.other) {
            connectedNetworkType = .other
        } else if networkPath.usesInterfaceType(.loopback) {
            connectedNetworkType = .loopback
        } else if networkPath.usesInterfaceType(.wiredEthernet) {
            connectedNetworkType = .wiredEthernet
        }
    }
}

