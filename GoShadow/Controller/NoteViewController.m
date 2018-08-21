//
//  NoteViewController.m
//  GoShadow
//
//  Created by Shawn Wall on 7/29/15.
//  Copyright (c) 2015 Inquiri. All rights reserved.
//

#import "NoteViewController.h"
#import "NoteCell.h"
#import "NotePhotoCell.h"
#import "GoShadowModels.h"
#import "GoShadowAPIManager.h"
#import <AFNetworking/UIImageView+AFNetworking.h>
#import "NoteHeaderView.h"
#import "TimerCell.h"

typedef NS_ENUM(NSInteger, NoteSection) {
    NoteSectionCaregiver,
    NoteSectionTouchpoint,
    NoteSectionNote
};

@interface NoteViewController () <UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate>

@property (strong, nonatomic) RLMResults *touchpointTimers;
@property (strong, nonatomic) RLMResults *caregiverTimers;
@property (strong, nonatomic) UIToolbar *noteToolbar;
@property (nonatomic) NoteCategoryInteger noteCategory;
@property (nonatomic) BOOL isOpportunity;
@property (strong, nonatomic) UIBarButtonItem *opportunityButton;
@property (strong, nonatomic) NSString *noteString;
@property (strong, nonatomic) UIImagePickerController *imagePicker;
@property (strong, nonatomic) UIImage *photo;
@property (strong, nonatomic) NSString *photoUrl;
@property (strong, nonatomic) Experience *experience;

@property BOOL touchpointsExpanded;
@property BOOL caregiversExpanded;
@property BOOL hasChanged;

@end

