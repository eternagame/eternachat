//
//  BaseViewController.m
//  Project: Eterna Chat
//
//  Created by Vineet Kosaraju on 7/1/15.
//  Copyright (c) 2016 Eterna. All rights reserved.
//  Controls behavior for the tab view

#import "BaseViewController.h"
#import "CAPSPageMenu.h"
#import "AppDelegate.h"
#import "ColorViewController.h"

@interface BaseViewController ()
@end

@implementation BaseViewController

// Initializes this controller by loading a color to the ColorViewController
// It will either use whatever value is stored in the properties database or
// the value represented by the given user ID (uid).
- (void) saveColorUID:(NSString *)uid {
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    UIColor* color = [appDelegate.loginViewController colorFromHexString: [appDelegate.homeViewController->colors objectAtIndex:( (int) ([uid integerValue] % 62))] ];

    NSData *defaultColorData = [[NSUserDefaults standardUserDefaults] objectForKey:@"userColor"];
    if(defaultColorData != nil) {
        color = [NSKeyedUnarchiver unarchiveObjectWithData:defaultColorData];
    }

    [self saveColor:color];
}

// Saves the current color to the given color
- (void) saveColor:(UIColor *)newcolor {
    currentColor = newcolor;
    [self updateColor];
}

// Updates the local properties database with the current color value
- (void) updateColor {
    NSData *colorData = [NSKeyedArchiver archivedDataWithRootObject:currentColor];
    [[NSUserDefaults standardUserDefaults] setObject:colorData forKey:@"userColor"];
}

// Delegate method for the color picker window that simply saves the chosen color
- (void) setSelectedColor:(UIColor *)color {
    [self saveColor:color];
}

// Called when this specific view loads
- (void)viewDidLoad {
    [super viewDidLoad];

    // Remove the status bar since it interferes with the tabs at the top of the screen
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
    // Access the application delegate to access other controllers & their methods
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    
    // The aray that keeps track of controllers in page menu
    NSMutableArray *controllerArray = [NSMutableArray array];

    // Add the chat page to the list of tabs
    [controllerArray addObject:appDelegate.homeViewController];
    
    // Create and add the color cusotmization page
    colorController = [[ColorViewController alloc] initWithColor:currentColor];
    colorController.title = @"Color";
    colorController.delegate = self; // Whenever a new color is chosen, notify this controller
    [controllerArray addObject:colorController];
    
    // Customize the color chooser so it uses specific colors & heights
    // Here we use the previously saved app delegate to access the 'colorFromHexString'
    // method of loginViewController.
    // A better designed class sytem would have this method go in a utility class but this
    // is OK for now.
    NSDictionary *parameters = @{
                                 CAPSPageMenuOptionBottomMenuHairlineColor: [appDelegate.loginViewController colorFromHexString:@"#AECEFF"],
                                 
                                 CAPSPageMenuOptionSelectionIndicatorColor:[appDelegate.loginViewController colorFromHexString:@"#AECEFF"],
                                 
                                 CAPSPageMenuOptionMenuHeight: @(39.0),
                                 CAPSPageMenuOptionScrollMenuBackgroundColor: [appDelegate.loginViewController colorFromHexString:@"#21608F"],
                                 CAPSPageMenuOptionMenuMargin: @(0.0),
                                 CAPSPageMenuOptionMenuItemWidth: @([UIScreen mainScreen].bounds.size.width/2.0),
                                 CAPSPageMenuOptionUnselectedMenuItemLabelColor: ([UIColor whiteColor])
                                 };
    
    
    // Initialize the page menu with the size of the phone frame
    _pagemenu = [[CAPSPageMenu alloc] initWithViewControllers:controllerArray frame:CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height) options:parameters];
    
    // Add the page menu as subview of the current one
    [self.view addSubview:_pagemenu.view];
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

@end
