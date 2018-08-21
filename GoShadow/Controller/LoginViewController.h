//
//  LoginViewController.h
//  GoShadow
//
//  Created by Shawn Wall on 7/28/15.
//  Copyright (c) 2015 Inquiri. All rights reserved.
//

#import <UIKit/UIKit.h>
@class TTUITextField;
@class TTUIButton;

@interface LoginViewController : UIViewController

@property (weak, nonatomic) IBOutlet TTUITextField *emailText;
@property (weak, nonatomic) IBOutlet TTUITextField *passwordText;
@property (weak, nonatomic) IBOutlet TTUIButton *signInButton;
@property (weak, nonatomic) IBOutlet UIButton *tourButton;
@property (weak, nonatomic) IBOutlet UIButton *forgetPasswordButton;
@property (weak, nonatomic) IBOutlet UIView *loginView;
@property (weak, nonatomic) IBOutlet UIImageView *logoView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *loginConstraint;
@property (weak, nonatomic) IBOutlet UIScrollView *signupScrollView;
@property (weak, nonatomic) IBOutlet TTUITextField *firstNameText;
@property (weak, nonatomic) IBOutlet TTUITextField *lastNametext;
@property (weak, nonatomic) IBOutlet TTUITextField *orgNameText;
@property (weak, nonatomic) IBOutlet TTUITextField *signupEmailText;
@property (weak, nonatomic) IBOutlet TTUITextField *signupPasswordText;
@property (weak, nonatomic) IBOutlet TTUIButton *signupButton;
@property (weak, nonatomic) IBOutlet UIButton *toggleSignInButton;
@property (weak, nonatomic) IBOutlet TTUIButton *createAccountButton;

- (IBAction)signIn:(id)sender;
- (IBAction)forgetPassword:(id)sender;
- (IBAction)tour:(id)sender;
- (IBAction)showCreateAccount:(id)sender;
- (IBAction)signUp:(id)sender;
- (IBAction)showSignIn:(id)sender;

@end