@implementation NoteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"Note", nil);
    self.tableView.estimatedRowHeight = 54.0;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    [self.tableView registerNib:[UINib nibWithNibName:@"NoteCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"NoteCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"TimerCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"TimerCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"NotePhotoCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"NotePhotoCell"];
    [self.tableView setTableFooterView:[UIView new]];
    
    self.noteToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 44.0)];
    [self.noteToolbar setTintColor:[UIColor darkGrayColor]];
    self.opportunityButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_opportunity"] style:UIBarButtonItemStylePlain target:self action:@selector(opportunityToggle:)];
    [self.noteToolbar setItems:@[self.opportunityButton, [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_photo"] style:UIBarButtonItemStylePlain target:self action:@selector(addPhoto:)], [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_more"] style:UIBarButtonItemStylePlain target:self action:@selector(chooseType:)]]];

    self.experience = [Experience objectForPrimaryKey:@(self.segment.experienceId)];
    
    if (!self.experience.isPublished) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
    }
    
    if (self.note) {
        self.noteString = self.note.note;
        self.isOpportunity = self.note.isHighlight;
        [self updateOpportunity];
        self.noteCategory = self.note.categoryId;
        if (self.note.attachmentUrl.length) {
            self.photoUrl = self.note.attachmentUrl;
        }
        self.touchpointTimers = [Note objectsWithPredicate:[NSPredicate predicateWithFormat:@"segmentId == %d and touchpointId != 0 and caregiverId == 0 and createdAt < %@ and startDate != %@ and localStatus != %d", self.note.segmentId, self.note.createdAt, [NSDate defaultDate],NoteLocalStatusDelete]];
        self.caregiverTimers = [Note objectsWithPredicate:[NSPredicate predicateWithFormat:@"segmentId == %d and caregiverId != 0 and touchpointId == 0 and createdAt < %@ and startDate != %@ and localStatus != %d", self.note.segmentId, self.note.createdAt, [NSDate defaultDate],NoteLocalStatusDelete]];
    }
    else {
        self.touchpointTimers = [Note objectsWithPredicate:[NSPredicate predicateWithFormat:@"segmentId == %d and touchpointId != 0 and caregiverId == 0 and createdAt < %@ and startDate != %@ and localStatus != %d", self.segment.segmentId, [NSDate date], [NSDate defaultDate],NoteLocalStatusDelete]];
        self.caregiverTimers = [Note objectsWithPredicate:[NSPredicate predicateWithFormat:@"segmentId == %d and caregiverId != 0 and touchpointId == 0 and createdAt < %@ and startDate != %@ and localStatus != %d", self.segment.segmentId, [NSDate date], [NSDate defaultDate],NoteLocalStatusDelete]];
    }
    
    if (self.isNewPhoto) {
        [self addPhoto:nil];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)cancel:(id)sender {
    if (self.hasChanged) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Warning", nil) message:NSLocalizedString(@"Changes have been made. Are you sure you want to discard your changes?", nil) preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Yes, Discard Changes", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self.navigationController popViewControllerAnimated:true];
        }]];
        [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"No", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        }]];
        [self presentViewController:alert animated:true completion:nil];
    }
    else {
        [self.navigationController popViewControllerAnimated:true];
    }
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

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    if (indexPath.section == NoteSectionNote) {
//        NSString *noteText = self.note.note;
//
//        return 100.0;
//    }
//    else {
//        return 54.0;
//    }
//}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    
    switch (section) {
        case NoteSectionCaregiver:
            if (self.caregiversExpanded) {
                //number of running caregiver timers with create date < (note date || curr date)
                return self.caregiverTimers.count;
            }
            else {
                return 0;
            }
            
        case NoteSectionTouchpoint:
            if (self.touchpointsExpanded) {
                //number of running touchpoint timers with create date < (note date || curr date)
                return self.touchpointTimers.count;
            }
            else {
                return 0;
            }
            
        case NoteSectionNote:
            return 1;
        default:
            return 0;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    switch (section) {
        case NoteSectionCaregiver:
            if (self.caregiverTimers.count > 0) {
                return 44.0;
            }
            return 0;
        case NoteSectionTouchpoint:
            if (self.touchpointTimers.count > 0) {
                return 44.0;
            }
            return 0;
        case NoteSectionNote:
            return 0;
        default:
            return 0;
    }
}

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    switch (section) {
        case NoteSectionCaregiver: {
            if (self.caregiverTimers.count > 0) {
                NSArray *views = [[NSBundle mainBundle] loadNibNamed:@"NoteHeaderView" owner:self options:nil];
                NoteHeaderView *header = views[0];
                header.backgroundColor = [UIColor gsLightBlueColor];
                header.iconImage.image = [UIImage imageNamed:@"icon_caregiver_white"];
                [header addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleCaregivers:)]];
                [header setUserInteractionEnabled:true];
                header.headerLabel.text = self.caregiverTimers.count == 1 ? NSLocalizedString(@"1 Active Timer", nil) : [NSString stringWithFormat:@"%lu Active Timers", (unsigned long)self.caregiverTimers.count];
                return header;
            }
            return nil;
        }
        case NoteSectionTouchpoint:
            if (self.touchpointTimers.count > 0) {
                NSArray *views = [[NSBundle mainBundle] loadNibNamed:@"NoteHeaderView" owner:self options:nil];
                NoteHeaderView *header = views[0];
                header.backgroundColor = [UIColor gsMidGreenColor];
                header.iconImage.image = [UIImage imageNamed:@"icon_touchpoint_white"];
                [header addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleTouchpoints:)]];
                [header setUserInteractionEnabled:true];
                header.headerLabel.text = self.touchpointTimers.count == 1 ? NSLocalizedString(@"1 Active Timer", nil) : [NSString stringWithFormat:@"%lu Active Timers", (unsigned long)self.touchpointTimers.count];
                return header;
            }
            return nil;
        case NoteSectionNote:
            return nil;
        default:
            return nil;
    }
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case NoteSectionCaregiver: {
            TimerCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TimerCell" forIndexPath:indexPath];
            Note *timer = self.caregiverTimers[indexPath.row];
            [cell setTimer:timer];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            cell.iconImage.hidden = true;
            if (self.experience.isPublished) {
                cell.startStopButton.enabled = false;
            }
            else {
                cell.startStopButton.enabled = true;
            }
            return cell;
        }
        case NoteSectionTouchpoint: {
            TimerCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TimerCell" forIndexPath:indexPath];
            Note *timer = self.touchpointTimers[indexPath.row];
            [cell setTimer:timer];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            cell.iconImage.hidden = true;
            if (self.experience.isPublished) {
                cell.startStopButton.enabled = false;
            }
            else {
                cell.startStopButton.enabled = true;
            }
            return cell;
        }
        case NoteSectionNote: {
            if (self.photo || self.photoUrl) {
                NotePhotoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NotePhotoCell" forIndexPath:indexPath];
                if (self.photo) {
                    cell.photoImage.image = self.photo;
                }
                else {
                    [cell.photoImage setImageWithURL:[NSURL URLWithString:self.photoUrl] placeholderImage:[UIImage imageNamed:@"icon_photo_placeholder"]];
                }
                if (cell.photoImage.gestureRecognizers.count == 0) {
                    [cell.photoImage addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showPhoto:)]];
                }
                [cell.photoImage setUserInteractionEnabled:true];
                cell.categoryIcon.image = [UIImage imageNamed:[Note imageNameForCategoryImage:self.noteCategory]];
                cell.dateTimeLabel.text = [[NSDate date] mt_stringValueWithDateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterShortStyle];
                cell.noteLabel.text = self.noteString;
                cell.textView.text = self.noteString;
                if (self.noteString.length <= 0) {
                    cell.noteLabel.text = @"\n\n\n\n\n\n\n\n";
                }
                cell.textView.hidden = false;
                cell.textView.textContainerInset = UIEdgeInsetsZero;
                cell.textView.textContainer.lineFragmentPadding = 0;
                cell.textView.returnKeyType = UIReturnKeyDone;
                cell.textView.delegate = self;
                if (self.experience.isPublished) {
                    cell.textView.editable = false;
                }
                else {
                    cell.textView.editable = true;
                    cell.textView.inputAccessoryView = self.noteToolbar;
                }
                if (![cell.textView isFirstResponder] && !self.experience.isPublished && !self.isNewPhoto) {
                    [cell.textView becomeFirstResponder];
                }
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                return cell;
            }
            else {
                NoteCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NoteCell" forIndexPath:indexPath];
                if (self.noteCategory > 0) {
                    cell.categoryIcon.image = [UIImage imageNamed:[Note imageNameForCategoryImage:self.noteCategory]];
                }
                else {
                    cell.categoryIcon.image = nil;
                }

                if (self.isOpportunity) {
                    [cell.opportunityImage setHidden:false];
                }
                else {
                    [cell.opportunityImage setHidden:true];
                }
                cell.dateTimeLabel.text = [[NSDate date] mt_stringValueWithDateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterShortStyle];
                cell.noteLabel.text = self.noteString;
                cell.textView.text = self.noteString;
                if (self.noteString.length <= 0) {
                    cell.noteLabel.text = @"\n\n\n\n\n\n\n\n";
                }
                cell.textView.hidden = false;
                cell.textView.textContainerInset = UIEdgeInsetsZero;
                cell.textView.textContainer.lineFragmentPadding = 0;
                cell.textView.returnKeyType = UIReturnKeyDone;
                cell.textView.delegate = self;
                cell.textView.inputAccessoryView = self.noteToolbar;
                if (self.experience.isPublished) {
                    cell.textView.editable = false;
                }
                else {
                    cell.textView.editable = true;
                    cell.textView.inputAccessoryView = self.noteToolbar;
                }
                if (![cell.textView isFirstResponder] && !self.experience.isPublished && !self.isNewPhoto) {
                    [cell.textView becomeFirstResponder];
                }
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                return cell;
            }
        }
        default:
            return nil;
    }
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}


