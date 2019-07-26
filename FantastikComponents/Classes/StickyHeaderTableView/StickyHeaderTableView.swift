//
//  StickyHeaderTableView.swift
//  FantastikComponents
//
//  Created by Dmitry Koryakin on 24/07/2019.
//

import Foundation
import UIKit

public protocol StickyHeaderTableViewHeaderDelegate: NSObjectProtocol {
    func stickyHeaderTableView(_ tableView: StickyHeaderTableView,
                               didReachHideThreshold threshold: (height: CGFloat, percent: CGFloat))
}

public final class StickyHeaderTableView: UITableView {
    public struct HeaderSettings {
        public let height: CGFloat
        public let hideThreshold: CGFloat
        public let bottomPinHeight: CGFloat

        public init(height: CGFloat,
                    hideThreshold: CGFloat,
                    bottomPinHeight: CGFloat = 0.0) {
            self.height = height
            self.hideThreshold = hideThreshold
            self.bottomPinHeight = bottomPinHeight
        }
    }

    public weak var headerDelegate: StickyHeaderTableViewHeaderDelegate?
    public override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var header: ViewHeaderLayoutManualComponentProtocol?
    var onScrollMap = [ConsumerContainer: (UITableView) -> ()]()
    var settings: HeaderSettings?
    private var headerCalculation: HeaderCalculationProtocol?
    public func configure(with header: ViewHeaderLayoutManualComponentProtocol, settings: HeaderSettings) {
        precondition(settings.height > 0.0)
        precondition(settings.bottomPinHeight >= 0.0)
        precondition(header.view.superview == nil)

        if let currentHeader = self.header?.view, self.subviews.contains(currentHeader) {
            currentHeader.removeFromSuperview()
        }

        self.header = header
        self.settings = settings

        var calculation = HeaderCalculationFactory().make()
        calculation.bottomPinHeight = settings.bottomPinHeight
        calculation.initialHeight = settings.height
        calculation.hideThreshold = settings.hideThreshold
        calculation.width = self.frame.width
        self.headerCalculation = calculation

        header.view.frame = calculation.frame
        self.addSubview(header.view)

        self.header!.set(standartHeight: settings.height)
        self.header!.set(bottomPinHeight: settings.bottomPinHeight)
        self.header!.set(hideThreshold: settings.hideThreshold)

        self.contentOffset = CGPoint(x: 0, y: -settings.height)

        if #available(iOS 11.0, *) {
            self.updateHeaderContentInsetIOS11(adjustBy: 0)
        } else {
            self.reportHideThresholdAndLayout()
            self.updateScrollIndicatorInsets()
        }
    }

    public override func scrollToRow(at indexPath: IndexPath, at scrollPosition: UITableView.ScrollPosition, animated: Bool) {
        if let calc = self.headerCalculation {
            var newInset = self.contentInset
            newInset.top = calc.minContentInsetsTop
            self.setSafeContent(inset: newInset)
        }
        super.scrollToRow(at: indexPath, at: scrollPosition, animated: animated)
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        // NOTE: Try to update header width as less as possible. And that the actuall point where it's possible
        if var header = self.header, var calc = self.headerCalculation, header.view.frame.width != self.bounds.width {
            calc.width = self.bounds.width
            header.updateLayout(on: calc.frame)
        }
    }

    public override func setContentOffset(_ contentOffset: CGPoint, animated: Bool) {
        super.setContentOffset(contentOffset, animated: animated)
        self.internalScrollViewDidScroll(self)
    }

    public override var contentOffset: CGPoint {
        didSet {
            self.internalScrollViewDidScroll(self)
        }
    }

    @available(iOS 11.0, *)
    public override func adjustedContentInsetDidChange() {
        super.adjustedContentInsetDidChange()
        self.internalAdjustedContentInsetDidChange(self)
    }

    // ******************************************************************
    // ******************************************************************
    //                   Introduced public methods
    // ******************************************************************
    // ******************************************************************
    public func registerOnScroll(for object: AnyObject, callback: @escaping (UITableView) -> ()) {
        let container = ConsumerContainer(object)
        self.onScrollMap[container] = callback
    }

    // MARK: - Stored props

    private var adjustedContentDiff: UIEdgeInsets = .zero
    // NOTE: Please do not update it from outside, at least top value.
    //       Only update from ViewController itself is tested
    //       If that is certainly needed, the behaviour should be tested on iOS 11- / 11+ with
    //       shown / hidden navigation bar
    public override var contentInset: UIEdgeInsets {
        didSet {
            // NOTE: Check that
            if #available(iOS 11.0, *) {
                self.updateAdjustedContentDiffIOS11()
            } else {
                self.updateAdjustedContentDiff(origin: oldValue, adjusted: self.contentInset)
                self.reportHideThresholdAndLayout()
                self.updateScrollIndicatorInsets()
            }
        }
    }

    // ******************************************************************
    // ******************************************************************
    //                      Independent Layouting
    // ******************************************************************
    // ******************************************************************
    private func updateScrollIndicatorInsets() {
        guard let calc = self.headerCalculation else { return }
        var newInset = self.scrollIndicatorInsets
        newInset.top = calc.scrollInsetsTop
        self.scrollIndicatorInsets = newInset
    }

    // ******************************************************************
    // ******************************************************************
    //                      iOS 11- Layouting
    // ******************************************************************
    // ******************************************************************
    private func updateAdjustedContentDiff(origin originInset: UIEdgeInsets, adjusted adjustedInset: UIEdgeInsets) {
        let inset = originInset
        let adjusted = adjustedInset
        self.adjustedContentDiff = UIEdgeInsets(top: adjusted.top - inset.top,
                                                left: adjusted.left - inset.left,
                                                bottom: adjusted.bottom - inset.bottom,
                                                right: adjusted.right - inset.right)
        self.headerCalculation?.topAdjustment = self.adjustedContentDiff.top
    }

    // ******************************************************************
    // ******************************************************************
    //                      iOS 11+ Layouting
    // ******************************************************************
    // ******************************************************************
    @available(iOS 11, *)
    private func updateHeaderContentInsetIOS11(adjustBy adjustment: CGFloat) {
        guard let calc = self.headerCalculation else { return }

        var newInset = self.contentInset
        newInset.top = calc.contentInsetsTop
        self.setSafeContent(inset: newInset)
        self.updateScrollIndicatorInsets()
    }

    @available(iOS 11, *)
    private func updateAdjustedContentDiffIOS11() {
        let inset = self.contentInset
        let adjusted = self.adjustedContentInset
        self.adjustedContentDiff = UIEdgeInsets(top: adjusted.top - inset.top,
                                                left: adjusted.left - inset.left,
                                                bottom: adjusted.bottom - inset.bottom,
                                                right: adjusted.right - inset.right)
        self.headerCalculation?.topAdjustment = self.adjustedContentDiff.top
    }

    // ******************************************************************
    // ******************************************************************
    //                      Delegate Interactions
    // ******************************************************************
    // ******************************************************************
    // NOTE: reachedOutThreshold is true to prevent first calls on inialization
    private var reachedOutThreshold = true
    private func getPreparedHideThreshold() -> (height: CGFloat, percent: CGFloat)? {
        guard let calc = self.headerCalculation else { return nil }

        let threshold = calc.hideThreshold
        var unadjustedHeight = max(calc.frame.height - threshold, 0)
        unadjustedHeight -= calc.bottomPinHeight

        if unadjustedHeight <= threshold {
            let diff = threshold - unadjustedHeight
            let percent = 1.0 - unadjustedHeight / threshold
            self.reachedOutThreshold = diff == 0.0
            return (diff, percent)
        } else if !self.reachedOutThreshold {
            // NOTE: inform delegate about correct value if velocity haven't reached exact values
            self.reachedOutThreshold = true
            return (0.0, 0.0)
        }
        return nil
    }

    private func reportHideThresholdAndLayout() {
        guard var header = self.header, var calc = self.headerCalculation, let settings = self.settings else { return }

        if let hideThreshold = self.getPreparedHideThreshold() {
            defer { self.headerDelegate?.stickyHeaderTableView(self, didReachHideThreshold: hideThreshold) }
            header.set(hiding: hideThreshold)
        }

        header.updateLayout(on: calc.frame)
    }

    private func setSafeContent(inset: UIEdgeInsets) {
        guard super.contentInset != inset else { return }
        super.contentInset = inset
    }

    private func internalScrollViewDidScroll(_ scrollView: UIScrollView) {
        guard var calc = self.headerCalculation else { return }

        calc.yOffset = scrollView.contentOffset.y
        self.reportHideThresholdAndLayout()

        var newInset = self.contentInset
        newInset.top = calc.contentInsetsTop
        self.setSafeContent(inset: newInset)
        self.updateScrollIndicatorInsets()
        self.onScrollMap = self.onScrollMap.filter { $0.key.isAlive }
        self.onScrollMap.values.forEach { $0(self) }
    }

    @available(iOS 11.0, *)
    private func internalAdjustedContentInsetDidChange(_ scrollView: UIScrollView) {
        let oldDiff = self.adjustedContentDiff
        self.updateAdjustedContentDiffIOS11()
        let newDiff = self.adjustedContentDiff
        self.updateHeaderContentInsetIOS11(adjustBy: newDiff.top - oldDiff.top)
    }
}

extension StickyHeaderTableView {
    class ConsumerContainer: Hashable {
        weak var object: AnyObject?
        var identifier: ObjectIdentifier
        init(_ object: AnyObject) {
            self.object = object
            self.identifier = ObjectIdentifier(object)
        }

        var isAlive: Bool {
            return self.object != nil
        }

        static func == (lhs: StickyHeaderTableView.ConsumerContainer, rhs: StickyHeaderTableView.ConsumerContainer) -> Bool {
            return lhs.identifier == rhs.identifier
        }

        func hash(into hasher: inout Hasher) {
            return self.identifier.hash(into: &hasher)
        }

        var hashValue: Int {
            return self.identifier.hashValue
        }
    }
}
