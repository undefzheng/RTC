//
// Created by pio on 2021/11/27.
//

#ifndef TEST_WEBRTC_CRYPTO_WRAPPER_H
#define TEST_WEBRTC_CRYPTO_WRAPPER_H

extern void AndroidLog(int type, const char *tag, const char *logdata);

#ifdef __cplusplus
extern "C" {
#endif

/**
 * @brief 头文件链接到libtest_webrtc_crypto.a，libdemo_rffi_crypto.a
 */

/**
 * @brief 创建一个AES 管理器
 * @param key aes 密钥 32 长度的 字符串 建议使用 md5 或 hash 的字符串
 */
long newAesManager(const char *key);

/**
 * @brief 从管理器中获取 加密器
 * @param manager 管理器的执政
 */
long getManagerVideoEnCryptor(long manager);
long getManagerEnCryptor(long manager);
long getManagerAudioEnCryptor(long manager);

/**
 * @brief 从管理器中获取解密器
 */
long getManagerDeCryptor(long manager);
long getManagerVideoDeCryptor(long manager);
long getManagerAudioDeCryptor(long manager);

/**
 * @brief 释放管理器
 */
void freeAesManager(long manager);

#ifdef __cplusplus
};
#endif


#endif //TEST_WEBRTC_CRYPTO_WRAPPER_H
