//
//  AppDelegate.h
//  Project: Eterna Chat
//
//  Created by Vineet Kosaraju on 7/1/15.
//  Copyright (c) 2015 Eterna. All rights reserved.
//  Class that handles overall application behavior (delegates actions/events)

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "HomeViewController.h"
#import "LoginViewController.h"
#import "BaseViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

// This class also has instance variables to keep track of various phone screens (called views)
// These views are each handled/controlled by their controllers

// homeViewController: The main page of the app where the user can chat
@property (nonatomic, strong) HomeViewController *homeViewController;

// loginViewController: The login page of the app (first page the user sees)
@property (nonatomic, strong) LoginViewController *loginViewController;

// baseViewController: The tabbed page that lets the user switch between the chat page
// and the color settings page
@property (nonatomic, strong) BaseViewController *baseViewController;

- (void) saveContext;
- (NSURL *) applicationDocumentsDirectory;


@end

