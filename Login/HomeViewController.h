//
//  HomeViewController.h
//  Project: Eterna Chat
//
//  Created by Vineet Kosaraju on 7/1/15.
//  Copyright (c) 2015 Eterna. All rights reserved.
//  Controls behavior for the chat window

#import <UIKit/UIKit.h>

@interface HomeViewController : UIViewController <UITextFieldDelegate, UIWebViewDelegate, UIAlertViewDelegate> {
    
    // Input and output streams that connect to the IRC server
    NSInputStream *inputStream;
    NSOutputStream *outputStream;
    
    // Whether or not the connection was successful
    BOOL connectionSuccessful;
    
    // The username and user ID (uid)
    NSString *originalUserName;
    NSString *originalUID;
    
    // Keeps track of whether or not the keyboard is shown
    BOOL centerInit;
    
    // Whether or not the chat history was loaded
    BOOL loadedHistory;
    
    // Eterna's predefined list of normal/default colors
    @public NSArray *colors;

}

// Function that sends a message to the IRC server (connected to the user clicking the send button)
- (IBAction)sendIRCMessage:(id)sender;

// GUI elements on the view (HomeViewController.xib)
// messageField - the text where the user can type
// webView - the output area where the user sees chat
@property (weak, nonatomic) IBOutlet UITextField *messageField;
@property (retain, nonatomic) IBOutlet UIWebView *webView;

// Utility methods created to work with IRC/chat

// Initializes the connection to the IRC server
- (void) initNetworkCommunication;

// Loads history from the HTML page
- (void) loadHistory;

// Joins the IRC server chatroom with the given username and user ID
- (void) joinChat:(NSString *)username withUID:(NSString *)uid;

// Adds the given message to the IRC chatroom, in Eterna's custom message format
- (void) formatAndAddMessage:(NSString *)message;

@end
