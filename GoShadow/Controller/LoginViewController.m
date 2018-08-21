//
//  LoginViewController.m
//  GoShadow
//
//  Created by Shawn Wall on 7/28/15.
//  Copyright (c) 2015 Inquiri. All rights reserved.
//

#import "LoginViewController.h"
#import "AppDelegate.h"
#import "GoShadowAPIManager.h"
#import <SVProgressHUD.h>
#import "TTUITextField.h"
#import <Intercom/Intercom.h>
#import "Shadower.h"
#import "TTUIButton.h"

@interface LoginViewController () <UITextFieldDelegate>

@property BOOL isKeyboardShown;
@property BOOL viewsSetup;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    if (self.view.bounds.size.height > 480.0) {
        [self.signupScrollView setScrollEnabled:false];
    }
    [self.signupScrollView setHidden:true];
    
    [self.signupButton useLightBlueButtonStyle];
    [self.signInButton useLightBlueButtonStyle];
    [self.createAccountButton useLightBlueButtonStyle];
    
    self.emailText.autocorrectionType = UITextAutocorrectionTypeNo;
    self.passwordText.autocorrectionType = UITextAutocorrectionTypeNo;

    [self.toggleSignInButton setTitleColor:[UIColor gsLightCyanColor] forState:UIControlStateNormal];
    
    self.emailText.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Email Address", nil) attributes:@{ NSForegroundColorAttributeName : [UIColor gsLightCyanColor] }];
    self.passwordText.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Password", nil) attributes:@{ NSForegroundColorAttributeName : [UIColor gsLightCyanColor] }];

    self.firstNameText.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"First Name", nil) attributes:@{ NSForegroundColorAttributeName : [UIColor gsLightCyanColor] }];
    self.lastNametext.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Last Name", nil) attributes:@{ NSForegroundColorAttributeName : [UIColor gsLightCyanColor] }];
    self.orgNameText.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Organization Name", nil) attributes:@{ NSForegroundColorAttributeName : [UIColor gsLightCyanColor] }];
    self.signupEmailText.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Email Address", nil) attributes:@{ NSForegroundColorAttributeName : [UIColor gsLightCyanColor] }];
    self.signupPasswordText.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Password", nil) attributes:@{ NSForegroundColorAttributeName : [UIColor gsLightCyanColor] }];
    
    self.passwordText.secureTextEntry = YES;
    self.signupPasswordText.secureTextEntry = YES;
    
    self.emailText.delegate = self;
    self.passwordText.delegate = self;
    self.firstNameText.delegate = self;
    self.lastNametext.delegate = self;
    self.orgNameText.delegate = self;
    self.signupEmailText.delegate = self;
    self.signupPasswordText.delegate = self;

#ifdef DEBUG
    self.emailText.text = @"test@goshadow.org";
    self.passwordText.text = @"3astliberty";
#endif
    
    [self registerForKeyboardNotifications];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self.emailText useUnderlineStyle];
    [self.passwordText useUnderlineStyle];
    [self.firstNameText useUnderlineStyle];
    [self.lastNametext useUnderlineStyle];
    [self.orgNameText useUnderlineStyle];
    [self.signupEmailText useUnderlineStyle];
    [self.signupPasswordText useUnderlineStyle];
}

#pragma mark Keyboard

- (void)registerForKeyboardNotifications
{
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
}

// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWillShow:(NSNotification*)aNotification
{
    if (!self.isKeyboardShown) {
        
        NSDictionary* userInfo = [aNotification userInfo];
        NSTimeInterval animationDuration;
        UIViewAnimationCurve animationCurve;
        CGRect keyboardEndFrame;
        
        [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
        [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
        [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardEndFrame];
        
        if (keyboardEndFrame.size.height > 0) {
            self.isKeyboardShown = YES;
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDuration:animationDuration];
            [UIView setAnimationCurve:animationCurve];
            CGRect keyboardFrame = [self.view convertRect:keyboardEndFrame toView:nil];
            self.loginConstraint.constant = keyboardFrame.size.height;
            [self.view layoutIfNeeded];
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
                self.logoView.alpha = 0.0;
            }
            [UIView commitAnimations];
        }
    }
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    NSDictionary* userInfo = [aNotification userInfo];
    NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    CGRect keyboardEndFrame;
    
    [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardEndFrame];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:animationCurve];
    self.loginConstraint.constant = 0.0;
    [self.view layoutIfNeeded];
    if (!self.loginView.isHidden) {
        self.logoView.alpha = 1.0;
    }

    [UIView commitAnimations];
    self.isKeyboardShown = NO;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

- (IBAction)signIn:(id)sender {
    if (self.emailText.text.length <= 0) {
        UIAlertController *error = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"Please enter your e-mail address", nil) actions:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:nil],nil];
        [self presentViewController:error animated:YES completion:nil];
        return;
    }
    if (self.passwordText.text.length <= 0) {
        UIAlertController *error = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"Please enter a password", nil) actions:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:nil],nil];
        [self presentViewController:error animated:YES completion:nil];
        return;
    }
    
    [SVProgressHUD showWithStatus:NSLocalizedString(@"Logging in...", nil)];
    [[GoShadowAPIManager sharedManager] authenticateWithEmail:self.emailText.text password:self.passwordText.text callback:^(id result, NSError *error) {
        if (!error) {
            //load necessary data
            [[GoShadowAPIManager sharedManager] updateDataWithCallback:^(id result, NSError *error) {
                Shadower *user = [[GoShadowAPIManager sharedManager] getCurrentUser];
                if (user) {
                    NSString *userId = [@(user.userId) stringValue];
                    [Intercom registerUserWithUserId:userId];
                    [Intercom updateUserWithAttributes:@{ @"email" : user.email,
                                                          @"name" : [NSString stringWithFormat:@"%@ %@", user.firstName, user.lastName],
                                                          @"created_at" : [[NSDate date] mt_stringFromDateWithFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZZ" localized:true]}];
                }
                [SVProgressHUD dismiss];                
                if (!error || true) {
                    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
                    [appDelegate showMainStoryboard];
                }
                else {
                    UIAlertController *error = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"An error occurred downloading application data", nil) actions:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:nil],nil];
                    [self presentViewController:error animated:YES completion:nil];
                }
            }];

        }
        else {
            [SVProgressHUD dismiss];
            if (result != nil && [result isKindOfClass:[NSArray class]] && [result count]) {
                if ([result containsObject:@4]) {
                    UIAlertController *error = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Your Email or Password is invalid", nil) message:NSLocalizedString(@"Please check your spelling and try again.", nil) actions:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:nil],nil];
                    [self presentViewController:error animated:YES completion:nil];
                }
            }
            else {
                UIAlertController *error = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"An error occurred logging in.", nil) actions:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:nil],nil];
                [self presentViewController:error animated:YES completion:nil];
            }
        }
    }];
}

- (IBAction)forgetPassword:(id)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Reset Password", nil) message:NSLocalizedString(@"Enter your email address to reset your password.", nil) preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = NSLocalizedString(@"Enter Email Address", @"Placeholder");
    }];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Send", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        UITextField *email = [alert.textFields firstObject];
        if (email.text.length) {
            [[GoShadowAPIManager sharedManager] resetPasswordWithEmail:email.text callback:^(id result, NSError *error) {
                if (error) {
                    UIAlertController *error = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"Email not found", nil) actions:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:nil],nil];
                    [self presentViewController:error animated:YES completion:nil];
                }
            }];
        }
        else {
            UIAlertController *error = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"Please enter an email address", nil) actions:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:nil],nil];
            [self presentViewController:error animated:YES completion:nil];
        }
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (IBAction)tour:(id)sender {

}

- (IBAction)showCreateAccount:(id)sender {
    self.logoView.alpha = 0.0;
    
    [self.loginView setHidden:true];
    [self.signupScrollView setHidden:false];
    [self.signupScrollView setContentOffset:CGPointZero animated:false];
}

