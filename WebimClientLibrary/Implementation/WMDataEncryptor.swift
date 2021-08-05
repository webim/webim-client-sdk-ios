//
//  WMDataEncryptor.swift
//  WebimClientLibrary
//
//  Created by EVGENII Loshchenko on 07.07.2021.
//  
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import UIKit
import CommonCrypto
import Foundation

extension Data {
    var utf8String: String {
        return String(decoding: self, as: UTF8.self)
    }
    
    func toBase64() -> String? {
        return self.base64EncodedString(options: Data.Base64EncodingOptions(rawValue: 0))
    }
    
    func summ(iv: Data, text: Data) -> String? {
        return (iv + text).toBase64()
    }
    
    func ivPart() -> Data? {
        if self.count >= kCCBlockSizeAES128 {
            return Data([UInt8](self[0..<kCCBlockSizeAES128]))
        }
        return nil
    }
    
    func textPart() -> Data? {
        if self.count > kCCBlockSizeAES128 {
            return Data([UInt8](self[kCCBlockSizeAES128..<self.count]))
        }
        return nil
    }
}

class WMDataEncryptor {
    static let keychainKey = "WMTableEncryptionKey"
    
    static var shared: WMDataEncryptor? = WMDataEncryptor.initWithKeychainData()
    
    private var key: Data
    
    public class func initWithKeychainData() -> WMDataEncryptor? {
        
        if let key = WMKeychainWrapper.load(key: keychainKey) {
            return WMDataEncryptor(key: key)
        } else {
            let key = WMDataEncryptor.randomKey()
            _ = WMKeychainWrapper.save(key: keychainKey, data: key)
            return WMDataEncryptor(key: key)
        }
    }
    
    public init?(key: Data) {
        self.key = key
        
        guard key.count == kCCKeySizeAES256 else {
            return nil
        }
    }
    
    private func encrypt(_ digest: Data, iv: Data) -> Data? {
        guard iv.count == kCCBlockSizeAES128 else {
            return nil
        }
        return crypt(input: digest, operation: CCOperation(kCCEncrypt), iv: iv)
    }
    
    func decryptFromBase64String(base64String: String?) -> String? {
        guard let base64String = base64String else {
            return nil
        }
        if let data = Data(base64Encoded: base64String), let textPart = data.textPart(), let ivPart = data.ivPart() {
            return decrypt(textPart, iv: ivPart)?.utf8String
        }
        return nil
    }
    
    func encryptToBase64String(text: String) -> String? {
        let iv = WMDataEncryptor.randomIv()
        if let encryptedData = self.encrypt(Data(text.utf8), iv: iv) {
            return (iv + encryptedData).toBase64()
        }
        return nil
    }
    
    private func decrypt(_ encrypted: Data, iv: Data) -> Data? {
        guard iv.count == kCCBlockSizeAES128 else {
            return nil
        }
        
        return crypt(input: encrypted, operation: CCOperation(kCCDecrypt), iv: iv)
    }
    
    private func crypt(input: Data, operation: CCOperation, iv: Data) -> Data? {
        var outLength = Int(0)
        var outBytes = [UInt8](repeating: 0, count: input.count + kCCBlockSizeAES128)
        var status: CCCryptorStatus = CCCryptorStatus(kCCSuccess)
        
        input.withUnsafeBytes { rawBufferPointer in
            let encryptedBytes = rawBufferPointer.baseAddress!
            
            iv.withUnsafeBytes { rawBufferPointer in
                let ivBytes = rawBufferPointer.baseAddress!
                
                key.withUnsafeBytes { rawBufferPointer in
                    let keyBytes = rawBufferPointer.baseAddress!
                    
                    status = CCCrypt(operation,
                                     CCAlgorithm(kCCAlgorithmAES128),            // algorithm
                                     CCOptions(kCCOptionPKCS7Padding),           // options
                                     keyBytes,                                   // key
                                     key.count,                                  // keylength
                                     ivBytes,                                    // iv
                                     encryptedBytes,                             // dataIn
                                     input.count,                                // dataInLength
                                     &outBytes,                                  // dataOut
                                     outBytes.count,                             // dataOutAvailable
                                     &outLength)                                 // dataOutMoved
                }
            }
        }
        
        guard status == kCCSuccess else {
            return nil
        }
        
        return Data(bytes: &outBytes, count: outLength)
    }
    
    private static func randomKey() -> Data {
        return randomData(length: 32)
    }
    
    private static func randomIv() -> Data {
        return randomData(length: kCCBlockSizeAES128)
    }
    
    private static func randomData(length: Int) -> Data {
        var data = Data(count: length)

        var mutableBytes: UnsafeMutableRawPointer!

        data.withUnsafeMutableBytes { rawBufferPointer in
            mutableBytes = rawBufferPointer.baseAddress!
        }

        let status = SecRandomCopyBytes(kSecRandomDefault, length, mutableBytes)

        assert(status == Int32(0))
        return data
    }
}
