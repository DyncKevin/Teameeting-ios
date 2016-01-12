//
//  M2MPublisher.h
//  anyrtc
//
//  Created by EricTao on 15/12/21.
//  Copyright © 2015年 EricTao. All rights reserved.
//

#ifndef M2MPublisher_h
#define M2MPublisher_h
#import <UIKit/UIKit.h>

// Subset of StreamType.
typedef NS_ENUM(NSInteger, StreamType) {
    kSTRtc,         //* AnyRTC的实时流
    kSTLive,        //* RTMP&HLS的直播流
    kSTBoth,        //* 以上二者均发布
};

@interface PublishParams : NSObject {
    
}

@property (nonatomic) BOOL enableVideo;
@property (nonatomic) BOOL enableRecord;
@property (nonatomic) StreamType streamType;

@end



#endif /* M2MPublisher_h */
