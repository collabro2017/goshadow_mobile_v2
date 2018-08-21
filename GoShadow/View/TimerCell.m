//
//  TimerCell.m
//  GoShadow
//
//  Created by Shawn Wall on 8/19/15.
//  Copyright (c) 2015 Inquiri. All rights reserved.
//

#import "TimerCell.h"
#import "TimerManager.h"
#import "GoShadowModels.h"

@implementation TimerCell

- (void)awakeFromNib {
    // Initialization code
    self.headerLabel.textColor = [UIColor whiteColor];
    self.timerLabel.textColor = [UIColor whiteColor];
    self.dateTimeLabel.textColor = [UIColor gsLightCyanColor];
    [self.startStopButton addTarget:self action:@selector(startStop:) forControlEvents:UIControlEventTouchUpInside];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(timerIncrement:) name:@"GoShadowTimerIncrement" object:nil];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

-(void)timerIncrement:(id)sender {
    NSDateComponentsFormatter *dateComponentsFormatter = [[NSDateComponentsFormatter alloc] init];
    dateComponentsFormatter.zeroFormattingBehavior = NSDateComponentsFormatterZeroFormattingBehaviorPad;
    dateComponentsFormatter.allowedUnits = (NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond);
    if (![self.timer isInvalidated]) {
        self.timerLabel.text = [dateComponentsFormatter stringFromTimeInterval:[[TimerManager sharedManager] accumulatedSecondsForTimer:self.timer]];
    }
}

-(void)startStop:(id)sender {
    if (self.timer != nil) {
        if ([[TimerManager sharedManager] isRunning:self.timer]) {
            [[TimerManager sharedManager] stopTimer:self.timer];
        }
        else {
            [[TimerManager sharedManager] startTimer:self.timer];
        }
        [self setNeedsLayout];
    }
}

-(void)setTimer:(Note *)timer {
    _timer = timer;
    self.dateTimeLabel.text = [timer.createdAt mt_stringValueWithDateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterShortStyle];
    NSDateComponentsFormatter *dateComponentsFormatter = [[NSDateComponentsFormatter alloc] init];
    dateComponentsFormatter.zeroFormattingBehavior = NSDateComponentsFormatterZeroFormattingBehaviorPad;
    dateComponentsFormatter.allowedUnits = (NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond);
    self.timerLabel.text = [dateComponentsFormatter stringFromTimeInterval:[[TimerManager sharedManager] accumulatedSecondsForTimer:self.timer]];
    [self setNeedsLayout];
}

-(void)layoutSubviews {
    [super layoutSubviews];
    if (self.timer != nil && ![self.timer isInvalidated]) {
        if (self.timer.caregiver) {
            self.headerLabel.text = self.timer.caregiver.name;
            self.contentView.backgroundColor = [UIColor gsLightBlueColor];
            self.iconImage.image = [UIImage imageNamed:@"icon_caregiver_white"];
        }
        else if (self.timer.touchpoint) {
            self.headerLabel.text = self.timer.touchpoint.name;
            self.contentView.backgroundColor = [UIColor gsMidGreenColor];
            self.iconImage.image = [UIImage imageNamed:@"icon_touchpoint_white"];
        }
        if ([[TimerManager sharedManager] isRunning:self.timer]) {
            [self.startStopButton setImage:[UIImage imageNamed:@"icon_pause"] forState:UIControlStateNormal];
        }
        else {
            [self.startStopButton setImage:[UIImage imageNamed:@"icon_play"] forState:UIControlStateNormal];
        }
    }
}

@end