#pragma mark - 

-(void)opportunityToggle:(id)sender {
    if (!self.experience.isPublished) {
        self.isOpportunity = !self.isOpportunity;
        [self updateOpportunity];
        self.hasChanged = true;
    }
}

-(void)updateOpportunity {
    if (self.isOpportunity) {
        [self.opportunityButton setTintColor:[UIColor greenColor]];
    }
    else {
        [self.opportunityButton setTintColor:[UIColor darkGrayColor]];
    }
}

-(void)addPhoto:(id)sender {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Take photo", nil), NSLocalizedString(@"Choose photo", nil), nil];
        [actionSheet showInView:self.view];
    }
    else {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Choose photo", nil), nil];
        [actionSheet showInView:self.view];
    }
}


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        if (buttonIndex == 0) {
            [self showImagePickerForCamera:nil];
        }
        else if (buttonIndex == 1) {
            [self showImagePickerForPhotoPicker:nil];
        }
    }
    else {
        if (buttonIndex == 0) {
            [self showImagePickerForPhotoPicker:nil];
        }
    }
}

- (void)showImagePickerForCamera:(id)sender
{
    [self showImagePickerForSourceType:UIImagePickerControllerSourceTypeCamera];
}


- (void)showImagePickerForPhotoPicker:(id)sender
{
    [self showImagePickerForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
}

- (void)showImagePickerForSourceType:(UIImagePickerControllerSourceType)sourceType
{
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.modalPresentationStyle = UIModalPresentationCurrentContext;
    imagePickerController.sourceType = sourceType;
    imagePickerController.delegate = self;
    imagePickerController.allowsEditing = YES;
    
    self.imagePicker = imagePickerController;
    [self presentViewController:self.imagePicker animated:YES completion:nil];
}



#pragma mark - UIImagePickerControllerDelegate

// This method is called when an image has been chosen from the library or taken from the camera.
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    self.hasChanged = true;
    UIImage *image = [info valueForKey:UIImagePickerControllerEditedImage];
    CGSize size = image.size;
    //resize photos to a smaller size to not take up too much space and allow faster up/downloads
    CGFloat maxWidth = 800;
//    CGFloat maxWidth = MAX(self.view.bounds.size.width, self.view.bounds.size.height);
    if (image.size.width > maxWidth) {
        size = CGSizeMake(maxWidth, image.size.height * (maxWidth / image.size.width));
    }
    
    CGRect rect = CGRectMake(0,0,size.width,size.height);
    UIGraphicsBeginImageContext( rect.size );
    [image drawInRect:rect];
    UIImage *resized = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    self.photo = resized;
    
    //to allow for text responder
    self.isNewPhoto = false;
    
    [self.tableView reloadData];
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}


