//
//  MainViewController.m
//  Room
//
//  Created by yangyang on 15/11/16.
//  Copyright © 2015年 yangyangwang. All rights reserved.
//

#import "MainViewController.h"
#import "PushView.h"
#import "RoomViewCell.h"

#import "GetRoomView.h"
#import "VideoCallViewController.h"
#import "ServerVisit.h"
#import "SvUDIDTools.h"
#import "ToolUtils.h"
#import "ASHUD.h"
#import <MessageUI/MessageUI.h>
#import "ASNetwork.h"
#import "RoomAlertView.h"
#import "UINavigationBar+Category.h"
#import "NavView.h"
#import "NtreatedDataManage.h"
#import "UIView+Category.h"
#import "AppDelegate.h"
#import "NtreatedDataManage.h"

#import "EmptyViewFactory.h"
#import "EnterMeetingIDViewController.h"
#import "UIImage+Category.h"
#import "TMMessageManage.h"

static NSString *kRoomCellID = @"RoomCell";

#define IPADLISTWIDTH 320

@interface MainViewController ()<UITableViewDelegate,UITableViewDataSource,RoomViewCellDelegate,GetRoomViewDelegate,PushViewDelegate,MFMessageComposeViewControllerDelegate>

{
    UIRefreshControl *refreshControl;
}

@property (nonatomic, strong) UIButton *getRoomButton;
@property (nonatomic, strong) PushView *push;
@property (nonatomic, strong) GetRoomView *getRoomView;

@property (nonatomic, strong) NSMutableArray *tempDataArray; // temp data
@property (nonatomic, strong) UIButton *cancleButton;    // cancle create room button
@property (nonatomic, strong) UIButton *inputButton;
@property (nonatomic, strong) RoomAlertView *netAlertView;
@property (nonatomic, strong) NavView *navView;
@property (nonatomic, assign) UIInterfaceOrientation oldInterface;
@property (nonatomic, strong) UIImageView *listBgView;
@property (nonatomic, strong) UIView *bgView;

@end

@implementation MainViewController
@synthesize dataArray;
@synthesize tempDataArray;

