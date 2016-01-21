//
//  CallOtherViewController.m
//  DropevaDevice
//
//  Created by zjq on 15/10/10.
//  Copyright © 2015年 zjq. All rights reserved.
//

#import "ReceiveCallViewController.h"
#import "AnyrtcM2Mutlier.h"
#import "AvcAudioRouteMgr.h"
#import <AVFoundation/AVFoundation.h>
#import "ASHUD.h"
#import "TMMessageManage.h"
//#import "VideoShowView.h"
#import "VideoShowItem.h"

#define bottonSpace 10
@interface ReceiveCallViewController ()<AnyrtcM2MDelegate,UIGestureRecognizerDelegate,tmMessageReceive>
{
    AvcAudioRouteMgr *_audioManager;
    VideoShowItem *_localVideoView;
    
    CGSize _localVideoSize;
    CGSize _videoSize;
    
    NSString *_peerSelectedId;
    NSString *_peerOldSelectedId;
    
    // VIEW
    UIView *_toolBarView;
    UIButton *_videoButton;
    UIButton *_muteButton;
    UIButton *_cameraSwitchButton;
    BOOL videoEnable;
    
    UIAlertView *_exitErrorAlertView;   // 退出房间失败的问题
    UIAlertView *_exitRoomAlertView;    // 退出房间
    
}
@property (nonatomic, strong)  NSMutableDictionary *_dicRemoteVideoView;
@property (nonatomic, strong) NSMutableArray *_userArray;
@property (nonatomic, strong) NSMutableArray *_channelArray;

@property(nonatomic, strong) AnyrtcM2Mutlier *_client;
@property(nonatomic, strong) UIScrollView *videosScrollView;
@property(nonatomic, assign) BOOL isFullScreen;

@end

@implementation ReceiveCallViewController

@synthesize _dicRemoteVideoView;

@synthesize _client;
@synthesize roomID;
@synthesize _userArray,_channelArray;

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    
    if (_audioManager) {
        _audioManager = nil;
    }
    
    if (_dicRemoteVideoView) {
        _dicRemoteVideoView = nil;
    }

    if (_client) {
        _client  = nil;
    }
}

- (id)init {
    
    if (self = [super init]) {
        
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
    self.videosScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height - 390, self.view.bounds.size.width, 300)];
    self.videosScrollView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
    self.videosScrollView.bounces = YES;
    self.videosScrollView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    [self.videosScrollView setUserInteractionEnabled:YES];
    [self.videosScrollView setHidden:NO];
    [self.videosScrollView setScrollEnabled:NO];
    self.videosScrollView.backgroundColor = [UIColor clearColor];
    _peerSelectedId = nil;
    _userArray = [[NSMutableArray alloc] initWithCapacity:5];
    _channelArray = [[NSMutableArray alloc] initWithCapacity:5];
    
    _dicRemoteVideoView = [[NSMutableDictionary alloc] initWithCapacity:5];
    [AnyrtcM2Mutlier InitAnyRTC:@"mzw0001" andToken:@"defq34hj92mxxjhaxxgjfdqi1s332dd" andAESKey:@"d74TcmQDMB5nWx9zfJ5al7JdEg3XwySwCkhdB9lvnd1" andAppId:@"org.dync.app"];
    _client = [[AnyrtcM2Mutlier alloc] init];
    _localVideoView = [[VideoShowItem alloc] init];
    [_localVideoView setFullScreen:NO];
    UIView *local = [[UIView alloc] initWithFrame:self.view.frame];
    _client.delegate = self;
    _client.localView = local;
    
    UITapGestureRecognizer *singleTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(locolvideoSingleTap:)];
    singleTapGestureRecognizer.delegate = self;
    [singleTapGestureRecognizer setNumberOfTapsRequired:1];
    [local addGestureRecognizer:singleTapGestureRecognizer];
    [self.view addSubview:local];
    _localVideoView.showVideoView = local;
    
    [self.view addSubview:self.videosScrollView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fullSreenNoti:) name:@"FULLSCREEN" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rotateChange:) name:@"ROTATECHANGE" object:nil];

    {//@Eric - Publish myself
        PublishParams *pramas = [[PublishParams alloc]init];
        [pramas setEnableVideo:true];
        [pramas setEnableRecord:false];
        [pramas setStreamType:kSTRtc];
        [_client Publish:pramas];
    }
}

