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
    BOOL videoEnable;
    
    BOOL isRightTran;
    
}
@property (nonatomic, strong) NSMutableDictionary *_dicRemoteVideoView;
@property (nonatomic, strong) NSMutableArray *_audioOperateArray;
@property (nonatomic, strong) NSMutableArray *_videoOperateArray;
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
@synthesize _userArray,_channelArray,_audioOperateArray,_videoOperateArray;

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
    _videoOperateArray = [[NSMutableArray alloc] initWithCapacity:5];
    _audioOperateArray = [[NSMutableArray alloc] initWithCapacity:5];
    
    _dicRemoteVideoView = [[NSMutableDictionary alloc] initWithCapacity:5];
    [AnyrtcMeet InitAnyRTC:@"mzw0001" andToken:@"defq34hj92mxxjhaxxgjfdqi1s332dd" andAESKey:@"d74TcmQDMB5nWx9zfJ5al7JdEg3XwySwCkhdB9lvnd1" andAppId:@"org.dync.app"];
    _client = [[AnyrtcMeet alloc] init];
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

- (void)videoAudioSet:(NSString *)content action:(NSInteger)action
{
     NSDictionary *dict = [ToolUtils JSONValue:content];
    
    BOOL isvideoFound = NO;
    BOOL isaudioFound = NO;
    if (action==6) {
        
        NSLog(@"%@",[_dicRemoteVideoView allKeys]);
        for (NSString *strTag in [_dicRemoteVideoView allKeys]) {
            VideoShowItem *item = [_dicRemoteVideoView objectForKey:strTag];
            if ([item.publishID isEqualToString:[dict objectForKey:@"PublishId"]]) {
                isaudioFound = YES;
                if ([[dict objectForKey:@"Media"] isEqualToString:@"Close"]) {
                      [item setAudioClose:YES];
                }else{
                     [item setAudioClose:NO];
                }
                break;
            }
        }
        // not found
        if (!isaudioFound) {
            [_audioOperateArray addObject:content];
        }
    }else{
        for (NSString *strTag in [_dicRemoteVideoView allKeys]) {
            VideoShowItem *item = [_dicRemoteVideoView objectForKey:strTag];
            if ([item.publishID isEqualToString:[dict objectForKey:@"PublishId"]]) {
                isvideoFound = YES;
                if ([[dict objectForKey:@"Media"] isEqualToString:@"Close"]) {
                    [item setVideoHidden:YES];
                }else{
                    [item setVideoHidden:NO];
                }
                break;
            }
        }
        if (!isvideoFound) {
            [_videoOperateArray addObject:content];
        }
    }
   
  
}
// setting pre operate to view
- (void)settingMediaToViewOperate:(VideoShowItem*)item
{
    if (_audioOperateArray.count != 0) {
        for (NSString *content in _audioOperateArray) {
            NSDictionary *dict = [ToolUtils JSONValue:content];
            if ([item.publishID isEqualToString:[dict objectForKey:@"PublishId"]]) {
                if ([[dict objectForKey:@"Media"] isEqualToString:@"Close"]) {
                    [item setAudioClose:YES];
                }else{
                    [item setAudioClose:NO];
                }
                [_audioOperateArray removeObject:content];
                break;
            }
        }
    }
    
    if(_videoOperateArray.count != 0) {
        for (NSString *content in _videoOperateArray) {
            NSDictionary *dict = [ToolUtils JSONValue:content];
            if ([item.publishID isEqualToString:[dict objectForKey:@"PublishId"]]) {
                if ([[dict objectForKey:@"Media"] isEqualToString:@"Close"]) {
                    [item setVideoHidden:YES];
                }else{
                    [item setVideoHidden:NO];
                }
                [_videoOperateArray removeObject:content];
                break;
            }
        }
    }
}

-(BOOL)receiveMessageEnable {
    
    return YES;
}

