//
//  NotePhotoCell.m
//  GoShadow
//
//  Created by Shawn Wall on 8/19/15.
//  Copyright (c) 2015 Inquiri. All rights reserved.
//

#import "NotePhotoCell.h"

@interface NotePhotoCell ()

@property (weak, nonatomic) IBOutlet UIView *borderView;

@end

@implementation NotePhotoCell

- (void)awakeFromNib {
    // Initialization code
    self.textView.hidden = YES;
    self.borderView.layer.borderColor = [UIColor gsLightGrayColor].CGColor;
    self.borderView.layer.borderWidth = 1.0;
    self.borderView.layer.cornerRadius = 2.0;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
