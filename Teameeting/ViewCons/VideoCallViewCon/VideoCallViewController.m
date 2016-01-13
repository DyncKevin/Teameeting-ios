//
//  VideoCallViewController.m
//  Room
//
//  Created by yangyang on 15/11/17.
//  Copyright © 2015年 yangyangwang. All rights reserved.
//

#import "VideoCallViewController.h"
#import "RootViewController.h"
#import "LockerView.h"
#import "DXPopover.h"
#import "AppDelegate.h"
#import "UILabel+Category.h"
#import <MessageUI/MFMessageComposeViewController.h>
#import "ReceiveCallViewController.h"
#import <GLKit/GLKit.h>
#import "TalkView.h"
#import "WXApiRequestHandler.h"
#import "TMMessageManage.h"
@implementation UINavigationController (Orientations)


- (NSUInteger)supportedInterfaceOrientations {
    
    return [self.topViewController supportedInterfaceOrientations];
}

- (BOOL)shouldAutorotate {
    
    return YES;
}

@end

typedef enum ViewState {
    
    UNKNOWN,
    CHATSTATE,
    VIDEOSTATE
    
} ViewState;

@interface VideoCallViewController ()<UINavigationControllerDelegate,LockerDelegate,MFMessageComposeViewControllerDelegate,UIGestureRecognizerDelegate>


@property(nonatomic,strong)UIControl *barView;
@property(nonatomic,strong)UIControl *chatBarView;
@property(nonatomic,strong)LockerView *menuView;
@property(nonatomic,strong)RootViewController *rootView;
@property(nonatomic,assign)ViewState state;
@property(nonatomic,strong)UIImageView *micStateImage;
@property(nonatomic,strong)UIImageView *videoGroudImage;
@property(nonatomic,strong)DXPopover *popver;
@property(nonatomic,strong)ReceiveCallViewController *callViewCon;
@property(nonatomic,strong)UIView *lineView;
@property(nonatomic,strong)UIView *shareViewGround;
@property(nonatomic,strong)TalkView *talkView;
@property(nonatomic,strong)UILabel *noUserTip;
@property(nonatomic,assign)BOOL isViewLoad;
@property(nonatomic,assign)BOOL isFullScreen;


- (void)didRotateAdjustUI;
- (void)willRotateAdjustUI;
- (void)sendMessage;
- (void)loadTableView;
@end

@implementation VideoCallViewController

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:nil];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    if (self.isViewLoad)
        return;
    self.isViewLoad = YES;
    self.isFullScreen = NO;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    self.view.backgroundColor = [UIColor blackColor];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(openVideo) name:OPENVIDEO object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(remoteVideoChange:) name:@"REMOTEVIDEOCHANGE" object:nil];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    self.state = VIDEOSTATE;
    [self initBar];
    self.callViewCon = [[ReceiveCallViewController alloc] init];
    self.callViewCon.roomID = self.roomItem.roomID;
    self.callViewCon.view.frame = self.view.bounds;
    self.talkView = [[TalkView alloc] initWithFrame:self.view.bounds];
    self.talkView.userInteractionEnabled = NO;
    self.menuView = [[LockerView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height - 90, 300, 60)];
    [self.menuView setCenter:CGPointMake(self.view.bounds.size.width/2, self.menuView.center.y)];
    self.menuView.delegate = self;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapEvent)];
    tapGesture.delegate = self;
    [self.view addGestureRecognizer:tapGesture];
    if (ISIPAD) {
        
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panEvent:)];
        panGesture.delegate = self;
        [self.view addGestureRecognizer:panGesture];
        
    }
    self.micStateImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"micState"]];
    self.micStateImage.frame = CGRectMake(self.view.bounds.size.width - 40, 66, 40, 40);
    self.micStateImage.hidden = YES;
    self.micStateImage.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    
    self.videoGroudImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"videoBackgroud"]];
    self.videoGroudImage.userInteractionEnabled = NO;
    self.videoGroudImage.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.videoGroudImage.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
    self.videoGroudImage.alpha = 0;
    self.videoGroudImage.hidden = YES;
    
    self.lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 66, self.view.bounds.size.width, 0.3)];
    self.lineView.hidden = YES;
    [[self.lineView layer] setCornerRadius:1];
    [[self.lineView layer] setBorderWidth:0.3];
    [[self.lineView layer] setBorderColor:[UIColor colorWithWhite:0.7 alpha:1].CGColor];
    [self.view addSubview:self.lineView];
    UIView *touchEvent = [[UIView alloc] initWithFrame:self.view.bounds];
    touchEvent.userInteractionEnabled = YES;
    touchEvent.tag = 500;
    touchEvent.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    touchEvent.backgroundColor = [UIColor clearColor];
    [self.view addSubview:touchEvent];
    [self.view addSubview:self.callViewCon.view];
    
    self.noUserTip = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width - 80, 80)];
    [self.noUserTip setUserInteractionEnabled:NO];
    [self.noUserTip setTextColor:[UIColor whiteColor]];
    [self.noUserTip setNumberOfLines:0];
    [self.noUserTip setTextAlignment:NSTextAlignmentCenter];
    self.noUserTip.text = @"Waiting for others to join the room";
    [self.noUserTip setCenter:CGPointMake(self.view.bounds.size.width/2, CGRectGetMidY(self.menuView.frame) - 80)];
    [self.view addSubview:self.noUserTip];
    [self.view addSubview:self.micStateImage];
    [self performSelector:@selector(loadTableView) withObject:nil afterDelay:0.1];
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [[TMMessageManage sharedManager] tmRoomCmd:MCMeetCmdENTER Userid:nil pass:nil roomid:self.roomItem.roomID remain:@""];
}

