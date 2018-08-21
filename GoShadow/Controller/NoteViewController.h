//
//  NoteViewController.h
//  GoShadow
//
//  Created by Shawn Wall on 7/29/15.
//  Copyright (c) 2015 Inquiri. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Note;
@class Segment;

@interface NoteViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) Segment *segment;
@property (strong, nonatomic) Note *note;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) BOOL isNewPhoto;

@end
