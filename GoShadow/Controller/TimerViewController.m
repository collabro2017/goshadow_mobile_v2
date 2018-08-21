//
//  TimerViewController.m
//  GoShadow
//
//  Created by Shawn Wall on 8/6/15.
//  Copyright (c) 2015 Inquiri. All rights reserved.
//

#import "TimerViewController.h"
#import "GoShadowModels.h"
#import "GoShadowAPIManager.h"
#import "TimerManager.h"
#import "TTUIButton.h"

@interface TimerViewController ()

@property (strong, nonatomic) Caregiver *caregiver;
@property (strong, nonatomic) Touchpoint *touchpoint;
@property (strong, nonatomic) UIDatePicker *startDatePicker;
@property (strong, nonatomic) UIDatePicker *durationPicker;
@property (strong, nonatomic) UIToolbar *startDateToolbar;
@property (strong, nonatomic) UIToolbar *durationToolbar;

@end

@implementation TimerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.startDateToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 44.0)];
    [self.startDateToolbar setItems:@[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil], [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(selectStartDate:)]]];
    
    self.durationToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 44.0)];
    [self.durationToolbar setItems:@[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil], [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(selectDuration:)]]];
    
    self.startDatePicker = [[UIDatePicker alloc] init];
    self.durationPicker = [[UIDatePicker alloc] init];
    self.startDatePicker.datePickerMode = UIDatePickerModeTime;
    self.durationPicker.datePickerMode = UIDatePickerModeCountDownTimer;
    self.startTimeText.inputView = self.startDatePicker;
    self.durationText.inputView = self.durationPicker;
    [self.startDatePicker addTarget:self action:@selector(startDateChanged:) forControlEvents:UIControlEventValueChanged];
    [self.durationPicker addTarget:self action:@selector(durationChanged:) forControlEvents:UIControlEventValueChanged];
    self.startTimeText.inputAccessoryView = self.startDateToolbar;
    self.durationText.inputAccessoryView = self.durationToolbar;
    
    if (!self.note) {
        self.startDatePicker.date = [NSDate date];
        self.startTimeText.text = [self.startDatePicker.date mt_stringValueWithDateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterShortStyle];
        self.durationPicker.countDownDuration = 0;
    }
    else {
        if (self.note.caregiver) {
            self.caregiver = self.note.caregiver;
            self.valueText.text = self.note.caregiver.name;
        }
        else if (self.note.touchpoint) {
            self.touchpoint = self.note.touchpoint;
            self.valueText.text = self.note.touchpoint.name;
        }
        if (self.note.createdAt) {
            self.startDatePicker.date = self.note.createdAt;
            self.startTimeText.text = [self.startDatePicker.date mt_stringValueWithDateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterShortStyle];
        }
        if (self.note.accumulatedTime > 0) {
            if ([[TimerManager sharedManager] isRunning:self.note]) {
                NSInteger accumulatedSeconds = [[TimerManager sharedManager] accumulatedSecondsForTimer:self.note];
                self.durationPicker.countDownDuration = accumulatedSeconds;
            }
            else {
                self.durationPicker.countDownDuration = self.note.accumulatedTime;
            }

            NSDateComponentsFormatter *dateComponentsFormatter = [[NSDateComponentsFormatter alloc] init];
            dateComponentsFormatter.zeroFormattingBehavior = NSDateComponentsFormatterZeroFormattingBehaviorPad;
            dateComponentsFormatter.allowedUnits = (NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond);
            self.durationText.text = [dateComponentsFormatter stringFromTimeInterval:self.note.accumulatedTime];
        }

    }
    self.valueText.delegate = self;
    if (self.mode == TimerModeAddCaregiver) {
        if (self.note) {
            self.title = NSLocalizedString(@"Edit Care Giver", nil);
        }
        else {
            self.title = NSLocalizedString(@"Add Care Giver", nil);
        }
        self.typeLabel.text = NSLocalizedString(@"Select Care Giver", nil);
//        self.valueText.placeholder = NSLocalizedString(@"", @"Placeholder");
    }
    else if (self.mode == TimerModeAddTouchpoint) {
        if (self.note) {
            self.title = NSLocalizedString(@"Edit Touchpoint", nil);
        }
        else {
            self.title = NSLocalizedString(@"Add Touchpoint", nil);
        }
        self.typeLabel.text = NSLocalizedString(@"Select Touchpoint", nil);
//        self.valueText.placeholder = NSLocalizedString(@"", @"Placeholder");
    }
    [self.startButton setTitle:NSLocalizedString(@"Start Timer", nil) forState:UIControlStateNormal];
    [self.saveButton setTitle:NSLocalizedString(@"Save Timer", nil) forState:UIControlStateNormal];
    [self.titleLabels makeObjectsPerformSelector:@selector(setFont:) withObject:[UIFont systemFontOfSize:14.0]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)validateStart {
    if (self.caregiver == nil && self.mode == TimerModeAddCaregiver) {
        UIAlertController *error = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Required Field", nil) message:NSLocalizedString(@"Please select a care giver", nil) actions:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:nil],nil];
        [self presentViewController:error animated:YES completion:nil];
        return false;
    }
    if (self.touchpoint == nil && self.mode == TimerModeAddTouchpoint) {
        UIAlertController *error = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Required Field", nil) message:NSLocalizedString(@"Please select a touchpoint", nil) actions:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:nil],nil];
        [self presentViewController:error animated:YES completion:nil];
        return false;
    }
    return true;
}

