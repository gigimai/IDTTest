//
//  NSString+Utilities.m
//  IDTTest
//
//  Created by MaiMai on 10/16/16.
//  Copyright © 2016 MaiMai. All rights reserved.
//

#import "NSString+Utilities.h"

@implementation NSString (Utilities)

/*
 String by reverse a string.
 - Problem is  many emoji characters are internally stored as a surrogate pair of 2 characters.
 - Apple document recommends using rangeOfComposedCharacterSequencesForRange: to avoid breaking up character sequences.
 - Using NSMutableString does the job nice and clean and I assume the input string might be large hence unfortunately NSMutableString would create a lot of unnecessary temporary objects.
 - I've found myself playing with UTF-32 buffer and the result is much faster. Oh you might notice that it only needs to loop through the first half.
*/

- (NSString *)stringByReverseString {
    NSUInteger length = [self length];
    if (length < 2) {
        return self;
    }
    
    NSStringEncoding encoding = NSHostByteOrder() == NS_BigEndian ? NSUTF32BigEndianStringEncoding : NSUTF32LittleEndianStringEncoding;
    NSUInteger utf32ByteCount = [self lengthOfBytesUsingEncoding:encoding];
    uint32_t *characters = malloc(utf32ByteCount);
    if (!characters) {
        return nil;
    }
    
    [self getBytes:characters
         maxLength:utf32ByteCount
        usedLength:NULL
          encoding:encoding
           options:0
             range:NSMakeRange(0, length)
    remainingRange:NULL];
    
    NSUInteger utf32Length = utf32ByteCount / sizeof(uint32_t);
    NSUInteger halfwayPoint = utf32Length / 2;
    for (NSUInteger i = 0; i < halfwayPoint; ++i) {
        uint32_t character = characters[utf32Length - i - 1];
        characters[utf32Length - i - 1] = characters[i];
        characters[i] = character;
    }
    
    return [[NSString alloc] initWithBytesNoCopy:characters
                                          length:utf32ByteCount
                                        encoding:encoding
                                    freeWhenDone:YES];
    
}

@end
