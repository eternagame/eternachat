//
//  HomeViewController.m
//  Project: Eterna Chat
//
//  Created by Vineet Kosaraju on 7/1/15.
//  Copyright (c) 2015 Eterna. All rights reserved.
//  Controls behavior for the chat window

#import "HomeViewController.h"
#import "AppDelegate.h"
#include <sys/socket.h>
#include <netdb.h>
#include <arpa/inet.h>
#include <err.h>

@interface HomeViewController () {
    
    // Maintain a private variable that references the appdelegate
    // This is again used to access other controllers & common utility methods
    AppDelegate *owner;
}

@end

@implementation HomeViewController

// When the controller is initialized, also create this colors array with hardcoded color values
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {

        colors = [NSArray arrayWithObjects: @"#f39191",@"#f39691",@"#f39b91",@"#f39f91",@"#f3a491",@"#f3a891",@"#f3ad91",@"#f3b191",@"#f3b691",@"#f3ba91",@"#f3bf91",@"#f3c491",@"#f3c891",@"#f3cd91",@"#f3d191",@"#f3d691",@"#f3da91",@"#f3df91",@"#f3e491",@"#f3e891",@"#f3ed91",@"#f3f191",@"#f0f391",@"#ebf391",@"#e7f391",@"#e2f391",@"#ddf391",@"#d9f391",@"#d4f391",@"#d0f391",@"#cbf391",@"#c7f391",@"#c2f391",@"#bef391",@"#b9f391",@"#b4f391",@"#b0f391",@"#abf391",@"#a7f391",@"#a2f391",@"#9ef391",@"#99f391",@"#94f391",@"#91f393",@"#91f398",@"#91f39c",@"#91f3a1",@"#91f3a5",@"#91f3aa",@"#91f3ae",@"#91f3b3",@"#91f3b7",@"#91f3bc",@"#f391ba",@"#f391b6",@"#f391b1",@"#f391ad",@"#f391a8",@"#f391a4",@"#f3919f",@"#f3919b",@"#f39196", nil];
    }
    return self;
}

// Called when the page is loaded
- (void)viewDidLoad {
    [super viewDidLoad];
    
    owner = [UIApplication sharedApplication].delegate;
    
    // Initially assume the keyboard has not been used and that the history has not been loaded
    centerInit = FALSE;
    loadedHistory = FALSE;
    
    // Ensure that whenever the user interacts with the webview or message field, this code
    // is notified and can handle the events properly
    [self.webView setDelegate:self];
    [[self messageField] setDelegate:self];
    
    // Make it so when the keyboard is hidden or shown, we call the appropriate methods
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
    
    // Load the HTML string to the main webview where all chat will be outputted
    // This HTML string merely creates the basic template and adds some barebones styling
    [self.webView loadHTMLString:@"<html style=\"background-color:#21608F; font-size: 12px;\"><head><style>a { color: white; text-decoration: underline; } </style></head><body style=\"font: 12px 'Helvetica Neue'; font-weight: 300; color: rgb(200, 200, 200);\"></body></html>" baseURL:nil];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

// If the webview is loaded and the webview contents are loaded, then this will
// load the IRC chat history and set the boolean `loadedHistory` to true
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    if ([[webView stringByEvaluatingJavaScriptFromString:@"document.readyState"] isEqualToString:@"complete"]) {
        if(!loadedHistory) {
            [self loadHistory];
            loadedHistory = TRUE;
        }
    }
}

