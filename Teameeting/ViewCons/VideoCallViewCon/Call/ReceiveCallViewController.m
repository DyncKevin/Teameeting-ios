//
//  CallOtherViewController.m
//  DropevaDevice
//
//  Created by zjq on 15/10/10.
//  Copyright © 2015年 zjq. All rights reserved.
//

#import "ReceiveCallViewController.h"
#import "AnyrtcMeet.h"

#import <AVFoundation/AVFoundation.h>
#import "ASHUD.h"
#import "TMMessageManage.h"
#import "VideoShowItem.h"
#import "ToolUtils.h"

#define bottonSpace 10
#define VideoWidth 100
@interface ReceiveCallViewController ()<AnyrtcMeetDelegate,UIGestureRecognizerDelegate,tmMessageReceive>
{
    VideoShowItem *_localVideoView;
    
    CGSize _localVideoSize;
    
    NSString *_peerSelectedId;
    NSString *_peerOldSelectedId;
    
    // VIEW
    UIView *_toolBarView;
    UIButton *_videoButton;
    UIButton *_muteButton;
    UIButton *_cameraSwitchButton;
    BOOL videoenable;
    
    BOOL isRightTran;
    
    BOOL isChat;
    
}
@property (nonatomic, strong) NSMutableDictionary *_dicRemoteVideoView;
@property (nonatomic, strong) NSMutableDictionary *_audioOperateDict;
@property (nonatomic, strong) NSMutableDictionary *_videoOperateDict;
@property (nonatomic, strong) NSMutableArray *_userArray;
@property (nonatomic, strong) NSMutableArray *_channelArray;

@property(nonatomic, strong) AnyrtcMeet *_client;
@property(nonatomic, strong) UIScrollView *videosScrollView;
@property(nonatomic, assign) BOOL isFullScreen;

@end

@implementation ReceiveCallViewController

@synthesize _dicRemoteVideoView;

@synthesize _client;
@synthesize roomItem;
@synthesize _userArray,_channelArray,_audioOperateDict,_videoOperateDict;

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"FULLSCREEN" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"TALKCHAT_NOTIFICATION" object:nil];

    if (_dicRemoteVideoView) {
        _dicRemoteVideoView = nil;
    }

    if (_client) {
        _client  = nil;
    }
}

- (id)init {
    
    if (self = [super init]) {
        isRightTran = NO;
        [[TMMessageManage sharedManager] registerMessageListener:self];
    }
    return self;
}
- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];

}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    self.videosScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height - 100 - VideoParViewHeight, self.view.bounds.size.width, VideoParViewHeight)];
    self.videosScrollView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
    self.videosScrollView.bounces = YES;
    self.videosScrollView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    [self.videosScrollView setUserInteractionEnabled:YES];
    [self.videosScrollView setHidden:NO];
    self.videosScrollView.alwaysBounceVertical = NO;
//    [self.videosScrollView setScrollEnabled:NO];
    self.videosScrollView.backgroundColor = [UIColor clearColor];
    _peerSelectedId = nil;
    _userArray = [[NSMutableArray alloc] initWithCapacity:5];
    _channelArray = [[NSMutableArray alloc] initWithCapacity:5];
    _videoOperateDict = [[NSMutableDictionary alloc] initWithCapacity:5];
    _audioOperateDict = [[NSMutableDictionary alloc] initWithCapacity:5];
    
    _dicRemoteVideoView = [[NSMutableDictionary alloc] initWithCapacity:5];
    [AnyrtcMeet InitAnyRTC:@"13103994" andToken:@"de095967d87cd6f9a51ec4e3ee9a0ab7" andAESKey:@"E7FCkvPeaRBWGIxtO+mTjoJqu+TmqEDRNyi9YyFu82o" andAppId:@"Teameeting"];
    
    _client = [[AnyrtcMeet alloc] init];
    _client.proximityMonitoringEnabled = NO;
    _localVideoView = [[VideoShowItem alloc] init];
    [_localVideoView setFullScreen:NO];
    UIView *local = [[UIView alloc] initWithFrame:self.view.frame];
    _client.delegate = self;
    _client.localView = local;
    _localVideoView.showVideoView = local;
    
    UITapGestureRecognizer *singleTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(locolvideoSingleTap:)];
    singleTapGestureRecognizer.delegate = self;
    [singleTapGestureRecognizer setNumberOfTapsRequired:1];
    [_localVideoView.showVideoView addGestureRecognizer:singleTapGestureRecognizer];
    [self.view addSubview:_localVideoView.showVideoView];
 
    
    [self.view addSubview:self.videosScrollView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fullSreenNoti:) name:@"FULLSCREEN" object:nil];
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(chatViewNoti:) name:@"TALKCHAT_NOTIFICATION" object:nil];

     [_client Join:roomItem.anyRtcID];
}
- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self layoutSubView];
}


