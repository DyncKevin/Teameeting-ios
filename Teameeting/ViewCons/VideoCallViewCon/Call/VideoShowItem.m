//
//  VideoShowItem.m
//  Teameeting
//
//  Created by zjq on 16/1/20.
//  Copyright © 2016年 zjq. All rights reserved.
//

#import "VideoShowItem.h"
@interface VideoShowItem()
@property (nonatomic, strong) UIImageView *micImageView;
@property (nonatomic, strong) UIView *videoHiddenView;
@property (nonatomic, strong) UIImageView *videoHiddenImageView;
@property (nonatomic, strong) NSLayoutConstraint * constraintTop;
@property (nonatomic, strong) NSLayoutConstraint * constraintRight;
@property (nonatomic, strong) NSLayoutConstraint * constraintWidth;
@property (nonatomic, strong) NSLayoutConstraint * constraintHeight;
@property (nonatomic, assign) BOOL isHiddenMic;
@property (nonatomic, assign) BOOL isHiddenVideo;
@property (nonatomic, assign) BOOL isFull;
@end
@implementation VideoShowItem
@synthesize micImageView = _micImageView;
@synthesize videoHiddenView = _videoHiddenView;
@synthesize videoHiddenImageView = _videoHiddenImageView;

- (id)init
{
    self = [super init];
    if (self) {
        self.isFull = YES;
    }
    return self;
}
- (void)dealloc
{
    if (_showVideoView) {
        [_showVideoView removeObserver:self forKeyPath:@"frame" context:nil];
    }
}
- (void)setSelectedTag:(NSString *)selectedTag
{
    _selectedTag = selectedTag;
}

- (void)setShowVideoView:(UIView *)showVideoView
{
    _showVideoView = showVideoView;
    
    [_showVideoView addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:nil];
    
    self.videoHiddenView = [UIView new];
    self.videoHiddenView.backgroundColor = [UIColor blackColor];
    [_showVideoView addSubview:self.videoHiddenView];
    _videoHiddenView.hidden = YES;
    
    self.videoHiddenImageView = [UIImageView new];
    self.videoHiddenImageView.backgroundColor = [UIColor redColor];
    self.videoHiddenImageView.image = [UIImage imageNamed:@""];
    [_videoHiddenView addSubview:self.videoHiddenImageView];
    
    self.micImageView = [UIImageView new];
    self.micImageView.backgroundColor = [UIColor blueColor];
    self.micImageView.image = [UIImage imageNamed:@"micState"];
    [_showVideoView addSubview:self.micImageView];
    self.micImageView.hidden = YES;
    
    self.videoHiddenView.translatesAutoresizingMaskIntoConstraints = NO;
    self.micImageView.translatesAutoresizingMaskIntoConstraints = NO;
    self.videoHiddenImageView.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSLayoutConstraint * consv = [NSLayoutConstraint constraintWithItem:_videoHiddenView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:_showVideoView attribute:NSLayoutAttributeWidth multiplier:1.0f constant:0.0f];
    
    NSLayoutConstraint * consv1 = [NSLayoutConstraint constraintWithItem:_videoHiddenView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:_showVideoView attribute:NSLayoutAttributeHeight multiplier:1.0f constant:0.0f];
    
    NSLayoutConstraint * consv2 = [NSLayoutConstraint constraintWithItem:_videoHiddenView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:_showVideoView attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0.0f];
    
    NSLayoutConstraint * consv3 = [NSLayoutConstraint constraintWithItem:_videoHiddenView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_showVideoView attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:0.0f];
    
    
    NSLayoutConstraint * cons = [NSLayoutConstraint constraintWithItem:_videoHiddenImageView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:_videoHiddenView attribute:NSLayoutAttributeWidth multiplier:0.3f constant:0.0f];
    
    NSLayoutConstraint * cons1 = [NSLayoutConstraint constraintWithItem:_videoHiddenImageView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:_videoHiddenView attribute:NSLayoutAttributeWidth multiplier:0.3f constant:0.0f];
    
    NSLayoutConstraint * cons2 = [NSLayoutConstraint constraintWithItem:_videoHiddenImageView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:_videoHiddenView attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0.0f];
    
    NSLayoutConstraint * cons3 = [NSLayoutConstraint constraintWithItem:_videoHiddenImageView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_videoHiddenView attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:0.0f];
    
    
    // mic
    self.constraintHeight = [NSLayoutConstraint constraintWithItem:_micImageView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:30.0f];
    
    self.constraintWidth = [NSLayoutConstraint constraintWithItem:_micImageView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:30.0f];
    
    self.constraintTop = [NSLayoutConstraint constraintWithItem:_micImageView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_showVideoView attribute:NSLayoutAttributeTop multiplier:1.0f constant:0.0f];
    
    self.constraintRight = [NSLayoutConstraint constraintWithItem:_micImageView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:_showVideoView attribute:NSLayoutAttributeRight multiplier:1.0f constant:0.0];
    
    [_showVideoView addConstraint:consv];
    [_showVideoView addConstraint:consv1];
    [_showVideoView addConstraint:consv2];
    [_showVideoView addConstraint:consv3];
    
    [_videoHiddenView addConstraint:cons];
    [_videoHiddenView addConstraint:cons1];
    [_videoHiddenView addConstraint:cons2];
    [_videoHiddenView addConstraint:cons3];
    
    
    [_showVideoView addConstraint:self.constraintWidth];
    [_showVideoView addConstraint:self.constraintHeight];
    [_showVideoView addConstraint:self.constraintTop];
    [_showVideoView addConstraint:self.constraintRight];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
     if ([keyPath isEqualToString:@"frame"]){
         if (_showVideoView) {
             if (_showVideoView.frame.size.width>[UIScreen mainScreen].bounds.size.width) {
                 [self.constraintRight setConstant:([UIScreen mainScreen].bounds.size.width-_showVideoView.frame.size.width)/2];
             }else{
                 [self.constraintRight setConstant:0.0f];
             }
             if (self.isFull) {
                 
                 if (_showVideoView.frame.size.height>[UIScreen mainScreen].bounds.size.height) {
                     [self.constraintTop setConstant:(_showVideoView.frame.size.height -[UIScreen mainScreen].bounds.size.height)/2];
                 }else{
                     [self.constraintTop setConstant:0.0f];
                 }
             }else{
                 
                 if (_showVideoView.frame.size.height>[UIScreen mainScreen].bounds.size.height) {
                     [self.constraintTop setConstant:(_showVideoView.frame.size.height -[UIScreen mainScreen].bounds.size.height)/2+64];
                 }else{
                     if (_showVideoView.superview.bounds.size.width>_showVideoView.superview.bounds.size.height) {
                          [self.constraintTop setConstant:(_showVideoView.frame.size.height -[UIScreen mainScreen].bounds.size.height)/2+64];
                     }else{
                          [self.constraintTop setConstant:64.0f];
                     }
                    
                 }
             }
             
             [_showVideoView layoutIfNeeded];
         }
     }
}

