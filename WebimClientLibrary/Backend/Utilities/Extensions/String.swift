//
//  String.swift
//  WebimClientLibrary
//
//  Created by Nikita Lazarev-Zubov on 11.10.17.
//  Copyright © 2017 Webim. All rights reserved.
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

import Foundation

extension String {
    
    // MARK: - Methods
    
    /**
     Percent escapes values to be added to a URL query as specified in RFC 3986.
     This percent-escapes all characters besides the alphanumeric character set and "-", ".", "_", and "~".
     - SeeAlso:
     http://ietf.org/rfc/rfc3986.txt
     - returns:
     Percent-escaped string.
     - author:
     Nikita Lazarev-Lubov
     - copyright:
     2017 Webim
     */
    func addingPercentEncodingForURLQueryValue() -> String? {
        let generalDelimitersToEncode = ":#[]@" // Does not include "?" or "/" due to RFC 3986 - Section 3.4.
        let subDelimitersToEncode = "!$&'()*+,;="
        
        var allowed = CharacterSet.urlQueryAllowed
        allowed.remove(charactersIn: (generalDelimitersToEncode + subDelimitersToEncode))
        
        return addingPercentEncoding(withAllowedCharacters: allowed)
    }
    
    /**
     Generates HMAC SHA256 code taken on passed key value for self.
     - parameter key:
     Key to generate hash code.
     - returns:
     Hash code of string taken with passed key.
     - author:
     Nikita Lazarev-Lubov
     - copyright:
     2017 Webim
     */
    func hmacSHA256(withKey key: String) -> String? {
        let stringBytes: [UInt8] = Array(self.utf8)
        let keyBytes: [UInt8] = Array(key.utf8)
        let hmac = try! HMACsha256(key: keyBytes).authenticate(stringBytes).toHexString()
        
        return hmac
    }
    
}

// MARK: -
/**
 - Author:
 Nikita Lazarev-Zubov
 - Copyright:
 2018 Webim
 */
public final class HMACsha256 {
    
    // MARK: - Constants
    private enum Error: Swift.Error {
        case authenticateError
    }
    private static let blockSize = 64
    
    
    // MARK: - Properties
    var key: Array<UInt8>
    
    
    // MARK: - Initialization
    public init(key: Array<UInt8>) {
        self.key = key
        
        if key.count > HMACsha256.blockSize {
            if let hash = calculateHash(key) {
                self.key = hash
            }
        }
        
        if key.count < HMACsha256.blockSize {
            self.key = add(to: key)
        }
    }
    
    
    // MARK: - Methods
    
    func authenticate(_ bytes: Array<UInt8>) throws -> Array<UInt8> {
        var opad = Array<UInt8>(repeating: 0x5c,
                                count: HMACsha256.blockSize)
        for idx in key.indices {
            opad[idx] = key[idx] ^ opad[idx]
        }
        var ipad = Array<UInt8>(repeating: 0x36,
                                count: HMACsha256.blockSize)
        for idx in key.indices {
            ipad[idx] = key[idx] ^ ipad[idx]
        }
        
        guard let ipadAndMessageHash = calculateHash(ipad + bytes),
            let result = calculateHash(opad + ipadAndMessageHash) else {
                throw Error.authenticateError
        }
        
        return result
    }
    
    // MARK: Private methods
    
    private func calculateHash(_ bytes: Array<UInt8>) -> Array<UInt8>? {
        return SHA256().calculate(for: bytes)
    }
    
    private func add(to bytes: Array<UInt8>) -> Array<UInt8> {
        let paddingCount = HMACsha256.blockSize - (bytes.count % HMACsha256.blockSize)
        if paddingCount > 0 {
            return (bytes + Array<UInt8>(repeating: 0,
                                         count: paddingCount))
        }
        
        return bytes
    }
    
}

// MARK: -
/**
 - Author:
 Nikita Lazarev-Zubov
 - Copyright:
 2018 Webim
 */
public final class SHA256 {
    
