//
//  Copyright (c) 2021 Open Whisper Systems. All rights reserved.
//

#import "DebugLogger.h"
#import <CocoaLumberjack/DDTTYLogger.h>

NS_ASSUME_NONNULL_BEGIN

const NSTimeInterval kSecondInterval = 1;
const NSTimeInterval kMinuteInterval = 60;
const NSTimeInterval kHourInterval = 60 * kMinuteInterval;
const NSTimeInterval kDayInterval = 24 * kHourInterval;
const NSTimeInterval kWeekInterval = 7 * kDayInterval;
const NSTimeInterval kMonthInterval = 30 * kDayInterval;
const NSTimeInterval kYearInterval = 365 * kDayInterval;

const NSUInteger kMaxDebugLogFileSize = 1024 * 1024 * 3;

@interface DebugLogger ()

@property (nonatomic, nullable) DDFileLogger *fileLogger;

@end

#pragma mark -

@implementation DebugLogger

+ (instancetype)sharedLogger
{
    static DebugLogger *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{ shared = [self new]; });
    return shared;
}

+ (NSString *)mainAppDebugLogsDirPath
{
    NSString *dirPath = [[DebugLogger cachesDirectoryPath] stringByAppendingPathComponent:@"Logs"];
    return dirPath;
}

#ifdef TESTABLE_BUILD
+ (NSString *)testDebugLogsDirPath
{
    return TestAppContext.testDebugLogsDirPath;
}
#endif

+ (NSArray<NSString *> *)allLogsDirPaths
{
    // We don't need to include testDebugLogsDirPath when
    // we upload debug logs.
    return @[
        DebugLogger.mainAppDebugLogsDirPath,
    ];
}

- (void)openLoging:(BOOL)open {
    [DebugLogger.sharedLogger enableTTYLogging];
    if (open) {
        [DebugLogger.sharedLogger enableFileLogging];
    }else{
        [DebugLogger.sharedLogger disableFileLogging];
    }
}

- (void)enableFileLogging
{

    NSString *logsDirPath = [DebugLogger mainAppDebugLogsDirPath];

    // Logging to file, because it's in the Cache folder, they are not uploaded in iTunes/iCloud backups.
    id<DDLogFileManager> logFileManager =
        [[DDLogFileManagerDefault alloc] initWithLogsDirectory:logsDirPath defaultFileProtectionLevel:@""];
    self.fileLogger = [[DDFileLogger alloc] initWithLogFileManager:logFileManager];

    // 24 hour rolling.
    self.fileLogger.rollingFrequency = kDayInterval;

    self.fileLogger.logFileManager.maximumNumberOfLogFiles = 32;

    self.fileLogger.maximumFileSize = kMaxDebugLogFileSize;
    self.fileLogger.logFormatter = [DDLogFileFormatterDefault new];

    [DDLog addLogger:self.fileLogger];
}

- (void)disableFileLogging
{
    [DDLog removeLogger:self.fileLogger];
    self.fileLogger = nil;
}

- (void)enableTTYLogging
{
    [DDLog addLogger:DDTTYLogger.sharedInstance];
}

- (NSURL *)errorLogsDir
{
    NSString *logDirPath = [[DebugLogger mainAppDebugLogsDirPath] stringByAppendingPathComponent:@"ErrorLogs"];
    return [NSURL fileURLWithPath:logDirPath];
}

- (id<DDLogger>)errorLogger
{
    static id<DDLogger> instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        id<DDLogFileManager> logFileManager =
            [[DDLogFileManagerDefault alloc] initWithLogsDirectory:self.errorLogsDir.path
                                        defaultFileProtectionLevel:@""];

        instance = [[ErrorLogger alloc] initWithLogFileManager:logFileManager];
    });

    return instance;
}

- (void)enableErrorReporting
{
    [DDLog addLogger:self.errorLogger withLevel:DDLogLevelError];
}

- (NSArray<NSString *> *)allLogFilePaths
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSMutableSet<NSString *> *logPathSet = [NSMutableSet new];
    for (NSString *logDirPath in DebugLogger.allLogsDirPaths) {
        NSError *error;
        for (NSString *filename in [fileManager contentsOfDirectoryAtPath:logDirPath error:&error]) {
            NSString *logPath = [logDirPath stringByAppendingPathComponent:filename];
            [logPathSet addObject:logPath];
        }
        if (error) {
//            OWSFailDebug(@"Failed to find log files: %@", error);
        }
    }
    // To be extra conservative, also add all logs from log file manager.
    // This should be redundant with the logic above.
    [logPathSet addObjectsFromArray:self.fileLogger.logFileManager.unsortedLogFilePaths];
    NSArray<NSString *> *logPaths = logPathSet.allObjects;
    return [logPaths sortedArrayUsingSelector:@selector((compare:))];
}

- (void)wipeLogs
{
    NSArray<NSString *> *logFilePaths = self.allLogFilePaths;

    BOOL reenableLogging = (self.fileLogger ? YES : NO);
    if (reenableLogging) {
        [self disableFileLogging];
    }

    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    for (NSString *logFilePath in logFilePaths) {
        BOOL success = [fileManager removeItemAtPath:logFilePath error:&error];
        if (!success || error) {
//            OWSFailDebug(@"Failed to delete log file: %@", error);
        }
    }

    if (reenableLogging) {
        [self enableFileLogging];
    }
}

+ (NSString *)cachesDirectoryPath
{
    static NSString *result;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSArray<NSString *> *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//        OWSAssert(paths.count >= 1);
        result = paths[0];
    });
    return result;
}

@end

@implementation ErrorLogger

//- (void)logMessage:(nonnull DDLogMessage *)logMessage
//{
//    [super logMessage:logMessage];
//    if (OWSPreferences.isAudibleErrorLoggingEnabled) {
//        [self.class playAlertSound];
//    }
//}
//
+ (void)playAlertSound
{
//    // "choo-choo"
//    const SystemSoundID errorSound = 1023;
//    AudioServicesPlayAlertSound(errorSound);
}

@end

NS_ASSUME_NONNULL_END
