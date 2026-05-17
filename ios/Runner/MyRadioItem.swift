//
//  MyRadioItem.swift
//  Runner
//
//  Created by Igor Zinin on 2.1.2025.
//

import Foundation
import MediaPlayer

enum MyRadioItemError: Error {
    case missingId
    case missingUrl
    case invalidUrl
    case missingName
}


class MyRadioItem: ObservableObject {
    let id: Int
    let url: URL
    let name: String
    let assetLogo: String?
    let logo: URL?
    @Published var currentSong = ""
    
    init(args: [String: Any]) throws {
        guard let id = args["id"] as? Int else {
            throw MyRadioItemError.missingId
        }
        guard let urlStr = args["url"] as? String else {
            throw MyRadioItemError.missingUrl
        }
        guard let url = URL(string: urlStr) else {
            throw MyRadioItemError.invalidUrl
        }
        guard let name = args["name"] as? String else {
            throw MyRadioItemError.missingName
        }
        if let assetLogo = args["assetLogo"] as? String {
            self.assetLogo = assetLogo
        } else {
            self.assetLogo = nil
        }
        if let logo = args["logo"] as? String, let url = URL(string: logo) {
            self.logo = url
        } else {
            self.logo = nil
        }
        self.id = id
        self.url = url
        self.name = name
    }
    
    func toNowPlayableStaticMetadata() -> NowPlayableStaticMetadata {
        print("currentSong: \(currentSong)")
        return NowPlayableStaticMetadata(assetURL: url,
                                         mediaType: .audio,
                                         isLiveStream: true,
                                         title: currentSong,
                                         artist: name,
                                         artwork: artworkNamed("LockedScr"),
                                         albumArtist: "Singer of Songs",
                                         albumTitle: "Songs to Sing")
    }
    
    // Create artwork.
    private func artworkNamed(_ imageName: String) -> MPMediaItemArtwork {
        
        #if os(macOS)
        let image = NSImage(named: imageName)!
        #else
        let image = UIImage(named: imageName)!
        #endif
        
        return MPMediaItemArtwork(boundsSize: image.size) { _ in image }
    }
    
    func updateCurrentSong(with newValue: String) {
        DispatchQueue.main.async {
            self.currentSong = newValue
        }
    }
}
