//
//  TTUITextField.m
//
//  Created by Shawn Wall on 12/16/12.
//  Copyright (c) 2012 TwoTap Labs. All rights reserved.
//

#import "TTUITextField.h"
#import <QuartzCore/QuartzCore.h>

@interface TTUITextField ()

@property (strong, nonatomic) CALayer *bottomBorder;

@end

@implementation TTUITextField

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initialize];
    }
    return self;
}

-(void)initialize {
    [self useDefaultStyle];
}

-(void)useDefaultStyle {
    CALayer *layer = self.layer;
    [layer setBorderWidth:1.0];
    [layer setBorderColor:[UIColor gsLightGrayColor].CGColor];
    [self setFont:[UIFont systemFontOfSize:16.0f]];
    layer.sublayerTransform = CATransform3DMakeTranslation(12, 0, 0);
}

-(void)useUnderlineStyle {
    if (!self.bottomBorder) {
        self.bottomBorder = [CALayer layer];
        [self.layer addSublayer:self.bottomBorder];
    }
    self.bottomBorder.frame = CGRectMake(0.0f, self.bounds.size.height - 1, self.bounds.size.width, 1.0f);
    self.bottomBorder.backgroundColor = [UIColor gsLightCyanColor].CGColor;
    [self.layer setBorderWidth:0.0];
    self.textColor = [UIColor whiteColor];
    self.font = [UIFont systemFontOfSize:20.0];
    self.layer.sublayerTransform = CATransform3DMakeTranslation(0, 0, 0);
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
