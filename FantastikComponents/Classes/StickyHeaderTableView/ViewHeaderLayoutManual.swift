//
//  ViewHeaderLayoutManual.swift
//  FantastikComponents
//
//  Created by Dmitry Koryakin on 25/07/2019.
//

import Foundation
import UIKit

public protocol ViewHeaderLayoutManual {
    associatedtype View: UIView
    var frame: CGRect { get set }
    var standartHeight: CGFloat { get set }
    var topAdjustment: CGFloat { get set }
    var hideThreshold: CGFloat { get set }
    var bottomPinHeight: CGFloat { get set }
    var hiding: (height: CGFloat, percent: CGFloat) { get set }
    func performLayout(for view: View)
}
