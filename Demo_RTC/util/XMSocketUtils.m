//
//
//  XMSocketUtils.m
//  MsgPackeDemo
//
//  Created by 蔡景松 on 2017/12/12.
//  Copyright © 2017年 bigCake. All rights reserved.
//

#import "XMSocketUtils.h"

// 后面NSString这是运行时能获取到的C语言的类型
NSString * const TYPE_UINT8    = @"TC";// char是1个字节，8位
NSString * const TYPE_UINT16   = @"TS";// short是2个字节，16位
NSString * const TYPE_UINT32   = @"TI";
NSString * const TYPE_UINT64   = @"TQ";
NSString * const TYPE_STRING   = @"T@\"NSString\"";
NSString * const TYPE_ARRAY    = @"T@\"NSArray\"";
NSString * const TYPE_OBJECT   = @"T@";

@implementation XMSocketUtils

/**
 *  反转字节序列
 *
 *  @param srcData 原始字节NSData
 *
 *  @return 反转序列后字节NSData
 */
+ (NSData *)dataWithReverse:(NSData *)srcData
{
//    NSMutableData *dstData = [[NSMutableData alloc] init];
//    for (NSUInteger i=0; i<srcData.length; i++) {
//        [dstData appendData:[srcData subdataWithRange:NSMakeRange(srcData.length-1-i, 1)]];
//    }//for
    
    NSUInteger byteCount = srcData.length;
    NSMutableData *dstData = [[NSMutableData alloc] initWithData:srcData];
    NSUInteger halfLength = byteCount / 2;
    for (NSUInteger i=0; i<halfLength; i++) {
        NSRange begin = NSMakeRange(i, 1);
        NSRange end = NSMakeRange(byteCount - i - 1, 1);
        NSData *beginData = [srcData subdataWithRange:begin];
        NSData *endData = [srcData subdataWithRange:end];
        [dstData replaceBytesInRange:begin withBytes:endData.bytes];
        [dstData replaceBytesInRange:end withBytes:beginData.bytes];
    }//for
    
    return dstData;
}

+ (NSData *)byteFromUInt8:(uint8_t)val
{
    NSMutableData *valData = [[NSMutableData alloc] init];
    
    unsigned char valChar[1];
    valChar[0] = 0xff & val;
    [valData appendBytes:valChar length:1];
    
    return [self dataWithReverse:valData];
}

+ (NSData *)bytesFromUInt16:(uint16_t)val
{
    NSMutableData *valData = [[NSMutableData alloc] init];
    
    unsigned char valChar[2];
    valChar[0] = 0xff & val;
    valChar[1] = (0xff00 & val) >> 8;
    [valData appendBytes:valChar length:2];
    
    return [self dataWithReverse:valData];
}

+ (NSData *)bytesFromUInt32:(uint32_t)val
{
    NSMutableData *valData = [[NSMutableData alloc] init];
    
    unsigned char valChar[4];
    valChar[0] = 0xff & val;
    valChar[1] = (0xff00 & val) >> 8;
    valChar[2] = (0xff0000 & val) >> 16;
    valChar[3] = (0xff000000 & val) >> 24;
    [valData appendBytes:valChar length:4];
    
    return [self dataWithReverse:valData];
}

+ (NSData *)bytesFromUInt64:(uint64_t)val
{
    NSMutableData *valData = [[NSMutableData alloc] init];
    
    unsigned char valChar[8];
    valChar[0] = 0xff & val;
    valChar[1] = (0xff00 & val) >> 8;
    valChar[2] = (0xff0000 & val) >> 16;
    valChar[3] = (0xff000000 & val) >> 24;
    valChar[4] = (0xff00000000 & val) >> 32;
    valChar[5] = (0xff0000000000 & val) >> 40;
    valChar[6] = (0xff000000000000 & val) >> 48;
    valChar[7] = (0xff00000000000000 & val) >> 56;
    [valData appendBytes:valChar length:8];
    
    return [self dataWithReverse:valData];
}

