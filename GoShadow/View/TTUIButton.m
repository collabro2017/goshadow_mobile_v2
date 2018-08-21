//
//  TTUIButton.m
//
//  Created by Shawn Wall on 12/16/12.
//  Copyright (c) 2012 TwoTap Labs. All rights reserved.
//

#import "TTUIButton.h"
#import <QuartzCore/QuartzCore.h>

typedef enum {
    TTUIButtonStyleBlue,
    TTUIButtonStyleLightBlue
} TTUIButtonStyle;

@interface TTUIButton ()

@property (nonatomic) TTUIButtonStyle style;

@end

@implementation TTUIButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self useBlueButtonStyle];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self useBlueButtonStyle];
    }
    return self;
}

-(void)useBlueButtonStyle {
    self.style = TTUIButtonStyleBlue;
    self.layer.borderColor = [UIColor gsCyanColor].CGColor;
    self.layer.borderWidth = 1.0f;
    [self setBackgroundColor:[UIColor clearColor]];
    [self setTitleColor:[UIColor gsCyanColor] forState:UIControlStateNormal];
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [self setTitleColor:[UIColor gsLightCyanColor] forState:UIControlStateDisabled];
    [self.titleLabel setFont:[UIFont systemFontOfSize:18.0]];
}

-(void)useLightBlueButtonStyle {
    self.style = TTUIButtonStyleBlue;
    self.layer.borderColor = [UIColor gsLightCyanColor].CGColor;
    self.layer.borderWidth = 1.0f;
    [self setBackgroundColor:[UIColor clearColor]];
    [self setTitleColor:[UIColor gsLightCyanColor] forState:UIControlStateNormal];
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [self setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    [self.titleLabel setFont:[UIFont systemFontOfSize:18.0]];
}

-(void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    if (highlighted) {
        switch (self.style) {
            case TTUIButtonStyleBlue:
            {
                [self setBackgroundColor:[UIColor clearColor]];
                break;
            }
            default:
                break;
        }
    }
    else {
        switch (self.style) {
            case TTUIButtonStyleBlue:
            {
                [self setBackgroundColor:[UIColor clearColor]];
                break;
            }
            default:
                break;
        }
    }
}

-(void)setEnabled:(BOOL)enabled {
    [super setEnabled:enabled];
    if (enabled) {
        switch (self.style) {
            case TTUIButtonStyleBlue:
            {
                [self setBackgroundColor:[UIColor clearColor]];
                self.layer.borderColor = [UIColor gsCyanColor].CGColor;
                break;
            }
            default:
                break;
        }
    }
    else {
        switch (self.style) {
            case TTUIButtonStyleBlue:
            {
                self.layer.borderColor = [UIColor gsLightCyanColor].CGColor;
                [self setBackgroundColor:[UIColor clearColor]];
                break;
            }
            default:
                break;
        }
    }
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
