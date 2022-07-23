//
//  PlaylistCollectionViewCell.swift
//  YoutubeApiPlayer
//
//  Created by Andrey Boyko on 27.06.2022.
//

import UIKit

class PlaylistCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imagePlaylist: UIImageView!
        @IBOutlet weak var count: UILabel!
        @IBOutlet weak var title: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setup(playlist: Playlists) {
            if let urlImage = URL(string: playlist.url) {
            self.imagePlaylist.load(url: urlImage)
                self.imagePlaylist.clipsToBounds = true
                self.imagePlaylist.layer.cornerRadius = 10
        }
        self.title.text = playlist.title
        self.count.text = playlist.id
    }
}
