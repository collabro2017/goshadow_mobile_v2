//
//  UIAlertController+Utilities.m
//
//  Created by valvoline on 18/12/14.
//  Copyright (c) 2014 sofapps. All rights reserved.
//

#import "UIAlertController+Utilities.h"

@implementation UIAlertController (Utilities)

+ (UIAlertController*)alertControllerWithTitle:(NSString *)aTitle
                                       message:(NSString *)aMessage
                                  actions:(UIAlertAction *)cancelAct, ...
{
    va_list args;
    va_start(args, cancelAct);
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:aTitle
                                                                   message:aMessage
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    for (UIAlertAction *anAct = cancelAct; anAct != nil; anAct = va_arg(args, UIAlertAction*))
    {
        [alert addAction:anAct];
    }
    va_end(args);
    return alert;
}


+ (UIAlertController*)sheetControllerWithTitle:(NSString *)aTitle
                                       message:(NSString *)aMessage
                                       actions:(UIAlertAction *)cancelAct, ...
{
    va_list args;
    va_start(args, cancelAct);
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:aTitle
                                                                   message:aMessage
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    
    for (UIAlertAction *anAct = cancelAct; anAct != nil; anAct = va_arg(args, UIAlertAction*))
    {
        [alert addAction:anAct];
    }
    va_end(args);
    return alert;
}

@end
