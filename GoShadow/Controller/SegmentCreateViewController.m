//
//  SegmentCreateViewController.m
//  GoShadow
//
//  Created by Shawn Wall on 7/29/15.
//  Copyright (c) 2015 Inquiri. All rights reserved.
//

#import "SegmentCreateViewController.h"
#import "GoShadowModels.h"
#import "GoShadowAPIManager.h"
#import "ShadowerListViewController.h"

@interface SegmentCreateViewController () <UITextFieldDelegate, ShadowerListDelegate>

@property (strong, nonatomic) NSArray *shadowers;

@end

@implementation SegmentCreateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"Create New Segment", nil);
    self.nameText.placeholder = NSLocalizedString(@"My Segment", nil);
    self.startText.placeholder = NSLocalizedString(@"Ex) Reception", nil);
    self.endText.placeholder = NSLocalizedString(@"Ex) When visitor is discharged", nil);
    self.facilityText.placeholder = NSLocalizedString(@"Ex) Exemplar Hospital", nil);
    self.shadowersText.placeholder = NSLocalizedString(@"Select Shadowers", nil);
    
    self.nameText.delegate = self;
    self.startText.delegate = self;
    self.endText.delegate = self;
    self.facilityText.delegate = self;
    self.shadowersText.delegate = self;
    self.shadowers = @[];
    [self.titleLabels makeObjectsPerformSelector:@selector(setFont:) withObject:[UIFont systemFontOfSize:14.0]];
    self.tableView.delaysContentTouches = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if ([textField isEqual:self.shadowersText]) {
        //push shadowers
        [self performSegueWithIdentifier:@"ShadowersSegue" sender:nil];
        return NO;
    }
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

-(BOOL)validate {
    if (![self.nameText.text length]) {
        UIAlertController *error = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Required Field", nil) message:NSLocalizedString(@"Please enter a name", nil) actions:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:nil],nil];
        [self presentViewController:error animated:YES completion:nil];
        return false;
    }
    if (![self.startText.text length]) {
        UIAlertController *error = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Required Field", nil) message:NSLocalizedString(@"Please enter the start of the segment", nil) actions:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:nil],nil];
        [self presentViewController:error animated:YES completion:nil];
        return false;
    }
    if (![self.endText.text length]) {
        UIAlertController *error = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Required Field", nil) message:NSLocalizedString(@"Please enter the end of the segment", nil) actions:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:nil],nil];
        [self presentViewController:error animated:YES completion:nil];
        return false;
    }
    if (![self.facilityText.text length]) {
        UIAlertController *error = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Required Field", nil) message:NSLocalizedString(@"Please enter a facility", nil) actions:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:nil],nil];
        [self presentViewController:error animated:YES completion:nil];
        return false;
    }
    if (!self.shadowers.count) {
        UIAlertController *error = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Required Field", nil) message:NSLocalizedString(@"Please select shadowers", nil) actions:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:nil],nil];
        [self presentViewController:error animated:YES completion:nil];
        return false;
    }
    return true;
}

- (IBAction)save:(id)sender {
    if ([self validate]) {
        Segment *segment = [[Segment alloc] init];
        segment.name = self.nameText.text;
        segment.locationStartName = self.startText.text;
        segment.locationEndName = self.endText.text;
        segment.facility = self.facilityText.text;
        segment.experienceId = self.experience.experienceId;
        segment.createdAt = [NSDate date];
        segment.updatedAt = [NSDate date];

        for (Shadower *shadower in self.shadowers) {
            [segment.shadowers addObject:shadower];
        }
        [[GoShadowAPIManager sharedManager] postSegment:segment withCallback:^(id result, NSError *error) {
            if (!error) {
                [self.navigationController popViewControllerAnimated:YES];
            }
            else {
                UIAlertController *error = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"An error occurred, please check your internet connection and try again", nil) actions:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:nil],nil];
                [self presentViewController:error animated:YES completion:nil];
            }
        }];
    }
}

-(void)shadowerListViewController:(ShadowerListViewController*)viewController didSelectShadowers:(NSArray*)shadowers {
    self.shadowers = shadowers;
    self.shadowersText.text = [[shadowers valueForKey:@"name"] componentsJoinedByString:@","];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ShadowersSegue"]) {
        ShadowerListViewController *vc = [segue destinationViewController];
        vc.delegate = self;
        vc.selectedShadowers = [NSMutableArray arrayWithArray:self.shadowers];
    }
}

@end
