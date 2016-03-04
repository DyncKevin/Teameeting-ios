//
//  GuideViewController.m
//  Teameeting
//
//  Created by yangyang on 16/3/1.
//  Copyright © 2016年 zjq. All rights reserved.
//

#import "GuideViewController.h"

@interface GuideViewController ()<UIScrollViewDelegate>


@property(nonatomic,strong)UIScrollView *scrollview;
@property(nonatomic,strong)UIPageControl *pageControl;

@end

@implementation GuideViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.scrollview = [[UIScrollView alloc] init];
    self.scrollview.translatesAutoresizingMaskIntoConstraints = NO;
    self.scrollview.delegate = self;
    self.scrollview.backgroundColor = [UIColor groupTableViewBackgroundColor];
    [self.view addSubview:self.scrollview];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(10, self.view.frame.size.height - 30, self.view.frame.size.width - 20, 20)];
    self.pageControl.translatesAutoresizingMaskIntoConstraints = NO;
    self.pageControl.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.pageControl];
    
    NSArray *array = [NSArray arrayWithObjects:@"2X-img-59",@"2X-img-60",@"2X-img-61", nil];
    self.scrollview.bounces = YES;
    self.scrollview.pagingEnabled = YES;
    self.scrollview.showsHorizontalScrollIndicator = YES;
    self.scrollview.showsVerticalScrollIndicator = YES;

    NSLayoutConstraint* scrollViewLeftConstraint = [NSLayoutConstraint constraintWithItem:self.scrollview attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1.0f constant:0.f];
    NSLayoutConstraint* scrollViewRightConstraint = [NSLayoutConstraint constraintWithItem:self.scrollview attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1.0f constant:0.f];
    NSLayoutConstraint* scrollViewTopConstraint = [NSLayoutConstraint constraintWithItem:self.scrollview attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0f constant:0.f];
    NSLayoutConstraint* scrollViewHeightConstraint = [NSLayoutConstraint constraintWithItem:self.scrollview attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:1.0f constant:0.f];
    scrollViewLeftConstraint.active = YES;
    scrollViewRightConstraint.active = YES;
    scrollViewTopConstraint.active = YES;
    scrollViewHeightConstraint.active = YES;
    
    NSLayoutConstraint* pageControllerLeftConstraint = [NSLayoutConstraint constraintWithItem:self.pageControl attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0.f];
    NSLayoutConstraint* pageControllerTopConstraint = [NSLayoutConstraint constraintWithItem:self.pageControl attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0f constant:-20.f];
    pageControllerLeftConstraint.active = YES;
    pageControllerTopConstraint.active = YES;
    

    static UIImageView *tempImageView = nil;
    NSArray* tempvConstraintArray = nil;
    for (int i = 0; i < [array count]; i ++) {
        
        if (i != 0) {
            
            UIImageView *imageView = [[UIImageView alloc] init];
            [self.scrollview addSubview:imageView];
            imageView.translatesAutoresizingMaskIntoConstraints = NO;
            imageView.image = [UIImage imageNamed:[array objectAtIndex:i]];
            if (tempvConstraintArray) {
                
                [NSLayoutConstraint deactivateConstraints:tempvConstraintArray];
            }
            
            NSArray* vConstraintArray = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[imageView]-0-|" options:0 metrics:nil views:@{@"imageView": imageView}];
            [NSLayoutConstraint activateConstraints:vConstraintArray];
            
            
            NSArray* v2ConstraintArray = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[imageView]-0-|" options:0 metrics:nil views:@{@"imageView": imageView}];
            [NSLayoutConstraint activateConstraints:v2ConstraintArray];
            
            
            NSArray* v4ConstraintArray = [NSLayoutConstraint constraintsWithVisualFormat:@"[tempImageView]-0-[imageView]" options:0 metrics:nil views:@{@"imageView": imageView,@"tempImageView": tempImageView}];
            [NSLayoutConstraint activateConstraints:v4ConstraintArray];
            
            NSLayoutConstraint* imageViewWidthConstraint = [NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.scrollview attribute:NSLayoutAttributeWidth multiplier:1.0f constant:0.f];
            NSLayoutConstraint* imageViewHeightConstraint = [NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.scrollview attribute:NSLayoutAttributeHeight multiplier:1.0f constant:0.f];
            imageViewWidthConstraint.active = YES;
            imageViewHeightConstraint.active = YES;
            tempImageView = imageView;
            tempvConstraintArray = v2ConstraintArray;
        
        } else {
            
            UIImageView *imageView = [[UIImageView alloc] init];
            tempImageView = imageView;
            [self.scrollview addSubview:imageView];
            imageView.translatesAutoresizingMaskIntoConstraints = NO;
            imageView.image = [UIImage imageNamed:[array objectAtIndex:i]];
            
            
            NSArray* vConstraintArray = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[imageView]-0-|" options:0 metrics:nil views:@{@"imageView": imageView}];
            [NSLayoutConstraint activateConstraints:vConstraintArray];
            
            
            NSArray* v2ConstraintArray = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[imageView]" options:0 metrics:nil views:@{@"imageView": imageView}];
            [NSLayoutConstraint activateConstraints:v2ConstraintArray];
            
            NSLayoutConstraint* imageViewWidthConstraint = [NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.scrollview attribute:NSLayoutAttributeWidth multiplier:1.0f constant:0.f];
            NSLayoutConstraint* imageViewHeightConstraint = [NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.scrollview attribute:NSLayoutAttributeHeight multiplier:1.0f constant:0.f];
            imageViewWidthConstraint.active = YES;
            imageViewHeightConstraint.active = YES;
        }
        
    }
    self.pageControl.numberOfPages = [array count];
    self.pageControl.currentPage = 0;
}

- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView {
    
    return YES;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    if (![scrollView isMemberOfClass:[UITableView class]]) {
        
        int index = fabs(scrollView.contentOffset.x)/scrollView.frame.size.width;
        self.pageControl.currentPage = index;
    }
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    
}

- (BOOL)shouldAutorotate {
    
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
