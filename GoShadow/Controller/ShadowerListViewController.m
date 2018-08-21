//
//  ShadowerListViewController.m
//  GoShadow
//
//  Created by Shawn Wall on 7/29/15.
//  Copyright (c) 2015 Inquiri. All rights reserved.
//

#import "ShadowerListViewController.h"
#import "Shadower+Extensions.h"
#import "GoShadowAPIManager.h"

@interface ShadowerListViewController ()

@property (strong, nonatomic) RLMResults *shadowers;

@end

@implementation ShadowerListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"Add Shadowers", nil);
    self.searchBar.delegate = self;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addShadower:)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self loadData];
}

-(void)loadData {
    if (self.searchBar.text.length) {
        self.shadowers = [[Shadower objectsWithPredicate:[NSPredicate predicateWithFormat:@"lastName CONTAINS[c] %@ OR firstName CONTAINS[c] %@", self.searchBar.text, self.searchBar.text]] sortedResultsUsingProperty:@"lastName" ascending:YES];
    }
    else {
        self.shadowers = [[Shadower allObjects] sortedResultsUsingProperty:@"lastName" ascending:YES];
    }
    [self.tableView reloadData];
}

-(void)addShadower:(id)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Invite a New Shadower", nil) message:NSLocalizedString(@"Enter an email address to invite your Shadower to GoShadow", nil) preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = NSLocalizedString(@"Enter Email Address", @"Placeholder");
    }];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        UITextField *email = [alert.textFields firstObject];
        if (email.text.length) {
            Shadower *shadower = [[Shadower alloc] init];
            shadower.email = email.text;
            [[GoShadowAPIManager sharedManager] postShadower:shadower withCallback:^(id result, NSError *error) {
                if (!error) {
                    [self.navigationController popViewControllerAnimated:true];
                }
                else {
                    UIAlertController *error = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"An error occurred adding a shadower", nil) actions:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:nil],nil];
                    [self presentViewController:error animated:YES completion:nil];
                }
            }];
        }
        else {
            UIAlertController *error = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"Please enter an email address", nil) actions:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:nil],nil];
            [self presentViewController:error animated:YES completion:nil];
        }
    }]];
    [self presentViewController:alert animated:YES completion:nil];
//    [self performSegueWithIdentifier:@"AddShadowerSegue" sender:sender];
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
    return self.shadowers.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ShadowerCell" forIndexPath:indexPath];
    
    Shadower *shadower = self.shadowers[indexPath.row];
    cell.textLabel.text = shadower.name;
    if ([self.selectedShadowers containsObject:shadower]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Shadower *shadower = self.shadowers[indexPath.row];
    if ([self.selectedShadowers containsObject:shadower]) {
        [self.selectedShadowers removeObject:shadower];
    }
    else {
        [self.selectedShadowers addObject:shadower];
    }
    if (self.delegate) {
        [self.delegate shadowerListViewController:self didSelectShadowers:self.selectedShadowers];
    }
    [self.tableView reloadData];
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
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