- (void)dealloc
{
    [[ASNetwork sharedNetwork] removeObserver:self forKeyPath:@"_netType" context:nil];
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.oldInterface = self.interfaceOrientation;
    self.view.backgroundColor = [UIColor clearColor];
    
    [[ASNetwork sharedNetwork] addObserver:self forKeyPath:@"_netType" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
    
    if (!dataArray) {
        dataArray = [[NSMutableArray alloc] initWithCapacity:5];
        tempDataArray = [[NSMutableArray alloc] initWithCapacity:5];
    }
    [self initUser];
    [self setBackGroundImageView];
    
    self.listBgView = [UIImageView new];
    self.listBgView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.listBgView];
    
    self.navView = [NavView new];
    self.navView.title = @"房间";
    [self.view addSubview:self.navView];

    
    self.roomList = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.roomList.backgroundColor = [UIColor clearColor];
    self.roomList.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.roomList.delegate = self;
    self.roomList.dataSource = self;
    [self.view addSubview:self.roomList];
    [self.roomList registerClass:[RoomViewCell class] forCellReuseIdentifier:kRoomCellID];
    
    refreshControl = [[UIRefreshControl alloc]init];
    [refreshControl addTarget:self action:@selector(refreshViewControlEventValueChanged) forControlEvents:UIControlEventValueChanged];
    [self.roomList addSubview:refreshControl];
    
    self.getRoomButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.getRoomButton setTitle:@"获取房间" forState:UIControlStateNormal];
    [self.getRoomButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.getRoomButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [self.view addSubview:self.getRoomButton];
    [self.getRoomButton addTarget:self action:@selector(getRoomButtonEvent:) forControlEvents:UIControlEventTouchUpInside];
    [self.getRoomButton setBackgroundColor:[UIColor colorWithRed:235.0/255.0 green:139.0/255.0 blue:75.0/255.0 alpha:1.0]];
    self.getRoomButton.layer.cornerRadius = 2;
    
    
    
    self.getRoomView = [[GetRoomView alloc] initWithFrame:CGRectMake(0, 64, self.view.bounds.size.width, CGRectGetHeight(self.view.frame)) withParView:self.view];
    self.getRoomView.delegate = self;
    
    self.cancleButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.cancleButton.frame = CGRectMake(15, 25, 35, 28);
    [self.cancleButton setTitle:@"取消" forState:UIControlStateNormal];
    self.cancleButton.titleLabel.font = [UIFont systemFontOfSize:16];
    self.cancleButton.titleLabel.textAlignment = NSTextAlignmentLeft;
    [self.cancleButton addTarget:self action:@selector(cancleButtonEvent:) forControlEvents:UIControlEventTouchUpInside];
    [self.navView addSubview:self.cancleButton];
    self.cancleButton.hidden = YES;
    
    self.inputButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.inputButton setImage:[UIImage imageNamed:@"share"] forState:UIControlStateNormal];
    [self.inputButton addTarget:self action:@selector(inputButtonEvent:) forControlEvents:UIControlEventTouchUpInside];
    [self.navView addSubview:self.inputButton];
    
    if (ISIPAD) {
        self.listBgView.frame = CGRectMake(0, 0, IPADLISTWIDTH, CGRectGetHeight(self.view.frame));
        
        self.navView.frame = CGRectMake(0, 0, IPADLISTWIDTH, 64);
        self.roomList.frame = CGRectMake(0, 64, IPADLISTWIDTH,CGRectGetHeight(self.view.frame)-CGRectGetMaxY(self.navView.frame) -75);
        self.getRoomButton.frame = CGRectMake(15, CGRectGetMaxY(self.view.frame) - 60,IPADLISTWIDTH -30, 45);
        
    }else{
        self.listBgView.frame = CGRectMake(0, 0, self.view.bounds.size.width, CGRectGetHeight(self.view.frame));
        
        self.navView.frame = CGRectMake(0, 0, self.view.bounds.size.width, 64);
        self.roomList.frame = CGRectMake(0, 64, self.view.bounds.size.width,CGRectGetHeight(self.view.frame)-CGRectGetMaxY(self.navView.frame) -75);
        self.getRoomButton.frame = CGRectMake(15, CGRectGetMaxY(self.view.frame) - 60,self.view.bounds.size.width -30, 45);

    }
    self.inputButton.frame = CGRectMake(CGRectGetWidth(self.navView.frame)-40, 30, 30, 30);
    
    self.push = [[PushView alloc] initWithFrame:self.view.bounds];
    self.push.delegate = self;
    AppDelegate *apple = [RoomApp shead].appDelgate;
    [apple.window.rootViewController.view addSubview:self.push];
    
    [self.view bringSubviewToFront:self.navView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shareMettingNotification:) name:ShareMettingNotification object:nil];
}
- (void)refreshViewControlEventValueChanged
{
    [refreshControl endRefreshing];
    [self.roomList reloadData];
    
}
// 旋转屏幕适配
- (void)viewDidLayoutSubviews
{
     [self refreshImage];
    if (self.oldInterface == self.interfaceOrientation || !ISIPAD) {
        return;
    }else{
         UIView *initView = [[UIApplication sharedApplication].keyWindow.rootViewController.view viewWithTag:400];
        if (self.interfaceOrientation == UIInterfaceOrientationPortrait) {
            if (initView) {
                initView.frame = [UIScreen mainScreen].bounds;
            }
            self.listBgView.frame = CGRectMake(0, 0, IPADLISTWIDTH, CGRectGetHeight(self.view.frame));
            self.navView.frame = CGRectMake(0, 0, IPADLISTWIDTH, 64);
            self.roomList.frame = CGRectMake(0, 64, IPADLISTWIDTH,CGRectGetHeight(self.view.frame)-CGRectGetMaxY(self.navView.frame) -75);
            self.getRoomButton.frame = CGRectMake(15, CGRectGetMaxY(self.view.frame) - 60,IPADLISTWIDTH -30, 45);
            self.push.frame = self.view.bounds;
            [self.push updateLayout];
            UIImageView *bgImageView = [self.bgView viewWithTag:500];
            bgImageView.image = [UIImage imageNamed:@"Default-Portrait"];
        }else if(self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft || self.interfaceOrientation == UIInterfaceOrientationLandscapeRight){
            if (initView) {
                initView.frame = [UIScreen mainScreen].bounds;
            }
            self.listBgView.frame = CGRectMake(0, 0, IPADLISTWIDTH, CGRectGetHeight(self.view.frame));
            self.navView.frame = CGRectMake(0, 0, IPADLISTWIDTH, 64);
            self.roomList.frame = CGRectMake(0, 64, IPADLISTWIDTH,CGRectGetHeight(self.view.frame)-CGRectGetMaxY(self.navView.frame) -75);
            self.getRoomButton.frame = CGRectMake(15, CGRectGetMaxY(self.view.frame) - 60,IPADLISTWIDTH -30, 45);
             self.push.frame = self.view.bounds;
            [self.push updateLayout];
            UIImageView *bgImageView = [self.bgView viewWithTag:500];
            bgImageView.image = [UIImage imageNamed:@"Default-Landscape"];
        }
    }
    
    self.oldInterface = self.interfaceOrientation;
    [self refreshImage];
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer*)gestureRecognizer shouldReceiveTouch:(UITouch*)touch {
    Class cellclass = NSClassFromString(@"UITableViewCellContentView");
    if([touch.view isKindOfClass:cellclass])
    {
        return NO;
    }else{
        return YES;
    }
}

