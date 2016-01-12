//
//  RootViewController.m
//  UUChatTableView
//
//  Created by shake on 15/1/4.
//  Copyright (c) 2015年 uyiuyao. All rights reserved.
//

#import "RootViewController.h"
#import "UUInputFunctionView.h"
#import "MJRefresh.h"
#import "UUMessageCell.h"
#import "ChatModel.h"
#import "UUMessageFrame.h"
#import "UUMessage.h"
#import "TMMessageManage.h"
@interface RootViewController ()<UUInputFunctionViewDelegate,UUMessageCellDelegate,UITableViewDataSource,UITableViewDelegate,tmMessageReceive>

//@property (strong, nonatomic) MJRefreshHeader *head;
@property (strong, nonatomic) ChatModel *chatModel;

@property (weak, nonatomic) IBOutlet UITableView *chatTableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;
@property (assign,nonatomic) BOOL isViewLoad;
@property (assign,nonatomic) BOOL receiveEnable;
@end

@implementation RootViewController{
    UUInputFunctionView *IFView;
}


- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    if (self.isViewLoad)
        return;
    self.isViewLoad = YES;
    self.receiveEnable = YES;
    [self addRefreshViews];
    [self loadBaseViewsAndData];
    [[TMMessageManage sharedManager] registerMessageListener:self];
    self.chatTableView.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.5];
    self.view.backgroundColor = [UIColor clearColor];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardChange:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardChange:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(tableViewScrollToBottom) name:UIKeyboardDidShowNotification object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (void)initBar
{
    UISegmentedControl *segment = [[UISegmentedControl alloc]initWithItems:@[@" private ",@" group "]];
    [segment addTarget:self action:@selector(segmentChanged:) forControlEvents:UIControlEventValueChanged];
    segment.selectedSegmentIndex = 0;
    self.navigationItem.titleView = segment;
    
    self.navigationController.navigationBar.tintColor = [UIColor grayColor];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemOrganize target:nil action:nil];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:nil];
}

- (void)messageDidReceiveWithContent:(NSString *)content messageTime:(NSString *)time {
    
    NSDictionary *dic = @{@"strContent": content,
                          @"type": @(UUMessageTypeText)};
    [self.chatModel addOtherItem:dic];
    [self.chatTableView reloadData];
    [self performSelector:@selector(tableViewScrollToBottom) withObject:nil afterDelay:0.3];
}

- (BOOL)receiveMessageEnable {
    
    return self.receiveEnable;
}

- (void)setReceiveMessageEnable:(BOOL)enable {
    
    self.receiveEnable = enable;
}

- (void)segmentChanged:(UISegmentedControl *)segment
{
    self.chatModel.isGroupChat = segment.selectedSegmentIndex;
    [self.chatModel.dataSource removeAllObjects];
    [self.chatModel populateRandomDataSource];
    [self.chatTableView reloadData];
}

- (void)addRefreshViews
{

    __weak typeof(self) weakSelf = self;
    self.chatTableView.header= [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        
        [weakSelf.chatTableView.header endRefreshing];
        
    }];
}

- (void)loadBaseViewsAndData
{
    self.chatModel = [[ChatModel alloc]init];
    self.chatModel.isGroupChat = NO;
    
    IFView = [[UUInputFunctionView alloc]initWithSuperVC:self];
    IFView.delegate = self;
    [self.view addSubview:IFView];
    
    [self.chatTableView reloadData];
    [self tableViewScrollToBottom];
}

- (void)resginKeyBord {
    
    [IFView.TextViewInput setText:@""];
    [IFView.TextViewInput resignFirstResponder];
    
}

- (void)hidenInput {
    
    [IFView removeFromSuperview];
}

