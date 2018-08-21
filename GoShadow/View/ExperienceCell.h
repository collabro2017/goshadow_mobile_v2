//
//  ExperienceCell.h
//  GoShadow
//
//  Created by Shawn Wall on 8/24/15.
//  Copyright (c) 2015 Inquiri. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Experience;

@interface ExperienceCell : UITableViewCell

@property (nonatomic) NSInteger experienceId;

-(void)publish:(id)sender;

@end
