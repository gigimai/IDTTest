//
//  NSStringUtilTests.swift
//  IDTTest
//
//  Created by MaiMai on 10/16/16.
//  Copyright © 2016 MaiMai. All rights reserved.
//

import XCTest

class NSStringUtilTests: XCTestCase {

    func testStringByReverseString() {
        let testString: NSString = "x"
        XCTAssertEqual(testString.stringByReverseString(), "x")
        let testString1: NSString = "abcxyz"
        XCTAssertEqual(testString1.stringByReverseString(), "zyxcba")
        let emojiString: NSString = "😀😱🙊"
        XCTAssertEqual(emojiString.stringByReverseString(), "🙊😱😀")
        let emptyString: NSString = ""
        XCTAssertEqual(emptyString.stringByReverseString(), "")
        let singleEmojiString: NSString = "🐱"
        XCTAssertEqual(singleEmojiString.stringByReverseString(), "🐱")
    }
    
    func testReverseStringPerformance() {
        let string: NSString = "This is a long text. Long text is long. Long cat is also long. Cat cat cat cat cat cat cat, cats everywhere, cats here and there. Yes have I mentioned I once had a cat named Kim Jong Un?"
        
        measureBlock { 
            let _ = string.stringByReverseString()
        }
    }

}