- (void)resetInputFrame:(CGRect)rect {
    
    [IFView removeFromSuperview];
    IFView = [[UUInputFunctionView alloc]initWithSuperVC:self];
    IFView.delegate = self;
    [self.view addSubview:IFView];
    
    NSArray *visible = [self.chatTableView visibleCells];
    NSMutableArray *indexPaths = [NSMutableArray array];
    for (UITableViewCell *cell in visible) {
        
        NSIndexPath *path = [self.chatTableView  indexPathForCell:cell];
        [indexPaths addObject:path];
    }
    [self.chatTableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
}

-(void)keyboardChange:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    CGRect keyboardEndFrame;
    
    [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardEndFrame];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:animationCurve];
    
    UIViewController *parenetView = (UIViewController *)self.parentViewCon;
    BOOL isVertical = YES;
    NSUInteger width = parenetView.view.bounds.size.width;
    NSUInteger height = parenetView.view.bounds.size.height;
    isVertical = width > height ? NO : YES;
    
    //adjust ChatTableView's height
    if (notification.name == UIKeyboardWillShowNotification) {
        
        float keyBordHeight = keyboardEndFrame.size.width > keyboardEndFrame.size.height ? keyboardEndFrame.size.height : keyboardEndFrame.size.width;
        [IFView setFrame:CGRectMake(0, parenetView.view.bounds.size.height - keyBordHeight - 40, IFView.bounds.size.width, IFView.bounds.size.height)];
        [self.bottomConstraint setConstant:keyBordHeight + 40];
        [self.view layoutIfNeeded];
        
    } else if (notification.name == UIKeyboardWillHideNotification){
        
        [IFView setFrame:CGRectMake(0, parenetView.view.bounds.size.height - 40, IFView.bounds.size.width, IFView.bounds.size.height)];
        [self.view layoutIfNeeded];
        [self.bottomConstraint setConstant:40];
    }
    [UIView commitAnimations];
}

//tableView Scroll to bottom
- (void)tableViewScrollToBottom
{
    
    if (self.chatModel.dataSource.count==0)
        return;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.chatModel.dataSource.count-1 inSection:0];
    [self.chatTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}


#pragma mark - InputFunctionViewDelegate
- (void)UUInputFunctionView:(UUInputFunctionView *)funcView sendMessage:(NSString *)message
{
    NSDictionary *dic = @{@"strContent": message,
                          @"type": @(UUMessageTypeText)};
    funcView.TextViewInput.text = @"";
    [funcView changeSendBtnWithPhoto:YES];
    [self dealTheFunctionData:dic];
    [[TMMessageManage sharedManager] sendMsgUserid:nil pass:nil roomid:@"123" msg:message];
}

- (void)UUInputFunctionView:(UUInputFunctionView *)funcView sendPicture:(UIImage *)image
{
    NSDictionary *dic = @{@"picture": image,
                          @"type": @(UUMessageTypePicture)};
    [self dealTheFunctionData:dic];
}

- (void)UUInputFunctionView:(UUInputFunctionView *)funcView sendVoice:(NSData *)voice time:(NSInteger)second
{
    NSDictionary *dic = @{@"voice": voice,
                          @"strVoiceTime": [NSString stringWithFormat:@"%d",(int)second],
                          @"type": @(UUMessageTypeVoice)};
    [self dealTheFunctionData:dic];
}

- (void)dealTheFunctionData:(NSDictionary *)dic
{
    [self.chatModel addMySeleItem:dic];
    [self.chatTableView reloadData];
    [self performSelector:@selector(tableViewScrollToBottom) withObject:nil afterDelay:0.3];
}

#pragma mark - tableView delegate & datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.chatModel.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UUMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellID"];
    if (cell == nil) {
        cell = [[UUMessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CellID"];
        cell.delegate = self;
        cell.backgroundColor = [UIColor clearColor];
    }
    [cell setMessageFrame:self.chatModel.dataSource[indexPath.row] isVertical:[self.parentViewCon isVertical]];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [self.chatModel.dataSource[indexPath.row] cellHeight];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.view endEditing:YES];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self.view endEditing:YES];
}

#pragma mark - cellDelegate
- (void)headImageDidClick:(UUMessageCell *)cell userId:(NSString *)userId{
    // headIamgeIcon is clicked
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:cell.messageFrame.message.strName message:@"headImage clicked" delegate:nil cancelButtonTitle:@"sure" otherButtonTitles:nil];
    [alert show];
}

@end
