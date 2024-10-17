//
//  Extensions.swift
//  WebimClientShare
//
//  Created by Anna Frolova on 22.07.2024.
//  Copyright © 2024 Webim. All rights reserved.
//

import UIKit

private var associatedObjectHandle: UInt8 = 0

extension UITableView {

    var registeredCellsSet: Set<String> {
        get {
            let set = objc_getAssociatedObject(self, &associatedObjectHandle) as? Set<String>
            if let set = set {
                return set
            } else {
                self.registeredCellsSet = Set<String>()
                return self.registeredCellsSet
            }
        }
        set {
            objc_setAssociatedObject(self,
                                     &associatedObjectHandle,
                                     newValue,
                                     objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    func identifierRegistered(_ identifier: String) -> Bool {
        return self.registeredCellsSet.contains(identifier)
    }

    public func dequeueReusableCellWithType<T>(_ type: T.Type) -> T {
        let identifier = "\(type)"

        if !self.identifierRegistered(identifier) {
            self.registerCellWithType(type)
        }

        guard let cell = self.dequeueReusableCell(withIdentifier: identifier) as? T else {
            let logMessage = "Cast dequeueReusableCell with identifier \(identifier) to \(type) failure in DialogController.\(#function)"
            // WMLogsManager.log(logMessage)
            fatalError(logMessage)
        }
        return cell
    }
    
    func registerCellWithType<T>(_ type: T.Type) {
        let identifier = "\(type)"
        self.registeredCellsSet.insert(identifier)
        if Bundle.main.path(forResource: identifier, ofType: "nib") != nil {
            self.register(UINib(nibName: identifier, bundle: nil), forCellReuseIdentifier: identifier)
        }
    }
}