// 滤镜效果
- (void)refreshImage
{
    UIImage *image = [self.bgView getImageWith:self.listBgView.frame];
    if (!image) {
        return;
    }
    UIColor *color = [UIColor colorWithRed:.1 green:.1 blue:.1 alpha:.8];
   UIImage * bgimage = [image applyBlurWithRadius:20 tintColor:color saturationDeltaFactor:1.8 maskImage:nil];
    [self.listBgView setImage:bgimage];
   // [self.listBgView setImageToBlur:image  blurRadius:20 completionBlock:^(){}];
}
- (void)shareMettingNotification:(NSNotification*)notification
{
    NSString *meetingID = [notification object];
    if (![[ServerVisit shead].authorization isEqualToString:@""]) {
        [self addItemAndEnterMettingWithID:meetingID];
    }else{
        [ToolUtils shead].meetingID = meetingID;
    }
}
#pragma mark -private methods
- (void)initUser
{
    UIView *initView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    initView.backgroundColor = [UIColor clearColor];
    initView.tag = 400;

    AppDelegate *apple = [RoomApp shead].appDelgate;
    [apple.window.rootViewController.view addSubview:initView];
    
    UIImageView *initViewBg = [UIImageView new];
    [initView addSubview:initViewBg];
    
    initViewBg.translatesAutoresizingMaskIntoConstraints = NO;
    NSDictionary *views = NSDictionaryOfVariableBindings(initViewBg);
    [initView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[initViewBg]-0-|" options:NSLayoutFormatAlignmentMask metrics:nil views:views]];
    [initView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[initViewBg]-0-|" options:NSLayoutFormatAlignmentMask metrics:nil views:views]];
    

    int height = CGRectGetHeight(self.view.bounds);
    NSString *imageName;
    switch (height) {
        case 480:
            imageName = @"Default.png";
            break;
        case 568:
            imageName = @"Default-568h";
            break;
        case 667:
            imageName = @"Default-667h";
            break;
        case 736:
            imageName = @"Default-736h";
            break;
        case 768:
            imageName = @"Default-Landscape";
            break;
        case 1024:
            imageName = @"Default-Portrait";
            break;
        default:
            imageName = @"Default-736h";
            
            break;
    }
    initViewBg.image = [UIImage imageNamed:imageName];
    UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [initView addSubview:activityIndicatorView];
    
    activityIndicatorView.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSDictionary* acViews = NSDictionaryOfVariableBindings(activityIndicatorView);
    //设置高度
    [initView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[activityIndicatorView]-|" options:NSLayoutFormatAlignAllCenterX metrics:nil views:acViews]];
   // 上面的代码可以让prgrssView 水平居中。垂直代码如下
    [initView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[activityIndicatorView]-380-|" options:NSLayoutFormatAlignAllTop metrics:nil views:acViews]];
    [activityIndicatorView startAnimating];
}

- (void)deviceInit
{
    __weak MainViewController *weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [ServerVisit userInitWithUserid:[SvUDIDTools UDID] uactype:@"0" uregtype:@"3" ulogindev:@"3" upushtoken:[ServerVisit shead].deviceToken completion:^(AFHTTPRequestOperation *operation, id responseData, NSError *error) {
            if (!error) {
                NSDictionary *dict = (NSDictionary*)responseData;
                if ([[dict objectForKey:@"code"] integerValue] == 200) {
                    [ServerVisit shead].authorization = [dict objectForKey:@"authorization"];
                    [weakSelf getData];
                    [[TMMessageManage sharedManager] OnMsgServerConnected];
                    
                }else{
                    
                }
            }else{
                
            }
        }];
    });
}

- (void)getData
{
    __weak MainViewController *weakSelf = self;
    [ServerVisit getRoomListWithSign:[ServerVisit shead].authorization withPageNum:1 withPageSize:20 completion:^(AFHTTPRequestOperation *operation, id responseData, NSError *error) {
        if (!error) {
            NSDictionary *dict = (NSDictionary*)responseData;
            if ([[dict objectForKey:@"code"] integerValue] == 200) {
                RoomVO *roomVO = [[RoomVO alloc] initWithParams:[dict objectForKey:@"meetingList"]];
                if (roomVO.deviceItemsList.count!=0) {
                    [weakSelf.dataArray addObjectsFromArray:roomVO.deviceItemsList];
                }
                [weakSelf.roomList reloadData];
                if (weakSelf.dataArray.count == 0) {
                    [EmptyViewFactory emptyMainView:weakSelf.roomList];
                }
                [[NtreatedDataManage sharedManager] dealwithDataWithTarget:self];
                if ([ToolUtils shead].meetingID != nil) {
                    [weakSelf addItemAndEnterMettingWithID:[ToolUtils shead].meetingID];
                }
                AppDelegate *apple = [RoomApp shead].appDelgate;
                UIView *initView = [apple.window.rootViewController.view viewWithTag:400];
                if (initView) {
                    [UIView animateWithDuration:0.3 animations:^{
                        initView.alpha = 0.0;
                    }completion:^(BOOL finished) {
                        [initView removeFromSuperview];
                    }];
                }
            }
        }
    }];
}

- (void)setBackGroundImageView
{
    self.bgView = [[UIView alloc] init];
    [self.view addSubview:self.bgView ];
    UIImageView *bgImageView = [UIImageView new];
    bgImageView.tag = 500;
    [self.bgView addSubview:bgImageView];
    
    _bgView.translatesAutoresizingMaskIntoConstraints = NO;
    bgImageView.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSDictionary *views = NSDictionaryOfVariableBindings(_bgView,bgImageView);
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[_bgView]-0-|" options:NSLayoutFormatAlignmentMask metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_bgView]-0-|" options:NSLayoutFormatAlignmentMask metrics:nil views:views]];
    
    [_bgView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[bgImageView]-0-|" options:NSLayoutFormatAlignmentMask metrics:nil views:views]];
    [_bgView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[bgImageView]-0-|" options:NSLayoutFormatAlignmentMask metrics:nil views:views]];
    
    int height = CGRectGetHeight(self.view.bounds);
    
    NSString *imageName;
    switch (height) {
        case 480:
            imageName = @"Default.png";
            break;
        case 568:
            imageName = @"Default-568h";
            break;
        case 667:
            imageName = @"Default-667h";
            break;
        case 736:
            imageName = @"Default-736h";
            break;
        case 768:
            imageName = @"Default-Landscape";
            break;
        case 1024:
            imageName = @"Default-Portrait";
            break;
        default:
            imageName = @"Default-736h";
            
            break;
    }
    bgImageView.image = [UIImage imageNamed:imageName];
}

-(void)displaySMSComposerSheet:(NSString*)roomID
{
    
    MFMessageComposeViewController *picker = [[MFMessageComposeViewController alloc] init];
    picker.messageComposeDelegate =self;
    NSString *smsBody =[NSString stringWithFormat:@"让我们在会议中见!👉 http://115.28.70.232/share_meetingRoom#%@",roomID];
    
    picker.body=smsBody;
    
    [self presentViewController:picker animated:YES completion:^{
         [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    }];
}



#pragma mark - button events
- (void)getRoomButtonEvent:(UIButton*)button
{
    self.inputButton.hidden = YES;
    if (self.roomList.isEditing) {
        self.roomList.editing = NO;
    }
    [self.getRoomView showGetRoomView];
    
    RoomItem *roomItem = [[RoomItem alloc] init];
    roomItem.userID = [SvUDIDTools UDID];
    [dataArray insertObject:roomItem atIndex:0];
    // 先把数据添加上，在搞下面的
    
    NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    
    [indexPaths addObject: indexPath];
    
    [self.roomList beginUpdates];
    
    [self.roomList insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationTop];
    
    [self.roomList endUpdates];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.roomList reloadData];
    });
    
}

