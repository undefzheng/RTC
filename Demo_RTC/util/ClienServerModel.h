//
//  ClienServerModel.h
//  XRTC
//
//  Created by apple on 2021/11/27.
//  Copyright © 2021 Open Whisper Systems. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ClienServerModel : NSObject

// 整个包长度 <4字节>
@property (nonatomic, assign) uint32_t len;

// start of text：固定为Ox09 <1字节>
@property (nonatomic, assign) uint8_t stx;

// 协议版本号，用于协议兼容 <2字节>
@property (nonatomic, assign) uint16_t ver;

// 压缩标识，0：不压缩，1：gzip，2：7zip <1字节>
@property (nonatomic, assign) uint8_t zip;

// 命令号 <2字节>
@property (nonatomic, assign) uint16_t cmd;

// 序列号 <4字节>
@property (nonatomic, assign) uint32_t seqno;

// 扩展字典1 <4字节>
@property (nonatomic, assign) uint32_t ext1;

// 扩展字典2 <4字节>
@property (nonatomic, assign) uint32_t ext2;

// body
@property (nonatomic, strong) id body;

+ (ClienServerModel *)modelWithCmd:(uint16_t)cmd body:(id)body seqno:(uint32_t)seqno uid:(uint32_t)uid;

+ (ClienServerModel *)modelWithZip:(uint8_t)zip cmd:(uint16_t)cmd seqno:(uint32_t)seqno body:(id)body uid:(uint32_t)uid;

+ (ClienServerModel *)test:(uint16_t)cmd body:(id)body;

@end

NS_ASSUME_NONNULL_END
