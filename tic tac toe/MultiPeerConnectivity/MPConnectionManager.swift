//
//  MPConnectionManager.swift
//  tic tac toe
//
//  Created by Ash on 17/05/2023.
//

import MultipeerConnectivity

extension String {
    static var serviceName = "TicTacToe"
}

class MPConnectionManager: NSObject, ObservableObject {
    let serviceType = String.serviceName
    let session: MCSession
    let playerID: MCPeerID
    let nearbyServiceAdvertiser: MCNearbyServiceAdvertiser
    let nearbyServiceBrowser: MCNearbyServiceBrowser
    var game: GameService?
    func setup(game: GameService) {
        self.game = game
    }
    
    @Published var availablePlayers = [MCPeerID]()
    @Published var receivedInvite: Bool = false
    @Published var receivedInviteFrom: MCPeerID?
    @Published var invitationHandler: ((Bool, MCSession?) -> Void)?
    @Published var paired: Bool = false
    
    var readyToPlay: Bool = false {
        didSet {
            if readyToPlay {
                startAdvertising()
            } else {
                stopAdvertising()
            }
        }
    }
    
    init(yourName: String) {
        playerID = MCPeerID(displayName: yourName)
        session = MCSession(peer: playerID)
        nearbyServiceAdvertiser = MCNearbyServiceAdvertiser(peer: playerID, discoveryInfo: nil, serviceType: serviceType)
        nearbyServiceBrowser = MCNearbyServiceBrowser(peer: playerID, serviceType: serviceType)
        super.init()
        session.delegate = self
        nearbyServiceAdvertiser.delegate = self
        nearbyServiceBrowser.delegate = self
    }
    deinit {
        stopAdvertising()
        stopBrowsing()
    }
    
    func startAdvertising() {
        nearbyServiceAdvertiser.startAdvertisingPeer()
    }
    func stopAdvertising() {
        nearbyServiceAdvertiser.stopAdvertisingPeer()
    }
    func startBrowsing() {
        nearbyServiceBrowser.startBrowsingForPeers()
    }
    func stopBrowsing() {
        nearbyServiceBrowser.stopBrowsingForPeers()
        availablePlayers.removeAll()
    }
    func send(GameMove: MPGameMove) {
        if !session.connectedPeers.isEmpty {
            do {
                if let data = GameMove.data() {
                    try session.send(data, toPeers: session.connectedPeers, with: .reliable)
                }
            } catch {
                print("error sending \(error.localizedDescription)")
            }
        }
    }
}

extension MPConnectionManager: MCNearbyServiceBrowserDelegate {
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        DispatchQueue.main.async {
            if !self.availablePlayers.contains(peerID) {
                self.availablePlayers.append(peerID)
            }
        }
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        guard let index = availablePlayers.firstIndex(of: peerID) else { return }
        DispatchQueue.main.async {
            self.availablePlayers.remove(at: index)
        }
    }
}

extension MPConnectionManager: MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        DispatchQueue.main.async {
            self.receivedInvite = true
            self.receivedInviteFrom = peerID
            self.invitationHandler = invitationHandler
        }
    }
}

extension MPConnectionManager: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case .notConnected:
            DispatchQueue.main.async {
                self.paired = false
                self.readyToPlay = true
            }
        case .connected:
            DispatchQueue.main.async {
                self.paired = true
                self.readyToPlay = false
            }
        default:
            DispatchQueue.main.async {
                self.paired = false
                self.readyToPlay = true
            }
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        if let gameMove = try? JSONDecoder().decode(MPGameMove.self, from: data) {
            DispatchQueue.main.async {
                switch gameMove.action {
                case .start:
                    break
                case .end:
                    self.session.disconnect()
                    self.readyToPlay = true
                case .reset:
                    self.game?.reset()
                case .move:
                    if let index = gameMove.index {
                        self.game?.makeMove(at: index)
                    }
                }
            }
        }
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        
    }
    
    
}