- (void)cancleButtonEvent:(UIButton*)button
{
    if (self.getRoomView) {
        [self.getRoomView dismissView];
    }
  
}
- (void)inputButtonEvent:(UIButton*)button
{
    EnterMeetingIDViewController *enterMeetingController = [EnterMeetingIDViewController new];
    enterMeetingController.mainViewController = self;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:enterMeetingController];
    [self presentViewController:nav animated:NO completion:nil];
}
#pragma mark - publish server methods
- (void)updataDataWithServerResponse:(NSDictionary*)dict
{
    dispatch_async(dispatch_get_main_queue(), ^{
        RoomItem *roomItem = [dataArray objectAtIndex:0];
        roomItem.roomID = [dict objectForKey:@"meetingid"];
        roomItem.jointime = [[dict objectForKey:@"jointime"] longValue];
        roomItem.mettingType = [[dict objectForKey:@"meettype"] integerValue];
        roomItem.mettingState = [[dict objectForKey:@"meetusable"] integerValue];
        
        [dataArray replaceObjectAtIndex:0 withObject:roomItem];
        [self.roomList reloadData];
    });
}
// 添加
- (void)addRoomWithRoomName:(NSString*)roomName withPrivate:(BOOL)isPrivate
{
    RoomItem *roomItem = [dataArray objectAtIndex:0];
    roomItem.roomName = roomName;
    
    [dataArray replaceObjectAtIndex:0 withObject:roomItem];
    [self.roomList reloadData];

    self.cancleButton.hidden = YES;
    
    NtreatedData *data = [[NtreatedData alloc] init];
    data.actionType = CreateRoom;
    data.isPrivate = isPrivate;
    data.item = roomItem;
    [[NtreatedDataManage sharedManager] addData:data];
    
    __weak MainViewController *weakSelf = self;
    // 上传信息
    [ServerVisit applyRoomWithSign:[ServerVisit shead].authorization mettingId:roomItem.roomID mettingname:roomItem.roomName mettingCanPush:roomItem.canNotification  mettingtype:@"0" meetenable:isPrivate == YES ? @"2" : @"1" mettingdesc:@""  completion:^(AFHTTPRequestOperation *operation, id responseData, NSError *error) {
        NSLog(@"create room");
        NSDictionary *dict = (NSDictionary*)responseData;
        if (!error) {
            if ([[dict objectForKey:@"code"] intValue]== 200) {
                [weakSelf updataDataWithServerResponse:[dict objectForKey:@"meetingInfo"]];
                 [[NtreatedDataManage sharedManager] removeData:data];
                [weakSelf.push showWithType:PushViewTypeDefault withObject:roomItem withIndex:0];
                //this TMCMD_CREATE has deprecated
                //[[TMMessageManage sharedManager] tmRoomCmd:TMCMD_CREATE Userid:nil pass:[ServerVisit shead].authorization roomid:[NSString stringWithFormat:@"%@",[[dict objectForKey:@"meetingInfo"] objectForKey:@"meetingid"]] remain:@""];
            }
        }
       
    }];
}

