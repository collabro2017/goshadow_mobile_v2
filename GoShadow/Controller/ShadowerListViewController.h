//
//  ShadowerListViewController.h
//  GoShadow
//
//  Created by Shawn Wall on 7/29/15.
//  Copyright (c) 2015 Inquiri. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ShadowerListViewController;

@protocol ShadowerListDelegate <NSObject>

-(void)shadowerListViewController:(ShadowerListViewController*)viewController didSelectShadowers:(NSArray*)shadowers;

@end

@interface ShadowerListViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) id<ShadowerListDelegate> delegate;
@property (strong, nonatomic) NSMutableArray *selectedShadowers;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@end