- (void)loadTableView {

    BOOL isVertical = [self isVertical];
    CGFloat rootViewWidth = isVertical == YES ? (self.view.bounds.size.width/2 - 50) : (self.view.bounds.size.width/2 - 100);
    self.rootView = [[RootViewController alloc] init];
    self.rootView.parentViewCon = self;
    self.rootView.view.autoresizingMask = UIViewAutoresizingNone;
    self.rootView.view.backgroundColor = [UIColor greenColor];
    if (ISIPAD) {
        
        self.rootView.view.frame = CGRectMake(0 - rootViewWidth, 0, rootViewWidth, self.view.bounds.size.height);
        
    } else {
        
        self.rootView.view.hidden = YES;
        self.rootView.view.alpha = 0;
        self.rootView.view.frame = self.view.bounds;
    }
    [self.view addSubview:self.videoGroudImage];
    [self.view addSubview:self.rootView.view];
    [self.view addSubview:self.menuView];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    
    return YES;
}

- (void)messageTest
{
    [self.talkView sendMessageView:@"abcdefgabcdefgabcdefgabcdefgabcdefgabcdefgabcdefg" withUser:@"abc"];
}

- (void)remoteVideoChange:(NSNotification *)noti {
    
    NSNumber *object = [noti object];
    NSInteger remoteCount = [object integerValue];
    if (remoteCount > 0) {
        
        [self.noUserTip setHidden:YES];
        
    } else {
        
        [self.noUserTip setHidden:NO];
    }
}

- (void)openVideo {
    
    [self.callViewCon videoEnable:YES];
}


- (void)panEvent:(UIPanGestureRecognizer *)gesture {
    
    BOOL isVertical = YES;
    NSUInteger width = self.view.bounds.size.width;
    NSUInteger height = self.view.bounds.size.height;
    isVertical = width > height ? NO : YES;
    CGPoint startPoint;
    CGPoint endPoint;
    if (gesture.state == UIGestureRecognizerStateBegan) {
        
        startPoint = [gesture translationInView:self.view];

        
    } else if (gesture.state == UIGestureRecognizerStateChanged) {
        
        endPoint = [gesture translationInView:self.view];
        [self.rootView.view setFrame:CGRectMake(self.rootView.view.frame.origin.x + endPoint.x, self.rootView.view.frame.origin.y, self.rootView.view.bounds.size.width, self.rootView.view.bounds.size.height)];
        
        [self.menuView setFrame:CGRectMake(self.menuView.frame.origin.x + endPoint.x, self.menuView.frame.origin.y, self.menuView.frame.size.width, self.menuView.frame.size.height)];
        
        [self.noUserTip setFrame:CGRectMake(self.noUserTip.frame.origin.x + endPoint.x, self.noUserTip.frame.origin.y, self.noUserTip.frame.size.width, self.noUserTip.frame.size.height)];
        [gesture setTranslation:CGPointMake(0, 0) inView:self.view];
        
    } else if (gesture.state == UIGestureRecognizerStateEnded) {
        
        CGFloat rootViewWidth = isVertical == YES ? (self.view.bounds.size.width/2 - 50) : (self.view.bounds.size.width/2 - 100);
        if (fabsf(self.rootView.view.frame.origin.x) <= rootViewWidth/2 || self.rootView.view.frame.origin.x > 0) {
            
            [UIView animateWithDuration:0.2 animations:^{
                
                [self.rootView.view setFrame:CGRectMake(0,self.rootView.view.frame.origin.y, self.rootView.view.bounds.size.width, self.rootView.view.bounds.size.height)];
                [self.menuView setCenter:CGPointMake(self.view.bounds.size.width/2 + self.view.bounds.size.width/4, self.menuView.center.y)];
                [self.noUserTip setCenter:CGPointMake(self.view.bounds.size.width/2 + self.view.bounds.size.width/4, self.noUserTip.center.y)];
            }];
            
            
        } else {
            
            [UIView animateWithDuration:0.2 animations:^{
                
                [self.rootView.view setFrame:CGRectMake(0 - rootViewWidth,self.rootView.view.frame.origin.y, self.rootView.view.bounds.size.width, self.rootView.view.bounds.size.height)];
                [self.menuView setCenter:CGPointMake(self.view.bounds.size.width/2, self.menuView.center.y)];
                [self.noUserTip setCenter:CGPointMake(self.view.bounds.size.width/2, self.noUserTip.center.y)];
            }];
            [self.rootView resginKeyBord];
        }
    }
    
}

