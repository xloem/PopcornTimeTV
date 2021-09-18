//
//  TraktViewModel.swift
//  PopcornTime
//
//  Created by Alexandru Tudose on 18.09.2021.
//  Copyright © 2021 PopcornTime. All rights reserved.
//

import Foundation
import PopcornKit
import SwiftUI

class TraktViewModel: ObservableObject {
    @Published var displayCode: String?
    @Published var error: Error?
    
    var intervalTimer: Timer?
    var deviceCode: String?
    var expiresIn: Date?
    
    var onSuccess: () -> Void = {}
    
    init (onSuccess: @escaping () -> Void) {
        self.onSuccess = onSuccess
    }
    
    func getNewCode() {
        self.error = nil
        TraktManager.shared.generateCode { [weak self] (displayCode, deviceCode, expires, interval, error) in
            guard let displayCode = displayCode,
                let deviceCode = deviceCode,
                let expires = expires,
                let interval = interval,
                let `self` = self,
                error == nil else {
                    self?.error = error
                    return
                }
            self.displayCode = displayCode
            self.expiresIn = expires
            self.deviceCode = deviceCode
            self.intervalTimer = Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(self.poll), userInfo: nil, repeats: true)
        }
    }
    
    func stopTimer() {
        self.intervalTimer?.invalidate()
        self.intervalTimer = nil
    }
    
    @objc public func poll(timer: Timer) {
        if let expiresIn = expiresIn, expiresIn < Date() {
            timer.invalidate()
            getNewCode()
        } else if let deviceCode = deviceCode, deviceCode.isEmpty == false {
            TraktManager.shared.check(deviceCode: deviceCode) { [weak self] in
                self?.onSuccess()
            }
        }
    }
}