// update room name
- (void)addTempDeleteData:(NSString*)roomName
{
    if (dataArray.count==0) {
        return;
    }
    // update object
    RoomItem *roomItem = [dataArray objectAtIndex:0];
    roomItem.roomName = roomName;
    [dataArray replaceObjectAtIndex:0 withObject:roomItem];
    
    
    NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
    for (NSInteger i = tempDataArray.count-1; i>-1; i--) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        [indexPaths addObject: indexPath];
        RoomItem *item = [tempDataArray objectAtIndex:i];
        [dataArray insertObject:item atIndex:0];
    }
    
    
    [self.roomList beginUpdates];
    
    [self.roomList insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationTop];
    
    [self.roomList endUpdates];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.roomList reloadData];
    });
    
    NtreatedData *data = [[NtreatedData alloc] init];
    data.actionType = ModifyRoomName;
    data.item = roomItem;
    [[NtreatedDataManage sharedManager] addData:data];
    
    [ServerVisit updatateRoomNameWithSign:[ServerVisit shead].authorization mettingID:roomItem.roomID mettingName:roomName completion:^(AFHTTPRequestOperation *operation, id responseData, NSError *error) {
        NSLog(@"updata name");
         NSDictionary *dict = (NSDictionary*)responseData;
        if (!error) {
            if ([[dict objectForKey:@"code"] intValue]== 200) {
                [[NtreatedDataManage sharedManager] removeData:data];
                
            }
        }
    }];
}
// delete room
- (void)deleteRoomWithItem:(RoomItem*)item withIndex:(NSInteger)index
{
    
    NtreatedData *data = [[NtreatedData alloc] init];
    data.actionType = ModifyRoomName;
    data.item = item;
    [[NtreatedDataManage sharedManager] addData:data];
    
    [dataArray removeObject:item];
    
    NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
    
    NSIndexPath *indexP = [NSIndexPath indexPathForRow:index inSection:0];
    
    [indexPaths addObject: indexP];
    [self.roomList beginUpdates];
    
    [self.roomList deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationMiddle];
    
    [self.roomList endUpdates];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.roomList reloadData];
    });
    
    [ServerVisit deleteRoomWithSign:[ServerVisit shead].authorization meetingID:item.roomID completion:^(AFHTTPRequestOperation *operation, id responseData, NSError *error) {
        NSLog(@"delete room");
        NSDictionary *dict = (NSDictionary*)responseData;
        if (!error) {
            if ([[dict objectForKey:@"code"] intValue]== 200) {
                [[NtreatedDataManage sharedManager] removeData:data];
                
            }
        }
    }];
}
// update room can notification
- (void)updateNotification:(RoomItem*)item withClose:(BOOL)close withIndex:(NSInteger)index
{
    NtreatedData *data = [[NtreatedData alloc] init];
    data.actionType = SettingNotificationRoom;
    data.isNotification = close;
    data.item = item;
    [[NtreatedDataManage sharedManager] addData:data];
    
    [dataArray replaceObjectAtIndex:index withObject:item];
    
    NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
    
    NSIndexPath *indexP = [NSIndexPath indexPathForRow:index inSection:0];
    
    [indexPaths addObject: indexP];
    
    [self.roomList beginUpdates];
    
    [self.roomList reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
    
    [self.roomList endUpdates];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.roomList reloadData];
    });
    
    [ServerVisit updateRoomPushableWithSign:[ServerVisit shead].authorization meetingID:item.roomID pushable:[NSString stringWithFormat:@"%d",close] completion:^(AFHTTPRequestOperation *operation, id responseData, NSError *error) {
        NSLog(@"open or close push");
        NSDictionary *dict = (NSDictionary*)responseData;
        if (!error) {
            if ([[dict objectForKey:@"code"] intValue]== 200) {
                [[NtreatedDataManage sharedManager] removeData:data];
                
            }
        }
    }];
}
// setting room is private
- (void)setPrivateMeeting:(RoomItem*)item withPrivate:(BOOL)private withIndex:(NSInteger)index
{
    NtreatedData *data = [[NtreatedData alloc] init];
    data.actionType = SettingPrivateRoom;
    data.isPrivate = private;
    data.item = item;
    [[NtreatedDataManage sharedManager] addData:data];
    
    [dataArray replaceObjectAtIndex:index withObject:item];
    
    NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
    
    NSIndexPath *indexP = [NSIndexPath indexPathForRow:index inSection:0];
    
    [indexPaths addObject: indexP];
    
    [self.roomList beginUpdates];
    
    [self.roomList reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
    
    [self.roomList endUpdates];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.roomList reloadData];
    });
    
    NSString *enable;
    if (private) {
        enable = @"2";
    }else{
        enable = @"1";
    }
    [ServerVisit updateRoomEnableWithSign:[ServerVisit shead].authorization meetingID:item.roomID enable:enable completion:^(AFHTTPRequestOperation *operation, id responseData, NSError *error) {
        NSLog(@"private meeting");
        NSDictionary *dict = (NSDictionary*)responseData;
        if (!error) {
            if ([[dict objectForKey:@"code"] intValue]== 200) {
                [[NtreatedDataManage sharedManager] removeData:data];
                
            }
        }
    }];
}
// add others meeting in ours
- (void)insertUserMeetingRoomWithID:(RoomItem*)item
{
    BOOL find = NO;
    for (RoomItem *tempItem in dataArray) {
        if ([tempItem.roomID isEqualToString:item.roomID]) {
            find = YES;
            break;
        }
    }
    if (!find) {
        [ASHUD showHUDWithCompleteStyleInView:self.view content:nil icon:nil];
        __weak MainViewController *weakSelf = self;
        [ServerVisit insertUserMeetingRoomWithSign:[ServerVisit shead].authorization meetingID:item.roomID completion:^(AFHTTPRequestOperation *operation, id responseData, NSError *error) {
            NSDictionary *dict = (NSDictionary*)responseData;
            [ASHUD hideHUD];
            if (!error) {
                if ([[dict objectForKey:@"code"] integerValue] == 200) {
                    [weakSelf addItemAndEnterMetting:item];
                }else{
                    
                }
            }else{
                
            }
        }];
    }
}

