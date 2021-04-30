//
//  main.swift
//  localizer2
//
//  Created by EVGENII Loshchenko on 22.03.2021.
//

import Foundation

let fileManager = FileManager.default

if CommandLine.arguments.count >= 2 {
    let projectPath = CommandLine.arguments[1]
    if projectPath.count > 10 && projectPath.contains("webim-client-sdk-ios/Example") { // protection from misunderstanded usage
        ProjectParser.run(projectPath)
    } else {
        print("project path is to short, looks like error, it should be absolute path")
    }

} else {
    print("project path not found")
}
