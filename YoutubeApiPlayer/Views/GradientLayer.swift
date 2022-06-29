//
//  GradientLayer.swift
//  YoutubeApiPlayer
//
//  Created by Andrey Boyko on 28.06.2022.
//

import UIKit

class GradientLayer {

    let gradientLayer: CAGradientLayer
    let colorTop: CGColor
    let colorBottom: CGColor

    init(colorTop: UIColor, colorBottom: UIColor) {
        self.colorTop = colorTop.cgColor
        self.colorBottom = colorBottom.cgColor
        gradientLayer = CAGradientLayer()
        gradientLayer.colors = [colorTop, colorBottom]
        gradientLayer.locations = [0.0, 1.0]
    }
}
