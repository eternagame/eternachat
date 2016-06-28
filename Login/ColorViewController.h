//
//  ColorViewController.h
//  Project: Eterna Chat
//
//  Created by Vineet Kosaraju on 7/1/15.
//  Copyright (c) 2016 Eterna. All rights reserved.
//  Controls behavior for the color chooser window
//  Taken largely from samples for the HRColorPickerView (Pods)

#import <UIKit/UIKit.h>
#import "HRColorPickerView.h"

@protocol HRColorPickerViewControllerDelegate

// Delegate method that is called when the color is changed
- (void)setSelectedColor:(UIColor *)color;

@end

@interface ColorViewController : UIViewController {
    
    // The actual color picker page
    @public HRColorPickerView *colorPickerView;
}

@property (weak) id <HRColorPickerViewControllerDelegate> delegate;

// The initialization method that is called with a default color
- (id)initWithColor:(UIColor *)defaultColor;

@end