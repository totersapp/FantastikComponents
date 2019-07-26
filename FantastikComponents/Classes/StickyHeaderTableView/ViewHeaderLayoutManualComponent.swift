//
//  ViewHeaderLayoutManualComponent.swift
//  FantastikComponents
//
//  Created by Dmitry Koryakin on 25/07/2019.
//

import Foundation
import UIKit

public protocol ViewHeaderLayoutManualComponentProtocol {
    var view: UIView { get }

    mutating func set(standartHeight: CGFloat)
    mutating func set(topAdjustment: CGFloat)
    mutating func set(hideThreshold: CGFloat)
    mutating func set(bottomPinHeight: CGFloat)
    mutating func set(hiding: (height: CGFloat, percent: CGFloat))

    mutating func updateLayout(on frame: CGRect)
}

public struct ViewHeaderLayoutManualComponent<T: ViewHeaderLayoutManual>: ViewHeaderLayoutManualComponentProtocol {
    public var view: UIView {
        return self.backView
    }

    let backView: T.View
    var layout: T

    public init(view: T.View, layout: T) {
        self.backView = view
        self.layout = layout
    }

    mutating func set(frame: CGRect) {
        self.layout.frame = frame
    }

    public mutating func set(standartHeight: CGFloat) {
        self.layout.standartHeight = standartHeight
    }

    public mutating func set(topAdjustment: CGFloat) {
        self.layout.topAdjustment = topAdjustment
    }

    public mutating func set(hideThreshold: CGFloat) {
        self.layout.hideThreshold = hideThreshold
    }

    public mutating func set(bottomPinHeight: CGFloat) {
        self.layout.bottomPinHeight = bottomPinHeight
    }

    public mutating func set(hiding: (height: CGFloat, percent: CGFloat)) {
        self.layout.hiding = hiding
    }

    public mutating func updateLayout(on frame: CGRect) {
        self.backView.frame = frame
        self.set(frame: frame)
        self.layout.performLayout(for: self.backView)
    }
}
