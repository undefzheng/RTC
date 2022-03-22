//
//  ClienServerModel.m
//  XRTC
//
//  Created by apple on 2021/11/27.
//  Copyright © 2021 Open Whisper Systems. All rights reserved.
//

#import "ClienServerModel.h"
#import <MPMessagePack/MPMessagePack.h>
#import "RSocketPacket.h"

@implementation ClienServerModel

+ (ClienServerModel *)modelWithCmd:(uint16_t)cmd body:(id)body seqno:(uint32_t)seqno uid:(uint32_t)uid {
    uint8_t zip = 0; ///预留，可能不做加密
    return [self modelWithZip:zip cmd:cmd seqno:seqno body:body uid:uid];
}

+ (ClienServerModel *)modelWithZip:(uint8_t)zip cmd:(uint16_t)cmd seqno:(uint32_t)seqno body:(id)body uid:(uint32_t)uid {
    
    printf("cmd======%d",cmd);
    if (!body) {
        return nil;
    }
    
    ClienServerModel *model = [ClienServerModel new];
    model.zip = zip;
    model.cmd = cmd;
    model.seqno = seqno;
    
    model.stx = 0x09;
    model.ext1 = uid;
    model.ver = 0xa;
    
    NSError *error = nil;
    NSData *bodyData = [MPMessagePackWriter writeObject:body error:&error];
    model.body = bodyData;
    
    // 1.Body
    uint32_t bodyLen = (uint32_t)bodyData.length;
    // 2.协议头
    uint32_t protocolLen = [RSocketPacket getC2SProtocolLen];
    
    model.len = protocolLen + bodyLen;
    return model;
}

+ (ClienServerModel *)test:(uint16_t)cmd body:(id)body {
    ClienServerModel *model = [ClienServerModel new];
    return model;
}

@end

