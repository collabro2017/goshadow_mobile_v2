//
//  NoteListViewController.m
//  GoShadow
//
//  Created by Shawn Wall on 7/29/15.
//  Copyright (c) 2015 Inquiri. All rights reserved.
//

#import "NoteListViewController.h"
#import "GoShadowModels.h"
#import "TimerViewController.h"
#import "NoteViewController.h"
#import "NoteCell.h"
#import "NotePhotoCell.h"
#import "TimerCell.h"
#import <AFNetworking/UIImageView+AFNetworking.h>
#import "GoShadowAPIManager.h"
#import "TimerManager.h"

@interface NoteListViewController ()

@property RLMResults *notes;
@property (strong, nonatomic) RLMNotificationToken *token;
@property (strong, nonatomic) Experience *experience;
@end

@implementation NoteListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = self.segment.name;
    self.tableView.estimatedRowHeight = 54.0;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    [self.tableView registerNib:[UINib nibWithNibName:@"NoteCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"NoteCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"TimerCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"TimerCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"NotePhotoCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"NotePhotoCell"];
    [self.tableView setTableFooterView:[UIView new]];
//    self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"login_background"]];
    
    self.experience = [Experience objectForPrimaryKey:@(self.segment.experienceId)];
    if (self.experience.isPublished) {
        [self.footerToolbar setUserInteractionEnabled:false];
        self.footerToolbar.hidden = true;
    }
    else {
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, self.footerToolbar.frame.size.height, 0);
    }
    // Observe Realm Notifications
//    self.token = [[RLMRealm defaultRealm] addNotificationBlock:^(NSString *note, RLMRealm * realm) {
//        [self loadData];
//    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
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
    if (!self.segment.isInvalidated) {
        self.notes = [[Note objectsWithPredicate:[NSPredicate predicateWithFormat:@"segmentId = %d and localStatus != %d", self.segment.segmentId, NoteLocalStatusDelete]] sortedResultsUsingProperty:@"createdAt" ascending:YES];
        [self.tableView reloadData];
    }
}

-(void)timerIncrement {
    [self.tableView reloadData];
}

#pragma mark - Table view data source

//-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    Note *note = self.notes[indexPath.row];
//    if (note.isTimer) {
//        return 54.0f;
//    }
//    else {
//        return 80.0f;
//    }
//}

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
    return self.notes.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    Note *note = self.notes[indexPath.row];
    if (note.isTimer) {
        TimerCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TimerCell" forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell setTimer:note];
        if (self.experience.isPublished) {
            cell.startStopButton.enabled = false;
        }
        else {
            cell.startStopButton.enabled = true;
        }
        return cell;
    }
    else {
        if (note.attachmentUrl.length) {
            NotePhotoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NotePhotoCell" forIndexPath:indexPath];
            cell.contentView.backgroundColor = [UIColor whiteColor];
            [cell.photoImage setImageWithURL:[NSURL URLWithString:note.attachmentUrl] placeholderImage:[UIImage imageNamed:@"icon_photo_placeholder"]];
            cell.categoryIcon.image = [UIImage imageNamed:[Note imageNameForCategoryImage:note.categoryId]];
            cell.dateTimeLabel.text = [note.createdAt mt_stringValueWithDateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterShortStyle];
            cell.noteLabel.text = note.note;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            if (note.categoryId > 0) {
                cell.categoryIcon.image = [UIImage imageNamed:[Note imageNameForCategoryImage:note.categoryId]];
            }
            else {
                cell.categoryIcon.image = nil;
            }
            if (note.isHighlight) {
                [cell.opportunityImage setHidden:false];
            }
            else {
                [cell.opportunityImage setHidden:true];
            }
            return cell;
        }
        else {
            NoteCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NoteCell" forIndexPath:indexPath];
            cell.contentView.backgroundColor = [UIColor whiteColor];
            cell.categoryIcon.image = [UIImage imageNamed:[Note imageNameForCategoryImage:note.categoryId]];
            cell.dateTimeLabel.text = [note.createdAt mt_stringValueWithDateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterShortStyle];
            cell.noteLabel.text = note.note;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            if (note.categoryId > 0) {
                cell.categoryIcon.image = [UIImage imageNamed:[Note imageNameForCategoryImage:note.categoryId]];
            }
            else {
                cell.categoryIcon.image = nil;
            }
            
            if (note.isHighlight) {
                [cell.opportunityImage setHidden:false];
            }
            else {
                [cell.opportunityImage setHidden:true];
            }
            return cell;
        }
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Note *note = self.notes[indexPath.row];
    if (note.isTimer && !self.experience.isPublished && ![[TimerManager sharedManager] isRunning:note]) {
        if (note.caregiverId > 0) {
            [self performSegueWithIdentifier:@"CaregiverSegue" sender:nil];
        }
        else if (note.touchpointId > 0) {
            [self performSegueWithIdentifier:@"TouchpointSegue" sender:nil];
        }
    }
    else if (!note.isTimer) {
        [self performSegueWithIdentifier:@"NoteEditSegue" sender:nil];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    if (self.experience.isPublished) {
        return false;
    }
    return true;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Note *note = self.notes[indexPath.row];
        //first flag as local delete
        RLMRealm *realm = [RLMRealm defaultRealm];
        [realm beginWriteTransaction];
        note.localStatus = NoteLocalStatusDelete;
        [realm commitWriteTransaction];
        //delete timer state if it is running
        if (note.isTimer && [[TimerManager sharedManager] isRunning:note]) {
            [[TimerManager sharedManager] deleteTimer:note];
        }
        //if it exists on server, delete on server
        if (note.noteId > 0) {
            [[GoShadowAPIManager sharedManager] deleteNoteWithId:note.noteId inSegmentId:note.segmentId withCallback:^(id result, NSError *error) {
                if (!error) {
                    RLMRealm *realm = [RLMRealm defaultRealm];
                    [realm beginWriteTransaction];
                    [realm deleteObject:note];
                    [realm commitWriteTransaction];
                }
            }];
        }
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
    if ([segue.identifier isEqualToString:@"CaregiverSegue"]) {
        TimerViewController *vc = segue.destinationViewController;
        vc.mode = TimerModeAddCaregiver;
        vc.segment = self.segment;
        if (self.tableView.indexPathForSelectedRow) {
            Note *note = self.notes[self.tableView.indexPathForSelectedRow.row];
            vc.note = note;
        }
    }
    else if ([segue.identifier isEqualToString:@"TouchpointSegue"]) {
        TimerViewController *vc = segue.destinationViewController;
        vc.mode = TimerModeAddTouchpoint;
        vc.segment = self.segment;
        if (self.tableView.indexPathForSelectedRow) {
            Note *note = self.notes[self.tableView.indexPathForSelectedRow.row];
            vc.note = note;
        }
    }
    else if ([segue.identifier isEqualToString:@"NoteEditSegue"]) {
        NoteViewController *vc = segue.destinationViewController;
        vc.note = self.notes[self.tableView.indexPathForSelectedRow.row];
        vc.segment = self.segment;        
    }
    else if ([segue.identifier isEqualToString:@"NoteSegue"]) {
        NoteViewController *vc = segue.destinationViewController;
        vc.segment = self.segment;
    }
    else if ([segue.identifier isEqualToString:@"PhotoSegue"]) {
        NoteViewController *vc = segue.destinationViewController;
        vc.segment = self.segment;
        vc.isNewPhoto = true;
    }
}

@end