- (void)setVideoHidden:(BOOL)isVideoHidden
{
    self.isHiddenVideo = isVideoHidden;
    if (self.isHiddenVideo) {
        self.videoHiddenView.hidden = NO;
        [_showVideoView bringSubviewToFront:self.videoHiddenView];
        if (self.isHiddenMic) {
            [_showVideoView bringSubviewToFront:self.micImageView];
        }
    }else{
        self.videoHiddenView.hidden = YES;
    }
}

- (void)setAudioClose:(BOOL)isAudioClose
{
    NSLog(@"%f   %f   %f   %f ",_showVideoView.frame.origin.x, _showVideoView.frame.origin.y,_showVideoView.frame.size.width,_showVideoView.frame.size.height);
    
    self.isHiddenMic = isAudioClose;
    if (self.isHiddenMic) {
        self.micImageView.hidden = NO;
        [_showVideoView bringSubviewToFront:self.micImageView];
    }else{
        self.micImageView.hidden = YES;
    }
    if (_showVideoView.superview.bounds.size.height<200) {
        self.isFull = YES;
    }else{
        self.isFull = NO;
    }
    if (self.isFull) {
        if (_showVideoView.frame.size.height>[UIScreen mainScreen].bounds.size.height) {
            [self.constraintTop setConstant:(_showVideoView.frame.size.height -[UIScreen mainScreen].bounds.size.height)/2];
        }else{
            [self.constraintTop setConstant:0.0f];
        }
    }else{
        
       [self.constraintTop setConstant:(_showVideoView.frame.size.height -[UIScreen mainScreen].bounds.size.height)/2+64];
    }
    
    [_showVideoView layoutIfNeeded];
    
}

- (void)setFullScreen:(BOOL)isFull
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.isFull = isFull;
        if (isFull) {
            if (self.constraintTop) {
                NSLog(@"%f   %f  %f",_showVideoView.frame.size.height, [UIScreen mainScreen].bounds.size.height, self.constraintTop.constant);
                if (_showVideoView.frame.size.height+1>=[UIScreen mainScreen].bounds.size.height) {
                    if (self.constraintTop.constant>0) {
                        [self.constraintTop setConstant: (_showVideoView.frame.size.height -[UIScreen mainScreen].bounds.size.height)/2];
                    }else{
                        [self.constraintTop setConstant:self.constraintTop.constant + 64];
                    }
                    
                }else{
                    [self.constraintTop setConstant:0.0f];
                }
                [_showVideoView layoutIfNeeded];
            }
        }else{
             NSLog(@"%f   %f  %f",_showVideoView.frame.size.height, [UIScreen mainScreen].bounds.size.height, self.constraintTop.constant);
            
            if (_showVideoView.frame.size.height+1>[UIScreen mainScreen].bounds.size.height) {
                if (self.constraintTop.constant>0) {
                    if (_showVideoView.superview.bounds.size.width>_showVideoView.superview.bounds.size.height) {
                         [self.constraintTop setConstant:(_showVideoView.frame.size.height -[UIScreen mainScreen].bounds.size.height)/2 +64];
                    }else{
                         [self.constraintTop setConstant:64];
                    }
                   
                }else{
                    [self.constraintTop setConstant:(_showVideoView.frame.size.height -[UIScreen mainScreen].bounds.size.height)/2+64];

                }
                
            }else{
                [self.constraintTop setConstant:64.0f];
            }
            [_showVideoView layoutIfNeeded];
        
        }
    });
}

@end
