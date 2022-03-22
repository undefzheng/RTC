//
// Created by pio on 2021/12/9.
//

#ifndef X_RTC_LIB_BASE_H
#define X_RTC_LIB_BASE_H
/**
 * @brief 用于外部导入的 日志信息 , 内部的日志打印将会同意调用这个方法进行输出, 上层需要更具不同的平台实现这个函数来对内部的日志进行捕捉
 * @param level 日志等级 内部的日志等级与android_log 相同
 * @param tag 所在标签
 * @param logdata 日志数据
 */
extern void AndroidOrIosLog(int level, const char *tag, const char *logdata);

#endif //X_RTC_LIB_BASE_H