-(BOOL)validateSignUp {
    self.signupEmailText.text = [self.signupEmailText.text lowercaseString];
    if (![self.firstNameText.text length]) {
        UIAlertController *error = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Required Field", nil) message:NSLocalizedString(@"Please enter your first name", nil) actions:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:nil],nil];
        [self presentViewController:error animated:YES completion:nil];
        return false;
    }
    if (![self.lastNametext.text length]) {
        UIAlertController *error = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Required Field", nil) message:NSLocalizedString(@"Please enter your last name", nil) actions:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:nil],nil];
        [self presentViewController:error animated:YES completion:nil];
        return false;
    }
    if (![self.orgNameText.text length]) {
        UIAlertController *error = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Required Field", nil) message:NSLocalizedString(@"Please enter an organization", nil) actions:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:nil],nil];
        [self presentViewController:error animated:YES completion:nil];
        return false;
    }
    if (![self.signupEmailText.text length]) {
        UIAlertController *error = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Required Field", nil) message:NSLocalizedString(@"Please enter your e-mail address", nil) actions:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:nil],nil];
        [self presentViewController:error animated:YES completion:nil];
        return false;
    }
    if (![self.signupPasswordText.text length]) {
        UIAlertController *error = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Required Field", nil) message:NSLocalizedString(@"Please enter a password", nil) actions:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:nil],nil];
        [self presentViewController:error animated:YES completion:nil];
        return false;
    }
    return true;
}

- (IBAction)signUp:(id)sender {
    if ([self validateSignUp]) {
        [SVProgressHUD showWithStatus:NSLocalizedString(@"Creating Account...", nil)];
        [[GoShadowAPIManager sharedManager] signupWithEmail:self.signupEmailText.text password:self.signupPasswordText.text firstName:self.firstNameText.text lastName:self.lastNametext.text organization:self.orgNameText.text callback:^(id result, NSError *error) {
            [SVProgressHUD dismiss];
            if (!error) {
                self.emailText.text = self.signupEmailText.text;
                self.passwordText.text = self.signupPasswordText.text;
                [self signIn:nil];
            }
            else {
                if (result != nil && [result isKindOfClass:[NSArray class]] && [result count]) {
                    if ([result containsObject:@1]) {
                        UIAlertController *error = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"This email address has already been taken", nil) message:NSLocalizedString(@"Do you want to reset your password?", nil) actions:[UIAlertAction actionWithTitle:NSLocalizedString(@"Yes", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                            [self forgetPassword:nil];
                        }], [UIAlertAction actionWithTitle:NSLocalizedString(@"No", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                            
                        }],nil];
                        [self presentViewController:error animated:YES completion:nil];
                    }
                    else if ([result containsObject:@3]) {
                        UIAlertController *error = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Your Email Address is Invalid", nil) message:NSLocalizedString(@"Please check your spelling and try again.", nil) actions:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:nil],nil];
                        [self presentViewController:error animated:YES completion:nil];
                    }
                    else if ([result containsObject:@4]) {
                        UIAlertController *error = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Your Email or Password is invalid", nil) message:NSLocalizedString(@"Please check your spelling and try again.", nil) actions:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:nil],nil];
                        [self presentViewController:error animated:YES completion:nil];
                    }
                }
                else {
                    UIAlertController *error = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"An error occurred creating your account", nil) actions:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:nil],nil];
                    [self presentViewController:error animated:YES completion:nil];
                }
            }
        }];
    }
}

- (IBAction)showSignIn:(id)sender {
    if (!self.isKeyboardShown) {
        self.logoView.alpha = 1.0;
    }
    [self.loginView setHidden:false];
    [self.signupScrollView setHidden:true];
}

-(void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        [self.view setNeedsLayout];
    } completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {

    }];
}

//- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
//    return UIInterfaceOrientationMaskPortrait;
//}


@end