    // MARK: - Constants
    private static let blockSize = 64
    private static let digestLength = 32
    private static let h: Array<UInt64> = [0x6a09e667,
                                           0xbb67ae85,
                                           0x3c6ef372,
                                           0xa54ff53a,
                                           0x510e527f,
                                           0x9b05688c,
                                           0x1f83d9ab,
                                           0x5be0cd19]
    private static let k: Array<UInt64> = [0x428a2f98,
                                           0x71374491,
                                           0xb5c0fbcf,
                                           0xe9b5dba5,
                                           0x3956c25b,
                                           0x59f111f1,
                                           0x923f82a4,
                                           0xab1c5ed5,
                                           0xd807aa98,
                                           0x12835b01,
                                           0x243185be,
                                           0x550c7dc3,
                                           0x72be5d74,
                                           0x80deb1fe,
                                           0x9bdc06a7,
                                           0xc19bf174,
                                           0xe49b69c1,
                                           0xefbe4786,
                                           0x0fc19dc6,
                                           0x240ca1cc,
                                           0x2de92c6f,
                                           0x4a7484aa,
                                           0x5cb0a9dc,
                                           0x76f988da,
                                           0x983e5152,
                                           0xa831c66d,
                                           0xb00327c8,
                                           0xbf597fc7,
                                           0xc6e00bf3,
                                           0xd5a79147,
                                           0x06ca6351,
                                           0x14292967,
                                           0x27b70a85,
                                           0x2e1b2138,
                                           0x4d2c6dfc,
                                           0x53380d13,
                                           0x650a7354,
                                           0x766a0abb,
                                           0x81c2c92e,
                                           0x92722c85,
                                           0xa2bfe8a1,
                                           0xa81a664b,
                                           0xc24b8b70,
                                           0xc76c51a3,
                                           0xd192e819,
                                           0xd6990624,
                                           0xf40e3585,
                                           0x106aa070,
                                           0x19a4c116,
                                           0x1e376c08,
                                           0x2748774c,
                                           0x34b0bcb5,
                                           0x391c0cb3,
                                           0x4ed8aa4a,
                                           0x5b9cca4f,
                                           0x682e6ff3,
                                           0x748f82ee,
                                           0x78a5636f,
                                           0x84c87814,
                                           0x8cc70208,
                                           0x90befffa,
                                           0xa4506ceb,
                                           0xbef9a3f7,
                                           0xc67178f2]
    
    
    // MARK: - Properties
    private var accumulatedHash32 = SHA256.h.map { UInt32($0) }
    private var processedBytesTotalCount: Int = 0
    
    
    // MARK: - Methods
    
    func calculate(for bytes: Array<UInt8>) -> Array<UInt8> {
        do {
            return try update(withBytes: bytes[bytes.startIndex ..< bytes.endIndex])
        } catch {
            return []
        }
    }
    
    // MARK: Private methods
    
    private func update(withBytes bytes: ArraySlice<UInt8>) throws -> Array<UInt8> {
        var accumulated = Array<UInt8>()
        accumulated += bytes
        
        let lengthInBits = (processedBytesTotalCount + accumulated.count) * 8
        let lengthBytes = lengthInBits.bytes(totalBytes: (SHA256.blockSize / 8)) // A 64-bit/128-bit representation of b. blockSize fit by accident.
        
        // Step 1. Append padding.
        SHA256.bitPadding(to: &accumulated,
                          blockSize: SHA256.blockSize,
                          allowance: (SHA256.blockSize / 8))
        
        // Step 2. Append Length a 64-bit representation of lengthInBits.
        accumulated += lengthBytes
        
        var processedBytes = 0
        for chunk in accumulated.batched(by: SHA256.blockSize) {
            process32(block: chunk,
                      currentHash: &accumulatedHash32)
            processedBytes += chunk.count
        }
        accumulated.removeFirst(processedBytes)
        processedBytesTotalCount += processedBytes
        
        // Current hash output.
        var result = Array<UInt8>(repeating: 0,
                                  count: SHA256.digestLength)
        var pos = 0
        for idx in 0 ..< accumulatedHash32.count where idx < Int.max {
            let h = accumulatedHash32[idx].bigEndian
            result[pos] = UInt8(h & 0xff)
            result[pos + 1] = UInt8((h >> 8) & 0xff)
            result[pos + 2] = UInt8((h >> 16) & 0xff)
            result[pos + 3] = UInt8((h >> 24) & 0xff)
            pos += 4
        }
        
        return result
    }
    