- (void)addItemAndEnterMetting:(RoomItem*)item
{
    [dataArray insertObject:item atIndex:0];
    
    NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    
    [indexPaths addObject: indexPath];
    
    [self.roomList beginUpdates];
    
    [self.roomList insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationTop];
    
    [self.roomList endUpdates];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.roomList reloadData];
        
        VideoCallViewController *video = [[VideoCallViewController alloc] init];
        video.roomItem = item;
        UINavigationController *nai = [[UINavigationController alloc] initWithRootViewController:video];
        [self presentViewController:nai animated:YES completion:^{
            
        }];
    });
}

- (void)addItemAndEnterMettingWithID:(NSString*)meeting
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString* number=@"^\\d{12}$";
        NSPredicate *numberPre = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",number];
        BOOL isTrue = [numberPre evaluateWithObject:meeting];
        if (isTrue) {
            __weak MainViewController *weakSelf = self;
            [ServerVisit  getMeetingInfoWithId:meeting completion:^(AFHTTPRequestOperation *operation, id responseData, NSError *error) {
                if (!error) {
                    NSDictionary *dict = (NSDictionary*)responseData;
                    if ([[dict objectForKey:@"code"] integerValue] == 400) {
                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"会议ID不存在" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                        [alertView show];
                    }else if ([[dict objectForKey:@"code"] integerValue] == 200){
                        NSDictionary *roomInfo = [dict objectForKey:@"meetingInfo"];
                        if ([[roomInfo objectForKey:@"meetusable"] integerValue]==2) {
                            // 私密会议不能添加和进入
                            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"私密会议不能添加，请联系其主人，让其关闭私密" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                            [alertView show];
                        }else{
                            RoomItem *item = [[RoomItem alloc] init];
                            item.roomID = [roomInfo objectForKey:@"meetingid"];
                            item.roomName = [roomInfo objectForKey:@"meetname"];
                            item.createTime = [[roomInfo objectForKey:@"crttime"] longValue];
                            item.mettingDesc = [roomInfo objectForKey:@"meetdesc"];
                            item.mettingNum = [[roomInfo objectForKey:@"memnumber"] stringValue];
                            item.mettingType = [[roomInfo objectForKey:@"meettype1"] integerValue];
                            item.mettingState = [[roomInfo objectForKey:@"meetusable"] integerValue];
                            item.userID = [roomInfo objectForKey:@"userid"];
                            item.canNotification = [[roomInfo objectForKey:@"pushable"] stringValue];
                            [ToolUtils shead].meetingID = nil;
                            [weakSelf insertUserMeetingRoomWithID:item];
                        }
                    }
                }else{
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"服务异常" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                    [alertView show];
                }
            }];
        }else{
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"会议ID不合法" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alertView show];
        }
    });
}

