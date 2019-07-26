//
//  HeaderCalculationFactory.swift
//  FantastikComponents
//
//  Created by Dmitry Koryakin on 25/07/2019.
//

import Foundation

struct HeaderCalculationFactory {
    func make() -> HeaderCalculationProtocol {
        if #available(iOS 11.0, *) {
            return HeaderCalculationPostiOS11()
        } else {
            return HeaderCalculationPreiOS11()
        }
    }
}
