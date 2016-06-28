//
//  LoginViewController.h
//  Project: Eterna Chat
//
//  Created by Vineet Kosaraju on 7/1/15.
//  Copyright (c) 2015 Eterna. All rights reserved.
//  Controls behavior for the login window

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@interface LoginViewController : UIViewController <UITextFieldDelegate>

// Convert a hex string into a UIColor object
- (UIColor*)colorFromHexString:(NSString*)hexString;

// Convert a UIColor object into a hex string
- (NSString *)hexStringFromColor:(UIColor *)color;

// The sign in code that is called when the user clicks the "sign in" button
- (IBAction)signInAction:(id)sender;

// The main page that holds the UI - it is a scrollview so that when a keyboard
// is shown, the view will move up and down
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

// UI elements for the username input, password input, and button to sign in
@property (weak, nonatomic) IBOutlet UITextField *username;
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (weak, nonatomic) IBOutlet UIButton *signInButton;

@end
