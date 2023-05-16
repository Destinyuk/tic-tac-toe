//
//  MPConnectionManager.swift
//  tic tac toe
//
//  Created by Ash on 16/05/2023.
//

import MultipeerConnectivity

extension String {
    static var serviceName = "XAndO"
}

class MPConnectionManager: NSObject, ObservableObject {
    
    let serviceType = String.serviceName
    let session: MCSession
    let myPeerId: MCPeerID
    let nearbyServiceAdvertiser: MCNearbyServiceAdvertiser
    let nearbyServiceBrowser: MCNearbyServiceBrowser
    var game: GameService?
    
    func setup(game: GameService) {
        self.game = game
    }
    
    @Published var avaliablePlayers = [MCPeerID]()
    @Published var receivedInvite: Bool = false
    @Published var receivedInviteFrom: MCPeerID?
    @Published var invitationHandler: ((Bool, MCSession) -> Void)?
    @Published var paired: Bool = false
    
    var isReadyToPlay: Bool = false {
        didSet {
            if isReadyToPlay {
                startAdvertising()
            } else {
                stopAdvertising()
            }
        }
    }
    
    init(yourName: String) {
        myPeerId = MCPeerID(displayName: yourName)
        session = MCSession(peer: myPeerId)
        nearbyServiceAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerId, discoveryInfo: nil, serviceType: serviceType)
        nearbyServiceBrowser = MCNearbyServiceBrowser(peer: myPeerId, serviceType: serviceType)
        super.init()
        session.delegate = self
        nearbyServiceBrowser.delegate = self
        nearbyServiceAdvertiser.delegate = self
    }
    
    deinit {
        stopBrowsing()
        stopAdvertising()
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
    }
    func send(gameMove: MPGameMove) {
        if !session.connectedPeers.isEmpty {
            do {
                if let data = gameMove.data() {
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
            if !self.avaliablePlayers.contains(peerID) {
                self.avaliablePlayers.append(peerID)
            }
        }
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        guard let index = avaliablePlayers.firstIndex(of: peerID) else { return }
        DispatchQueue.main.async {
            self.avaliablePlayers.remove(at: index)
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
                self.isReadyToPlay = true
            }
        case .connected:
            DispatchQueue.main.async {
                self.paired = true
                self.isReadyToPlay = false
            }
        default:
            DispatchQueue.main.async {
                self.paired = false
                self.isReadyToPlay = true
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
                    self.isReadyToPlay = true
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