-(BOOL)validateSave {
    if ([self validateStart]) {
        NSDate *date = self.startDatePicker.date;
        if (self.durationText.text.length <= 0) {
            UIAlertController *error = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Required Field", nil) message:NSLocalizedString(@"Please select a duration", nil) actions:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:nil],nil];
            [self presentViewController:error animated:YES completion:nil];
            return false;
        }
        if (self.durationText.text.length) {
            if ([[date mt_dateByAddingYears:0 months:0 weeks:0 days:0 hours:0 minutes:0 seconds:self.durationPicker.countDownDuration] mt_isAfter:[NSDate date]]) {
                UIAlertController *error = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Oops, you're scheduling into the future!", nil) message:NSLocalizedString(@"Adding that duration to that start time will schedule into the future. Push your start time back, or shorten your duration.", nil) actions:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:nil],nil];
                [self presentViewController:error animated:YES completion:nil];
                return false;
            }
        }
    }
    return true;
}

- (void)createOrUpdateNote {
    if (!self.note) {
        self.note = [[Note alloc] init];
    }
    else {
        RLMRealm *defaultRealm = [RLMRealm defaultRealm];
        [defaultRealm beginWriteTransaction];
    }
    if (self.caregiver) {
        self.note.caregiver = self.caregiver;
        self.note.caregiverId = self.caregiver.caregiverId;
    }
    if (self.touchpoint) {
        self.note.touchpoint = self.touchpoint;
        self.note.touchpointId = self.touchpoint.touchpointId;
    }
    
    self.note.segmentId = self.segment.segmentId;
    self.note.updatedAt = [NSDate date];
    if ([[GoShadowAPIManager sharedManager] getCurrentUser]) {
        self.note.userId = [[GoShadowAPIManager sharedManager] getCurrentUser].userId;
    }
    
    #warning is this right?
    self.note.categoryId = NoteCategoryGeneral;
}

- (IBAction)save:(id)sender {
    if ([self validateSave]) {

        [self createOrUpdateNote];
        
        if (self.note.noteId == 0) {
            self.note.startDate = [NSDate defaultDate];
            self.note.createdAt = self.startDatePicker.date;
            self.note.updatedAt = [NSDate date];
            //handler for 'have they selected a duration'
            if (self.durationText.text.length) {
                self.note.accumulatedTime = self.durationPicker.countDownDuration;
            }
            else {
                self.note.accumulatedTime = 0;
            }
            
            [[GoShadowAPIManager sharedManager] postNote:self.note withCallback:^(id result, NSError *error) {
                if (!error) {
                    [self.navigationController popViewControllerAnimated:true];
                }
                else {
                    UIAlertController *error = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"An error occurred, please check your internet connection and try again", nil) actions:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:nil],nil];
                    [self presentViewController:error animated:YES completion:nil];
                }
            }];
        }
        else {
            self.note.startDate = [NSDate defaultDate];
            self.note.createdAt = self.startDatePicker.date;
            self.note.updatedAt = [NSDate date];
            if (self.durationText.text.length) {
                self.note.accumulatedTime = self.durationPicker.countDownDuration;
            }
//            self.note.createdAt = self.startDatePicker.date;
            [[TimerManager sharedManager] updateTimer:self.note];
            [[GoShadowAPIManager sharedManager] putNote:self.note withCallback:^(id result, NSError *error) {
                if (!error) {
                    [self.navigationController popViewControllerAnimated:true];
                }
                else {
                    UIAlertController *error = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"An error occurred, please check your internet connection and try again", nil) actions:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:nil],nil];
                    [self presentViewController:error animated:YES completion:nil];
                }
            }];
        }
    }
}

