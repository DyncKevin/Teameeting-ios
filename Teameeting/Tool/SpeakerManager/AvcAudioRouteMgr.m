//
//  AvcAudioRouteMgr.m
//  DBing
//
//  Created by Tao Eric on 12-12-13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "AvcAudioRouteMgr.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

@interface AvcAudioRouteMgr()
- (BOOL)hasMicphone;
- (void)resetOutputTarget;
@end

@implementation AvcAudioRouteMgr

@synthesize _isSpeakerOn;
@synthesize delegate;

- (id) init 
{
    self = [super init];
    if (self) {
        _isSpeakerOn = NO;
        // Set audio propety.
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        NSError *audioSessionError;
        [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:&audioSessionError];
        
        [[AVAudioSession sharedInstance] setActive:YES error:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(routeChanged:)
                                                     name: AVAudioSessionRouteChangeNotification
                                                   object: nil];
        
    }
    
    return self;
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVAudioSessionRouteChangeNotification object:nil];
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
        _isSpeakerOn = NO;
    }
    
}

- (BOOL)HasHeadsetMic
{
    AVAudioSession *session = [AVAudioSession sharedInstance];
    // Input
    AVAudioSessionPortDescription *input = [[session.currentRoute.inputs count] ? session.currentRoute.inputs:nil objectAtIndex:0];
   
    if ([input.portType isEqualToString:AVAudioSessionPortHeadsetMic]) {
        _isSpeakerOn = NO;
        return YES;
    }
    return NO;
}
// 检测声音输入设备
- (BOOL)hasMicphone 
{ 
    return [AVAudioSession sharedInstance].inputAvailable;
}

- (void)resetOutputTarget 
{
    NSError *error;
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    NSInteger audioRouteOverride = _isSpeakerOn ? AVAudioSessionPortOverrideSpeaker:AVAudioSessionPortOverrideNone;
    [audioSession overrideOutputAudioPort:audioRouteOverride error:&error];
    if(error)
    {
        NSLog(@"AvcAudioRouteMgr: resetOutputTarget");
    }
} 

#pragma mark Route change listener
// *********************************************************************************************************
// *********** Route change listener ***********************************************************************
// *********************************************************************************************************
-(void)routeChanged:(NSNotification*)notification {
    
    NSLog(@"]-----------------[ Audio Route Change ]--------------------[");
    
    AVAudioSession *session = [AVAudioSession sharedInstance];
    // Reason
    NSInteger reason = [[[notification userInfo] objectForKey:AVAudioSessionRouteChangeReasonKey] integerValue];
    switch (reason) {
        case AVAudioSessionRouteChangeReasonNoSuitableRouteForCategory:
            NSLog(@"] Audio Route: The route changed because no suitable route is now available for the specified category.");
            break;
        case AVAudioSessionRouteChangeReasonWakeFromSleep:
            NSLog(@"] Audio Route: The route changed when the device woke up from sleep.");
            break;
        case AVAudioSessionRouteChangeReasonOverride:
            NSLog(@"] Audio Route: The output route was overridden by the app.");
            break;
        case AVAudioSessionRouteChangeReasonCategoryChange:
            NSLog(@"] Audio Route: The category of the session object changed.");
            break;
        case AVAudioSessionRouteChangeReasonOldDeviceUnavailable:
            NSLog(@"] Audio Route: The previous audio output path is no longer available.");
            break;
        case AVAudioSessionRouteChangeReasonNewDeviceAvailable:
            NSLog(@"] Audio Route: A preferred new audio output path is now available.");
            break;
        case AVAudioSessionRouteChangeReasonUnknown:
            NSLog(@"] Audio Route: The reason for the change is unknown.");
            break;
        default:
            NSLog(@"] Audio Route: The reason for the change is very unknown.");
            break;
    }
    
    // Output
    AVAudioSessionPortDescription *output = [[session.currentRoute.outputs count]?session.currentRoute.outputs:nil objectAtIndex:0];
    if ([output.portType isEqualToString:AVAudioSessionPortLineOut]) {
        NSLog(@"] Audio Route: Output Port: LineOut");
    }
    else if ([output.portType isEqualToString:AVAudioSessionPortHeadphones]) {
        NSLog(@"] Audio Route: Output Port: Headphones");
    }
    else if ([output.portType isEqualToString:AVAudioSessionPortBluetoothA2DP]) {
        NSLog(@"] Audio Route: Output Port: BluetoothA2DP");
    }
    else if ([output.portType isEqualToString:AVAudioSessionPortBuiltInReceiver]) {
        NSLog(@"] Audio Route: Output Port: BuiltInReceiver");
        // 打开扬声器
        [self setSpeakerOn];
    }
    else if ([output.portType isEqualToString:AVAudioSessionPortBuiltInSpeaker]) {
        NSLog(@"] Audio Route: Output Port: BuiltInSpeaker");
    }
    else if ([output.portType isEqualToString:AVAudioSessionPortHDMI]) {
        NSLog(@"] Audio Route: Output Port: HDMI");
    }
    else if ([output.portType isEqualToString:AVAudioSessionPortAirPlay]) {
        NSLog(@"] Audio Route: Output Port: AirPlay");
    }
    else if ([output.portType isEqualToString:AVAudioSessionPortBluetoothLE]) {
        NSLog(@"] Audio Route: Output Port: BluetoothLE");
    }
    else {
        NSLog(@"] Audio Route: Output Port: Unknown: %@",output.portType);
    }
    
    // Input
    AVAudioSessionPortDescription *input = [[session.currentRoute.inputs count] ? session.currentRoute.inputs:nil objectAtIndex:0];
    
    if ([input.portType isEqualToString:AVAudioSessionPortLineIn]) {
        NSLog(@"] Audio Route: Input Port: LineIn");
    }
    else if ([input.portType isEqualToString:AVAudioSessionPortBuiltInMic]) {
        NSLog(@"] Audio Route: Input Port: BuiltInMic");
    }
    else if ([input.portType isEqualToString:AVAudioSessionPortHeadsetMic]) {
        NSLog(@"] Audio Route: Input Port: HeadsetMic");
    }
    else if ([input.portType isEqualToString:AVAudioSessionPortBluetoothHFP]) {
        NSLog(@"] Audio Route: Input Port: BluetoothHFP");
    }
    else if ([input.portType isEqualToString:AVAudioSessionPortUSBAudio]) {
        NSLog(@"] Audio Route: Input Port: USBAudio");
    }
    else if ([input.portType isEqualToString:AVAudioSessionPortCarAudio]) {
        NSLog(@"] Audio Route: Input Port: CarAudio");
    }
    else {
        NSLog(@"] Audio Input Port: Unknown: %@",input.portType);
    }
    
    NSLog(@"]--------------------------[  ]-----------------------------[");
    
}

@end
