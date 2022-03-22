//
//  RSocketPacket.m
//  XRTC
//
//  Created by apple on 2021/11/27.
//  Copyright © 2021 Open Whisper Systems. All rights reserved.
//

#import "RSocketPacket.h"
#import "ClienServerModel.h"
#import "XMSocketUtils.h"
#import <MPMessagePack/MPMessagePack.h>

@implementation RSocketPacket

+ (NSData *)setPacketDataWithCmd:(uint16_t)cmd body:(id)body seqno:(uint32_t)seqno uid:(uint32_t)uid{
    
    ClienServerModel *model = [ClienServerModel modelWithCmd:cmd body:body seqno:seqno uid:uid];
    NSData *data = [self modelToData:model];
    return data;
}

+ (uint32_t)getC2SProtocolLen {
    
    return 4 + 1 + 2 + 1 + 2 + 4 + 4 + 4;
}

+ (uint32_t)getS2CProtocolLen {
    return 4 + 1 + 2 + 1 + 2 + 4 + 8 + 4 + 4;
}

+ (NSData *)modelToData:(ClienServerModel *)model {

    if (!model) {
        return nil;
    }
    
    NSMutableData *multData = [[NSMutableData alloc] init];
    
    // len
    NSData *lenData = [XMSocketUtils bytesFromUInt32:model.len];
    [multData appendData:lenData];
    
    // stx
    NSData *stxData = [XMSocketUtils byteFromUInt8:model.stx];
    [multData appendData:stxData];
    
    // ver
    NSData *verData = [XMSocketUtils bytesFromUInt16:model.ver];
    [multData appendData:verData];
    
    // zip
    NSData *zipData = [XMSocketUtils byteFromUInt8:model.zip];
    [multData appendData:zipData];
    
    // cmd
    NSData *cmdData = [XMSocketUtils bytesFromUInt16:model.cmd];
    [multData appendData:cmdData];
    
    // seqno
    NSData *seqnoData = [XMSocketUtils bytesFromUInt32:model.seqno];
    [multData appendData:seqnoData];
    
    // ext1
    NSData *ext1Data = [XMSocketUtils bytesFromUInt32:model.ext1];
    [multData appendData:ext1Data];
    
    // ext2
    NSData *ext2Data = [XMSocketUtils bytesFromUInt32:model.ext2];
    [multData appendData:ext2Data];
    
    // body
    NSError *error = nil;
    NSData *bodyData = model.body;
    
    if (!error) {
        [multData appendData:bodyData];
    }
    else {
        NSAssert(YES, [error localizedDescription]);
    }
    
    return multData;
}

+ (NSData *)getOriginalBodyWithTotalData:(NSData *)totalData {
    if (!totalData) {
        return nil;
    }
    
    NSMutableData *srcData = [[NSMutableData alloc] initWithData:totalData];
    uint32_t protocolLen = [self getS2CProtocolLen];
    NSUInteger bodyLen = srcData.length - protocolLen;
    NSData *bodyData = [srcData subdataWithRange:NSMakeRange(protocolLen, bodyLen)];
    return bodyData;
}

+ (id)getMsgPackReaderBodyWithBodyData:(NSData *)bodyData {
    if (!bodyData) {
        return nil;
    }
    
    NSError *error = nil;
    MPMessagePackReader *reader = [[MPMessagePackReader alloc]initWithData:bodyData];
    id body = [reader readObject:&error];
    
    if (!error) {
        return body;
    }
    else {
    }
    return nil;
}

+ (NSData *)getHeaderDataWithTotalData:(NSData *)totalData {
    if (!totalData) {
        return nil;
    }
    
    NSMutableData *srcData = [[NSMutableData alloc] initWithData:totalData];
    
    NSUInteger protocolLoc = 0;
    uint32_t protocolLen = [self getS2CProtocolLen];
    NSRange protocolRange = NSMakeRange(protocolLoc, protocolLen);
    NSData *protocolHeaderData = [srcData subdataWithRange:protocolRange];
    return protocolHeaderData;
}

@end
