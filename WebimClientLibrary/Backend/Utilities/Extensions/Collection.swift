//
//  Collection.swift
//  WebimClientLibrary
//
//  Created by Nikita Lazarev-Zubov on 17.01.18.
//  Copyright © 2018 Webim. All rights reserved.
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

extension Collection {
    
    /**
     Part or HMAC SHA256 generation system.
     - author:
     Nikita Lazarev-Zubov
     - copyright:
     2018 Webim
     */
    func batched(by size: Int) -> BatchedCollection<Self> {
        return BatchedCollection(base: self,
                                 size: size)
    }
    
}

// MARK: -
/**
 Part or HMAC SHA256 generation system.
 - author:
 Nikita Lazarev-Zubov
 - copyright:
 2018 Webim
 */
struct BatchedCollection<Base: Collection>: Collection {
    
    typealias Index = BatchedCollectionIndex<Base>
    
    // MARK: - Properties
    let base: Base
    let size: Int
    
    // MARK: - Methods
    private func nextBreak(after idx: Base.Index) -> Base.Index {
        return (base.index(idx,
                           offsetBy: size,
                           limitedBy: base.endIndex) ?? base.endIndex)
    }
    
    var startIndex: Index {
        return Index(range: base.startIndex ..< nextBreak(after: base.startIndex))
    }
    
    var endIndex: Index {
        return Index(range: base.endIndex ..< base.endIndex)
    }
    
    func index(after idx: Index) -> Index {
        return Index(range: idx.range.upperBound ..< nextBreak(after: idx.range.upperBound))
    }
    
    subscript(idx: Index) -> Base.SubSequence {
        return base[idx.range]
    }
}

// MARK: - Comparable
extension BatchedCollectionIndex: Comparable {
    
    // MARK: - Methods
    
    static func ==<Base>(lhs: BatchedCollectionIndex<Base>,
                         rhs: BatchedCollectionIndex<Base>) -> Bool {
        return (lhs.range.lowerBound == rhs.range.lowerBound)
    }
    
    static func <<Base>(lhs: BatchedCollectionIndex<Base>,
                        rhs: BatchedCollectionIndex<Base>) -> Bool {
        return (lhs.range.lowerBound < rhs.range.lowerBound)
    }
    
}

// MARK: -
/**
 Part or HMAC SHA256 generation system.
 - author:
 Nikita Lazarev-Zubov
 - copyright:
 2018 Webim
 */
struct BatchedCollectionIndex<Base: Collection> {
    let range: Range<Base.Index>
}
