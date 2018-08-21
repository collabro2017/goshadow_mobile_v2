//
//  SegmentCreateViewController.h
//  GoShadow
//
//  Created by Shawn Wall on 7/29/15.
//  Copyright (c) 2015 Inquiri. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Experience;

@interface SegmentCreateViewController : UITableViewController

@property (strong, nonatomic) Experience *experience;
@property (weak, nonatomic) IBOutlet UITextField *nameText;
@property (weak, nonatomic) IBOutlet UITextField *startText;
@property (weak, nonatomic) IBOutlet UITextField *endText;
@property (weak, nonatomic) IBOutlet UITextField *facilityText;
@property (weak, nonatomic) IBOutlet UITextField *shadowersText;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *titleLabels;

@end