- (void)tapEvent {
    
    if (self.popver) {
        
        [self.popver dismiss];
        self.popver = nil;
        [self.shareViewGround performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:0.2];
    }
    if (!ISIPAD) {
        
        self.isFullScreen = !self.isFullScreen;
        [UIView animateWithDuration:0.2 animations:^{
            
            if (self.barView) {
                
                [self.barView setFrame:CGRectMake(0, self.isFullScreen == YES ? (0 - self.barView.bounds.size.height -20) : -20 , self.barView.bounds.size.width, self.barView.bounds.size.height)];
                
            }
            [self.menuView setCenter:CGPointMake(self.menuView.center.x, self.isFullScreen == YES ? (self.view.bounds.size.height + self.menuView.bounds.size.height) : (self.view.bounds.size.height - self.menuView.bounds.size.height))];
            [self.noUserTip setCenter:CGPointMake(self.view.bounds.size.width/2, self.isFullScreen == YES ? (self.view.bounds.size.height + self.noUserTip.bounds.size.height) : (CGRectGetMinY(self.menuView.frame) - self.noUserTip.bounds.size.height/2))];
            
        }];
    }
    
}

- (void)initBar {
    
    [self.chatBarView removeFromSuperview];
    self.chatBarView = nil;
    [self.barView removeFromSuperview];
    BOOL isVertical = YES;
    NSUInteger width = self.view.bounds.size.width;
    NSUInteger height = self.view.bounds.size.height;
    isVertical = width > height ? NO : YES;
    if (isVertical) {

        [[UIApplication sharedApplication] setStatusBarHidden:NO];
        self.navigationController.delegate = self;
        self.barView = [[UIControl alloc] initWithFrame:CGRectMake(0, -20, self.view.bounds.size.width, 66)];
        [self.barView addTarget:self action:@selector(topBarTouchEvent) forControlEvents:UIControlEventTouchUpInside];
        self.barView.backgroundColor = [UIColor colorWithRed:24.f/255.f green:24.f/255.f blue:24.f/255.f alpha:0.7];
        self.barView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        UIButton *chatButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [chatButton setImage:[UIImage imageNamed:@"chat"] forState:UIControlStateNormal];
        [chatButton addTarget:self action:@selector(goToChat:) forControlEvents:UIControlEventTouchUpInside];
        [chatButton setBackgroundColor:[UIColor clearColor]];
        chatButton.frame = CGRectMake(10, 0, 49, 40);
        [chatButton setCenter:CGPointMake(chatButton.center.x, self.barView.bounds.size.height/2 + 10)];
        UIButton *shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [shareButton setImage:[UIImage imageNamed:@"share"] forState:UIControlStateNormal];
        [shareButton addTarget:self action:@selector(shareView) forControlEvents:UIControlEventTouchUpInside];
        shareButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        shareButton.frame = CGRectMake(self.view.bounds.size.width - 50, 0, 50, 50);
        shareButton.center = CGPointMake(shareButton.center.x, self.barView.bounds.size.height/2 + 10);
        
        UILabel *naiTitle = [[UILabel alloc] init];
        naiTitle.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        [naiTitle setTextColor:[UIColor whiteColor]];
        naiTitle.text = self.roomItem.roomName;
        [naiTitle setFont:[UIFont boldSystemFontOfSize:18]];
        [naiTitle setTextAlignment:NSTextAlignmentCenter];
        [naiTitle setLineBreakMode:NSLineBreakByWordWrapping];
        CGSize labelsize = [naiTitle boundingRectWithSize:CGSizeMake(100, 40)];
        [naiTitle setFrame:CGRectMake(0, 30, labelsize.width, labelsize.height)];
        [naiTitle setBackgroundColor:[UIColor clearColor]];
        naiTitle.center = CGPointMake(self.barView.bounds.size.width/2, self.barView.bounds.size.height/2 + 10);
        
        [self.barView addSubview:naiTitle];
        [self.barView addSubview:shareButton];
        [self.barView addSubview:chatButton];
        
    } else {
        
        if (!ISIPAD) {
    
            [[UIApplication sharedApplication] setStatusBarHidden:YES];
        }
        self.navigationController.delegate = self;
        self.barView = [[UIControl alloc] initWithFrame:CGRectMake(0, -20, self.view.bounds.size.width, ISIPAD == YES ? (66) : 50)];
        [self.barView addTarget:self action:@selector(topBarTouchEvent) forControlEvents:UIControlEventTouchUpInside];
        self.barView.backgroundColor = [UIColor colorWithRed:24.f/255.f green:24.f/255.f blue:24.f/255.f alpha:0.7];
        self.barView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        UIButton *chatButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [chatButton setImage:[UIImage imageNamed:@"chat"] forState:UIControlStateNormal];
        [chatButton addTarget:self action:@selector(goToChat:) forControlEvents:UIControlEventTouchUpInside];
        [chatButton setBackgroundColor:[UIColor clearColor]];
        chatButton.frame = CGRectMake(10, 0, 49, 40);
        [chatButton setCenter:CGPointMake(chatButton.center.x, self.barView.bounds.size.height/2 + 10)];
        UIButton *shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [shareButton setImage:[UIImage imageNamed:@"share"] forState:UIControlStateNormal];
        [shareButton addTarget:self action:@selector(shareView) forControlEvents:UIControlEventTouchUpInside];
        shareButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        shareButton.frame = CGRectMake(self.view.bounds.size.width - 50, 0, 50, 50);
        shareButton.center = CGPointMake(shareButton.center.x, self.barView.bounds.size.height/2 + 10);
        
        UILabel *naiTitle = [[UILabel alloc] init];
        naiTitle.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        [naiTitle setTextColor:[UIColor whiteColor]];
        naiTitle.text = self.roomItem.roomName;
        [naiTitle setFont:[UIFont boldSystemFontOfSize:18]];
        [naiTitle setTextAlignment:NSTextAlignmentCenter];
        [naiTitle setLineBreakMode:NSLineBreakByWordWrapping];
        CGSize labelsize = [naiTitle boundingRectWithSize:CGSizeMake(100, 40)];
        [naiTitle setFrame:CGRectMake(0, 30, labelsize.width, labelsize.height)];
        [naiTitle setBackgroundColor:[UIColor clearColor]];
        naiTitle.center = CGPointMake(self.barView.bounds.size.width/2, self.barView.bounds.size.height/2 + 10);
        
        [self.barView addSubview:naiTitle];
        [self.barView addSubview:shareButton];
        [self.barView addSubview:chatButton];
    }
    [self.navigationController.navigationBar addSubview:self.barView];
    [self.barView setFrame:CGRectMake(0, self.isFullScreen == YES ? (0 - self.barView.bounds.size.height -20) : -20 , self.barView.bounds.size.width, self.barView.bounds.size.height)];
}

