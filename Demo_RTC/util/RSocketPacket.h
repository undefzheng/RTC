//
//  RSocketPacket.h
//  XRTC
//
//  Created by apple on 2021/11/27.
//  Copyright © 2021 Open Whisper Systems. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RSocketPacket : NSObject

+ (NSData *)setPacketDataWithCmd:(uint16_t)cmd body:(id)body seqno:(uint32_t)seqno uid:(uint32_t)uid;

+ (uint32_t)getC2SProtocolLen;
+ (uint32_t)getS2CProtocolLen;

+ (NSData *)getOriginalBodyWithTotalData:(NSData *)totalData;
+ (id)getMsgPackReaderBodyWithBodyData:(NSData *)bodyData;

+ (NSData *)getHeaderDataWithTotalData:(NSData *)totalData;
@end

NS_ASSUME_NONNULL_END