#pragma mark - UITableViewDelegate UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return dataArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    RoomViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kRoomCellID forIndexPath:indexPath];
    cell.delegate = self;
    cell.parIndexPath = indexPath;
    [cell setItem:[dataArray objectAtIndex:indexPath.row]];
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
        RoomItem *item = [dataArray objectAtIndex:indexPath.row];
        if (item.mettingState == 0) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"该会议暂不可用" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alertView show];
            return;
        }
        __weak MainViewController *weakSelf = self;
        [ServerVisit getMeetingInfoWithId:item.roomID completion:^(AFHTTPRequestOperation *operation, id responseData, NSError *error) {
            if (!error) {
                NSDictionary *dict = (NSDictionary*)responseData;
                if ([[dict objectForKey:@"code"] integerValue] == 400) {
                    //该会议已经被持有人删除
                    [ASHUD showHUDWithCompleteStyleInView:self.view content:@"该会议已经被持有人删除" icon:nil];
                    [weakSelf deleteRoomWithItem:item withIndex:indexPath.row];
                }else if ([[dict objectForKey:@"code"] integerValue] == 200){
                    dispatch_async(dispatch_get_main_queue(), ^{
                        VideoCallViewController *video = [[VideoCallViewController alloc] init];
                        video.roomItem = [dataArray objectAtIndex:indexPath.row];
                        UINavigationController *nai = [[UINavigationController alloc] initWithRootViewController:video];
                        [self presentViewController:nai animated:YES completion:^{
                            
                        }];
                    });
                }
            }else{
                [ASHUD showHUDWithCompleteStyleInView:self.view content:@"进入会议出现异常" icon:nil];
            }
        }];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}
  //当在Cell上滑动时会调用此函数
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
  return  UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    RoomItem *deleteItem = [dataArray objectAtIndex:indexPath.row];
    [self deleteRoomWithItem:deleteItem withIndex:indexPath.row];
    
}
-(NSString*)tableView:(UITableView*)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath*)indexpath
{
    return @"删除";
}

#pragma mark - RoomViewCellDelegate
- (void)roomViewCellDlegateSettingEvent:(NSInteger)index
{
    if (self.roomList.isEditing) {
        return;
    }
    RoomItem *roomItem = [dataArray objectAtIndex:index];
    if ([roomItem.userID isEqualToString:[SvUDIDTools UDID]]) {
        [self.push showWithType:PushViewTypeSetting withObject:roomItem withIndex:index];
    }else{
        [self.push showWithType:PushViewTypeSettingConferee withObject:roomItem withIndex:index];
    }
   
}

#pragma mark - GetRoomViewDelegate

- (void)showCancleButton//show button
{
   self.cancleButton.hidden = NO;
}

- (void)getRoomWithRoomName:(NSString*)roomName withPrivateMetting:(BOOL)isPrivate
{
    [self addRoomWithRoomName:roomName withPrivate:isPrivate];
    
}
- (void)cancleGetRoom
{
    
    [dataArray removeObjectAtIndex:0];
    
    NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    
    [indexPaths addObject: indexPath];
    
    [self.roomList beginUpdates];
    
    [self.roomList deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationLeft];
    
    [self.roomList endUpdates];
    
     self.cancleButton.hidden = YES;
     self.inputButton.hidden = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
         [self.roomList reloadData];
    });
}

- (void)renameRoomNameScuess:(NSString*)roomName
{
    [self addTempDeleteData:roomName];
    self.cancleButton.hidden = YES;
    
}

// cancle update name
- (void)cancleRename:(NSString*)oldName
{
    [self addTempDeleteData:oldName];
     self.cancleButton.hidden = YES;
}