- (void)videoSubscribeWith:(NSString *)publishId action:(NSInteger)action {
    
    if (action == 4) {
        
        [_client Subscribe:publishId andEnableVideo:YES];
        
    } else {
        
        [_client UnSubscribe:publishId];
    }
    
}



-(BOOL)receiveMessageEnable {
    
    return YES;
}

- (void)rotateChange:(NSNotification *)noti {
    
    //[self.videosScrollView setContentSize:CGSizeMake([[noti object] integerValue], 300)];
    //[self.videosScrollView setContentOffset:CGPointMake(self.videosScrollView.contentSize.width/4, 0)];
}

- (void)fullSreenNoti:(NSNotification *)noti {
    
    self.isFullScreen = !self.isFullScreen;
    if (self.isFullScreen ) {
        
        if (_peerSelectedId) {
            VideoShowItem *item = [_dicRemoteVideoView objectForKey:_peerSelectedId];
            [item setFullScreen:YES];
        }else{
            [_localVideoView setFullScreen:YES];
        }
        
        [UIView animateWithDuration:0.2 animations:^{
            
            self.videosScrollView.frame = CGRectMake(self.videosScrollView.frame.origin.x, self.view.bounds.size.height - 180, self.view.bounds.size.width, 180);
        }];
        
    } else {
        if (_peerSelectedId) {
            VideoShowItem *item = [_dicRemoteVideoView objectForKey:_peerSelectedId];
            [item setFullScreen:NO];
        }else{
            [_localVideoView setFullScreen:NO];
        }
        
        [UIView animateWithDuration:0.2 animations:^{
            
            self.videosScrollView.frame = CGRectMake(self.videosScrollView.frame.origin.x, self.view.bounds.size.height - 280, self.view.bounds.size.width, 180);
        }];
    }
    
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    
    Class class = NSClassFromString(@"GLKView");
    if ([touch.view isKindOfClass:class] && CGRectGetWidth(touch.view.frame) < self.view.bounds.size.width/2){
        
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
        [_client CloseAll];
        [_client UnSubscribe:self.roomID];
        [[TMMessageManage sharedManager] tmRoomCmd:MCMeetCmdLEAVE roomid:self.roomID remain:@""];
        [[TMMessageManage sharedManager] removeMessageListener:self];
    }
    
    return;
    _exitRoomAlertView = [[UIAlertView alloc] initWithTitle:nil message:@"你确定要退出吗？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [_exitRoomAlertView show];
}
- (void)sendMessageWithCmmand:(NSString *)cmd userID:(NSString *)userid {
    
}

#pragma mark - notification
// 程序进入后台时，停止视频
- (void)applicationWillResignActive
{
    if (!_videoButton.selected) {
        videoEnable = YES;
        [_client setLocalVideoEnable:NO];
    }
}

// 程序进入前台时，重启视频
- (void)applicationDidBecomeActive
{
    if (videoEnable) {
        videoEnable = NO;
        [_client setLocalVideoEnable:YES];
    }
}

- (void)layoutSubView
{
    [ASHUD hideHUD];
    if (self.isFullScreen) {
            self.videosScrollView.frame = CGRectMake(self.videosScrollView.frame.origin.x, self.view.bounds.size.height - 180, self.view.bounds.size.width, 180);
        
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
        }
        
    } else {
            self.videosScrollView.frame = CGRectMake(self.videosScrollView.frame.origin.x, self.view.bounds.size.height - 280, self.view.bounds.size.width, 180);
        if (_peerSelectedId) {
            VideoShowItem *item = [_dicRemoteVideoView objectForKey:_peerSelectedId];
            [item setFullScreen:NO];
            if (_peerOldSelectedId) {
                VideoShowItem *item = [_dicRemoteVideoView objectForKey:_peerOldSelectedId];
                [item setFullScreen:YES];
            }else{
                [_localVideoView setFullScreen:NO];
            }
        }else{
              [_localVideoView setFullScreen:NO];
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
            view.showVideoView.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);;
        }
        
        [view.showVideoView removeFromSuperview];
        [self.view addSubview:view.showVideoView];
        [self.view sendSubviewToBack:view.showVideoView];
        
        CGFloat scalelocal = _localVideoSize.width/_localVideoSize.height;
        CGFloat localViewwidth = self.view.bounds.size.width/4;
        CGFloat localViewheight = localViewwidth/scalelocal;
        
        CGFloat remoteViewHeight = 0.0;
        CGFloat remoteViewWidth = 0.0;
    
        remoteViewWidth = self.view.bounds.size.width/4;
        
        CGFloat x = (self.view.bounds.size.width - (_dicRemoteVideoView.count-1)*remoteViewWidth - localViewwidth)/2;
        CGFloat y = 180;//self.view.bounds.size.height - localViewheight - 20;
        
        if (_localVideoSize.width && _localVideoSize.height > 0 ) {
            
            _localVideoView.showVideoView.frame =  CGRectMake(0, 0, localViewwidth, localViewheight);
            [_localVideoView.showVideoView removeFromSuperview];
        }
        [self.videosScrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        
        NSMutableArray *videoArrays = [NSMutableArray array];
        VideoShowItem* viewsmail = nil;
        for (id key in [_dicRemoteVideoView allKeys]) {
            if (![key isEqualToString:_peerSelectedId]) {
                viewsmail = [_dicRemoteVideoView objectForKey:key];
                if (viewsmail.videoSize.width>0&& viewsmail.videoSize.height>0) {
                    CGFloat scale = viewsmail.videoSize.width/viewsmail.videoSize.height;
                     remoteViewHeight = remoteViewWidth/scale;
                }
                viewsmail.showVideoView.frame = CGRectMake(x, y, remoteViewWidth, remoteViewHeight);
                x+=remoteViewWidth;
                [videoArrays addObject:viewsmail];
            }
        }
        if (![videoArrays containsObject:_localVideoView])
            [videoArrays addObject:_localVideoView];
        
        NSMutableArray *leftVideos = [NSMutableArray array];
        NSMutableArray *rightVideos = [NSMutableArray array];
        if ([videoArrays count] == 1) {
            
            VideoShowItem *subView = [videoArrays objectAtIndex:0];
            [subView.showVideoView setCenter:CGPointMake(self.videosScrollView.bounds.size.width/2, self.videosScrollView.bounds.size.height-subView.showVideoView.bounds.size.height/2-bottonSpace)];
            [self.videosScrollView addSubview:subView.showVideoView];
            
        } else {
            
            for (int i = 0; i < [videoArrays count]; i++) {
                
                VideoShowItem *subView = [videoArrays objectAtIndex:i];
                if (i %2 == 0) {
                    
                    [leftVideos addObject:subView];
                    
                } else {
                    
                    [rightVideos addObject:subView];
                }
                
            }
            for (int i = 0; i < [leftVideos count]; i ++) {
                
                VideoShowItem *subView = [leftVideos objectAtIndex:i];
                CGRect rect = CGRectMake(self.videosScrollView.bounds.size.width/2 - (i + 1)*subView.showVideoView.bounds.size.width, self.videosScrollView.bounds.size.height/2, subView.showVideoView.bounds.size.width, subView.showVideoView.bounds.size.height);
                subView.showVideoView.frame = rect;
                [subView.showVideoView setCenter:CGPointMake(subView.showVideoView.center.x, self.videosScrollView.bounds.size.height-subView.showVideoView.bounds.size.height/2-bottonSpace)];
                [self.videosScrollView addSubview:subView.showVideoView];
            }
            for (int i = 0; i < [rightVideos count]; i ++) {
                
                VideoShowItem*subView = [rightVideos objectAtIndex:i];
                CGRect rect = CGRectMake(self.videosScrollView.bounds.size.width/2 + i*subView.showVideoView.bounds.size.width, self.videosScrollView.bounds.size.height/2, subView.showVideoView.bounds.size.width, subView.showVideoView.bounds.size.height);
                subView.showVideoView.frame = rect;
                [subView.showVideoView setCenter:CGPointMake(subView.showVideoView.center.x, self.videosScrollView.bounds.size.height-subView.showVideoView.bounds.size.height/2-bottonSpace)];
                [self.videosScrollView addSubview:subView.showVideoView];
            }
            
        }
    
        
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
    

        CGFloat remoteViewWidth = self.view.bounds.size.width/4;
        CGFloat remoteViewHeight = 0.0;
        
        CGFloat x = self.view.bounds.size.width - _dicRemoteVideoView.count*remoteViewWidth -20;
        CGFloat y = self.view.bounds.size.height - 180;
        
        
        NSMutableArray *videoArrays = [NSMutableArray array];
        VideoShowItem* viewsmail = nil;
        for (id key in [_dicRemoteVideoView allKeys]) {
            viewsmail = [_dicRemoteVideoView objectForKey:key];
            if (viewsmail.videoSize.width>0 && viewsmail.videoSize.height>0) {
                CGFloat scale = viewsmail.videoSize.width/viewsmail.videoSize.height;
                remoteViewHeight = remoteViewWidth/scale;
            }
            viewsmail.showVideoView.frame = CGRectMake(x, y, remoteViewWidth, remoteViewHeight);
            x+=remoteViewWidth;
            [viewsmail.showVideoView removeFromSuperview];
            [videoArrays addObject:viewsmail];
        }
        NSMutableArray *leftVideos = [NSMutableArray array];
        NSMutableArray *rightVideos = [NSMutableArray array];
        
        if ([videoArrays count] == 1) {
            
            VideoShowItem *subView = [videoArrays objectAtIndex:0];
            [subView.showVideoView setCenter:CGPointMake(self.videosScrollView.bounds.size.width/2, self.videosScrollView.bounds.size.height-subView.showVideoView.bounds.size.height/2-bottonSpace)];
            [self.videosScrollView addSubview:subView.showVideoView];
            
        } else {
            
            for (int i = 0; i < [videoArrays count]; i++) {
                
                VideoShowItem *subView = [videoArrays objectAtIndex:i];
                if (i %2 == 0) {
                    
                    [leftVideos addObject:subView];
                    
                } else {
                    
                    [rightVideos addObject:subView];
                }
                
            }
            for (int i = 0; i < [leftVideos count]; i ++) {
                
                VideoShowItem *subView = [leftVideos objectAtIndex:i];
                CGRect rect = CGRectMake(self.videosScrollView.bounds.size.width/2 - (i + 1)*subView.showVideoView.bounds.size.width, self.videosScrollView.bounds.size.height/2, subView.showVideoView.bounds.size.width, subView.showVideoView.bounds.size.height);
                subView.showVideoView.frame = rect;
                [subView.showVideoView setCenter:CGPointMake(subView.showVideoView.center.x, self.videosScrollView.bounds.size.height-subView.showVideoView.bounds.size.height/2-bottonSpace)];
                [self.videosScrollView addSubview:subView.showVideoView];
            }
            for (int i = 0; i < [rightVideos count]; i ++) {
                
                VideoShowItem *subView = [rightVideos objectAtIndex:i];
                CGRect rect = CGRectMake(self.videosScrollView.bounds.size.width/2 + i*subView.showVideoView.bounds.size.width, self.videosScrollView.bounds.size.height/2, subView.showVideoView.bounds.size.width, subView.showVideoView.bounds.size.height);
                subView.showVideoView.frame = rect;
                [subView.showVideoView setCenter:CGPointMake(subView.showVideoView.center.x, self.videosScrollView.bounds.size.height-subView.showVideoView.bounds.size.height/2-bottonSpace)];
                [self.videosScrollView addSubview:subView.showVideoView];
            }
        }
    
    }
}

