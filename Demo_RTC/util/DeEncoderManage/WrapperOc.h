//
//  WrapperOc.h
//  Demo_RTC
//
//  Created by apple on 2021/12/7.
//

#import <Foundation/Foundation.h>
#import "RTCRtpSender+Native.h"
#import "RTCRtpReceiver+Native.h"
#import "WrapperRust.h"

NS_ASSUME_NONNULL_BEGIN

@interface WrapperOc : NSObject

/// 音频加密
/// @param sender 发送者
/// @param crypto 32位key
+ (void)RTCSenderEncryptor:(RTCRtpSender *)sender crypto:(long)crypto;


/// 音频解密
/// @param sender 接受者
/// @param crypto 32位key
+ (void)RTCReceiverDecryptor:(RTCRtpReceiver *)sender crypto:(long)crypto;

@end

NS_ASSUME_NONNULL_END
