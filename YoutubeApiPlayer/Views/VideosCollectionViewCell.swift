//
//  VideosCollectionViewCell.swift
//  YoutubeApiPlayer
//
//  Created by Andrey Boyko on 27.06.2022.
//

import UIKit

class VideosCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var imageVideo: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var count: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func setup(video: Video) {
            if let urlImage = URL(string: video.url) {
            self.imageVideo.load(url: urlImage)
                self.imageVideo.layer.cornerRadius = self.imageVideo.frame.width / 7.0
        }
        self.title.text = video.title
        self.count.text = video.count
    }
}