// setting pre operate to view
- (void)settingMediaToViewOperate:(VideoShowItem*)item
{
    NSNumber *audio = [_audioOperateDict objectForKey:item.publishID];
    NSNumber *video = [_videoOperateDict objectForKey:item.publishID];
    
    if (audio) {
        if (![audio boolValue]) {
            [item setAudioClose:YES];
        }else{
            [item setAudioClose:NO];
        }
        [_audioOperateDict removeObjectForKey:item.publishID];
    }
    if (video) {
        if (![video boolValue]) {
            [item setVideoHidden:YES];
        }else{
            [item setVideoHidden:NO];
        }
        [_videoOperateDict removeObjectForKey:item.publishID];
    }
}

-(BOOL)receiveMessageEnable {
    
    return YES;
}

// ios iphone notification
- (void)chatViewNoti:(NSNotification*)noti
{
    isChat = [noti.object boolValue];
    if (isChat) {
        [UIView animateWithDuration:0.2 animations:^{
            
            self.videosScrollView.frame = CGRectMake(self.videosScrollView.frame.origin.x, self.view.bounds.size.height - VideoParViewHeight, self.view.bounds.size.width, VideoParViewHeight);
        }];
    }else{
        [UIView animateWithDuration:0.2 animations:^{
            
            self.videosScrollView.frame = CGRectMake(self.videosScrollView.frame.origin.x, self.view.bounds.size.height - 100 - VideoParViewHeight, self.view.bounds.size.width, VideoParViewHeight);
        }];
    }
}

- (void)fullSreenNoti:(NSNotification *)noti {
    
    self.isFullScreen = !self.isFullScreen;
    [self layoutSubView];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    
    Class class = NSClassFromString(@"GLKView");
    if ([touch.view isKindOfClass:class] && CGRectGetWidth(touch.view.frame) < self.view.bounds.size.width){
        
        return YES;
        
    }
    return NO;
}

#pragma mark - publish method
- (void)videoEnable:(BOOL)enable
{
    if (_client) {
         [_client setLocalVideoEnable:enable];
       
        if (enable) {
            [_localVideoView setVideoHidden:NO];
        }else{
            [_localVideoView setVideoHidden:YES];
        }
    }
}
- (void)audioEnable:(BOOL)enable
{
    if (_client) {
        [_client setLocalAudioEnable:enable];
        if (enable) {
            [_localVideoView setAudioClose:NO];
        }else{
             [_localVideoView setAudioClose:YES];
        }
    }
}

- (void)switchCamera // switch camera
{
    if (_client) {
        [_client switchCamera];
    }
}
- (void)hangeUp      // hunge up
{
    if (_client) {
         [_client Leave];
        _client.delegate = nil;
        [[TMMessageManage sharedManager] tmRoomCmd:MCMeetCmdLEAVE roomid:self.roomItem.roomID withRoomName:self.roomItem.roomName remain:@""];
        [[TMMessageManage sharedManager] removeMessageListener:self];
    }
}
- (void)sendMessageWithCmmand:(NSString *)cmd userID:(NSString *)userid {
    
}

