//
//  NoteCell.h
//  GoShadow
//
//  Created by Shawn Wall on 8/19/15.
//  Copyright (c) 2015 Inquiri. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NoteCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UILabel *noteLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateTimeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *categoryIcon;
@property (weak, nonatomic) IBOutlet UIImageView *opportunityImage;

@end
