//
//  TimerViewController.h
//  GoShadow
//
//  Created by Shawn Wall on 8/6/15.
//  Copyright (c) 2015 Inquiri. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CaregiverListViewController.h"
#import "TouchpointListViewController.h"
@class Segment;
@class Note;
@class TTUIButton;

typedef NS_ENUM(NSInteger, TimerMode) {
    TimerModeAddCaregiver,
    TimerModeAddTouchpoint
};

@interface TimerViewController : UITableViewController <UITextFieldDelegate, CaregiverListDelegate, TouchpointListDelegate>

@property (nonatomic) TimerMode mode;
@property (strong, nonatomic) Segment *segment;
@property (strong, nonatomic) Note *note;
@property (weak, nonatomic) IBOutlet UILabel *typeLabel;
@property (weak, nonatomic) IBOutlet UITextField *valueText;
@property (weak, nonatomic) IBOutlet UILabel *startTimeLabel;
@property (weak, nonatomic) IBOutlet UITextField *startTimeText;
@property (weak, nonatomic) IBOutlet UILabel *durationLabel;
@property (weak, nonatomic) IBOutlet UITextField *durationText;
@property (weak, nonatomic) IBOutlet TTUIButton *saveButton;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *titleLabels;
@property (weak, nonatomic) IBOutlet TTUIButton *startButton;

- (IBAction)save:(id)sender;
- (IBAction)startTimer:(id)sender;

@end
