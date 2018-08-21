//
//  ExperienceCell.m
//  GoShadow
//
//  Created by Shawn Wall on 8/24/15.
//  Copyright (c) 2015 Inquiri. All rights reserved.
//

#import "ExperienceCell.h"
#import "GoShadowModels.h"
#import "GoShadowAPIManager.h"
#import "TimerManager.h"
#import "AppDelegate.h"

@implementation ExperienceCell

- (void)awakeFromNib {
    // Initialization code
    self.textLabel.textColor = [UIColor gsDarkBlueColor];
    self.textLabel.font = [UIFont boldSystemFontOfSize:17.0];
    self.detailTextLabel.textColor = [UIColor grayColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)publish:(id)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"​Publish Your Care Experience", nil) message:NSLocalizedString(@"You can view, but no longer edit, published Care Experiences.", nil) preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Publish", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        RLMRealm *realm = [RLMRealm defaultRealm];
        Experience *experience = [Experience objectForPrimaryKey:@(self.experienceId)];
        if (experience) {
            // stop timers related to this experience
            for (Segment *segment in experience.segments) {
                for (Note *note in segment.notes) {
                    if (note.isTimer && [[TimerManager sharedManager] isRunning:note]) {
                        [[TimerManager sharedManager] stopTimer:note];
                    }
                }
            }
            if (!realm.inWriteTransaction) {
                [realm beginWriteTransaction];
            }
            experience.isPublished = true;
            [realm commitWriteTransaction];
            [[GoShadowAPIManager sharedManager] putExperience:experience withCallback:^(id result, NSError *error) {
                
            }];
        }
    }]];
    AppDelegate *appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [appDelegate.window.rootViewController presentViewController:alert animated:true completion:nil];
}

@end
