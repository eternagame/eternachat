//
//  BaseViewController.h
//  Project: Eterna Chat
//
//  Created by Vineet Kosaraju on 7/1/15.
//  Copyright (c) 2016 Eterna. All rights reserved.
//  Controls behavior for the tab view

#import <UIKit/UIKit.h>
#import "CapsPageMenu.h"
#import "ColorViewController.h"

@interface BaseViewController : UIViewController <HRColorPickerViewControllerDelegate> {
    
    // The current color that the user's username should output as
    @public UIColor *currentColor;
    
    // The window that lets the user change their username color
    ColorViewController *colorController;
}

// The left-right tab page scroller
@property (nonatomic) CAPSPageMenu *pagemenu;

// Initializes this controller by loading a color to the ColorViewController
// It will either use whatever value is stored in the properties database or
// the value represented by the given user ID (uid).
- (void) saveColorUID:(NSString *)uid;

// Saves the current color to the given color
- (void) saveColor:(UIColor *)newcolor;

// Updates the local properties database with the current color value
- (void) updateColor;

@end
