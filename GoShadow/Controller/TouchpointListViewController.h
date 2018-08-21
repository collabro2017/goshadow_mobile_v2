//
//  TouchpointListViewController.h
//  GoShadow
//
//  Created by Shawn Wall on 7/29/15.
//  Copyright (c) 2015 Inquiri. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TouchpointListViewController;
@class Touchpoint;

@protocol TouchpointListDelegate <NSObject>

-(void)touchpointListViewController:(TouchpointListViewController*)viewController didSelectTouchpoint:(Touchpoint*)touchpoint;

@end

@interface TouchpointListViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>

@property (nonatomic) NSInteger segmentId;
@property (weak, nonatomic) id<TouchpointListDelegate> delegate;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