- (void)initChatBar {
    
    [self.barView removeFromSuperview];
    self.barView = nil;
    [self.chatBarView removeFromSuperview];
    BOOL isVertical = YES;
    NSUInteger width = self.view.bounds.size.width;
    NSUInteger height = self.view.bounds.size.height;
    isVertical = width > height ? NO : YES;
    if (isVertical) {

        self.lineView.frame = CGRectMake(0, 66, self.view.bounds.size.width, 0.3);
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
        self.chatBarView = [[UIControl alloc] initWithFrame:CGRectMake(0, -20, self.view.bounds.size.width, 66)];
        [self.chatBarView addTarget:self action:@selector(topBarTouchEvent) forControlEvents:UIControlEventTouchUpInside];
        self.chatBarView.backgroundColor = [UIColor colorWithRed:24.f/255.f green:24.f/255.f blue:24.f/255.f alpha:0.8];
        self.chatBarView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [closeButton setImage:[UIImage imageNamed:@"cancelChat"] forState:UIControlStateNormal];
        [closeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [closeButton addTarget:self action:@selector(closeChatView) forControlEvents:UIControlEventTouchUpInside];
        [closeButton setBackgroundColor:[UIColor clearColor]];
        closeButton.frame = CGRectMake(15, 30, 25, 25);
        closeButton.center = CGPointMake(closeButton.center.x, closeButton.center.y);
        
        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0,30, 60, 20)];
        title.center = CGPointMake(self.chatBarView.bounds.size.width/2, title.center.y);
        [title setFont:[UIFont boldSystemFontOfSize:18]];
        title.text = @"Chat";
        title.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        [title setBackgroundColor:[UIColor clearColor]];
        title.textColor = [UIColor whiteColor];
        title.textAlignment = NSTextAlignmentCenter;
        [self.chatBarView addSubview:title];
        [self.chatBarView addSubview:closeButton];
        
    } else {
        
        self.lineView.frame = CGRectMake(0, 30, self.view.bounds.size.width, 0.3);
        [[UIApplication sharedApplication] setStatusBarHidden:YES];
        self.chatBarView = [[UIControl alloc] initWithFrame:CGRectMake(0, -20, self.view.bounds.size.width, 50)];
        [self.chatBarView addTarget:self action:@selector(topBarTouchEvent) forControlEvents:UIControlEventTouchUpInside];
        self.chatBarView.backgroundColor = [UIColor colorWithRed:24.f/255.f green:24.f/255.f blue:24.f/255.f alpha:0.8];
        self.chatBarView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [closeButton setImage:[UIImage imageNamed:@"cancelChat"] forState:UIControlStateNormal];
        [closeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [closeButton addTarget:self action:@selector(closeChatView) forControlEvents:UIControlEventTouchUpInside];
        [closeButton setBackgroundColor:[UIColor clearColor]];
        closeButton.frame = CGRectMake(15, 0, 25, 25);
        closeButton.center = CGPointMake(closeButton.center.x, self.chatBarView.bounds.size.height/2 + 10);
        
        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0,30, 60, 20)];
        title.center = CGPointMake(self.chatBarView.bounds.size.width/2, self.chatBarView.bounds.size.height/2 + 10);
        [title setFont:[UIFont boldSystemFontOfSize:18]];
        title.text = @"Chat";
        title.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        [title setBackgroundColor:[UIColor clearColor]];
        title.textColor = [UIColor whiteColor];
        title.textAlignment = NSTextAlignmentCenter;
        [self.chatBarView addSubview:title];
        [self.chatBarView addSubview:closeButton];
    }
    [self.navigationController.navigationBar addSubview:self.chatBarView];
}