#pragma mark - 

-(void)chooseType:(id)sender {
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:nil message:NSLocalizedString(@"Choose a Category", nil) preferredStyle:UIAlertControllerStyleActionSheet];
    [actionSheet addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Dialogue", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        self.hasChanged = true;
        self.noteCategory = NoteCategoryDialog;
        [self updateCategoryImage];
    }]];
    [actionSheet addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Positive Response", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        self.hasChanged = true;
        self.noteCategory = NoteCategoryPositive;
        [self updateCategoryImage];
    }]];
    [actionSheet addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Anxious/Negative Response", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        self.hasChanged = true;
        self.noteCategory = NoteCategoryAnxiety;
        [self updateCategoryImage];
    }]];
    [actionSheet addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
    }]];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        actionSheet.popoverPresentationController.barButtonItem = sender;
        actionSheet.popoverPresentationController.sourceView = self.view;
    }
    [self presentViewController:actionSheet animated:YES completion:nil];
}

-(void)updateCategoryImage {
    NoteCell *cell = (NoteCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:NoteSectionNote]];
    cell.categoryIcon.image = [UIImage imageNamed:[Note imageNameForCategoryImage:self.noteCategory]];
}

-(void)save {
    NoteCell *cell = (NoteCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:NoteSectionNote]];
    if (!self.note) {
        self.note = [[Note alloc] init];
    }
    else {
        RLMRealm *defaultRealm = [RLMRealm defaultRealm];
        [defaultRealm beginWriteTransaction];
    }
    self.note.categoryId = self.noteCategory;
    self.note.note = cell.textView.text;
    self.note.updatedAt = [NSDate date];
    self.note.isHighlight = self.isOpportunity;
    self.note.segmentId = self.segment.segmentId;
    if ([[GoShadowAPIManager sharedManager] getCurrentUser]) {
        self.note.userId = [[GoShadowAPIManager sharedManager] getCurrentUser].userId;
    }
    if (self.photo) {
        self.note.attachmentFile = UIImagePNGRepresentation(self.photo);        
    }

    
    if (self.note.noteId != 0) {
        //put
        self.note.localStatus = NoteLocalStatusUpdate;
        [[GoShadowAPIManager sharedManager] putNote:self.note withCallback:^(id result, NSError *error) {
            if (result) {
                [self.navigationController popViewControllerAnimated:true];
            }
            else {
                
            }
        }];
    }
    else {
        self.note.createdAt = [NSDate date];
        self.note.localStatus = NoteLocalStatusAdd;
        //post
        [[GoShadowAPIManager sharedManager] postNote:self.note withCallback:^(id result, NSError *error) {
            if (result) {
                [self.navigationController popViewControllerAnimated:true];
            }
            else {
                
            }
        }];
    }
}

-(void)toggleCaregivers:(id)sender {
    self.caregiversExpanded = !self.caregiversExpanded;
//    [self.tableView reloadData];
    if (!self.caregiversExpanded) {
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:NoteSectionCaregiver] withRowAnimation:UITableViewRowAnimationBottom];
    }
    else {
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:NoteSectionCaregiver] withRowAnimation:UITableViewRowAnimationNone];
    }

}

-(void)toggleTouchpoints:(id)sender {
    self.touchpointsExpanded = !self.touchpointsExpanded;
//    [self.tableView reloadData];
    if (!self.touchpointsExpanded) {
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:NoteSectionTouchpoint] withRowAnimation:UITableViewRowAnimationBottom];
    }
    else {
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:NoteSectionTouchpoint] withRowAnimation:UITableViewRowAnimationNone];
    }
}

-(void)showPhoto:(id)sender {
    [self.view endEditing:YES];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.navigationController.view.bounds.size.width, self.navigationController.view.bounds.size.height)];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.backgroundColor = [UIColor blackColor];
    
    if (self.photo) {
        imageView.image = self.photo;
    }
    else {
        [imageView setImageWithURL:[NSURL URLWithString:self.photoUrl] placeholderImage:nil];
    }
    [imageView setUserInteractionEnabled:true];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hidePhoto:)];
    [imageView addGestureRecognizer:tap];
    [self.navigationController.view addSubview:imageView];
}

-(void)hidePhoto:(id)sender {
    if ([[sender view] isKindOfClass:[UIImageView class]]) {
        [[sender view] removeFromSuperview];
    }
}

#pragma mark -

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqual:@"\n"]) {
        [textView resignFirstResponder];
        self.noteString = textView.text;
        [self save];
        return NO;
    }
    self.hasChanged = true;
    return YES;
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