- (void)transitionVideoView:(BOOL)isRigth
{
    if (isRigth) {
        isRightTran = YES;
        [UIView animateWithDuration:.2 animations:^{
            self.videosScrollView.frame = CGRectMake(self.videosScrollView.frame.origin.x+TalkPannelWidth, self.videosScrollView.frame.origin.y, self.videosScrollView.frame.size.width-TalkPannelWidth, VideoParViewHeight);
             self.videosScrollView.contentOffset = CGPointMake(0, 0);
            [self layoutSubView];
        }completion:^(BOOL finished) {
//           [self layoutSubView];
        }];
    }else{
        isRightTran = NO;
        [UIView animateWithDuration:.2 animations:^{
            self.videosScrollView.frame = CGRectMake(self.videosScrollView.frame.origin.x-TalkPannelWidth, self.videosScrollView.frame.origin.y, self.videosScrollView.frame.size.width+TalkPannelWidth, VideoParViewHeight);
             self.videosScrollView.contentOffset = CGPointZero;
            [self layoutSubView];
        }completion:^(BOOL finished) {
//            [self layoutSubView];
        }];
    }
   
}


#pragma mark - notification
// 程序进入后台时，停止视频
- (void)applicationWillResignActive
{
    if (!_videoButton.selected) {
        videoenable = YES;
        [_client setLocalVideoEnable:NO];
    }
}

// 程序进入前台时，重启视频
- (void)applicationDidBecomeActive
{
    if (videoenable) {
        videoenable = NO;
        [_client setLocalVideoEnable:YES];
    }
    [self layoutSubView];
}