+ (NSData *)bytesFromValue:(NSInteger)value byteCount:(int)byteCount
{
    NSAssert(value <= 4294967295, @"bytesFromValue: (max value is 4294967295)");
    NSAssert(byteCount <= 4, @"bytesFromValue: (byte count is too long)");
    
    NSMutableData *valData = [[NSMutableData alloc] init];
    NSUInteger tempVal = value;
    int offset = 0;
    
    while (offset < byteCount) {
        unsigned char valChar = 0xff & tempVal;
        [valData appendBytes:&valChar length:1];
        tempVal = tempVal >> 8;
        offset++;
    }//while
    
    return valData;
}

+ (NSData *)bytesFromValue:(NSInteger)value byteCount:(int)byteCount reverse:(BOOL)reverse
{
    NSData *tempData = [self bytesFromValue:value byteCount:byteCount];
    if (reverse) {
        return tempData;
    }
    
    return [self dataWithReverse:tempData];
}

+ (uint8_t)uint8FromBytes:(NSData *)fData
{
    NSAssert(fData.length == 1, @"uint8FromBytes: (data length != 1)");
    NSData *data = fData;
    uint8_t val0 = 0;
    [data getBytes:&val0 length:1];
    return val0;
}

+ (uint16_t)uint16FromBytes:(NSData *)fData
{
    NSAssert(fData.length == 2, @"uint16FromBytes: (data length != 2)");
    NSData *data = [self dataWithReverse:fData];;
    uint16_t val0 = 0;
    uint16_t val1 = 0;
    [data getBytes:&val0 range:NSMakeRange(0, 1)];
    [data getBytes:&val1 range:NSMakeRange(1, 1)];
    
    uint16_t dstVal =
    (val0 & 0xff) +
    ((val1 << 8) & 0xff00);
    return dstVal;
}

+ (uint32_t)uint32FromBytes:(NSData *)fData
{
    NSAssert(fData.length == 4, @"uint32FromBytes: (data length != 4)");
    NSData *data = [self dataWithReverse:fData];
    
    uint32_t val0 = 0;
    uint32_t val1 = 0;
    uint32_t val2 = 0;
    uint32_t val3 = 0;
    [data getBytes:&val0 range:NSMakeRange(0, 1)];
    [data getBytes:&val1 range:NSMakeRange(1, 1)];
    [data getBytes:&val2 range:NSMakeRange(2, 1)];
    [data getBytes:&val3 range:NSMakeRange(3, 1)];
    
    uint32_t dstVal =
    (val0 & 0xff) +
    ((val1 << 8) & 0xff00) +
    ((val2 << 16) & 0xff0000) +
    ((val3 << 24) & 0xff000000);
    return dstVal;
}

+ (uint64_t)uint64FromBytes:(NSData *)fData
{
    NSAssert(fData.length == 8, @"uint64FromBytes: (data length != 8)");
    
    NSData *data = [self dataWithReverse:fData];
    
    uint64_t val0 = 0;
    uint64_t val1 = 0;
    uint64_t val2 = 0;
    uint64_t val3 = 0;
    uint64_t val4 = 0;
    uint64_t val5 = 0;
    uint64_t val6 = 0;
    uint64_t val7 = 0;

    [data getBytes:&val0 range:NSMakeRange(0, 1)];
    [data getBytes:&val1 range:NSMakeRange(1, 1)];
    [data getBytes:&val2 range:NSMakeRange(2, 1)];
    [data getBytes:&val3 range:NSMakeRange(3, 1)];
    [data getBytes:&val4 range:NSMakeRange(4, 1)];
    [data getBytes:&val5 range:NSMakeRange(5, 1)];
    [data getBytes:&val6 range:NSMakeRange(6, 1)];
    [data getBytes:&val7 range:NSMakeRange(7, 1)];

    uint64_t dstVal =
    (val0 & 0xff) +
    ((val1 << 8)  & 0xff00) +
    ((val2 << 16) & 0xff0000) +
    ((val3 << 24) & 0xff000000) +
    ((val4 << 32) & 0xff00000000) +
    ((val5 << 40) & 0xff0000000000) +
    ((val6 << 48) & 0xff000000000000) +
    ((val7 << 56) & 0xff00000000000000);
    
    return dstVal;
}

