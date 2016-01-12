//
//  AnyrtcM2Mutlier.h
//  anyrtc
//
//  Created by EricTao on 15/12/21.
//  Copyright © 2015年 EricTao. All rights reserved.
//

#ifndef AnyrtcM2Mutlier_h
#define AnyrtcM2Mutlier_h
#import <UIKit/UIKit.h>
#import "AnyrtcVideoCallView.h"
#import "M2MPublisher.h"

@protocol AnyrtcM2MDelegate <NSObject>

/** 发布成功
 * @param strPublishId	实时流的ID
 * @param strRtmpUrl	rtmp直播流的地址
 * @param strHlsUrl		hls直播流的地址
 */
- (void) OnRtcPublishOK:(NSString*)strPublishId withRtmpUrl:(NSString*)strRtmpUtl withHlsUrl:(NSString*)strHlsUrl;
/** 发布失败
 * @param nCode		失败的代码
 * @param strErr	错误的具体原因
 */
- (void) OnRtcPublishFailed:(int)code withErr:(NSString*)strErr;
/** 发布通道关闭
 */
- (void) OnRtcPublishClosed;

/** 订阅成功
 * @param strPublishId	订阅的通道ID
 */
- (void) OnRtcSubscribeOK:(NSString*)strPublishId;
/** 订阅失败
 * @param strPublishId	订阅的通道ID
 * @param nCode			失败的代码
 * @param strErr		错误的具体原因
 */
- (void) OnRtcSubscribeFailed:(NSString*)strPublishId withCode:(int)code withErr:(NSString*)strErr;
/** 订阅通道关闭
 * @param strPublishId	订阅的通道ID
 */
- (void) OnRtcSubscribeClosed:(NSString*)strPublishId;
@end

@interface AnyrtcM2Mutlier : NSObject {
    
}

@property (nonatomic, strong) AnyrtcVideoCallView *videoCallView;
@property (nonatomic, strong) id<AnyrtcM2MDelegate> delegate;

+ (void) InitAnyRTC:(NSString*)strDeveloperId andToken:(NSString*)strToken andAESKey:(NSString*)strAESKey andAppId:(NSString*)strAppId;

- (BOOL) Publish:(PublishParams*)params;
- (void) UnPublish;

- (BOOL) Subscribe:(NSString*)strPublishId andEnableVideo:(BOOL)enabelVideo;
- (void) UnSubscribe:(NSString*)strPublishId;

- (void) CloseAll;

- (void) setLocalAudioEnable:(BOOL)enable;
- (void) setLocalVideoEnable:(BOOL)enable;
- (void) switchCamera;

@end

#endif /* AnyrtcM2Mutlier_h */
