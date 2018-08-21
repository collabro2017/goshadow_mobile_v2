//
//  ExperienceListViewController.h
//  GoShadow
//
//  Created by Shawn Wall on 7/28/15.
//  Copyright (c) 2015 Inquiri. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ExperienceListViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *createButton;

@end
