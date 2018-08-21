//
//  ExperienceListViewController.m
//  GoShadow
//
//  Created by Shawn Wall on 7/28/15.
//  Copyright (c) 2015 Inquiri. All rights reserved.
//

#import "ExperienceListViewController.h"
#import "Experience+Extensions.h"
#import "SegmentListViewController.h"
#import "AppDelegate.h"
#import "ExperienceCell.h"
#import "GoShadowAPIManager.h"
#import "RESideMenu.h"

@interface ExperienceListViewController ()

@property (strong, nonatomic) RLMResults *experiences;
@property (strong, nonatomic) RLMNotificationToken *token;
@end

@implementation ExperienceListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"Care Experiences", nil);
    self.createButton.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
    [self.createButton setTitleColor:[UIColor gsLightBlueColor] forState:UIControlStateNormal];
    [self loadData];
    [self.tableView setTableFooterView:[UIView new]];
//    self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"login_background"]];    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Menu", nil) style:UIBarButtonItemStylePlain target:self.sideMenuViewController action:@selector(presentLeftMenuViewController)];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Experiences", nil) style:UIBarButtonItemStylePlain target:nil action:nil];
    // Observe Realm Notifications
    self.token = [[RLMRealm defaultRealm] addNotificationBlock:^(NSString *note, RLMRealm * realm) {
        [self loadData];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.tableView.indexPathForSelectedRow) {
        [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:YES];
    }
}

-(void)loadData {
    self.experiences = [Experience allObjects];
    [self.tableView reloadData];
}

-(void)logout {
    [(AppDelegate*)[[UIApplication sharedApplication] delegate] logout];
}

-(void)publish:(id)sender {

}

#pragma mark - Table view data source

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if ([tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.experiences.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ExperienceCell *cell = (ExperienceCell*)[tableView dequeueReusableCellWithIdentifier:@"ExperienceCell" forIndexPath:indexPath];
    Experience *experience = self.experiences[indexPath.row];
    cell.textLabel.text = experience.name;
    cell.detailTextLabel.text = experience.cellSummary;
    cell.experienceId = experience.experienceId;
    if (experience.isPublished) {
        cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_lock"]];
        [cell.accessoryView setUserInteractionEnabled:false];
    }
    else {
        cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_export"]];
        [cell.accessoryView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:cell action:@selector(publish:)]];
        [cell.accessoryView setUserInteractionEnabled:true];
    }
    return cell;
}


 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
     Experience *experience = self.experiences[indexPath.row];
     if (experience.isPublished) {
         return false;
     }
     return true;
 }

 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
     if (editingStyle == UITableViewCellEditingStyleDelete) {
         Experience *experience = self.experiences[indexPath.row];
         NSInteger experienceId = experience.experienceId;
         [[GoShadowAPIManager sharedManager] deleteExperienceWithId:experienceId withCallback:^(id result, NSError *error) {
             
         }];
         RLMRealm *realm = [RLMRealm defaultRealm];
         [realm beginWriteTransaction];
         [realm deleteObject:experience];
         [realm commitWriteTransaction];
     }
}

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


 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"SegmentListSegue"]) {
        SegmentListViewController *vc = [segue destinationViewController];
        Experience *experience = self.experiences[self.tableView.indexPathForSelectedRow.row];
        vc.experience = experience;
    }
}

- (BOOL)slideNavigationControllerShouldDisplayLeftMenu
{
    return YES;
}

@end