#pragma mark -  UITapGestureRecognizer
- (void)locolvideoSingleTap:(UITapGestureRecognizer*)gesture
{
    if (_peerSelectedId) {
        _peerOldSelectedId = _peerSelectedId;
        _peerSelectedId = nil;
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
                [self layoutSubView];
                return;
            }
        }
    }
}
#pragma mark -  UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (_exitErrorAlertView == alertView) {
//        [self dismissViewControllerAnimated:YES completion:nil];
    }else if (_exitRoomAlertView == alertView){
        if (buttonIndex == 1) {
            [ASHUD showHUDWithStayLoadingStyleInView:self.view belowView:nil content:@"正在退出。。。"];
            [_client CloseAll];
        }
    }
    
}

#pragma mark - AnyrtcM2MDelegate
/** 发布成功
 * @param strPublishId	实时流的ID
 * @param strRtmpUrl	rtmp直播流的地址
 * @param strHlsUrl		hls直播流的地址
 */
- (void) OnRtcPublishOK:(NSString*)strPublishId withRtmpUrl:(NSString*)strRtmpUtl withHlsUrl:(NSString*)strHlsUrl
{
    [ASHUD hideHUD];

    [[TMMessageManage sharedManager] tMNotifyMsgRoomid:roomID withMessage:strPublishId];
}
/** 发布失败
 * @param nCode		失败的代码
 * @param strErr	错误的具体原因
 */
