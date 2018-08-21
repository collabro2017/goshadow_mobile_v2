//
//  UIAlertController+Utilities.h
//
//  Created by valvoline on 18/12/14.
//  Copyright (c) 2014 sofapps. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIAlertController (Utilities)


+ (UIAlertController*)alertControllerWithTitle:(NSString *)aTitle
                                       message:(NSString *)aMessage
                                       actions:(UIAlertAction *)cancelAct,...;


+ (UIAlertController*)sheetControllerWithTitle:(NSString *)aTitle
                                       message:(NSString *)aMessage
                                       actions:(UIAlertAction *)cancelAct, ...;

@end
