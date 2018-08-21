//
//  NoteCell.m
//  GoShadow
//
//  Created by Shawn Wall on 8/19/15.
//  Copyright (c) 2015 Inquiri. All rights reserved.
//

#import "NoteCell.h"

@implementation NoteCell

- (void)awakeFromNib {
    // Initialization code
    self.textView.hidden = YES;
    
    if ([UIScreen mainScreen].bounds.size.height <= 480) {
        self.textView.autocorrectionType = UITextAutocorrectionTypeNo;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
