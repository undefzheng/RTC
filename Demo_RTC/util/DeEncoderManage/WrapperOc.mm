//
//  WrapperOc.m
//  Demo_RTC
//
//  Created by apple on 2021/12/7.
//

#import "WrapperOc.h"

@implementation WrapperOc

void AndroidOrIosLog(int type, const char *tag, const char *logdata)
{
    NSLog(@"AndroidLogType:%d tag:%s log:%s",type,tag,logdata);
}

+ (void)RTCSenderEncryptor:(RTCRtpSender *)sender crypto:(long)crypto {

    long crylong = getAesManagerAudioEnCryptor(crypto,int32_t(0));
    void *encrypto =  (void *)&crylong;
    [sender setFrameEncryptor:(encrypto)];
}


+ (void)RTCReceiverDecryptor:(RTCRtpReceiver *)sender crypto:(long)crypto {

    long crylong = getAesManagerAudioDeCryptor(crypto,int32_t(0));
    void *encrypto =  (void *)&crylong;
    [sender setFrameDecryptor:(encrypto)];
}

@end
