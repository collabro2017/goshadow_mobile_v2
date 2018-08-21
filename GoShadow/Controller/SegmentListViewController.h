//
//  SegmentListViewController.h
//  GoShadow
//
//  Created by Shawn Wall on 7/29/15.
//  Copyright (c) 2015 Inquiri. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Experience;

@interface SegmentListViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) Experience *experience;
@property (weak, nonatomic) IBOutlet UIButton *createButton;

@end
