//
//  ProjectParser.swift
//  localizer2
//
//  Created by EVGENII Loshchenko on 22.03.2021.
//

import Cocoa
typealias Value = String
typealias CodeKey = String
typealias FileName = String
typealias Locale = String

typealias XibFileData = [FileName: [CodeKey: Value]]
typealias Translations = [Locale: [CodeKey: Value]]
typealias XibTranslations = [Locale: [CodeKey: Value]]

// swiftlint:disable force_unwrapping
class ProjectParser: NSObject {
    
    static func run(_ projectFolderPath: String) {
        
        // get all code keys
        var codeKeys = [CodeKey: [FileName]]()
        getAllCodeKeys(projectFolderPath: projectFolderPath, codeKeys: &codeKeys)

        // get all xib keys
        var xibKeysMap = XibFileData()
        getAllXibKeys(projectFolderPath: projectFolderPath, codeKeys: &codeKeys, xibKeysMap: &xibKeysMap)
        
        let xibTranslations = loadAllXibTranslations(projectFolderPath: projectFolderPath, xibKeysMap: xibKeysMap)
        
        // read and update translations
        let translations = updateAllTranslations(projectFolderPath: projectFolderPath, codeKeys: &codeKeys, xibTranslations: xibTranslations)

        // update xib localizations
        updateXibTranslations(projectFolderPath: projectFolderPath, xibKeysMap: xibKeysMap, translations: translations, xibTranslations: xibTranslations)
        
    }
    
    static func loadAllXibTranslations(projectFolderPath: String, xibKeysMap: XibFileData) -> XibTranslations {
        
        var xibTranslations = XibTranslations()
        
        let stringsFiles = StringsFileParser.filesList(inFolder: projectFolderPath, withSuffix: ".strings")
        for file in stringsFiles {
            
            if !file.hasSuffix("Localizable.strings") && !file.hasSuffix("InfoPlist.strings") {
                let locale = file.getLocale()
                
                var locationDictionary = xibTranslations[locale] ?? [String: String]()
                let fileName = file.lastPathComponent.nameWithoutExtension()
                
                let text = ShellWrapper.readUTF8File(file)
                let localizedValues: [String: String] = StringsFileParser.getKeysFromStringsFile(text: text)
                
                let xibKeyDixtionary = xibKeysMap[fileName] ?? [String: String]()
                for key in localizedValues.keys {
                    locationDictionary[key] = localizedValues[key]
                    
                    if let xibKey = xibKeyDixtionary[key] {
                        locationDictionary[xibKey] = localizedValues[key]
                    }
                }
                
                xibTranslations[locale] = locationDictionary
            }
        }
        
        return xibTranslations
    }
    
    static func updateXibTranslations(projectFolderPath: String, xibKeysMap: XibFileData, translations: Translations, xibTranslations: XibTranslations ) {
        let stringsFiles = StringsFileParser.filesList(inFolder: projectFolderPath, withSuffix: ".strings")
        for filePath in stringsFiles {
            if !filePath.hasSuffix("Localizable.strings")  && !filePath.hasSuffix("InfoPlist.strings"){
                
                let locale = filePath.getLocale()
                let filename = filePath.nameWithoutExtension().lastPathComponent
                let localeTranslations = translations[locale] ?? [:]
                let localeXibTranslations: [CodeKey: Value] = xibTranslations[locale] ?? [CodeKey: Value]()
                let xibKeys = xibKeysMap[filename] ?? [:]
                
                var fileString = ""
                for key in xibKeys.keys.sorted() {
                    var translatedValue = localeTranslations[xibKeys[key]!] ?? ""
                    if translatedValue.isEmpty {
                        translatedValue = localeXibTranslations[key] ?? ""
                    }
                    if translatedValue.isEmpty {
                        translatedValue = xibKeys[key] ?? ""
                    }
                    fileString += "\"\(key)\" = \"\(translatedValue)\";\n"
                }
                fileString.writeToFile(filePath)
            }
            
        }
    }
    
    static func updateAllTranslations(projectFolderPath: String, codeKeys: inout [CodeKey: [FileName]], xibTranslations: XibTranslations) -> Translations {
        var baseTranslation = [String: String]()
        var translations = Translations()
        let stringsFiles = StringsFileParser.filesList(inFolder: projectFolderPath, withSuffix: "Localizable.strings")
        for filePath in stringsFiles.reversed() {
            
            print(filePath)
            let locale = filePath.getLocale()
            
            let text = ShellWrapper.readUTF8File(filePath)
            let localizedValues: [String: String] = StringsFileParser.getKeysFromStringsFile(text: text)
            translations[locale] = localizedValues
            
            let localeXibTranslations: [CodeKey: Value] = xibTranslations[locale] ?? [CodeKey: Value]()
            
            var fileString = ""
            for key in codeKeys.keys.sorted() {
                var translation = localizedValues[key] ?? ""
                
                if translation.isEmpty {
                    translation = localeXibTranslations[key] ?? ""
                }
                if translation.isEmpty {
                    translation = key
                }
                
                let comment = codeKeys[key]?.sorted().joined(separator: ",") ?? ""
                fileString += "//" + comment + "\n"
                fileString += "\"\(key)\" = \"\(translation)\";\n"
                
                if locale == "Base.lproj" {
                    baseTranslation[key] = translation
                }
            }
            fileString.writeToFile(filePath)
        }
        return translations
    }
    
    static func getAllCodeKeys(projectFolderPath: String, codeKeys: inout [CodeKey: [FileName]]) {
        
        let codeFiles = StringsFileParser.filesList(inFolder: projectFolderPath, withSuffix: ".swift")
        for filePath in codeFiles {
            
            let fileName = filePath.lastPathComponent
            
            let keys = StringsFileParser.getCodeKeysFromFile(filePath: filePath)

            for key in keys {
                addKey(key, fromFile: fileName, to: &codeKeys)
            }
        }
    }
    
    static func addKey(_ key: String, fromFile fileName: String, to codeKeys: inout [CodeKey: [FileName]]) {
        if codeKeys[key] == nil {
            codeKeys[key] = [String]()
        }
        if !codeKeys[key]!.contains(fileName) {
            codeKeys[key]?.append(fileName)
        }
    }
    
    static func getAllXibKeys(projectFolderPath: String, codeKeys: inout [CodeKey: [FileName]], xibKeysMap: inout XibFileData) {
        let xibFiles = StringsFileParser.filesList(inFolder: projectFolderPath, withSuffix: ".xib")
        let storyboardFiles = StringsFileParser.filesList(inFolder: projectFolderPath, withSuffix: ".storyboard")
        let UIFiles = xibFiles + storyboardFiles
        
        for file in UIFiles {
            
            let xibKeys = StringsFileParser.getXibKeysFromFile(filePath: file)
            
            for key in xibKeys.keys {

                addKey(xibKeys[key]!, fromFile: file.lastPathComponent, to: &codeKeys)

            }
            
            xibKeysMap[file.lastPathComponent.nameWithoutExtension()] = xibKeys
        }
        
    }
    
}
// swiftlint:enable force_unwrapping