    // Mutating currentHash in place is way faster than returning new result.
    private func process32(block chunk: ArraySlice<UInt8>,
                           currentHash hh: inout Array<UInt32>) {
        // Break chunk into sixteen 32-bit words M[j], 0 ≤ j ≤ 15, big-endian.
        // Extend the sixteen 32-bit words into sixty-four 32-bit words:
        let M = UnsafeMutablePointer<UInt32>.allocate(capacity: SHA256.k.count)
        M.initialize(to: 0, count:
            SHA256.k.count)
        defer {
            M.deinitialize(count: SHA256.k.count)
            M.deallocate(capacity: SHA256.k.count)
        }
        
        for x in 0 ..< SHA256.k.count {
            switch x {
            case 0 ... 15:
                let start = chunk.startIndex.advanced(by: (x * 4))
                M[x] = UInt32(bytes: chunk,
                              fromIndex: start)
                
                break
            default:
                let s0 = SHA256.rotateRight(M[x - 15],
                                            by: 7) ^ SHA256.rotateRight(M[x - 15],
                                                                        by: 18) ^ (M[x - 15] >> 3)
                let s1 = SHA256.rotateRight(M[x - 2],
                                            by: 17) ^ SHA256.rotateRight(M[x - 2],
                                                                         by: 19) ^ (M[x - 2] >> 10)
                M[x] = M[x - 16] &+ s0 &+ M[x - 7] &+ s1
                
                break
            }
        }
        
        var A = hh[0]
        var B = hh[1]
        var C = hh[2]
        var D = hh[3]
        var E = hh[4]
        var F = hh[5]
        var G = hh[6]
        var H = hh[7]
        
        // Main loop
        for j in 0..<SHA256.k.count {
            let s0 = SHA256.rotateRight(A,
                                        by: 2) ^ SHA256.rotateRight(A,
                                                                    by: 13) ^ SHA256.rotateRight(A,
                                                                                                 by: 22)
            let maj = (A & B) ^ (A & C) ^ (B & C)
            let t2 = s0 &+ maj
            let s1 = SHA256.rotateRight(E,
                                        by: 6) ^ SHA256.rotateRight(E,
                                                                    by: 11) ^ SHA256.rotateRight(E,
                                                                                                 by: 25)
            let ch = (E & F) ^ ((~E) & G)
            let t1 = H &+ s1 &+ ch &+ UInt32(SHA256.k[j]) &+ M[j]
            
            H = G
            G = F
            F = E
            E = D &+ t1
            D = C
            C = B
            B = A
            A = t1 &+ t2
        }
        
        hh[0] = hh[0] &+ A
        hh[1] = hh[1] &+ B
        hh[2] = hh[2] &+ C
        hh[3] = hh[3] &+ D
        hh[4] = hh[4] &+ E
        hh[5] = hh[5] &+ F
        hh[6] = hh[6] &+ G
        hh[7] = hh[7] &+ H
    }
    
    /**
     ISO/IEC 9797-1 Padding method 2.
     Add a single bit with value 1 to the end of the data.
     If necessary add bits with value 0 to the end of the data until the padded data is a multiple of blockSize.
     - parameter blockSize:
     Padding size in bytes.
     - parameter allowance:
     Excluded trailing number of bytes.
     */
    @inline(__always)
    private static func bitPadding(to data: inout Array<UInt8>,
                                   blockSize: Int,
                                   allowance: Int) {
        let msgLength = data.count
        // Step 1. Append Padding Bits.
        // Append one bit (UInt8 with one bit) to message.
        data.append(0x80)
        
        // Step 2. Append "0" bit until message length in bits ≡ 448 (mod 512).
        let max = blockSize - allowance // 448, 986.
        if msgLength % blockSize < max { // 448.
            data += Array<UInt8>(repeating: 0,
                                 count: (max - 1 - (msgLength % blockSize)))
        } else {
            data += Array<UInt8>(repeating: 0,
                                 count: (blockSize + max - 1 - (msgLength % blockSize)))
        }
    }
    
    private static func rotateRight(_ value: UInt32,
                                    by: UInt32) -> UInt32 {
        return ((value >> by) | (value << (32 - by)))
    }
    
}
