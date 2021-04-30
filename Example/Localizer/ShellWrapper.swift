//
//  ShellWrapper.swift
//  localizer2
//
//  Created by EVGENII Loshchenko on 22.03.2021.
//

import Cocoa
import Foundation

class ShellWrapper: NSObject {
    static let tempStringsFileName = "temp_strings_file.strings"
    
    static func shell(_ args: [String]) {
        let task = Process()
        task.launchPath = "/usr/bin/env"
        task.arguments = args
        task.launch()
        task.waitUntilExit()
    }
    
    static func readUTF8File(_ filePath: String) -> String {
        var text = ""
        do {
            text = try String(contentsOfFile: filePath, encoding: .utf8)
        } catch { print("readUTF8File error \(filePath)") }
        return text
    }
    
    static func readUTF16File(_ filePath: String) -> String {
        var text = ""
        do {
            text = try String(contentsOfFile: filePath, encoding: .utf16)
        } catch { print("readUTF16File error \(filePath)") }
        return text
    }
    
    static func generateStringsFileForXib(_ filePath: String) -> String {
        
        var text = ""
        shell(["ibtool", filePath, "--generate-strings-file", tempStringsFileName])
        text = readUTF16File(tempStringsFileName)
        shell(["rm", tempStringsFileName])
        
        return text
    }
    
}
