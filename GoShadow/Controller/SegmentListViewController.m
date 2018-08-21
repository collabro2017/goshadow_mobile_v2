//
//  SegmentListViewController.m
//  GoShadow
//
//  Created by Shawn Wall on 7/29/15.
//  Copyright (c) 2015 Inquiri. All rights reserved.
//

#import "SegmentListViewController.h"
#import "GoShadowModels.h"
#import "NoteListViewController.h"
#import "SegmentCreateViewController.h"
#import "GoShadowAPIManager.h"

@interface SegmentListViewController ()

@property RLMResults *segments;
@property (strong, nonatomic) RLMNotificationToken *token;

@end

@implementation SegmentListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = self.experience.name;
    self.createButton.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
    [self.createButton setTitleColor:[UIColor gsLightBlueColor] forState:UIControlStateNormal];
//    self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"login_background"]];
    [self.tableView setTableFooterView:[UIView new]];
    
    if (self.experience.isPublished) {
        [self.tableView setTableHeaderView:[UIView new]];
    }
    //removed for 1.0
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_info"] style:UIBarButtonItemStylePlain target:self action:@selector(showInfo:)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // Observe Realm Notifications
    __weak typeof(self) weakSelf = self;
    self.token = [[RLMRealm defaultRealm] addNotificationBlock:^(NSString *note, RLMRealm * realm) {
        [weakSelf loadData];
    }];
    if (self.tableView.indexPathForSelectedRow) {
        [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:YES];
    }
    [self loadData];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[RLMRealm defaultRealm] removeNotification:self.token];
}

-(void)loadData {
    if (!self.experience.isInvalidated) {
        self.segments = [Segment objectsWithPredicate:[NSPredicate predicateWithFormat:@"experienceId = %d", self.experience.experienceId]];
        [self.tableView reloadData];
    }
}

-(void)showInfo:(id)sender {
    UIAlertController *error = [UIAlertController alertControllerWithTitle:self.experience.name message:@"Coming soon" actions:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:nil],nil];
    [self presentViewController:error animated:YES completion:nil];
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
    return self.segments.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SegmentCell" forIndexPath:indexPath];
    
    Segment *segment = self.segments[indexPath.row];
    cell.textLabel.text = segment.name;
    cell.textLabel.textColor = [UIColor gsDarkBlueColor];
    cell.textLabel.font = [UIFont boldSystemFontOfSize:17.0];
    
    cell.detailTextLabel.text = segment.cellSummary;
    cell.detailTextLabel.textColor = [UIColor grayColor];
    
    return cell;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.experience.isPublished) {
        return false;
    }
    return true;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Segment *segment = self.segments[indexPath.row];
        NSInteger segmentId = segment.segmentId;
        [[GoShadowAPIManager sharedManager] deleteSegmentWithId:segmentId withCallback:^(id result, NSError *error) {
            
        }];
        RLMRealm *realm = [RLMRealm defaultRealm];
        [realm beginWriteTransaction];
        [realm deleteObject:segment];
        [realm commitWriteTransaction];
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


 #pragma mark - Navigation
 
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"NoteListSegue"]) {
        NoteListViewController *vc = [segue destinationViewController];
        Segment *segment = self.segments[self.tableView.indexPathForSelectedRow.row];
        vc.segment = segment;
    }
    else if ([segue.identifier isEqualToString:@"SegmentCreateSegue"]) {
        SegmentCreateViewController *vc = [segue destinationViewController];
        vc.experience = self.experience;
    }
}


@end
