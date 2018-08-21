//
//  ExperienceCreateViewController.m
//  GoShadow
//
//  Created by Shawn Wall on 7/29/15.
//  Copyright (c) 2015 Inquiri. All rights reserved.
//

#import "ExperienceCreateViewController.h"
#import "Experience+Extensions.h"
#import "GoShadowAPIManager.h"
#import <SVProgressHUD.h>

@interface ExperienceCreateViewController () <UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate>

@property (strong, nonatomic) UIPickerView *typePicker;
@property (strong, nonatomic) NSArray *experienceTypes;
@property (strong, nonatomic) UIToolbar *typeToolbar;

@end

@implementation ExperienceCreateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"Create a Care Experience", nil);
    self.nameText.placeholder = NSLocalizedString(@"My Care Experience", nil);
    self.startText.placeholder = NSLocalizedString(@"Ex) Reception", nil);
    self.endText.placeholder = NSLocalizedString(@"Ex) When visitor is discharged", nil);
    self.facilityText.placeholder = NSLocalizedString(@"Ex) Exemplar Hospital", nil);
    self.typeText.placeholder = NSLocalizedString(@"Select a Type of Experience", nil);
    
    self.nameText.delegate = self;
    self.startText.delegate = self;
    self.endText.delegate = self;
    self.facilityText.delegate = self;
    self.typeText.delegate = self;
    
    self.typePicker = [[UIPickerView alloc] initWithFrame:CGRectZero];
    self.typePicker.dataSource = self;
    self.typePicker.delegate = self;
    self.typeToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 44.0)];
    [self.typeToolbar setItems:@[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil], [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(selectType:)]]];
    self.experienceTypes = [Experience experienceTypes];
    [self.titleLabels makeObjectsPerformSelector:@selector(setFont:) withObject:[UIFont systemFontOfSize:14.0]];
    self.typeText.inputView = self.typePicker;
    self.typeText.inputAccessoryView = self.typeToolbar;
    
    self.tableView.delaysContentTouches = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - 

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if ([textField isEqual:self.typeText]) {
        self.typeText.text = self.experienceTypes[[self.typePicker selectedRowInComponent:0]];
    }
}

#pragma mark - 

-(void)selectType:(id)sender {
    [self.typeText resignFirstResponder];
    self.typeText.text = self.experienceTypes[[self.typePicker selectedRowInComponent:0]];
}

-(BOOL)validate {
    if (![self.nameText.text length]) {
        UIAlertController *error = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Required Field", nil) message:NSLocalizedString(@"Please enter a name", nil) actions:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:nil],nil];
        [self presentViewController:error animated:YES completion:nil];
        return false;
    }
    if (![self.startText.text length]) {
        UIAlertController *error = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Required Field", nil) message:NSLocalizedString(@"Please enter the start of the experience", nil) actions:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:nil],nil];
        [self presentViewController:error animated:YES completion:nil];
        return false;
    }
    if (![self.endText.text length]) {
        UIAlertController *error = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Required Field", nil) message:NSLocalizedString(@"Please enter the end of the experience", nil) actions:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:nil],nil];
        [self presentViewController:error animated:YES completion:nil];
        return false;
    }
    if (![self.facilityText.text length]) {
        UIAlertController *error = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Required Field", nil) message:NSLocalizedString(@"Please enter a facility", nil) actions:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:nil],nil];
        [self presentViewController:error animated:YES completion:nil];
        return false;
    }
    if (![self.typeText.text length]) {
        UIAlertController *error = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Required Field", nil) message:NSLocalizedString(@"Please select a type", nil) actions:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:nil],nil];
        [self presentViewController:error animated:YES completion:nil];
        return false;
    }
    return true;
}

- (IBAction)save:(id)sender {
    if ([self validate]) {
        Experience *experience = [[Experience alloc] init];
        experience.name = self.nameText.text;
        experience.locationStartName = self.startText.text;
        experience.locationEndName = self.endText.text;
        experience.facility = self.facilityText.text;
        experience.type = self.typeText.text;
        experience.createdAt = [NSDate date];
        experience.updatedAt = [NSDate date];
        experience.isPublished = false;
        [SVProgressHUD show];
        [[GoShadowAPIManager sharedManager] postExperience:experience withCallback:^(id result, NSError *error) {
            [SVProgressHUD dismiss];            
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


#pragma mark - 

// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return  self.experienceTypes.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return self.experienceTypes[row];
}

@end