- (void) OnRtcPublishFailed:(int)code withErr:(NSString*)strErr
{
    
}
/** 发布通道关闭
 */
- (void) OnRtcPublishClosed
{
    
}

/** 订阅成功
 * @param strPublishId	订阅的通道ID
 */
- (void) OnRtcSubscribeOK:(NSString*)strPublishId
{
    
}
/** 订阅失败
 * @param strPublishId	订阅的通道ID
 * @param nCode			失败的代码
 * @param strErr		错误的具体原因
 */
- (void) OnRtcSubscribeFailed:(NSString*)strPublishId withCode:(int)code withErr:(NSString*)strErr
{
}
/** 订阅通道关闭
 * @param strPublishId	订阅的通道ID
 */
- (void) OnRtcSubscribeClosed:(NSString*)strPublishId
{
    
}

- (void) OnRtcVideoView:(UIView*)videoView didChangeVideoSize:(CGSize)size {
    
    if (videoView == _localVideoView.showVideoView) {
        _localVideoSize = size;
    }else{
        _videoSize = size;
        for (NSString *strTag in [_dicRemoteVideoView allKeys]) {
           VideoShowItem *remoteView = (VideoShowItem*)[_dicRemoteVideoView objectForKey:strTag];
            if (remoteView.showVideoView == videoView) {
                remoteView.videoSize = size;
                break;
            }
        }
        NSLog(@"OnRtcVideoView:%f %f",_videoSize.width,_videoSize.height);
    }
    [self layoutSubView];
    
}
/*! @brief 远程图像进入p2p会议
 *
 *  @param removeView 远程图像
 *  @param strTag  该通道标识符
 */