- (void)layoutSubView
{
    if ([ToolUtils shead].isBack) {
        return;
    }
    [ASHUD hideHUD];
    if (self.isFullScreen) {
        [UIView animateWithDuration:.2 animations:^{
            if (isRightTran) {
                self.videosScrollView.frame = CGRectMake(self.videosScrollView.frame.origin.x, self.view.bounds.size.height - VideoParViewHeight, self.view.bounds.size.width-TalkPannelWidth, VideoParViewHeight);
            }else{
                self.videosScrollView.frame = CGRectMake(0, self.view.bounds.size.height - VideoParViewHeight, self.view.bounds.size.width, VideoParViewHeight);
            }
        }];
        if (_peerSelectedId) {
            VideoShowItem *item = [_dicRemoteVideoView objectForKey:_peerSelectedId];
            [item setFullScreen:YES];
            if (_peerOldSelectedId) {
                VideoShowItem *item = [_dicRemoteVideoView objectForKey:_peerOldSelectedId];
                [item setFullScreen:YES];
            }else{
                [_localVideoView setFullScreen:YES];
            }
        }else{
              [_localVideoView setFullScreen:YES];
            if (_peerOldSelectedId) {
                VideoShowItem *item = [_dicRemoteVideoView objectForKey:_peerOldSelectedId];
                [item setFullScreen:YES];
            }
        }
        
    }else {
        [UIView animateWithDuration:.2 animations:^{
            if (isRightTran) {
                self.videosScrollView.frame = CGRectMake(self.videosScrollView.frame.origin.x, self.view.bounds.size.height - 100 - VideoParViewHeight, self.view.bounds.size.width-TalkPannelWidth, VideoParViewHeight);
            }else{
                if (!isChat) {
                     self.videosScrollView.frame = CGRectMake(0, self.view.bounds.size.height - 100 - VideoParViewHeight, self.view.bounds.size.width, VideoParViewHeight);
                }
               
            }
        }];
        if (_peerSelectedId) {
            VideoShowItem *item = [_dicRemoteVideoView objectForKey:_peerSelectedId];
            [item setFullScreen:NO];
        }else{
             [_localVideoView setFullScreen:NO];
        }
        if (_peerOldSelectedId) {
            VideoShowItem *item = [_dicRemoteVideoView objectForKey:_peerOldSelectedId];
            [item setFullScreen:YES];
        }
    }
    
    if (_peerSelectedId) {
        [_localVideoView setFullScreen:YES];
        
        VideoShowItem* view = nil;
        view = (VideoShowItem*)[_dicRemoteVideoView objectForKey:_peerSelectedId];

        if (view.videoSize.width>0&& view.videoSize.height>0) {
             //Aspect fit local video view into a square box.
            CGRect remoteVideoFrame =
            AVMakeRectWithAspectRatioInsideRect(view.videoSize, self.view.bounds);
            CGFloat scale = 1;
            if (remoteVideoFrame.size.width < remoteVideoFrame.size.height) {
                // Scale by height.
                scale = self.view.bounds.size.height / remoteVideoFrame.size.height;
            } else {
                // Scale by width.
                scale = self.view.bounds.size.width / remoteVideoFrame.size.width;
            }
            remoteVideoFrame.size.height *= scale;
            remoteVideoFrame.size.width *= scale;
            view.showVideoView.frame = remoteVideoFrame;
            view.showVideoView.center = CGPointMake(self.view.bounds.size.width/2,self.view.bounds.size.height/2);
            
        }else{
            view.showVideoView.frame = self.view.bounds;
            view.showVideoView.center = CGPointMake(self.view.bounds.size.width/2,self.view.bounds.size.height/2);
        }
        if ([view.showVideoView.superview isKindOfClass:[self.videosScrollView class]]) {
            [view.showVideoView removeFromSuperview];
            [self.view addSubview:view.showVideoView];
            [self.view sendSubviewToBack:view.showVideoView];
        }else if([view.showVideoView.superview isKindOfClass:[self.view class]]){
             [self.view sendSubviewToBack:view.showVideoView];
        }else{
            [self.view addSubview:view.showVideoView];
            [self.view sendSubviewToBack:view.showVideoView];
        }
        
        [self.videosScrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        
        float sizeViewAllWidth = 0;

        if ([_localVideoView.showVideoView.superview isKindOfClass:[self.view class]]) {
            [_localVideoView.showVideoView removeFromSuperview];
        }
        
        CGFloat videoViewHeight = 0.0;
        if (ISIPAD) {
            videoViewHeight = self.view.bounds.size.height/4.5;
        }else{
            videoViewHeight = self.view.bounds.size.height/4;
        }
        CGFloat localViewWidth = 0.0;
        CGFloat remoteViewWidth = 0.0;

        float scaleHeight = [self getAllWidthWithHeight:videoViewHeight withAllHeight:&sizeViewAllWidth withLocal:YES];
        videoViewHeight = scaleHeight;
        if (_localVideoSize.width>0 && _localVideoSize.height>0) {
            localViewWidth = (_localVideoSize.width/_localVideoSize.height)*videoViewHeight;
        }else{
            localViewWidth = VideoWidth;
        }
        
        CGFloat x = (self.videosScrollView.bounds.size.width - (sizeViewAllWidth))/2;
      
        CGFloat y = self.videosScrollView.bounds.size.height - videoViewHeight;
        
        for (id key in [_dicRemoteVideoView allKeys]) {
            if (![key isEqualToString:_peerSelectedId]) {
                VideoShowItem * viewsmail = [_dicRemoteVideoView objectForKey:key];
                if (viewsmail.videoSize.width>0&& viewsmail.videoSize.height>0) {
                   remoteViewWidth = (viewsmail.videoSize.width/viewsmail.videoSize.height)*videoViewHeight;
                   viewsmail.showVideoView.frame = CGRectMake(x,y, remoteViewWidth, videoViewHeight);
                    [self.videosScrollView addSubview:viewsmail.showVideoView];
                    x = x+remoteViewWidth;
                }else{
                    remoteViewWidth = VideoWidth;
                    viewsmail.showVideoView.frame = CGRectMake(x,y, remoteViewWidth, videoViewHeight);
                    [self.videosScrollView addSubview:viewsmail.showVideoView];
                    x = x+remoteViewWidth;
                }
            }
        }
        _localVideoView.showVideoView.frame = CGRectMake(x, y, localViewWidth, videoViewHeight);
        [self.videosScrollView addSubview:_localVideoView.showVideoView];
  
    } else {
        
        if (_dicRemoteVideoView.count==0) {
            if (_localVideoSize.width && _localVideoSize.height > 0) {
                float scaleW = self.view.bounds.size.width/_localVideoSize.width;
                float scaleH = self.view.bounds.size.height/_localVideoSize.height;
                if (scaleW>scaleH) {
                    _localVideoView.showVideoView.frame = CGRectMake(0, 0, _localVideoSize.width*scaleW, _localVideoSize.height*scaleW);
                    _localVideoView.showVideoView.center =  CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds));;
                }else{
                    _localVideoView.showVideoView.frame = CGRectMake(0, 0, _localVideoSize.width*scaleH, _localVideoSize.height*scaleH);
                    _localVideoView.showVideoView.center =  CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds));;
                }
                
            } else {
                _localVideoView.showVideoView.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
            }
            [_localVideoView.showVideoView removeFromSuperview];
            [self.view addSubview:_localVideoView.showVideoView];
            [self.view sendSubviewToBack:_localVideoView.showVideoView];
            return;
        }
        if (_localVideoSize.width && _localVideoSize.height > 0) {
            float scaleW = self.view.bounds.size.width/_localVideoSize.width;
            float scaleH = self.view.bounds.size.height/_localVideoSize.height;
            if (scaleW>scaleH) {
                _localVideoView.showVideoView.frame = CGRectMake(0, 0, _localVideoSize.width*scaleW, _localVideoSize.height*scaleW);
                _localVideoView.showVideoView.center =  CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds));;
            }else{
                _localVideoView.showVideoView.frame = CGRectMake(0, 0, _localVideoSize.width*scaleH, _localVideoSize.height*scaleH);
                _localVideoView.showVideoView.center =  CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds));;
            }
        } else {
            _localVideoView.showVideoView.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
        }
        [_localVideoView.showVideoView removeFromSuperview];
        [self.view addSubview:_localVideoView.showVideoView];
        [self.view sendSubviewToBack:_localVideoView.showVideoView];
    
        
        float sizeViewAllWidth = 0;
        CGFloat videoViewHeight = 0.0;
        if (ISIPAD) {
            videoViewHeight = self.view.bounds.size.height/4.5;
        }else{
            videoViewHeight = self.view.bounds.size.height/4;
        }
        CGFloat remoteViewWidth = 0.0;
        
        float scaleHeight = [self getAllWidthWithHeight:videoViewHeight withAllHeight:&sizeViewAllWidth withLocal:NO];
        videoViewHeight = scaleHeight;
        
        CGFloat x = (self.videosScrollView.bounds.size.width - sizeViewAllWidth)/2;
     
        CGFloat y = self.videosScrollView.bounds.size.height - videoViewHeight;
        
        for (id key in [_dicRemoteVideoView allKeys]) {
            if (![key isEqualToString:_peerSelectedId]) {
                VideoShowItem * viewsmail = [_dicRemoteVideoView objectForKey:key];
                if (viewsmail.videoSize.width>0&& viewsmail.videoSize.height>0) {
                    remoteViewWidth = (viewsmail.videoSize.width/viewsmail.videoSize.height)*videoViewHeight;
                    viewsmail.showVideoView.frame = CGRectMake(x,y, remoteViewWidth, videoViewHeight);
                    [self.videosScrollView addSubview:viewsmail.showVideoView];
                    x = x+remoteViewWidth;
                }else{
                    remoteViewWidth = VideoWidth;
                    viewsmail.showVideoView.frame = CGRectMake(x,y, remoteViewWidth, videoViewHeight);
                    [self.videosScrollView addSubview:viewsmail.showVideoView];
                    x = x+remoteViewWidth;
                }
            }
        }
    }
}
- (float)getAllWidthWithHeight:(float)height withAllHeight:(float*)allWidth withLocal:(BOOL)hasLocal{
    float width = 0.0f;
    float videowidth = 0.0f;
    for (id key in [_dicRemoteVideoView allKeys]) {
        if (![key isEqualToString:_peerSelectedId]) {
            VideoShowItem * viewsmail = [_dicRemoteVideoView objectForKey:key];
            if (viewsmail.videoSize.width>0&& viewsmail.videoSize.height>0) {
               videowidth = (viewsmail.videoSize.width/viewsmail.videoSize.height)*height;
            }else{
                videowidth = VideoWidth;
            }
            viewsmail.showVideoView.frame = CGRectMake(0,0, videowidth, height);
            width += videowidth;
        }
    }
    float localWidth = 0.0;
    if (hasLocal) {
        if (_localVideoSize.width>0 && _localVideoSize.height>0) {
            localWidth = (_localVideoSize.width/_localVideoSize.height)*height;
        }else{
            localWidth = VideoWidth;
        }
    }
  
    *allWidth = width+localWidth;
    
    if ((width + localWidth)>self.videosScrollView.bounds.size.width) {
        height-=20;
        return [self getAllWidthWithHeight:height withAllHeight:allWidth withLocal:hasLocal];
    }
    return height;
}

