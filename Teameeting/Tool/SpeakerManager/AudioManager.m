//
//  AudioManager.m
//  Teameeting
//
//  Created by jianqiangzhang on 16/2/29.
//  Copyright © 2016年 zjq. All rights reserved.
//

#import "AudioManager.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

@implementation AudioManager

- (void)openOrCloseProximityMonitorEnable:(BOOL)isOpen
{
    if (isOpen) {
        [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];
    }else{
        [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
    }
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceProximityStateDidChangeNotification object:nil];
}
- (id)init
{
    self = [super init];
    if (self) {
        NSError *error;
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        [audioSession overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:&error];
        if(error)
        {
            NSLog(@"AvcAudioRouteMgr: AudioSession cannot use speakers");
        }
        //默认情况下扬声器播放
        [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
        [audioSession setActive:YES error:nil];
        //红外线感应监听
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(sensorStateChange:)
                                                     name:UIDeviceProximityStateDidChangeNotification
                                                   object:nil];
      
        
    }
    return self;
}
- (void)setSpeakerOn
{
    if ([self HasHeadsetMic]) {
        return;
    }
    NSError *error;
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:&error];
    if(error)
    {
        NSLog(@"AvcAudioRouteMgr: AudioSession cannot use speakers");
    }
    
}

- (BOOL)HasHeadsetMic
{
    AVAudioSession *session = [AVAudioSession sharedInstance];
    // Input
    AVAudioSessionPortDescription *input = [[session.currentRoute.inputs count] ? session.currentRoute.inputs:nil objectAtIndex:0];
    NSLog(@"%@",input.portType);
    if ([input.portType isEqualToString:AVAudioSessionPortHeadsetMic]) {
        return YES;
    }
    return NO;
}

//处理监听触发事件
-(void)sensorStateChange:(NSNotificationCenter *)notification;
{
    if ([[UIDevice currentDevice] proximityState] == YES){
        NSLog(@"Device is close to user");
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    }
    else{
        NSLog(@"Device is not close to user");
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    }
}


@end