+ (NSInteger)valueFromBytes:(NSData *)data
{
    NSAssert(data.length <= 4, @"valueFromBytes: (data is too long)");
    
    NSUInteger dataLen = data.length;
    NSUInteger value = 0;
    int offset = 0;
    
    while (offset < dataLen) {
        uint32_t tempVal = 0;
        [data getBytes:&tempVal range:NSMakeRange(offset, 1)];
        value += (tempVal << (8 * offset));
        offset++;
    }//while
    
    return value;
}

+ (NSInteger)valueFromBytes:(NSData *)data reverse:(BOOL)reverse
{
    NSData *tempData = data;
    if (reverse) {
        tempData = [self dataWithReverse:tempData];
    }
    return [self valueFromBytes:tempData];
}

+ (NSData *)dataFromHexString:(NSString *)hexString
{
    NSAssert((hexString.length > 0) && (hexString.length % 2 == 0), @"hexString.length mod 2 != 0");
    NSMutableData *data = [[NSMutableData alloc] init];
    for (NSUInteger i=0; i<hexString.length; i+=2) {
        NSRange tempRange = NSMakeRange(i, 2);
        NSString *tempStr = [hexString substringWithRange:tempRange];
        NSScanner *scanner = [NSScanner scannerWithString:tempStr];
        unsigned int tempIntValue;
        [scanner scanHexInt:&tempIntValue];
        [data appendBytes:&tempIntValue length:1];
    }
    return data;
}

+ (NSString *)hexStringFromData:(NSData *)data
{
    NSAssert(data.length > 0, @"data.length <= 0");
    NSMutableString *hexString = [[NSMutableString alloc] init];
    const Byte *bytes = data.bytes;
    for (NSUInteger i=0; i<data.length; i++) {
        Byte value = bytes[i];
        Byte high = (value & 0xf0) >> 4;
        Byte low = value & 0xf;
        [hexString appendFormat:@"%x%x", high, low];
    }//for
    return hexString;
}

+ (NSString *)asciiStringFromHexString:(NSString *)hexString
{
    NSMutableString *asciiString = [[NSMutableString alloc] init];
    const char *bytes = [hexString UTF8String];
    for (NSUInteger i=0; i<hexString.length; i++) {
        [asciiString appendFormat:@"%0.2X", bytes[i]];
    }
    return asciiString;
}

+ (NSString *)hexStringFromASCIIString:(NSString *)asciiString
{
    NSMutableString *hexString = [[NSMutableString alloc] init];
    const char *asciiChars = [asciiString UTF8String];
    for (NSUInteger i=0; i<asciiString.length; i+=2) {
        char hexChar = '\0';
        
        //high
        if (asciiChars[i] >= '0' && asciiChars[i] <= '9') {
            hexChar = (asciiChars[i] - '0') << 4;
        } else if (asciiChars[i] >= 'a' && asciiChars[i] <= 'z') {
            hexChar = (asciiChars[i] - 'a' + 10) << 4;
        } else if (asciiChars[i] >= 'A' && asciiChars[i] <= 'Z') {
            hexChar = (asciiChars[i] - 'A' + 10) << 4;
        }//if
        
        //low
        if (asciiChars[i+1] >= '0' && asciiChars[i+1] <= '9') {
            hexChar += asciiChars[i+1] - '0';
        } else if (asciiChars[i+1] >= 'a' && asciiChars[i+1] <= 'z') {
            hexChar += asciiChars[i+1] - 'a' + 10;
        } else if (asciiChars[i+1] >= 'A' && asciiChars[i+1] <= 'Z') {
            hexChar += asciiChars[i+1] - 'A' + 10;
        }//if
        
        [hexString appendFormat:@"%c", hexChar];
    }
    return hexString;
}

@end
