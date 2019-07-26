//
//  HeaderCalculationProtocol.swift
//  FantastikComponents
//
//  Created by Dmitry Koryakin on 25/07/2019.
//

import CoreGraphics

protocol HeaderCalculationProtocol {
    // In interface
    var initialHeight: CGFloat { get set }
    var hideThreshold: CGFloat { get set }
    var bottomPinHeight: CGFloat { get set }
    var topAdjustment: CGFloat { get set }
    var yOffset: CGFloat { get set }
    var width: CGFloat { get set }

    // Out interface
    var minContentInsetsTop: CGFloat { get }
    var scrollInsetsTop: CGFloat { get }
    var contentInsetsTop: CGFloat { get }
    var frame: CGRect { get }
}
