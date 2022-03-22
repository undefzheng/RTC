/*
 * XRTC api 接口
 */

#ifndef XRTC_RUST_FFI_BINDINGS_H
#define XRTC_RUST_FFI_BINDINGS_H

/* X-RTC FFI 库 */


#ifdef __cplusplus
extern "C" {
#endif
static const uintptr_t MAC_SIZE_BYTES = 16;

/// rust 底层日志桥接
extern void AndroidOrIosLogRust(int32_t level, const char *tag, const char *msg);

/// 用于初始化rust 底层日志
/// @param[in] log_level
///   0 => Off
///   1 => Trace
///   2 => Debug
///   3 => Info
///   4 => Warn
///   5 => Error
void init_rust_logger(int32_t log_level);

/// 用于构造 Aes 管理器
/// @param[in] userCtx 用户定义的上下文指针
/// @param[in] key aes 的 密钥
/// @return aes 管理器指针 . 0 --- 空指针 ; >0 管理器的指针
long newAesManager(long userCtx, const char *key);

/// 析构 Aes 管理器
/// @param[in] manager aes 管理器的指针
void freeAesManager(long manager);

/// 通过Aes管理器 获取Aes加密器
/// @param[in] manager Aes 管理器的指针
/// @param[in] call_user_id aes 使用的用户id 注意 aes 版本目前没有使用这个字段
/// @return 返回Aes 加密器的指针
long getAesManagerAudioEnCryptor(long manager, int32_t call_user_id);

/// 通过Aes管理器 获取Aes解密器
/// @param[in] manager Aes 管理器的指针
/// @param[in] call_user_id aes 使用的用户id 注意 aes 版本目前没有使用这个字段
/// @return 返回Aes 解密器的指针
long getAesManagerAudioDeCryptor(long manager, int32_t call_user_id);


/// 创建一个新的 E2EE 管理器 . 注意初始的E2EE 私钥是空 需要自己设置
/// @param userCtx 用户定义的上下文信息 -- 可以传入一个自定义的类的指针.
/// @param my_user_id 我的用户id
/// @return manager 返回的是一个 管理器的指针
long newE2EEManager(long userCtx, uint32_t my_user_id);

/// 释放 E2EE 管理器指针
/// @param manager E2EE 管理器的指针
void freeE2EEManager(long manager);

/// 获取E2EE算法的加密器
/// @param[in] manager 管理器
/// @param[in] call_user_id 对方的用户id
/// @return 加密器的指针 0 -- 即空指针 , 加密器生成失败 ; >0 -- 不是空指针 加密器有效
long getE2EEManagerAudioEnCryptor(long manager,
                                  int32_t call_user_id);

/// 获取E2EE算法的解密器
/// @param[in] manager 管理器
/// @param[in] call_user_id 对方的用户id
/// @return 解密器的指针 0 -- 即空指针 , 解密器生成失败 ; >0 -- 不是空指针 解密器有效
long getE2EEManagerAudioDeCryptor(long manager,
                                  int32_t call_user_id);
#ifdef __cplusplus
} // extern "C"
#endif
#endif // XRTC_RUST_FFI_BINDINGS_H
