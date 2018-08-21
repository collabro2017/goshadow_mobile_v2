//
//  TimerManager.m
//  GoShadow
//
//  Created by Shawn Wall on 8/7/15.
//  Copyright (c) 2015 Inquiri. All rights reserved.
//

#import "TimerManager.h"
#import "Note+Extensions.h"
#import "GoShadowAPIManager.h"

@interface TimerManager ()

@property (strong, nonatomic) RLMResults *activeTimers;
@property (strong, nonatomic) NSTimer *timer;
@property (strong, nonatomic) NSMutableArray *timerValues;
@property (strong, nonatomic) NSMutableDictionary *timerToAccumulated;

@end

@implementation TimerManager

+(instancetype)sharedManager {
    static TimerManager *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[TimerManager alloc] init];
        _sharedManager.timerToAccumulated = [NSMutableDictionary new];
        [_sharedManager wakeUp];
    });
    
    return _sharedManager;
}

-(void)wakeUp {
    self.activeTimers = [Note objectsWhere:@"startDate != %@ and localStatus != %d", [NSDate defaultDate], NoteLocalStatusDelete];
    for (Note *timer in self.activeTimers) {
        NSInteger accumulated = [[NSDate date] timeIntervalSinceDate:timer.startDate] + timer.accumulatedTime;
        [self.timerToAccumulated setObject:@(accumulated) forKey:@(timer.noteId)];
    }
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                  target:self
                                                selector:@selector(increment)
                                                userInfo:nil
                                                 repeats:YES];
}

-(void)sleep {
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
}

-(void)increment {
    for (Note *timer in self.activeTimers) {
        NSInteger current = [self.timerToAccumulated[@(timer.noteId)] integerValue];
        [self.timerToAccumulated setObject:@(current+1) forKey:@(timer.noteId)];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"GoShadowTimerIncrement"
                                                            object:self
                                                          userInfo:@{@"NoteID" : @(timer.noteId)}];
    }
}

-(void)startTimer:(Note*)timer {
    //if the timer wasn't already started, start it
    if ([timer.startDate isEqual:[NSDate defaultDate]]) {
        RLMRealm *realm = [RLMRealm defaultRealm];
        if (!realm.inWriteTransaction) {
            [realm beginWriteTransaction];
        }
        timer.startDate = [NSDate date];
        [realm commitWriteTransaction];
        [realm beginWriteTransaction];
        timer.localStatus = NoteLocalStatusUpdate;
        [[GoShadowAPIManager sharedManager] putNote:timer withCallback:^(id result, NSError *error) {
            
        }];
        self.activeTimers = [Note objectsWhere:@"startDate != %@ and localStatus != %d", [NSDate defaultDate], NoteLocalStatusDelete];
        NSInteger accumulated = [[NSDate date] timeIntervalSinceDate:timer.startDate] + timer.accumulatedTime;
        [self.timerToAccumulated setObject:@(accumulated) forKey:@(timer.noteId)];
    }
}

-(void)updateTimer:(Note*)timer {
    if ([self isRunning:timer]) {
        [self.timerToAccumulated setObject:@(timer.accumulatedTime) forKey:@(timer.noteId)];
    }
}

-(void)deleteTimer:(Note *)timer {
    [self.timerToAccumulated removeObjectForKey:@(timer.noteId)];
    self.activeTimers = [Note objectsWhere:@"startDate != %@ and localStatus != %d", [NSDate defaultDate], NoteLocalStatusDelete];
}

-(void)stopTimer:(Note*)timer {
    //if the timer was already started, stop it
    if (![timer.startDate isEqual:[NSDate defaultDate]]) {
        RLMRealm *realm = [RLMRealm defaultRealm];
        if (!realm.inWriteTransaction) {
            [realm beginWriteTransaction];
        }
        timer.startDate = [NSDate defaultDate];
        timer.accumulatedTime = [self.timerToAccumulated[@(timer.noteId)] integerValue];
        [realm commitWriteTransaction];
        if (!realm.inWriteTransaction) {
            [realm beginWriteTransaction];
        }
        timer.localStatus = NoteLocalStatusUpdate;
        [[GoShadowAPIManager sharedManager] putNote:timer withCallback:^(id result, NSError *error) {
            
        }];
        self.activeTimers = [Note objectsWhere:@"startDate != %@ and localStatus != %d", [NSDate defaultDate], NoteLocalStatusDelete];
        [self.timerToAccumulated removeObjectForKey:@(timer.noteId)];
    }
}

-(BOOL)isRunning:(Note*)timer {
    return ([self.activeTimers indexOfObject:timer] != NSNotFound);
}

-(NSInteger)accumulatedSecondsForTimer:(Note*)timer {
    id value = self.timerToAccumulated[@(timer.noteId)];
    if (value) {
        return [value integerValue];
    }
    else {
        return timer.accumulatedTime;
    }
}

@end