- (IBAction)startTimer:(id)sender {
    if ([self validateStart]) {
        [self createOrUpdateNote];
        
        if (self.note.noteId == 0) {
            self.note.startDate = [NSDate date];
            self.note.createdAt = [NSDate date];
            self.note.accumulatedTime = 0;
            
            [[GoShadowAPIManager sharedManager] postNote:self.note withCallback:^(id result, NSError *error) {
                if (!error) {
                    [self.navigationController popViewControllerAnimated:true];
                }
                else {
                    UIAlertController *error = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"An error occurred, please check your internet connection and try again", nil) actions:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:nil],nil];
                    [self presentViewController:error animated:YES completion:nil];
                }
            }];
        }
        else {
            self.note.startDate = [NSDate date];
            [[TimerManager sharedManager] updateTimer:self.note];
            [[GoShadowAPIManager sharedManager] putNote:self.note withCallback:^(id result, NSError *error) {
                if (!error) {
                    [self.navigationController popViewControllerAnimated:true];
                }
                else {
                    UIAlertController *error = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"An error occurred, please check your internet connection and try again", nil) actions:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:nil],nil];
                    [self presentViewController:error animated:YES completion:nil];
                }
            }];
        }
    }
}

-(void)selectStartDate:(id)sender {
    [self.startTimeText resignFirstResponder];
}

-(void)selectDuration:(id)sender {
    [self.durationText resignFirstResponder];
    NSDateComponentsFormatter *dateComponentsFormatter = [[NSDateComponentsFormatter alloc] init];
    dateComponentsFormatter.zeroFormattingBehavior = NSDateComponentsFormatterZeroFormattingBehaviorPad;
    dateComponentsFormatter.allowedUnits = (NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond);
    
    self.durationText.text = [dateComponentsFormatter stringFromTimeInterval:self.durationPicker.countDownDuration];
}

-(void)startDateChanged:(id)sender {
    self.startTimeText.text = [self.startDatePicker.date mt_stringValueWithDateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterShortStyle];
}

-(void)durationChanged:(id)sender {
//    NSDateComponentsFormatter *dateComponentsFormatter = [[NSDateComponentsFormatter alloc] init];
//    dateComponentsFormatter.zeroFormattingBehavior = NSDateComponentsFormatterZeroFormattingBehaviorPad;
//    dateComponentsFormatter.allowedUnits = (NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond);
//    
//    self.durationText.text = [dateComponentsFormatter stringFromTimeInterval:self.durationPicker.countDownDuration];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (self.mode == TimerModeAddCaregiver) {
        [self performSegueWithIdentifier:@"CaregiverSegue" sender:nil];
    }
    else if (self.mode == TimerModeAddTouchpoint) {
        [self performSegueWithIdentifier:@"TouchpointSegue" sender:nil];
    }
    return NO;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to dof a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"CaregiverSegue"]) {
        CaregiverListViewController *vc = segue.destinationViewController;
        vc.delegate = self;
        vc.segmentId = self.segment.segmentId;
    }
    else if ([segue.identifier isEqualToString:@"TouchpointSegue"]) {
        TouchpointListViewController *vc = segue.destinationViewController;
        vc.delegate = self;
        vc.segmentId = self.segment.segmentId;        
    }
}

-(void)caregiverListViewController:(CaregiverListViewController*)viewController didSelectCaregiver:(Caregiver*)caregiver {
    self.caregiver = caregiver;
    self.valueText.text = self.caregiver.name;
}

-(void)touchpointListViewController:(TouchpointListViewController *)viewController didSelectTouchpoint:(Touchpoint *)touchpoint {
    self.touchpoint = touchpoint;
    self.valueText.text = self.touchpoint.name;
}

@end