#pragma mark -  UITapGestureRecognizer
- (void)locolvideoSingleTap:(UITapGestureRecognizer*)gesture
{
    if (_peerSelectedId) {
        _peerOldSelectedId = _peerSelectedId;
        _peerSelectedId = nil;
        [_client setBigVideoBitsWithPulishId:nil];
        [self layoutSubView];
    }
   
}
- (void)singleTap:(UITapGestureRecognizer*)gesture
{
    // 像变大(先看是不是点中的)
    UIView  *view = (UIView*)[gesture view];
    // 如果得到的是小图的，变为大图
    if (CGRectGetWidth(view.frame) < self.view.bounds.size.width) {
        for (id key in [_dicRemoteVideoView allKeys]) {
            VideoShowItem *item = [_dicRemoteVideoView objectForKey:key];
         
            if (item.showVideoView == view) {
                _peerOldSelectedId = _peerSelectedId;
                _peerSelectedId = key;
                [_client setBigVideoBitsWithPulishId:key];
                [self layoutSubView];
                return;
            }
        }
    }
}
#pragma mark -  UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
}

#pragma mark - AnyrtcM2MDelegate


/** 进会成功
 * @param strAnyrtcId	AnyRTC的ID
 */
- (void) OnRtcJoinMeetOK:(NSString*) strAnyrtcId
{
    
}

