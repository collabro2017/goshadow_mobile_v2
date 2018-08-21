//
//  CaregiverListViewController.h
//  GoShadow
//
//  Created by Shawn Wall on 7/29/15.
//  Copyright (c) 2015 Inquiri. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CaregiverListViewController;
@class Caregiver;

@protocol CaregiverListDelegate <NSObject>

-(void)caregiverListViewController:(CaregiverListViewController*)viewController didSelectCaregiver:(Caregiver*)caregiver;

@end

@interface CaregiverListViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>

@property (nonatomic) NSInteger segmentId;
@property (weak, nonatomic) id<CaregiverListDelegate> delegate;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