#pragma mark - PushViewDelegate
- (void)pushViewInviteViaMessages:(RoomItem*)obj
{
    Class messageClass = (NSClassFromString(@"MFMessageComposeViewController"));
    if (messageClass != nil) {
        // Check whether the current device is configured for sending SMS messages
        if ([messageClass canSendText]) {
            
            [self displaySMSComposerSheet:obj.roomID];
        }
        else {
            UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@""message:@"设备不支持短信功能" delegate:self cancelButtonTitle:@"确定"otherButtonTitles:nil];
            [alert show];
        }
        
    }
}

- (void)pushViewInviteViaWeiXin:(RoomItem*)obj
{
    
}
- (void)pushViewInviteViaLink:(RoomItem*)obj
{
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = @"www.baidu.com";
    [ASHUD showHUDWithCompleteStyleInView:self.view content:@"拷贝成功" icon:@"messageInvite"];
}

- (void)pushViewJoinRoom:(RoomItem*)obj
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        VideoCallViewController *video = [[VideoCallViewController alloc] init];
        video.roomItem = obj;
        UINavigationController *nai = [[UINavigationController alloc] initWithRootViewController:video];
        [self presentViewController:nai animated:YES completion:^{
        }];
    });
}
- (void)pushViewCloseOrOpenNotifications:(RoomItem *)obj withOpen:(BOOL)isOpen withIndex:(NSInteger)index
{
    [self updateNotification:obj withClose:isOpen withIndex:index];
}
- (void)pushViewPrivateMeeting:(RoomItem*)obj withPrivate:(BOOL)isPrivate withIndex:(NSInteger)index
{
    [self setPrivateMeeting:obj withPrivate:isPrivate withIndex:index];
}

- (void)pushViewRenameRoom:(RoomItem*)obj
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self.roomList.isEditing) {
            self.roomList.editing = NO;
        }
        if (tempDataArray.count!=0) {
            [tempDataArray removeAllObjects];
        }
        NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
        
        for (NSInteger i = 0; i<dataArray.count; i++ ) {
            RoomItem *item = [dataArray objectAtIndex:i];
            if (item != obj) {
                [tempDataArray addObject:item];
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
                [indexPaths addObject:indexPath];
            }else{
                break;
            }
            
        }
        [dataArray removeObjectsInArray:tempDataArray];
        
        [self.roomList beginUpdates];
        
        [self.roomList deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationBottom];
        
        [self.roomList endUpdates];
        
        [self.getRoomView showWithRenameRoom:obj.roomName];
    });
    
    
}
- (void)pushViewDelegateRoom:(RoomItem*)obj withIndex:(NSInteger)index
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self deleteRoomWithItem:obj withIndex:index];
    });
}

#pragma mark MFMessageComposeViewControllerDelegate
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    if (result == MessageComposeResultSent) {
        [controller dismissViewControllerAnimated:YES completion:nil];
        [ASHUD showHUDWithCompleteStyleInView:self.view content:@"短信发送成功" icon:nil];
    }else{
        [controller dismissViewControllerAnimated:YES completion:nil];
        [ASHUD showHUDWithCompleteStyleInView:self.view content:@"短信发送失败" icon:nil];
    }
    
}

#pragma mark - monitor the network status
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"_netType"]){
        NSInteger type = [[change valueForKey:NSKeyValueChangeNewKey] integerValue];
        NSLog(@"observeValueForKeyPath:%ld",(long)type);
        dispatch_async(dispatch_get_main_queue(), ^{
            if (type!=NoNet) {
                if ([[ServerVisit shead].authorization isEqualToString:@""]) {
                    [self deviceInit];
                }else{
                    AppDelegate *apple = [RoomApp shead].appDelgate;
                    UIView *initView = [apple.window.rootViewController.view viewWithTag:400];
                    if (initView) {
                        [self getData];
                    }else{
                        if (self.netAlertView) {
                            [self.netAlertView dismiss];
                            self.netAlertView = nil;
                        }
                    }
                }
            }else{
                if (!self.netAlertView) {
                    self.netAlertView = [[RoomAlertView alloc] initType:AlertViewNotNetType];
                    [self.netAlertView show];
                }
                
            }
        });
        
    }
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if (ISIPAD) {
        return (interfaceOrientation == UIInterfaceOrientationPortrait||interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight);
    }else{
        return (interfaceOrientation == UIInterfaceOrientationPortrait);
    }
    
}

- (BOOL)shouldAutorotate
{
    if (ISIPAD) {
        return YES;
    }else{
        return NO;
    }
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    if (ISIPAD) {
        return  (UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight);
    }else{
        return UIInterfaceOrientationMaskPortrait;
    }
    
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
