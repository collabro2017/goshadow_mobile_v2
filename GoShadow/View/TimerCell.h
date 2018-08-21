//
//  TimerCell.h
//  GoShadow
//
//  Created by Shawn Wall on 8/19/15.
//  Copyright (c) 2015 Inquiri. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Note;

@interface TimerCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *iconImage;
@property (weak, nonatomic) IBOutlet UILabel *headerLabel;
@property (weak, nonatomic) IBOutlet UILabel *timerLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateTimeLabel;
@property (weak, nonatomic) IBOutlet UIButton *startStopButton;
@property (strong, nonatomic) Note *timer;

@end