- (void)topBarTouchEvent {
    
    if (self.popver) {
        
        [self.popver dismiss];
        [self.shareViewGround performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:0.2];
        self.popver = nil;
    }
}

- (void)shareView {
    
    BOOL isVertical = YES;
    NSUInteger width = self.view.bounds.size.width;
    NSUInteger height = self.view.bounds.size.height;
    isVertical = width > height ? NO : YES;
    
    UIView *shareView = [[UIView alloc] init];
    shareView.backgroundColor = [UIColor colorWithRed:205.f/255.f green:205.f/255.f blue:203.f/255.f alpha:1];
    if (ISIPAD) {
        
        if (isVertical) {
            
            shareView.frame = CGRectMake(0, 0, 300, 400);
        } else {
            
            shareView.frame = CGRectMake(0, 0, 400, 300);
        }
    
    } else {
        
        if (!isVertical) {
            
            shareView.frame = CGRectMake(0, 0, self.view.bounds.size.width - 30, self.view.bounds.size.height - 66);
            
        } else {
            
            shareView.frame = CGRectMake(0, 0, self.view.bounds.size.width - 30, 400);
        }
        
    }
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 8;
    NSDictionary *attributes = @{
                                 NSFontAttributeName:[UIFont systemFontOfSize:19],
                                 NSParagraphStyleAttributeName:paragraphStyle
                                 };
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, shareView.bounds.size.width-40, 60)];
    title.attributedText = [[NSAttributedString alloc] initWithString:@"How do you want to invite people to the room?" attributes:attributes];
    title.autoresizingMask = UIViewContentModeBottom;
    [title setTextAlignment:NSTextAlignmentCenter];
    [title setTextColor:[UIColor blackColor]];
    [title setNumberOfLines:0];
    [shareView addSubview:title];
    
    UIButton *messageImage = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
    [messageImage addTarget:self action:@selector(sendMessage) forControlEvents:UIControlEventTouchUpInside];
    [messageImage setBackgroundImage:[UIImage imageNamed:@"messageInvite"] forState:UIControlStateNormal];
    messageImage.backgroundColor = [UIColor clearColor];
    [shareView addSubview:messageImage];
    
    UIButton *mailImage = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
    [mailImage setBackgroundImage:[UIImage imageNamed:@"mailInvite"] forState:UIControlStateNormal];
    [mailImage addTarget:self action:@selector(weChatShare) forControlEvents:UIControlEventTouchUpInside];
    mailImage.backgroundColor = [UIColor clearColor];
    [shareView addSubview:mailImage];
    
    
    UIImageView *bottomBar = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"sharebackgroud"]];
    bottomBar.autoresizingMask = UIViewContentModeBottom;
    bottomBar.backgroundColor = [UIColor redColor];
    [shareView addSubview:bottomBar];
    
    UILabel *messageTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
    [messageTitle setFont:[UIFont systemFontOfSize:12]];
    messageTitle.text = @"Message";
    [messageTitle setTextColor:[UIColor blackColor]];
    [messageTitle setTextAlignment:NSTextAlignmentCenter];
    
    UILabel *mailTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
    [mailTitle setFont:[UIFont systemFontOfSize:12]];
    mailTitle.text = @"Mail";
    [mailTitle setTextColor:[UIColor blackColor]];
    [mailTitle setTextAlignment:NSTextAlignmentCenter];
    [shareView addSubview:messageTitle];
    [shareView addSubview:mailTitle];
    
    
    UILabel *descriptionTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, shareView.bounds.size.width - 40, 80)];
    
    descriptionTitle.attributedText = [[NSAttributedString alloc] initWithString:@"You can also copy adn paste the secure room link to invite others" attributes:attributes];
    [descriptionTitle setFont:[UIFont systemFontOfSize:17]];
    [descriptionTitle setNumberOfLines:0];
    [descriptionTitle setTextColor:[UIColor grayColor]];
    [descriptionTitle setTextAlignment:NSTextAlignmentCenter];
    [descriptionTitle setBackgroundColor:[UIColor clearColor]];
    [shareView addSubview:descriptionTitle];
    
    UILabel *linkTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, shareView.bounds.size.width - (isVertical ? 60 : 120), 56)];
    if (ISIPAD) {
        
        [linkTitle setFrame:CGRectMake(0, 0, shareView.bounds.size.width - (isVertical ? 60 : 80), 56)];
        
    } else {
        
        [linkTitle setFrame:CGRectMake(0, 0, shareView.bounds.size.width - (isVertical ? 60 : 120), 56)];
    }
    
    [linkTitle setFont:[UIFont systemFontOfSize:12]];
    linkTitle.text = [NSString stringWithFormat:@"http://192.168.7.62/demo/rtpmp/rtpmp.html#%@",self.roomItem.roomID];
    [linkTitle setTextColor:[UIColor grayColor]];
    [linkTitle setBackgroundColor:[UIColor clearColor]];
    [linkTitle setTextAlignment:NSTextAlignmentCenter];
    [shareView addSubview:linkTitle];
    
    UIButton *copyLink = [[UIButton alloc] init];
    [copyLink setTitle:@"Copy" forState:UIControlStateNormal];
    [copyLink setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [copyLink setBackgroundColor:[UIColor clearColor]];
    [shareView addSubview:copyLink];
    
    if (!isVertical) {
        
        [title setCenter:CGPointMake(shareView.bounds.size.width/2, 40)];
        messageImage.center = CGPointMake(shareView.bounds.size.width/2 - 40, CGRectGetMaxY(title.frame) + 30);
        mailImage.center = CGPointMake(shareView.bounds.size.width/2 + 40, CGRectGetMaxY(title.frame) + 30);
        bottomBar.frame = CGRectMake(0, shareView.bounds.size.height - 36, shareView.bounds.size.width +1, 36);
        [messageTitle setCenter:CGPointMake(messageImage.center.x, CGRectGetMaxY(messageImage.frame) + 15)];
        [mailTitle setCenter:CGPointMake(mailImage.center.x, CGRectGetMaxY(mailImage.frame) + 15)];
        [descriptionTitle setCenter:CGPointMake(shareView.bounds.size.width/2, CGRectGetMaxY(mailTitle.frame) + 25)];
        [linkTitle setCenter:CGPointMake(linkTitle.center.x, shareView.bounds.size.height - 20)];
        [copyLink setFrame:CGRectMake(CGRectGetMaxX(linkTitle.frame), 0, shareView.bounds.size.width - CGRectGetMaxX(linkTitle.frame), 45)];
        [copyLink setCenter:CGPointMake(copyLink.center.x, shareView.bounds.size.height - 20)];
        
    }  else {
        
        [title setCenter:CGPointMake(shareView.bounds.size.width/2, 60)];
        messageImage.center = CGPointMake(shareView.bounds.size.width/2 - 40, CGRectGetMaxY(title.frame) + 50);
        mailImage.center = CGPointMake(shareView.bounds.size.width/2 + 40, CGRectGetMaxY(title.frame) + 50);
        bottomBar.frame = CGRectMake(0, shareView.bounds.size.height - 56, shareView.bounds.size.width +1, 56);
        [messageTitle setCenter:CGPointMake(messageImage.center.x, CGRectGetMaxY(messageImage.frame) + 15)];
        [mailTitle setCenter:CGPointMake(mailImage.center.x, CGRectGetMaxY(mailImage.frame) + 15)];
        [descriptionTitle setCenter:CGPointMake(shareView.bounds.size.width/2, CGRectGetMaxY(mailTitle.frame) + 35)];
        [linkTitle setCenter:CGPointMake(linkTitle.center.x, shareView.bounds.size.height - 30)];
        [copyLink setFrame:CGRectMake(CGRectGetMaxX(linkTitle.frame), 0, shareView.bounds.size.width - CGRectGetMaxX(linkTitle.frame), 56)];
        [copyLink setCenter:CGPointMake(copyLink.center.x, shareView.bounds.size.height - 30)];
        
    }
    if (self.popver) {
        
        [self.popver dismiss];
        self.popver = nil;
    }
    self.popver = [DXPopover popover];
    self.popver.sideEdge = 15;
    self.popver.arrowSize = CGSizeMake(15, 15);
    if (_shareViewGround) {
        
        [_shareViewGround removeFromSuperview];
    }
    _shareViewGround = [[UIView alloc] initWithFrame:self.view.bounds];
    _shareViewGround.userInteractionEnabled = YES;
    _shareViewGround.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_shareViewGround];
    
    if (ISIPAD) {
        
        if (!isVertical) {
            
            [self.popver showAtPoint:CGPointMake(self.view.bounds.size.width - 25, 65) popoverPostion:DXPopoverPositionDown withContentView:shareView inView:_shareViewGround];
            
        } else {
            
            [self.popver showAtPoint:CGPointMake(self.view.bounds.size.width - 25, 65) popoverPostion:DXPopoverPositionDown withContentView:shareView inView:_shareViewGround];
            
        }
        
    } else {
        
        if (!isVertical) {
            
            [self.popver showAtPoint:CGPointMake(self.view.bounds.size.width - 25, 32) popoverPostion:DXPopoverPositionDown withContentView:shareView inView:_shareViewGround];
            
        } else {
            
            [self.popver showAtPoint:CGPointMake(self.view.bounds.size.width - 25, 65) popoverPostion:DXPopoverPositionDown withContentView:shareView inView:_shareViewGround];
            
        }
    }
}

