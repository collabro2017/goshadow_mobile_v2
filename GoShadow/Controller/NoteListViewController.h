//
//  NoteListViewController.h
//  GoShadow
//
//  Created by Shawn Wall on 7/29/15.
//  Copyright (c) 2015 Inquiri. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Segment;

@interface NoteListViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) Segment *segment;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIToolbar *footerToolbar;

@end