// ios iphone notification
- (void)chatViewNoti:(NSNotification*)noti
{
    BOOL isChat = [noti.object boolValue];
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
            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:_localVideoView.publishID,@"PublishId",@"Open",@"Media", nil];
            [[TMMessageManage sharedManager] tMNotifyMsgRoomid:self.roomItem.roomID withTags:MCSendTagsVIDEOSET withMessage:[ToolUtils JSONTOString:dict]];
        }else{
            [_localVideoView setVideoHidden:YES];
            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:_localVideoView.publishID,@"PublishId",@"Close",@"Media", nil];
            [[TMMessageManage sharedManager] tMNotifyMsgRoomid:self.roomItem.roomID withTags:MCSendTagsVIDEOSET withMessage:[ToolUtils JSONTOString:dict]];
        }
    }
}
- (void)audioEnable:(BOOL)enable
{
    if (_client) {
        [_client setLocalAudioEnable:enable];
        if (enable) {
            [_localVideoView setAudioClose:NO];
            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:_localVideoView.publishID,@"PublishId",@"Open",@"Media", nil];
            [[TMMessageManage sharedManager] tMNotifyMsgRoomid:self.roomItem.roomID withTags:MCSendTagsAUDIOSET withMessage:[ToolUtils JSONTOString:dict]];

        }else{
             [_localVideoView setAudioClose:YES];
            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:_localVideoView.publishID,@"PublishId",@"Close",@"Media", nil];
            [[TMMessageManage sharedManager] tMNotifyMsgRoomid:self.roomItem.roomID withTags:MCSendTagsAUDIOSET withMessage:[ToolUtils JSONTOString:dict]];
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
                self.videosScrollView.frame = CGRectMake(0, self.view.bounds.size.height - 100 - VideoParViewHeight, self.view.bounds.size.width, VideoParViewHeight);
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
            return;
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
        
        BOOL localHasSize = NO;
        float sizeViewAllWidth = 0;
        if (_localVideoSize.width>0 && _localVideoSize.height>0) {
            if ([_localVideoView.showVideoView.superview isKindOfClass:[self.view class]]) {
                [_localVideoView.showVideoView removeFromSuperview];
            }
            localHasSize = YES;
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
        if (localHasSize) {
            localViewWidth = (_localVideoSize.width/_localVideoSize.height)*videoViewHeight;
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
            }
            viewsmail.showVideoView.frame = CGRectMake(0,0, videowidth, height);
            width += videowidth;
        }
    }
    float localWidth = 0.0;
    if (hasLocal) {
        if (_localVideoSize.width>0 && _localVideoSize.height>0) {
            localWidth = (_localVideoSize.width/_localVideoSize.height)*height;
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
         _client.selectedTag = nil;
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
                _client.selectedTag = key;
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
/** 发布成功
 * @param strPublishId	实时流的ID
 * @param strRtmpUrl	rtmp直播流的地址
 * @param strHlsUrl		hls直播流的地址
 */
- (void) OnRtcPublishOK:(NSString*)strPublishId withRtmpUrl:(NSString*)strRtmpUtl withHlsUrl:(NSString*)strHlsUrl
{
    [ASHUD hideHUD];
    _localVideoView.publishID = strPublishId;
    [[TMMessageManage sharedManager] tMNotifyMsgRoomid:self.roomItem.roomID withTags:MCSendTagsSUBSCRIBE withMessage:strPublishId];
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
- (void) OnRtcInRemoveView:(UIView *)removeView  withChannelID:(NSString *)peerChannelID withPublishID:(NSString *)publishID{
   
    VideoShowItem* findView = [_dicRemoteVideoView objectForKey:peerChannelID];
    if (findView.showVideoView == removeView) {
        return;
    }
    if (!_peerSelectedId&&_dicRemoteVideoView.count==0) {
        _peerSelectedId = peerChannelID;
        _client.selectedTag = peerChannelID;
    }
    
    VideoShowItem *item = [[VideoShowItem alloc] init];
    item.selectedTag = peerChannelID;
    item.showVideoView = removeView;
    item.publishID = publishID;
    
    [_dicRemoteVideoView setObject:item forKey:peerChannelID];
    
    UITapGestureRecognizer *singleTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(singleTap:)];
    [singleTapGestureRecognizer setNumberOfTapsRequired:1];
    singleTapGestureRecognizer.delegate = self;
    [item.showVideoView  addGestureRecognizer:singleTapGestureRecognizer];

    
//    [self layoutSubView];
    //While the number of remote image change, send a notification
    NSNumber *remoteVideoCount = [NSNumber numberWithInteger:[_dicRemoteVideoView count]];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"REMOTEVIDEOCHANGE" object:remoteVideoCount];

   
    
}

/*! @brief 远程图像离开会议
 *
 *  @param removeView 远程图像
 *  @param peerChannelID  该通道标识符
 */
- (void)OnRtcLeaveRemoveView:(UIView *)removeView  withChannelID:(NSString *)peerChannelID{
    
    VideoShowItem *findView = [_dicRemoteVideoView objectForKey:peerChannelID];
    if (findView) {
        if ([peerChannelID isEqualToString:_peerSelectedId]) {
            [findView.showVideoView removeFromSuperview];
            [_dicRemoteVideoView removeObjectForKey:peerChannelID];
            if (_dicRemoteVideoView.count!=0) {
                _peerSelectedId =[[_dicRemoteVideoView allKeys] firstObject];
                _client.selectedTag = _peerSelectedId;
            }else{
                _peerSelectedId = nil;
                _client.selectedTag = nil;
            }
        }else{
            [findView.showVideoView removeFromSuperview];
            [_dicRemoteVideoView removeObjectForKey:peerChannelID];
           
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
