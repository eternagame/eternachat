//
//  LoginViewController.m
//  Project: Eterna Chat
//
//  Created by Vineet Kosaraju on 7/1/15.
//  Copyright (c) 2015 Eterna. All rights reserved.
//  Controls behavior for the login window

#import "LoginViewController.h"
#import "AppDelegate.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

// Utility method that converts a given hex string into a UIColor
// Implementation taken from stackoverflow
- (UIColor *)colorFromHexString:(NSString *)hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

// Utility method that converts a given UIColor into a hex string
// Implementation also taken from stackoverflow
- (NSString *)hexStringFromColor:(UIColor *)color {
    const CGFloat *components = CGColorGetComponents(color.CGColor);
    
    CGFloat r = components[0];
    CGFloat g = components[1];
    CGFloat b = components[2];
    
    return [NSString stringWithFormat:@"%02lX%02lX%02lX",
            lroundf(r * 255),
            lroundf(g * 255),
            lroundf(b * 255)];
}

// Called when the page (view) is successfully loaded
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Ensure that when the user inputs a username/password, all events/actions are sent to be
    // handled to this controller's code
    [[self username] setDelegate:self];
    [[self password] setDelegate:self];
    
    // Give the username and password inputs placeholders that are gray
    UIColor *color = [UIColor grayColor];
    self.username.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Username" attributes:@{NSForegroundColorAttributeName: color}];
    self.password.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Password" attributes:@{NSForegroundColorAttributeName: color}];
    
    // Remove the borders on the username and password boxes
    self.username.borderStyle = UITextBorderStyleNone;
    self.password.borderStyle = UITextBorderStyleNone;
    
    // Add a custom bottom border to the username input
    CALayer *topBorder = [CALayer layer];
    topBorder.borderColor = [UIColor whiteColor].CGColor;
    topBorder.borderWidth = 3;
    topBorder.frame = CGRectMake(0, self.username.frame.size.height - 6, 220, self.username.frame.size.height-9);
    [self.username.layer addSublayer:topBorder];
    
    // Add a custom bottom border to the password input
    CALayer *bottomBorder = [CALayer layer];
    bottomBorder.borderColor = [UIColor whiteColor].CGColor;
    bottomBorder.borderWidth = 3;
    bottomBorder.frame = CGRectMake(0, self.password.frame.size.height - 6, 220, self.password.frame.size.height-9);
    [self.password.layer addSublayer:bottomBorder];
    
    // Add a gradient to the page, similar to the gradient used on the main Eterna site
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.view.bounds;
    gradient.colors = [NSArray arrayWithObjects:(id)[[self colorFromHexString:@"#1B568C"] CGColor], (id)[[self colorFromHexString:@"#274163"] CGColor], nil];
    [self.view.layer insertSublayer:gradient atIndex:0];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

// Called when the connection receives data, this parses the data and checks if the login was successful
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData*)data {
    
    // Get the data (in JSON format) and parse it out
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    NSDictionary *dict = [json objectForKey: @"data"];
    
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

    // Hide the 'loading' activity indicator
    [MBProgressHUD hideHUDForView:self.view animated:YES];

    // Look at the success variable stored in the data
    NSInteger success = [[dict objectForKey:@"success"] integerValue];
    
    // If it was unsuccessful, read out the error and display a new popup
    if(success == 0) {
        NSString *message = json[@"data"][@"error"];
        [[self password] setText:@""];

        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:message
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    } else {
        // Otherwise, it was a successful login
        AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;

        // Prepare the chat window by initializing a connection to the IRC server
        [appDelegate.homeViewController initNetworkCommunication];
        
        // Also prepare the chat window by joining the chat server and accessing the correct user color
        [appDelegate.homeViewController joinChat:self.username.text withUID:json[@"data"][@"uid"]];
        [appDelegate.baseViewController saveColorUID:json[@"data"][@"uid"]];
        
        // Finally, transition to a new page in the application of the baseViewController,
        // which lets the user switch between displaying the chat and the color settings
        [appDelegate.window setRootViewController:appDelegate.baseViewController];
    }
    
}

// If the connection fails, show a new error in a pop up
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"Error occured :( %@", error);
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                    message:[error localizedDescription]
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

// Ensure that this page always stays as portrait
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

// Delegate method for when the login connection attempt is done loading
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
}

// Ensure that the keyboard hides when return is clicked
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

// Add keyboard registration to this controller when the managed view appears
- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    [self registerForKeyboardNotifications];
    
}

// Remove keyboard registration from this controller when the managed view disappears
- (void)viewWillDisappear:(BOOL)animated {
    
    [self deregisterFromKeyboardNotifications];
    [super viewWillDisappear:animated];
    
}

// If the keyboard is shown, scroll up/down the page to accomodate and give it extra space
- (void)keyboardWasShown:(NSNotification *)notification {
    
    NSDictionary* info = [notification userInfo];
    
    CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    CGPoint buttonOrigin = self.signInButton.frame.origin;
    
    CGFloat buttonHeight = self.signInButton.frame.size.height;
    
    CGRect visibleRect = self.view.frame;
    
    visibleRect.size.height -= keyboardSize.height;
    
    if (!CGRectContainsPoint(visibleRect, buttonOrigin)){
        
        CGPoint scrollPoint = CGPointMake(0.0, buttonOrigin.y - visibleRect.size.height + buttonHeight + 10);
        
        [self.scrollView setContentOffset:scrollPoint animated:YES];
        
    }
    
}

// When the keyboard is hidden, move all the content back down the page
- (void)keyboardWillBeHidden:(NSNotification *)notification {
    
    [self.scrollView setContentOffset:CGPointZero animated:YES];
    
}

// Register for keyboard notifications by handling when the keyboard is shown/hidden
- (void)registerForKeyboardNotifications {
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
}

// Deregister for keyboard notifications by removing the handling for when the keyboard is shown/hidden
- (void)deregisterFromKeyboardNotifications {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardDidHideNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
    
}

// When the "Sign in" button is clicked, create a new POST request to eterna
- (IBAction)signInAction:(id)sender {
    
    // Create a POST request with the given data set to:
    // name: the username of the user
    // pass: the password of the user
    // type: the type of the request (in this case 'login')
    // workbranch: the workbranch to login to (in this case, since it is the main server, 'main')
    NSString *post = [NSString stringWithFormat:@"name=%@&pass=%@&type=%@&workbranch=%@",self.username.text,self.password.text, @"login", @"main"];
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%lu",(unsigned long)[postData length]];
    
    // Set the request's URL to the eternagame login URL
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://eternagame.org/login/"]];
    
    // Send the post request
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];

    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    // Show the activity indicator as loading
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    // Disable further button clicks / keyboard changes
    [self.view endEditing:YES];
    
}
@end