- (void) OnRtcInRemoveView:(UIView *)removeView  withTag:(NSString *)strTag {
    
    VideoShowItem* findView = [_dicRemoteVideoView objectForKey:strTag];
    if (findView.showVideoView == removeView) {
        return;
    }
    if (!_peerSelectedId) {
        _peerSelectedId = strTag;
    }
    
    UITapGestureRecognizer *singleTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(singleTap:)];
    [singleTapGestureRecognizer setNumberOfTapsRequired:1];
    singleTapGestureRecognizer.delegate = self;
    [removeView addGestureRecognizer:singleTapGestureRecognizer];
    [self.view addSubview:removeView];
    VideoShowItem *item = [[VideoShowItem alloc] init];
    item.showVideoView = removeView;
    [_dicRemoteVideoView setObject:item forKey:strTag];
  //  [self layoutSubView];
    //While the number of remote image change, send a notification
    NSNumber *remoteVideoCount = [NSNumber numberWithInteger:[_dicRemoteVideoView count]];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"REMOTEVIDEOCHANGE" object:remoteVideoCount];
    
}

/*! @brief 远程图像离开会议
 *
 *  @param removeView 远程图像
 *  @param strTag  该通道标识符
 */
- (void)OnRtcLeaveRemoveView:(UIView *)removeView  withTag:(NSString *)strTag {
    
    VideoShowItem *findView = [_dicRemoteVideoView objectForKey:strTag];
    if (findView) {
        if ([strTag isEqualToString:_peerSelectedId]) {
            [findView.showVideoView removeFromSuperview];
            [_dicRemoteVideoView removeObjectForKey:strTag];
            if (_dicRemoteVideoView.count!=0) {
                _peerSelectedId =[[_dicRemoteVideoView allKeys] firstObject];
            }else{
                _peerSelectedId = nil;
            }
            [self layoutSubView];
        }else{
            [findView.showVideoView removeFromSuperview];
            [_dicRemoteVideoView removeObjectForKey:strTag];
            [self layoutSubView];
        }
    }
    //While the number of remote image change, send a notification
    NSNumber *remoteVideoCount = [NSNumber numberWithInteger:[_dicRemoteVideoView count]];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"REMOTEVIDEOCHANGE" object:remoteVideoCount];
    
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