- (void)weChatShare {
    
    
    [WXApiRequestHandler sendLinkURL:[NSString stringWithFormat:@"http://115.28.70.232/share_meetingRoom#%@",self.roomItem.roomID]
                             TagName:nil
                               Title:@"Teameeting"
                         Description:@"视频邀请"
                          ThumbImage:nil
                             InScene:WXSceneSession];
}

- (void)closeChatView {
    
    [[[[UIApplication sharedApplication] delegate] window] setUserInteractionEnabled:NO];
    [UIView animateWithDuration:0.2 animations:^{
        
        [self initBar];
        [self.menuView setAlpha:1];
        [self.rootView.view setAlpha:0];
        [self.videoGroudImage setAlpha:0];
        
    } completion:^(BOOL finished) {
        
        [[[[UIApplication sharedApplication] delegate] window] setUserInteractionEnabled:YES];
        [self.rootView.view setHidden:YES];
        [self.videoGroudImage setHidden:YES];
        
    }];
    [self.rootView setReceiveMessageEnable:NO];

}

- (void)goToChat:(UIButton *)button {
    
    if (ISIPAD) {
        
        [UIView animateWithDuration:0.2 animations:^{
            
            if (self.rootView.view.frame.origin.x < 0) {
                
                [self.rootView.view setFrame:CGRectMake(0,self.rootView.view.frame.origin.y, self.rootView.view.bounds.size.width, self.rootView.view.bounds.size.height)];
                [self.menuView setCenter:CGPointMake(self.view.bounds.size.width/2 + self.view.bounds.size.width/4, self.menuView.center.y)];
                [self.noUserTip setCenter:CGPointMake(self.view.bounds.size.width/2 + self.view.bounds.size.width/4, self.noUserTip.center.y)];
                [self.rootView setReceiveMessageEnable:YES];
                
            } else {
                
                [self.rootView.view setFrame:CGRectMake(0 - self.rootView.view.bounds.size.width,self.rootView.view.frame.origin.y, self.rootView.view.bounds.size.width, self.rootView.view.bounds.size.height)];
                [self.menuView setCenter:CGPointMake(self.view.bounds.size.width/2, self.menuView.center.y)];
                [self.noUserTip setCenter:CGPointMake(self.view.bounds.size.width/2, self.noUserTip.center.y)];
                [self.rootView setReceiveMessageEnable:NO];
            }
            
        }];
        
    } else {
        
        if (self.rootView.view.hidden) {
            
            [self.rootView.view setHidden:NO];
            [self.videoGroudImage setHidden:NO];
            
            [UIView animateWithDuration:0.2 animations:^{
                
                [self initChatBar];
                [self.menuView setAlpha:0];
                [self.rootView.view setAlpha:1];
                [self.videoGroudImage setAlpha:1];
            }];
            [self.rootView setReceiveMessageEnable:YES];
            
        } else {
        
            [UIView animateWithDuration:0.2 animations:^{
                
                [self initBar];
                [self.menuView setAlpha:1];
                [self.rootView.view setAlpha:0];
                [self.videoGroudImage setAlpha:0];
                
            } completion:^(BOOL finished) {
                
                [self.rootView.view setHidden:YES];
                [self.videoGroudImage setHidden:YES];
                
            }];
            [self.rootView setReceiveMessageEnable:NO];
            
        }
    }
}


