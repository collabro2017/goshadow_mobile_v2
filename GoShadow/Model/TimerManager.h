//
//  TimerManager.h
//  GoShadow
//
//  Created by Shawn Wall on 8/7/15.
//  Copyright (c) 2015 Inquiri. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Note;

@interface TimerManager : NSObject

+(instancetype)sharedManager;
-(void)startTimer:(Note*)timer;
/**
 Used to update the internal non persistent version of a timer for example when you are updating the
 duration value of a running timer
 */
-(void)updateTimer:(Note*)timer;
-(void)stopTimer:(Note*)timer;
/**
 Used to remove this timer from the internal managed state. The core purpose of this
 is to be used when deleting a timer from the server.
 */
-(void)deleteTimer:(Note*)timer;
-(void)wakeUp;
-(void)sleep;
-(BOOL)isRunning:(Note*)timer;
-(NSInteger)accumulatedSecondsForTimer:(Note*)timer;

@end
