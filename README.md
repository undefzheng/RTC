# XRtc IOS Api文档 

## FAQ：

### 技术选型：
* 基于swfit开发

### 基础库：
* webRTC: 使用google官方提供的编译库
* Starscream： 采用swfit写的webScoket
* MPMessagePack： 编解码信令服传输数据
* CocoaLumberjack： 日志基础库

### 加密库:
* 采用rust编译出来的静态库 libxrtc_crypto.a 
* 采用桥接方式进行调用加密库，完成加解密操作

### 日志系统：
* 提供verbose，debug，info，warn，error等5种模式
* 提供swfit版本和OC版本调用
* Swift可用使用Logger
* OC可用使用OWSLogs

### 使用方法:
* 提供swift编写的Demo，目前暂未提供OC编写的Demo
* 在swift项目需要创建Bridging-Header头，用来做SDK调用C++加密库的桥接文件
* 在OC项目，需要创建桥接Swift桥接文件进行配置，Swift的桥接文件也需要

### 配置权限:
* 需要在项目的info进行配安全权限
* Privacy - Camera Usage Description 用于捕获视频
* Privacy - Microphone Usage Description 用户捕获音频

## 快速集成：
### 基于上面配置后，编译成功下：
 1.初始化操作  appkey:项目key  uid：当前用户id  请使用单例进行接受当前实例
 ```
XRtcSDK.init(appkey: 1006, uid: self.uid)
 ```
 2.加解密配置 start: 是否开启加解密 type，棘轮  ransmission： 信令服，P2P 目前只做p2p，相对安全
  ```
self.rtcCall?.startEncryptor(start: self.start, type: EncryptorType.aes, ransmission: RansmissionType.p2p)
  ```
3. 进行代理操作
  ```
rtcCall?.delegate = self
  ```
4.实现代理
  ```
///会议操作结果 0代表成功，其他错误码可以在XRtconError看到
func XRtcOnRoomResult(_ rtcSDK: XRtcSDK, code: Int, result: String{}
///切换音视频结果 code 0代表成功 其余失败
func XRtcOnSwitchAvType(_ rtcSDK: XRtcSDK, code: Int, result: String){}
/// SDK 错误码
func XRtconError(_ rtcSDK: XRtcSDK, errorCode: Int, errorString: String){}
/// 被邀请进入房间成功
func XRtcOnInvitedMember(_ rtcSDK: XRtcSDK){}
/// 关闭房间结果
func XRtcOnRoomClose(_ rtcSDK: XRtcSDK){}
/// 查询房间信息
func XRtcOnRoomInfo(_ rtcSDK: XRtcSDK, roomInfo: NSDictionary){}
/// 用户进入房间结果
func XRtcOnMemberJoin(_ rtcSDK: XRtcSDK, memberJoin uid: Int){}
/// 用户离开房间
func XRtcOnMemberLeave(_ rtcSDK: XRtcSDK, memberJoin uid: Int){}
/// 用户拒绝邀请
func XRtcOnMemberRefuse(_ rtcSDK: XRtcSDK, memberJoin uid: Int){}
/// 网络状态改变
func XRtconWebStatusChanged(_ rtcSDK: XRtcSDK, State: WebStatus){}
  ```
5.获取本地流和远程流 用于展示
  ```
///获取本地流
self.rtcCall?.setLocalView()
  ```
  ```
///获取远程流 Tip： 一般情况下在用户进入房间的回调代理，进行处理，记得使用主线程进行更新UI
self.rtcCall!.addRemoteView()
   ```
   
# API说明：

## 初始化

sdk初始化

#### client -> SDK(init)

| 名称        | 类型   | 必选 | 描述                                                         |
| ----------- | ------ | ---- | ------------------------------------------------------------ |
| appkey     | int | 是   | 唯一标识|
| uid     | int | 是   | 用户id|

## 日志是否打开

用于打印当前的操作情况，定位问题

#### client -> SDK(openLog)

| 名称        | 类型   | 必选 | 描述                                                         |
| ----------- | ------ | ---- | ------------------------------------------------------------ |
| isOpen     | bool | 是   | 是否打开|

## 更新用户uid

考虑到有些项目会存在多个账号，所以需要进行切换

#### client -> SDK(setUid)

| 名称        | 类型   | 必选 | 描述                                                         |
| ----------- | ------ | ---- | ------------------------------------------------------------ |
| uid     | int | 是   | 用户UID|

## 查询房间信息

这个方法不提倡调用。目前SDK已经在回调给出当前的房间信息，业务层可以存储起来

#### client -> SDK(quaryRoomInfo)

| 名称        | 类型   | 必选 | 描述                                                         |
| ----------- | ------ | ---- | ------------------------------------------------------------ |
| roomID     | string | 是   | 房间UID|

## 创建房间

创建房间等于发起了视频通话，会根据下发配置进行呼叫

#### client -> SDK(creatRoom)

| 名称        | 类型   | 必选 | 描述                                                         |
| ----------- | ------ | ---- | ------------------------------------------------------------ |
| roomID     | string | 是   | 房间UID|
| type     | int | 是   | 1代表私聊 2代表群聊|
| rooType     | int | 是   | 1代表房主 2代表加入者|
| users     | Array | 是   | 用户id数组，需要int类型|
| avType     | int | 是   | 1音视频 2 音频|

