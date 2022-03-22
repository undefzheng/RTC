//
//  ServerToClientModel.m
//  rtc_demo
//
//  Created by apple on 2021/11/30.
//

#import "ServerToClientModel.h"
#import "RSocketPacket.h"
#import "XMSocketUtils.h"

@implementation ServerToClientModel

// 二进制 转  模型
+ (ServerToClientModel *)serverHeaderData:(NSData *)headerData{
    if (!headerData) {
        return nil;
    }
    
    ServerToClientModel *model = [ServerToClientModel new];
    
    // length
    NSUInteger lengthLoc = 0;
    NSUInteger lengthLen = 4;
    NSData *lengthData = [headerData subdataWithRange:NSMakeRange(lengthLoc, lengthLen)];
    uint32_t len = [XMSocketUtils uint32FromBytes:lengthData];
    model.len = len;
    
    // stx
    NSUInteger stxLoc = 4;
    NSUInteger stxLen = 1;
    NSData *stxData = [headerData subdataWithRange:NSMakeRange(stxLoc, stxLen)];
    uint8_t stx = [XMSocketUtils uint8FromBytes:stxData];
    model.stx = stx;
    
    // ver
    NSUInteger verLoc = 4 + 1;
    NSUInteger verLen = 2;
    NSData *verData = [headerData subdataWithRange:NSMakeRange(verLoc, verLen)];
    uint16_t ver = [XMSocketUtils uint16FromBytes:verData];
    model.ver = ver;
    
    // zip
    NSUInteger zipLoc = 4 + 1 + 2;
    NSUInteger zipLen = 1;
    NSData *zipData = [headerData subdataWithRange:NSMakeRange(zipLoc, zipLen)];
    uint8_t zip = [XMSocketUtils uint8FromBytes:zipData];
    model.zip = zip;
    
    // cmd
    NSUInteger cmdLoc = 4 + 1 + 2 + 1;
    NSUInteger cmdLen = 2;
    NSData *cmdData = [headerData subdataWithRange:NSMakeRange(cmdLoc, cmdLen)];
    uint16_t cmd = [XMSocketUtils uint16FromBytes:cmdData];
    model.cmd = cmd;
    
    // seqno
    NSUInteger seqnoLoc = 4 + 1 + 2 + 1 + 2;
    NSUInteger seqnoLen = 4;
    NSData *seqnoData = [headerData subdataWithRange:NSMakeRange(seqnoLoc, seqnoLen)];
    uint32_t seqno = [XMSocketUtils uint32FromBytes:seqnoData];
    model.seqno = seqno;
    
    // timestamp
    NSUInteger timestampLoc = 4 + 1 + 2 + 1 + 2 + 4;
    NSUInteger timestampLen = 8;
    NSData *timestampData = [headerData subdataWithRange:NSMakeRange(timestampLoc, timestampLen)];
    uint64_t timestamp = [XMSocketUtils uint64FromBytes:timestampData];
    model.timestamp = timestamp;
    
    // ext1
    NSUInteger ext1Loc = 4 + 1 + 2 + 1 + 2 + 4 + 8;
    NSUInteger ext1Len = 4;
    NSData *ext1Data = [headerData subdataWithRange:NSMakeRange(ext1Loc, ext1Len)];
    uint32_t ext1 = [XMSocketUtils uint32FromBytes:ext1Data];
    model.ext1 = ext1;
    
    // ext2
    NSUInteger ext2Loc = 4 + 1 + 2 + 1 + 2 + 4 + 8 + 4;
    NSUInteger ext2Len = 4;
    NSData *ext2Data = [headerData subdataWithRange:NSMakeRange(ext2Loc, ext2Len)];
    uint32_t ext2 = [XMSocketUtils uint32FromBytes:ext2Data];
    model.ext2 = ext2;
    
    return model;
}// 26

+ (ServerToClientModel *)serverTotalData:(NSData *)totalData {
    NSData *headerData = [RSocketPacket getHeaderDataWithTotalData:totalData];
    if (!headerData) {
        return nil;
    }
    
    ServerToClientModel *model = [self serverHeaderData:headerData];

    // body
    NSData *oriBodyData = [RSocketPacket getOriginalBodyWithTotalData:totalData];
    id body = [RSocketPacket getMsgPackReaderBodyWithBodyData:oriBodyData];
    model.body = body;
    
    return model;
}

@end
