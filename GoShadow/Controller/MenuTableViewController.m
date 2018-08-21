//
//  MenuTableViewController.m
//  GoShadow
//
//  Created by Shawn Wall on 9/18/15.
//  Copyright © 2015 Inquiri. All rights reserved.
//

#import "MenuTableViewController.h"
#import "AppDelegate.h"
#import <Intercom/Intercom.h>
#import "GoShadowAPIManager.h"
#import "Shadower.h"
#import "TourViewController.h"

@interface MenuTableViewController ()

@end

typedef NS_ENUM(NSInteger, MenuRow) {
    MenuRowName,
    MenuRowFeedback,
    MenuRowTour,
    MenuRowLogout
};

@implementation MenuTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.contentInset  = UIEdgeInsetsMake(40.0, 0, 0, 0);
    UIImageView *background = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"login_background"]];
    background.contentMode = UIViewContentModeScaleAspectFill;
    self.tableView.backgroundView = background;
    
    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = YES;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MenuCell" forIndexPath:indexPath];
    
    switch (indexPath.row) {
        case MenuRowName:
        {
            cell.textLabel.font = [UIFont boldSystemFontOfSize:16.0];
            cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Hello %@", @"Row Title"), [[GoShadowAPIManager sharedManager] getCurrentUser].firstName];
            break;
        }
        case MenuRowFeedback:
        {
            cell.textLabel.text = NSLocalizedString(@"Feedback and Support", @"Row Title");
            break;
        }
        case MenuRowTour:
        {
            cell.textLabel.text = NSLocalizedString(@"Take the Tour", @"Row Title");
            break;
        }
        case MenuRowLogout:
        {
            cell.textLabel.text = NSLocalizedString(@"Logout", @"Row Title");
            break;
        }
        default:
            break;
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor clearColor];
    cell.contentView.backgroundColor = [UIColor clearColor];
    cell.textLabel.textColor = [UIColor whiteColor];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case MenuRowName:
        {
            [self.sideMenuViewController hideMenuViewController];
            break;
        }
        case MenuRowFeedback:
        {
            [Intercom presentMessageComposer];
            [self.sideMenuViewController hideMenuViewController];
            break;
        }
        case MenuRowTour:
        {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Authentication" bundle:nil];
            TourViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"TourViewController"];
            [self presentViewController:vc animated:true completion:^{
                [self.sideMenuViewController hideMenuViewController];
            }];
            break;
        }
        case MenuRowLogout:
        {
            [(AppDelegate*)[[UIApplication sharedApplication] delegate] logout];
            break;
        }
        default:
            break;
    }
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