## 邀请用户

当前通话情况下，邀请用户进入房间

#### client -> SDK(inviteMember)

| 名称        | 类型   | 必选 | 描述                                                         |
| ----------- | ------ | ---- | ------------------------------------------------------------ |
| users     | Array | 是   | 用户id数组，需要int类型|

## 设置ice 服务器

请按照此格式进行配置 
```json
[
    [
        "urls": ["turn:119.91.72.223:7834"],
        "username": "im", "credential": "123456"
    ],
    [
        "urls": ["stun:im.quanzhanim.com:3478"],
        "username": "", "credential": ""
    ],
    [
        "urls": ["turn:124.156.141.233:3478"]
        ,"username": "im", "credential": "123456"
    ]
]
```
#### client -> SDK(replaceIceServer)

| 名称        | 类型   | 必选 | 描述                                                         |
| ----------- | ------ | ---- | ------------------------------------------------------------ |
| iceSevers     | Array | 是   | ice服务器字符串数组|

## 加减密

提供ase 加密功能

#### client -> SDK(startEncryptor)

| 名称        | 类型   | 必选 | 描述                                                         |
| ----------- | ------ | ---- | ------------------------------------------------------------ |
| start     | bool | 是   | 开启状态 是否开启|
| type     | int | 是   | 1不加密 2aes加密 3棘轮加密|
| ransmission     | int | 是   | 1: 信令服 2：透明通道|

## 切换音视频

用于A切换音频，B也跟着切换为音频。针对与房间，不针对个人

#### client -> SDK(switchAvType)

| 名称        | 类型   | 必选 | 描述                                                         |
| ----------- | ------ | ---- | ------------------------------------------------------------ |
| start     | bool | 是   | 开启状态 是否开启|
| type     | int | 是   | 1不加密 2aes加密 3棘轮加密|
| ransmission     | int | 是   | 1: 信令服 2：透明通道|

## 切换摄像头

用于切换前后摄像头 针对个人

#### client -> SDK(switchCameraPostion)

| 名称        | 类型   | 必选 | 描述                                                         |
| ----------- | ------ | ---- | ------------------------------------------------------------ |
| switchCamera     | bool | 是   | fale 前  turn 后|

## 话筒

是否开启话筒 针对个人

#### client -> SDK(isMuteAudio)

| 名称        | 类型   | 必选 | 描述                                                         |
| ----------- | ------ | ---- | ------------------------------------------------------------ |
| isBool     | bool | 是   | 开 关|

## 扬声器

扬声器 话筒切换

#### client -> SDK(isSpeaker)

| 名称        | 类型   | 必选 | 描述                                                         |
| ----------- | ------ | ---- | ------------------------------------------------------------ |
| isBool     | bool | 是   | 开 关|

## 显示视频

针对个人 的摄像头是否开关， 开会把流传出去， 关会把流给关掉

#### client -> SDK(isHideVideo)

| 名称        | 类型   | 必选 | 描述                                                         |
| ----------- | ------ | ---- | ------------------------------------------------------------ |
| isBool     | bool | 是   | trun 隐藏视频  fale 显示视频|

## 挂断音视频

进行挂断音视频操作

#### client -> SDK(overCall)

| 名称        | 
| -----------| 
| 不需要传参数     | 

## 设置本地流

获取本地流，用户展示自己

#### SDK -> client(setLocalView)

| 名称        | 类型   | 必选 | 描述                                                         |
| ----------- | ------ | ---- | ------------------------------------------------------------ |
| UIView     | UIView | 是   | 返回当前本地流 |

## 获取远程流

获取远程流，返回远程流数组

#### SDK -> client(addRemoteView)

| 名称        | 类型   | 必选 | 描述                                                         |
| ----------- | ------ | ---- | ------------------------------------------------------------ |
| RtcVideoCanvas     | Array | 是   | view数组|

RtcVideoCanvas数组

| 名称        | 类型   | 必选 | 描述                                                         |
| ----------- | ------ | ---- | ------------------------------------------------------------ |
| uid     | int | 是   | 用户id|
| view     | View | 是   | 远程流|

# 附录：

## 错误码

####code错误码提示

| code        | 描述                                                         |
| ----------- | ------------------------------------------------------------ |
| 40001      | 没有权限访问. 不是房间的成员,或者无权加入,无权发起 |
| 40004      | 不在这个会议,或者未找到这个会议 |
| 40010      | 创建音视频会议失败, 可能是这个 channel 被占用 |
| 40011      | 加入音视频会议失败, 可能是channel 错误,或者验证码错误,无权加入等 |
| 40012      | 不是这个channel 的成员 , 无法对这channel 进行操作 |
| 50001      | 请添加成员 |
| 50001      | 请添加成员 |
| 50002      | 请输入房间号 |
| 50003      | 会议字典转模型解析失败 |
| 50004      | 音视频切换失败 |

####socket 链接状态

| code        | 描述                                                         |
| ----------- | ------------------------------------------------------------ |
| 0      | 默认 |
| 1      | 已链接 |
| 2      | 断开 |