// Moves the page up or down when the textfield is clicked
// Taken from stackoverflow
-(void)animateTextField:(BOOL)up notification:(NSNotification*)note
{
    
    NSDictionary* info = [note userInfo];
    CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    const int movementDistance = -(keyboardSize.height); // tweak as needed
    const float movementDuration = 0.3f; // tweak as needed
    
    int movement = (up ? movementDistance : -movementDistance);
    
    [UIView beginAnimations: @"animateTextField" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
    self.view.frame = CGRectOffset(self.view.frame, 0, movement);
    [UIView commitAnimations];
}

// When the keyboard is shown, move the frame up to make room for it
- (void) keyboardDidShow:(NSNotification *)note
{
    centerInit = TRUE;
    [self animateTextField:YES notification:note];
}

// When the keyboard is hidden, move the frame down to take up the extra space
- (void) keyboardDidHide:(NSNotification *)note
{
    if(centerInit) {
        [self animateTextField:NO notification:note];
    }
}

// Make the textfield disappear when the user clicks return
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

// Gets an IP value from an IPv4 literal
// This returned value can either be ipv4 or ipv6, depending on router support
// For more info check out apple's new requirements on supporting ipv6 networks
// For testing, try running iPhone/simulator on wifi, then iPhone on wifi nat64
// network emulated by mac through ethernet
- (NSString*) getIPValue:(NSString*)literal {
    
    struct addrinfo hints;
    struct addrinfo *addrs, *addr;

    const char *ipv4_str = [literal UTF8String];
    
    memset(&hints, 0, sizeof(hints));
    hints.ai_family = PF_UNSPEC;
    hints.ai_socktype = SOCK_STREAM;
    hints.ai_flags = AI_DEFAULT;
    getaddrinfo(ipv4_str, "http", &hints, &addrs);

    char host[NI_MAXHOST];
    
    for (addr = addrs; addr; addr = addr->ai_next) {
        
        getnameinfo(addr->ai_addr, addr->ai_addrlen, host, sizeof(host), NULL, 0, NI_NUMERICHOST);
        // printf("%s\n", host);
        
    }
    freeaddrinfo(addrs);
    return [NSString stringWithCString:host encoding:NSUTF8StringEncoding];
}

// Load the chat history
- (void) loadHistory {
    
    // Download the chat history from the server HTML page
    NSString * result = NULL;
    NSError *err = nil;
    NSString* siteip = [self getIPValue:@"174.129.26.87"];
    NSURL *urlToRequest;
    
    if ([siteip rangeOfString:@"::"].location == NSNotFound) {
        // ipv4
        urlToRequest = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/sites/output.html", siteip]];
    } else {
        // the ip is ipv6 literal, so use square brackets around it
        urlToRequest = [NSURL URLWithString:[NSString stringWithFormat:@"http://[%@]/sites/output.html", siteip]];
    }
    
    //NSLog(@"%@", urlToRequest);
    if(urlToRequest)
    {
        result = [NSString stringWithContentsOfURL: urlToRequest
                                          encoding:NSUTF8StringEncoding error:&err];
    }
    
    if(err) {
        NSLog(@"Error loading chat history: %@", err);
    }
    
    NSMutableArray *lines = [[result componentsSeparatedByCharactersInSet: [NSCharacterSet newlineCharacterSet]] mutableCopy];
    
    // For each loaded line, add the message to the user's output screen
    for (int i = 0; i < [lines count] - 1; i++) // last one in lines arr is a newline char/whitespace
    {
        NSString *lineMessage = [NSString stringWithFormat:@"%@", [lines objectAtIndex:i]];
        [self formatAndAddMessage:lineMessage];
    }
}

// Initialize a connection using the input/output streams to the IRC chat server
- (void)initNetworkCommunication {
    
    // Initially assume that the connection was unsuccessful
    // This will become true when the app receives MODE from server
    // After that, the app can join the main chat room, which is #global
    connectionSuccessful = false;
    
    CFReadStreamRef readStream;
    CFWriteStreamRef writeStream;
    
    // Connect to the IRC server on the 6667 port
    NSString* siteip = [self getIPValue:@"174.129.26.87"];
    CFStreamCreatePairWithSocketToHost(NULL, (__bridge CFStringRef)siteip, 6667, &readStream, &writeStream);
    
    inputStream = (__bridge NSInputStream *)readStream;
    outputStream = (__bridge NSOutputStream *)writeStream;
    
    [inputStream setDelegate:self];
    [outputStream setDelegate:self];
    
    [inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    
    [inputStream open];
    [outputStream open];
    
}

// Adds an output message to the webview by executing some javascript code
- (void)addToWebView:(NSString *)toAdd {
    
    NSString *javascript = [NSString stringWithFormat:@"document.body.innerHTML += '%@'", toAdd];
    [self.webView stringByEvaluatingJavaScriptFromString:javascript];
}

// If a link is clicked inside the webview, don't load it directly, instead have it open in Safari
-(BOOL) webView:(UIWebView *)inWeb shouldStartLoadWithRequest:(NSURLRequest *)inRequest navigationType:(UIWebViewNavigationType)inType {
    if ( inType == UIWebViewNavigationTypeLinkClicked ) {
        [[UIApplication sharedApplication] openURL:[inRequest URL]];
        return NO;
    }
    
    return YES;
}

// Adds a message to the player's output window
// Since 'fromPlayer' was not specified, it is assumed that this message
// comes not from the current user/player but from someone else
- (void) formatAndAddMessage:(NSString *)messageData {
    [self formatAndAddMessage:messageData fromPlayer:false];
}

// Adds a message to the player's output window
// All messages follow a very specific format, as follows:
// playerid_playername_timestamp_message
// There is one exception: devs can insert their own custom message that just looks like
// message
// Both of these are parsed and handled by this method to correctly display on the user's screen
- (void) formatAndAddMessage:(NSString *)messageData fromPlayer:(BOOL) mainPlayer {
    
    // The code to add to the webview
    NSString *webViewDiv = @"";
    
    // If the format is just a message from the devs (missing UTC or missing _)
    if([messageData componentsSeparatedByString:@"_"].count < 3 || [messageData rangeOfString:@"UTC_"].location == NSNotFound) {
        
        // Then add the message directly in a new div
        webViewDiv = [NSString stringWithFormat:@"<div style='margin-top: 10px; color: white;'>%@</div>",messageData];
        
    } else {
    
        // Otherwise, we'll need to parse out each of the components of the format string
        // playerid_playername_timestamp_message
        
        // Step 1: Parse playerID
        // PlayerID is everything in the string from 0 to the first instance of "_"
        NSRange range1 = [messageData rangeOfString:@"_"];
        NSString *playerID = [messageData substringToIndex:range1.location];
    
        // Step 2: Parse message
        // Message is everything in the string from the first instance of "UTC_" to the end
        NSRange range2 = [messageData rangeOfString:@"UTC_"];
        NSString *message = [messageData substringFromIndex:(range2.location+range2.length)];
    

        NSString *regexToReplaceRawLinks = @"(\\b(https?):\\/\\/[-A-Z0-9+&@#\\/%?=~_|!:,.;]*[-A-Z0-9+&@#\\/%=~_|])";
        
        NSError *error = NULL;
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regexToReplaceRawLinks
                                                                               options:NSRegularExpressionCaseInsensitive
                                                                                 error:&error];
        
        // This not only parses the message but also makes all links have the text of 'Link'
        NSString *modMessage = [regex stringByReplacingMatchesInString:message
                                                                   options:0
                                                                     range:NSMakeRange(0, [message length])
                                                              withTemplate:@"<a href=\"$1\">Link</a>"];
        message = modMessage;
        
        
        // Step 3: Parse time
        // Time is everything from UTC_ to the first "_" before that
        NSRange range3 = [messageData rangeOfString:@"_" options:NSBackwardsSearch range:NSMakeRange(0, range2.location)];
        NSString *timeUTC = [messageData substringWithRange:NSMakeRange(range3.location + range3.length, (range2.location - range3.location) + 2)];
        
        // Step 4: Parse player name
        // Username is everything from first "_" to the "_" in step 3
        NSString *playerName = [messageData substringWithRange:NSMakeRange(range1.location + range1.length, (range3.location - range1.location) - 1)];
    
        // Now format the time from the given UTC format into the user's timezone
        NSString *formatUTC = @"EEE MMM d HH:mm:ss yyyy zzz";
        NSTimeZone *inputTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
        NSDateFormatter *inputDateFormatter = [[NSDateFormatter alloc] init];
        [inputDateFormatter setTimeZone:inputTimeZone];
        [inputDateFormatter setDateFormat:formatUTC];
        NSDate *date = [inputDateFormatter dateFromString:timeUTC];
    
        NSString *localDate = [NSDateFormatter localizedStringFromDate:date dateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterShortStyle];
    
        NSString *stringFromDate = localDate;
    
        // Validate the message string by removing new line characters
        message = [message stringByTrimmingCharactersInSet:
                   [NSCharacterSet newlineCharacterSet]];
    
        // Determine the color thta the username should be displayed in
        NSString* colortext = colors[[playerID intValue] % 62];
        if(mainPlayer) {
            // If the message is coming from the user, display it in the user's custom color choice
            colortext = [owner.loginViewController hexStringFromColor:owner.baseViewController->currentColor];
        }
        
        // Create the div with the below format to show the message to the user
        webViewDiv = [NSString stringWithFormat:@"<div style='margin-top: 10px;'><b><a style='text-decoration: none; color: %@' href='http://eternagame.org/web/player/%@/'>%@</a></b>: %@ <small style='font-size: 10px;'>[%@]</small></div>", colortext, playerID, playerName, message, stringFromDate];
        
    }
    
    // Validate the code and add it to the output window
    webViewDiv = [webViewDiv stringByReplacingOccurrencesOfString:@"'" withString:@"\\'"];
    [self addToWebView:webViewDiv];
    
    // Automatically scroll to the bottom of the output
    NSInteger height = [[self.webView stringByEvaluatingJavaScriptFromString:@"document.body.offsetHeight;"] intValue];
    NSString* javascript = [NSString stringWithFormat:@"window.scrollBy(0, %ld);", (long)height];
    [self.webView stringByEvaluatingJavaScriptFromString:javascript];
    
}

// The main powerhouse that handles IRC events
// All functionality for new IRC features should be placed here
- (void)stream:(NSStream *)theStream handleEvent:(NSStreamEvent)streamEvent {
    
    switch (streamEvent) {
        
        // The input or output stream was successfully opened
        case NSStreamEventOpenCompleted:
            break;
        
        // The input or output stream successfully got data
        case NSStreamEventHasBytesAvailable:
            
            // If it is the input stream
            if (theStream == inputStream) {
                
                uint8_t buffer[1024];
                int len;
                
                // Read in the data
                while ([inputStream hasBytesAvailable]) {
                    len = [inputStream read:buffer maxLength:sizeof(buffer)];
                    
                    if (len > 0) {
                        NSString *output = [[NSString alloc] initWithBytes:buffer length:len encoding:NSASCIIStringEncoding];
                        
                        // If the data is not empty
                        if(nil != output) {
                            
                            // Seperate the server message by newlines
                            NSMutableArray *data = [[output componentsSeparatedByString: @"\n"] mutableCopy];
                            for (int i = 0; i < [data count]; i++)
                            {
                                // For each line in the server message
                                NSString *line = [data objectAtIndex:i];
                                
                                line = [line stringByTrimmingCharactersInSet:
                                        [NSCharacterSet whitespaceCharacterSet]];
                                
                                // Validate the line by removing whitespace
                                NSMutableArray *lineData = [[line componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] mutableCopy];
                                
                                // If the message is PING, send a PONG so the server knows we are responsive
                                if( [[lineData objectAtIndex:0] isEqualToString:@"PING"])
                                {
                                    NSString *response  = [NSString stringWithFormat:@"PONG %@\r\n", [lineData objectAtIndex:1]];
                                    [self sendMessage:response];
                                }
                                
                                // If the message is MODE, then we successfully connected to the server
                                // and so we send a message to join the global chat room
                                else if( [lineData count] > 1 && [[lineData objectAtIndex:1] isEqualToString:@"MODE"] && !connectionSuccessful)
                                {
                                    connectionSuccessful = true;
                                    NSString *response = [NSString stringWithFormat:@"JOIN #global\r\n"];
                                    [self sendMessage:response];
                                }
                                
                                // If the message is PRIVMSG, then we either got a message from someone on the server or a message from anyone on the flash app
                                else if( [lineData count] > 1 && [[lineData objectAtIndex:1] isEqualToString:@"PRIVMSG"])
                                {
                                    
                                    // Assume that the message was sent to the global server (from the flash app) and add the message to the output
                                    NSRange range = [line rangeOfString:@"#global"];
                                    NSString *substring = [line substringFromIndex:NSMaxRange(range)];
                                    substring = [substring stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                                    
                                    [self formatAndAddMessage:substring];
                                    
                                }
                            }
                            
                        }
                    }
                    
                }
            }
            break;
        
        // When an error occurs, display an alert window
        case NSStreamEventErrorOccurred:
        {

            //UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"An error occured with connecting to chat - please check your internet connection." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil ];
            //alert.tag = 100;
            //[alert show];
            
            break;
        }

        // When the stream ends (successfully or not, it is unsure)
        case NSStreamEventEndEncountered:
        {
            break;
        }

        // Otherwise, this is an event that this app does not support, so log it as unknown
        default:
            NSLog(@"Error: Unknown event");
    }
    
}

// When an error occurs, close the application
// Taken from stackoverflow
-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 100) { // The error button tag
        if (buttonIndex == 0) {

            // Press the home button programmatically
            UIApplication *app = [UIApplication sharedApplication];
            [app performSelector:@selector(suspend)];
            
            //wait 2 seconds while app is going background
            [NSThread sleepForTimeInterval:2.0];
            
            //exit app when app is in background
            exit(0);
            
        }
    }
}

