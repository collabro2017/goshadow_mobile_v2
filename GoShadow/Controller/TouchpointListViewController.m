//
//  TouchpointListViewController.m
//  GoShadow
//
//  Created by Shawn Wall on 7/29/15.
//  Copyright (c) 2015 Inquiri. All rights reserved.
//

#import "TouchpointListViewController.h"
#import "GoShadowModels.h"
#import "GoShadowAPIManager.h"

@interface TouchpointListViewController ()

@property (strong, nonatomic) RLMResults *touchpoints;

@end

@implementation TouchpointListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = NSLocalizedString(@"Touchpoints", nil);
    [self loadData];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(add:)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)loadData {
    if (self.searchBar.text.length) {
        self.touchpoints = [[Touchpoint objectsWithPredicate:[NSPredicate predicateWithFormat:@"name CONTAINS[c] %@", self.searchBar.text]] sortedResultsUsingProperty:@"name" ascending:YES];
    }
    else {
        self.touchpoints = [[Touchpoint allObjects] sortedResultsUsingProperty:@"name" ascending:YES];
    }
    [self.tableView reloadData];
}

-(void)add:(id)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Add Touchpoint", nil) message:NSLocalizedString(@"Enter name", nil) preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = NSLocalizedString(@"Enter name", @"Placeholder");
    }];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Save", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        UITextField *name = [alert.textFields firstObject];
        if (name.text.length) {
            Touchpoint *touchpoint = [[Touchpoint alloc] init];
            touchpoint.name = name.text;
            touchpoint.segmentId = self.segmentId;
            [[GoShadowAPIManager sharedManager] postTouchpoint:touchpoint withCallback:^(id result, NSError *error) {
                if (error) {
                    UIAlertController *error = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"Something went wrong", nil) actions:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:nil],nil];
                    [self presentViewController:error animated:YES completion:nil];
                }
                else {
                    [self loadData];
                }
            }];
        }
        else {
            UIAlertController *error = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"Please enter an name", nil) actions:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:nil],nil];
            [self presentViewController:error animated:YES completion:nil];
        }
    }]];
    [self presentViewController:alert animated:YES completion:nil];
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
    return self.touchpoints.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TouchpointCell" forIndexPath:indexPath];
    
    Touchpoint *touchpoint = self.touchpoints[indexPath.row];
    cell.textLabel.text = touchpoint.name;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Touchpoint *touchpoint = self.touchpoints[indexPath.row];
    if (self.delegate) {
        [self.delegate touchpointListViewController:self didSelectTouchpoint:touchpoint];
        [self.navigationController popViewControllerAnimated:YES];        
    }
}

#pragma mark -

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [self loadData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self loadData];
    [self.searchBar resignFirstResponder];    
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self.searchBar resignFirstResponder];
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
