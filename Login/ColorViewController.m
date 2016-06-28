//
//  ColorViewController.m
//  Project: Eterna Chat
//
//  Created by Vineet Kosaraju on 7/1/15.
//  Copyright (c) 2016 Eterna. All rights reserved.
//  Controls behavior for the color chooser window
//  Taken largely from samples for the HRColorPickerView (Pods)

#import "ColorViewController.h"
#import "HRColorPickerView.h"
#import "HRColorMapView.h"
#import "HRBrightnessSlider.h"
#import "AppDelegate.h"

@interface ColorViewController ()

@end

@implementation ColorViewController {

    // The delegate that this controller should send events to
    id <HRColorPickerViewControllerDelegate> __weak delegate;
    
    // The color that has been selected
    UIColor *_color;

}

@synthesize delegate;

// Create this controller with the given color by additionally setting the local instance variable
- (id)initWithColor:(UIColor *)defaultColor {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _color = defaultColor;
    }
    return self;
}

// When the view is loaded, add the color picker UI widget
- (void)loadView {
    self.view = [[UIView alloc] init];

    colorPickerView = [[HRColorPickerView alloc] init];
    colorPickerView.color = _color;
    
    [self.view addSubview:colorPickerView];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    colorPickerView.frame = (CGRect) {.origin = CGPointZero, .size = self.view.frame.size};
    
    if ([self respondsToSelector:@selector(topLayoutGuide)]) {
        CGRect frame = colorPickerView.frame;
        frame.origin.y = self.topLayoutGuide.length;
        frame.size.height -= self.topLayoutGuide.length;
        colorPickerView.frame = frame;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (self.delegate) {
        [self.delegate setSelectedColor:colorPickerView.color];
    }
}

@end
