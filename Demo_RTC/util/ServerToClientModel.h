//
//  ServerToClientModel.h
//  rtc_demo
//
//  Created by apple on 2021/11/30.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ServerToClientModel : NSObject

// 整个包长度 <4字节>
@property (nonatomic, assign) uint32_t len;

// start of text：固定为Ox09 <1字节>
@property (nonatomic, assign) uint8_t stx;

// 协议版本号，用于协议兼容 <2字节>
@property (nonatomic, assign) uint16_t ver;

// 压缩标识，直接hardcode，0：不压缩，1：gzip，2：7zip <1字节>
@property (nonatomic, assign) uint8_t zip;

// 命令号 <2字节>
@property (nonatomic, assign) uint16_t cmd;

// 序列号，递增，用于兼容udp, 直接hardcode <4字节>
@property (nonatomic, assign) uint32_t seqno;

// 服务端当前时间戳，精确到毫秒 <8字节>
@property (nonatomic, assign) uint64_t timestamp;

// 扩展字段1，直接hardcode <4字节>
@property (nonatomic, assign) uint32_t ext1;

// 扩展字段2，直接hardcode <4字节>
@property (nonatomic, assign) uint32_t ext2;

// body 包体，不同的cmd对应到不同的包体,body所有的打包用msgpack格式生成 <不定长>
@property (nonatomic, strong) id body;

// 二进制 转  模型
+ (ServerToClientModel *)serverHeaderData:(NSData *)headerData;

+ (ServerToClientModel *)serverTotalData:(NSData *)totalData;

@end

NS_ASSUME_NONNULL_END
