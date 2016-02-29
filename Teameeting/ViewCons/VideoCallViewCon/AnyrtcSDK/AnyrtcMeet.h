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
#import "M2MPublisher.h"

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
- (void) OnRtcLeaveMeet;
/** 视频大小
 * @param strPublishId	订阅的通道ID
 */
- (void) OnRtcVideoView:(UIView*)videoView didChangeVideoSize:(CGSize)size;
/*! @brief 远程图像进入p2p会议
 *
 *  @param removeView 远程图像
 *  @param peerChannelID  该通道标识符
 *  @param publishID  发布的ID
 */
- (void) OnRtcInRemoveView:(UIView *)removeView  withChannelID:(NSString *)peerChannelID withPublishID:(NSString*)publishID;

/*! @brief 远程图像离开会议
 *
 *  @param removeView 远程图像
 *  @param peerChannelID  该通道标识符
 */
- (void)OnRtcLeaveRemoveView:(UIView *)removeView  withChannelID:(NSString *)peerChannelID;
@end

@interface AnyrtcMeet : NSObject {
    
}

@property (nonatomic, weak) UIView *localView;

@property (nonatomic, strong) NSString *selectedTag;//大视图的tag 本地localView为大视图的时候请设置为nil

@property (nonatomic, weak) id<AnyrtcMeetDelegate> delegate;

+ (void) InitAnyRTC:(NSString*)strDeveloperId andToken:(NSString*)strToken andAESKey:(NSString*)strAESKey andAppId:(NSString*)strAppId;

- (BOOL) Join:(NSString*)strAnyrtcId;
- (void) Leave;

- (void) setLocalAudioEnable:(BOOL)enable;
- (void) setLocalVideoEnable:(BOOL)enable;
- (void) switchCamera;

@end

#endif /* AnyrtcM2Mutlier_h */