// Send a message to the IRC server by writing some data to the output stream
- (void) sendMessage:(NSString*)message {
    NSData *data = [[NSData alloc] initWithData:[message dataUsingEncoding:NSASCIIStringEncoding]];
    [outputStream write:[data bytes] maxLength:[data length]];
}

// Joins the IRC chat server with the given username and user ID
- (void) joinChat:(NSString *)username withUID:(NSString *)uid {
    
    // Creates a unique username to enter the IRC server by
    // Uses a hack to ensure the username is unique by making it based off the current time
    NSString *usernamenows = [username stringByReplacingOccurrencesOfString:@" " withString:@""];
    long uniqueID = (long)[[NSDate date] timeIntervalSince1970];
    usernamenows = [NSString stringWithFormat:@"%@_iOS_%ld", usernamenows, uniqueID];
    
    originalUserName = username;
    originalUID = uid;
    
    NSString *name = usernamenows;
    NSString *ident = usernamenows;
    NSString *realName = usernamenows;
    
    // Identify the user as the given username
    NSString *response  = [NSString stringWithFormat:@"NICK %@\r\n", name];
    [self sendMessage:response];
    
    // Have the user connect to the server
    // Note that the server ignores the hostname and servername, so these are set to bogus 'eternachat' values
    NSString *response2  = [NSString stringWithFormat:@"USER %@ eternachat eternachat %@\r\n", ident, realName];
    [self sendMessage:response2];
    
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

// Ensure that this always stays in portrait mode
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

// When the send button is clicked, send a message to the IRC server
- (IBAction)sendIRCMessage:(id)sender {
    
    // First the message the user entered is saved
    NSString *textMessage = [self.messageField text];
    [self.messageField setText:@""];
    
    // and validated to remove whitespace on the ends
    textMessage = [textMessage stringByTrimmingCharactersInSet:
            [NSCharacterSet whitespaceCharacterSet]];
    
    // Additionally, the current date/time in UTC format is saved
    NSDate *currentDate = [[NSDate alloc] init];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    [dateFormatter setTimeZone:timeZone];
    [dateFormatter setDateFormat:@"EEE MMM d HH:mm:ss YYYY"];
    NSString *utcTime = [dateFormatter stringFromDate:currentDate];
    
    // Then, as long as the message is not empty, it is sent
    if(![textMessage isEqual: @""]) {
        
        // It is sent in the following format, as an example message from lroppy
        // PRIVMSG #global 2804_lroppy_Fri Jul 3 02:27:56 2015 UTC_ciap
        
        // The message is sent in the user's custom color
        NSString *userColor = [owner.loginViewController hexStringFromColor:owner.baseViewController->currentColor];
        NSString *response  = [NSString stringWithFormat:@"PRIVMSG #global %@_<font color=\"#%@\">%@</font>_%@ UTC_%@\r\n", originalUID, userColor, originalUserName, utcTime, textMessage];

        // The message is sent to the server and added to the output window
        [self sendMessage:response];
        NSString *lineMessage = [NSString stringWithFormat:@":%@", response];
        [self formatAndAddMessage:lineMessage fromPlayer:YES];
    }
    
}

@end