- (void)menuClick:(LockerButton *)item {
    
    if (item.tag == 10) {
        
        if (self.callViewCon) {
            [self.callViewCon hangeUp];
        }
        [self dismissViewControllerAnimated:YES completion:nil];
        
    } else if (item.tag == 20) {
        
        item.isSelect = !item.isSelect;
        if (self.callViewCon) {
            [self.callViewCon audioEnable:!item.isSelect];
        }
        if (!item.isSelect) {
            
            [self.micStateImage setHidden:YES];
            [item setBackgroundImage:[UIImage imageNamed:@"mic"] forState:UIControlStateNormal];
            [item setBackgroundImage:[UIImage imageNamed:@"micselect"] forState:UIControlStateHighlighted];
            
        } else {
            
            [self.micStateImage setHidden:NO];
            [item setBackgroundImage:[UIImage imageNamed:@"noMic"] forState:UIControlStateNormal];
            [item setBackgroundImage:[UIImage imageNamed:@"noMicselect"] forState:UIControlStateHighlighted];
        }
    }else if(item.tag == 30){
        
        if (self.callViewCon) {
            [self.callViewCon switchCamera];
        }
        
    }else if (item.tag == 40){
        
        item.isSelect = !item.isSelect;
        if (self.callViewCon) {
            [self.callViewCon videoEnable:!item.isSelect];
        }
        [self.menuView showEnable:YES];
    }
}

