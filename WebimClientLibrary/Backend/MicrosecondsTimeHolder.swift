//
//  MicrosecondsTimeHolder.swift
//  WebimClientLibrary
//
//  Created by Nikita Lazarev-Zubov on 15.08.17.
//  Copyright © 2017 Webim. All rights reserved.
//

import Foundation

protocol MicrosecondsTimeHolder {
    
    func getTimeInMicrosecond() -> Int64

}
