//
//  VideoShowItem.h
//  Teameeting
//
//  Created by zjq on 16/1/20.
//  Copyright © 2016年 zjq. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VideoShowItem : NSObject

@property (nonatomic,strong) UIView *showVideoView;

@property (nonatomic, strong) NSString *publishID;

@property (nonatomic)CGSize videoSize; // reality video Size

@property (nonatomic, strong) NSString *selectedTag;

- (void)setVideoHidden:(BOOL)isVideoHidden;
- (void)setAudioClose:(BOOL)isAudioClose;

- (void)setFullScreen:(BOOL)isFull;

@end