/** 进会失败
 * @param strAnyrtcId	AnyRTC的ID
 * @param code	错误代码
 * @param strReason		原因
 */
- (void) OnRtcJoinMeetFailed:(NSString*) strAnyrtcId withCode:(int) code withReason:(NSString*) strReason
{
    
}

/** 离开会议
 *
 */
- (void) OnRtcLeaveMeet:(int) code
{
    
}

- (void) OnRtcVideoView:(UIView*)videoView didChangeVideoSize:(CGSize)size {
    NSLog(@"-------%d",[NSThread isMainThread]);
    if (videoView == _localVideoView.showVideoView) {
        _localVideoView.videoSize = size;
        _localVideoSize = size;
    }else{
        NSLog(@"didChangeVideoSize:%f  %f",size.width,size.height);
        for (NSString *strTag in [_dicRemoteVideoView allKeys]) {
           VideoShowItem *remoteView = (VideoShowItem*)[_dicRemoteVideoView objectForKey:strTag];
            if (remoteView.showVideoView == videoView) {
                remoteView.videoSize = size;
                // setting
                [self settingMediaToViewOperate:remoteView];
                break;
            }
        }
        NSLog(@"OnRtcVideoView:%f %f",size.width,size.height);
    }
    [self layoutSubView];
    
}
/*! @brief 远程图像进入p2p会议
 *
 *  @param removeView 远程图像
 *  @param peerChannelID  该通道标识符
 */
