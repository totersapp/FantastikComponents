//
//  HeaderCalculationPreiOS11.swift
//  FantastikComponents
//
//  Created by Dmitry Koryakin on 25/07/2019.
//

import CoreGraphics

final class HeaderCalculationPreiOS11: HeaderCalculationProtocol {
    var initialHeight: CGFloat = 0.0 {
        didSet { self.update() }
    }

    var hideThreshold: CGFloat = 0.0 {
        didSet { self.update() }
    }

    var bottomPinHeight: CGFloat = 0.0 {
        didSet { self.update() }
    }

    var topAdjustment: CGFloat = 0.0 {
        didSet { self.update() }
    }

    var yOffset: CGFloat = 0.0 {
        didSet { self.update() }
    }

    var width: CGFloat = 0.0 {
        didSet { self.update() }
    }

    var minContentInsetsTop: CGFloat {
        return self.bottomPinHeight + self.hideThreshold
    }

    var contentInsetsTop: CGFloat = 0.0
    var scrollInsetsTop: CGFloat = 0.0
    var frame: CGRect = .zero

    private func update() {
        self.updateFrame()
        self.updateContentInsetsTop()
        self.updateScrollInsetsTop()
    }

    private func updateScrollInsetsTop() {
        self.scrollInsetsTop = self.contentInsetsTop
    }

    private func updateFrame() {
        let minHeight = self.hideThreshold + self.bottomPinHeight
        var height = abs(min(0, self.yOffset))
        let y: CGFloat
        if height > minHeight {
            y = -height
        } else {
            height = minHeight
            y = self.yOffset
        }

        self.frame = CGRect(x: 0, y: y, width: self.width, height: height)
    }

    private func updateContentInsetsTop() {
        let minInset = self.bottomPinHeight + self.hideThreshold
        if self.yOffset < -minInset {
            self.contentInsetsTop = self.initialHeight
        } else {
            self.contentInsetsTop = minInset
        }
    }
}