- (void)sendMessage {
    
    [_popver dismiss];
    MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
    controller.navigationBar.barTintColor = [UIColor whiteColor];
    if([MFMessageComposeViewController canSendText])
    {
        controller.body = [NSString stringWithFormat:@"http://192.168.7.62/demo/rtpmp/rtpmp.html#%@",self.roomItem.roomID];
        
        controller.recipients = nil;
        
        controller.messageComposeDelegate = self;
        
        [self presentViewController:controller animated:YES completion:nil];
        
    }
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    
    [self willRotateAdjustUI];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    
    [self didRotateAdjustUI];
}

//NS_AVAILABLE_IOS(8_0);
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id <UIViewControllerTransitionCoordinator>)coordinator
{
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context)
     {
         [self willRotateAdjustUI];
         
     } completion:^(id<UIViewControllerTransitionCoordinatorContext> context)
     {
         [self didRotateAdjustUI];
     }];
    
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
}

- (void)willRotateAdjustUI {
    
    [self.rootView.view setAlpha:0];
    if (ISIPAD) {
        
        self.noUserTip.alpha = 0;
        self.menuView.alpha = 0;
    }
}

- (void)didRotateAdjustUI {
    
    BOOL isVertical = [self isVertical];
    CGFloat rootViewWidth = isVertical == YES ? (self.view.bounds.size.width/2 - 50) : (self.view.bounds.size.width/2 - 100);
    [self.rootView.view setAlpha:1];
    if (ISIPAD) {
        
        self.noUserTip.alpha = 1;
        self.menuView.alpha = 1;
        [UIView animateWithDuration:0.1 animations:^{
            
            if (self.rootView.view.frame.origin.x < 0) {
                
                [self.rootView.view setFrame:CGRectMake(0 - rootViewWidth, 0, rootViewWidth, self.view.bounds.size.height)];
                [self.menuView setCenter:CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height - self.menuView.bounds.size.height)];
                [self.noUserTip setCenter:CGPointMake(self.view.bounds.size.width/2, CGRectGetMinY(self.menuView.frame) - self.noUserTip.bounds.size.height)];
                
            } else {
                
                [self.rootView.view setFrame:CGRectMake(0, 0, rootViewWidth, self.view.bounds.size.height)];
                [self.menuView setCenter:CGPointMake(self.view.bounds.size.width/2 + self.view.bounds.size.width/4, self.view.bounds.size.height - self.menuView.bounds.size.height)];
                [self.noUserTip setCenter:CGPointMake(self.view.bounds.size.width/2 + self.view.bounds.size.width/4, CGRectGetMinY(self.menuView.frame) - self.noUserTip.bounds.size.height)];
            }
            [self.rootView resetInputFrame:CGRectMake(0, self.view.bounds.size.height - 40, self.view.bounds.size.width, 40)];
        }];
        
    } else {
        
        [UIView animateWithDuration:0.2 animations:^{
            
            [self.menuView setCenter:CGPointMake(self.view.bounds.size.width/2, self.isFullScreen == YES ? (self.view.bounds.size.height + self.menuView.bounds.size.height) : (self.view.bounds.size.height - self.menuView.bounds.size.height))];
            [self.noUserTip setCenter:CGPointMake(self.view.bounds.size.width/2, self.isFullScreen == YES ? (self.view.bounds.size.height + self.noUserTip.bounds.size.height) : (CGRectGetMinY(self.menuView.frame) - self.noUserTip.bounds.size.height/2))];
            [self.rootView.view setFrame:self.view.bounds];
            [self.rootView resetInputFrame:CGRectMake(0, self.view.bounds.size.height - 40, self.view.bounds.size.width, 40)];
        }];
        if (self.barView) {
            
            [self initBar];
            
        } else {
            
            [self initChatBar];
        }
    }
}

- (BOOL)isVertical {
    
    BOOL isVertical = YES;
    NSUInteger width = self.view.bounds.size.width;
    NSUInteger height = self.view.bounds.size.height;
    isVertical = width > height ? NO : YES;
    return isVertical;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (BOOL)prefersStatusBarHidden {
    
    return NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
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