- (void) OnRtcOpenRemoteView:(NSString*)publishID  withRemoteView:(UIView *)removeView
{
   
    VideoShowItem* findView = [_dicRemoteVideoView objectForKey:publishID];
    if (findView.showVideoView == removeView) {
        return;
    }
    if (!_peerSelectedId&&_dicRemoteVideoView.count==0) {
        _peerSelectedId = publishID;
         [_client setBigVideoBitsWithPulishId:publishID];
    }
    
    VideoShowItem *item = [[VideoShowItem alloc] init];
    item.showVideoView = removeView;
    item.publishID = publishID;
    
    [_dicRemoteVideoView setObject:item forKey:publishID];
    
    UITapGestureRecognizer *singleTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(singleTap:)];
    [singleTapGestureRecognizer setNumberOfTapsRequired:1];
    singleTapGestureRecognizer.delegate = self;
    [item.showVideoView  addGestureRecognizer:singleTapGestureRecognizer];

    
    [self layoutSubView];
    //While the number of remote image change, send a notification
    NSNumber *remoteVideoCount = [NSNumber numberWithInteger:[_dicRemoteVideoView count]];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"REMOTEVIDEOCHANGE" object:remoteVideoCount];

   
    
}

/*! @brief 远程图像离开会议
 *
 *  @param publishID  该通道标识符
 */
- (void)OnRtcRemoveRemoteView:(NSString*)publishID
{
    
    VideoShowItem *findView = [_dicRemoteVideoView objectForKey:publishID];
    if (findView) {
        if ([publishID isEqualToString:_peerSelectedId]) {
            [findView.showVideoView removeFromSuperview];
            [_dicRemoteVideoView removeObjectForKey:publishID];
            if (_dicRemoteVideoView.count!=0) {
                _peerSelectedId =[[_dicRemoteVideoView allKeys] firstObject];
                 [_client setBigVideoBitsWithPulishId:_peerSelectedId];
            }else{
                _peerSelectedId = nil;
                 [_client setBigVideoBitsWithPulishId:nil];
            }
        }else{
            [findView.showVideoView removeFromSuperview];
            [_dicRemoteVideoView removeObjectForKey:publishID];
           
        }
        if (_dicRemoteVideoView.count ==0) {
            self.isFullScreen = NO;
        }
        [self layoutSubView];
    }
   
    //While the number of remote image change, send a notification
    NSNumber *remoteVideoCount = [NSNumber numberWithInteger:[_dicRemoteVideoView count]];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"REMOTEVIDEOCHANGE" object:remoteVideoCount];
    
}
/*! @brief 远程视频的音视频状态
 *
 *  @param publishID 通道的ID
 *  @param audioEnable  音频是否开启
 *  @param videoEnable  视频是否开启
 */
- (void)OnRtcRemoteAVStatus:(NSString*)publishID withAudioEnable:(BOOL)audioEnable withVideoEnable:(BOOL)videoEnable
{
    
    VideoShowItem *item = [_dicRemoteVideoView objectForKey:publishID];
    if (item) {
        if (audioEnable) {
            [item setAudioClose:NO];
        }else{
            [item setAudioClose:YES];
        }
        if (videoEnable) {
            [item setVideoHidden:NO];
        }else{
            [item setVideoHidden:YES];
        }
    }else{
        if (!audioEnable) {
            [_audioOperateDict setObject:[NSNumber numberWithBool:audioEnable] forKey:publishID];
        }
        
        if (!videoEnable) {
            [_videoOperateDict setObject:[NSNumber numberWithBool:videoEnable] forKey:publishID];
        }
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
