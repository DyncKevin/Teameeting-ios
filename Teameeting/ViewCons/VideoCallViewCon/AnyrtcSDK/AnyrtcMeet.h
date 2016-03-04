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


@protocol AnyrtcMeetDelegate <NSObject>

/** 进会成功
 * @param strAnyrtcId	AnyRTC的ID
 */
- (void) OnRtcJoinMeetOK:(NSString*) strAnyrtcId;

/** 进会失败
 * @param strAnyrtcId	AnyRTC的ID
 * @param code	错误代码
 * @param strReason		原因
 */
- (void) OnRtcJoinMeetFailed:(NSString*) strAnyrtcId withCode:(int) code withReason:(NSString*) strReason;

/** 离开会议
 *
 */
- (void) OnRtcLeaveMeet:(int) code;
/** 视频大小
 * @param strPublishId	订阅的通道ID
 */
- (void) OnRtcVideoView:(UIView*)videoView didChangeVideoSize:(CGSize)size;
/*! @brief 远程图像进入p2p会议
 *
 *  @param publishID  通道的ID
 *  @param remoteView 远程图像
 */
- (void) OnRtcOpenRemoteView:(NSString*)publishID  withRemoteView:(UIView *)removeView;

/*! @brief 远程图像离开会议
 *
 *  @param publishID 通道的ID
 */
- (void)OnRtcRemoveRemoteView:(NSString*)publishID;

/*! @brief 远程视频的音视频状态
 *
 *  @param publishID 通道的ID
 *  @param audioEnable  音频是否开启
 *  @param videoEnable  视频是否开启
 */
- (void)OnRtcRemoteAVStatus:(NSString*)publishID withAudioEnable:(BOOL)audioEnable withVideoEnable:(BOOL)videoEnable;
@end

@interface AnyrtcMeet : NSObject {
    
}
@property (nonatomic, assign) BOOL proximityMonitoringEnabled; // 默认 YES

@property (nonatomic, weak) UIView *localView;



@property (nonatomic, weak) id<AnyrtcMeetDelegate> delegate;

+ (void) InitAnyRTC:(NSString*)strDeveloperId andToken:(NSString*)strToken andAESKey:(NSString*)strAESKey andAppId:(NSString*)strAppId;

- (BOOL) Join:(NSString*)strAnyrtcId;
- (void) Leave;
/**
 *  Big Video Bits
 *
 *  @param if local video view is big View please set publishID to nil or set video view publishID.
 */
- (void) setBigVideoBitsWithPulishId:(NSString*)publishID;

- (void) setLocalAudioEnable:(BOOL)enable;
- (void) setLocalVideoEnable:(BOOL)enable;
- (void) switchCamera;
/**
 *  Enable / Disable speaker
 *
 *  @param enableSpeaker set YES to enable, NO to disable.
 */
- (void)setEnableSpeaker:(BOOL)enableSpeaker;

@end

#endif /* AnyrtcM2Mutlier_h */
