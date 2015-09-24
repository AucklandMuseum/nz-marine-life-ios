//
//  iphoneAboutViewController.m
//  Field Guide 2010
//
//  Created by Simon Sherrin on 17/02/11.
/*
 Copyright (c) 2011 Museum Victoria
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
//

#import "iphoneAboutViewController.h"
#import "UITabBarController+ShowHideBar.h"

@implementation iphoneAboutViewController

#define SYSTEM_VERSION_LESS_THAN(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_GREATER_THAN(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
	self.title = NSLocalizedString(@"About",nil);
    
    [UIApplication sharedApplication].statusBarHidden = YES;
	welcomeWebView.opaque = NO;
    welcomeWebView.delegate = self;
    welcomeWebView.scrollView.delegate = self;
	welcomeWebView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0];
    [self updateSplashImageAndRotation];
    
    if ( SYSTEM_VERSION_LESS_THAN(@"7.0") ) {
        [self.tabBarController setHidden:YES];
    }
    
    self.tabBarController.tabBar.hidden = YES;

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [UIApplication sharedApplication].statusBarHidden = YES;
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [UIApplication sharedApplication].statusBarHidden = NO;
}

- (void)loadHTMLwithStatus:(NSString *)status
{
    NSString *path = [[NSBundle mainBundle] bundlePath];
    NSURL *baseURL = [NSURL fileURLWithPath:path];
    NSString *aboutPath = [[NSBundle mainBundle] pathForResource:@"ipod-welcome" ofType:@"html"];
    NSError *error = nil;
    NSMutableString *aboutHTMLCode = [[NSMutableString alloc] initWithContentsOfFile:aboutPath
                                                                            encoding:NSUTF8StringEncoding
                                                                               error:&error];
    [self htmlTemplate:aboutHTMLCode keyString:@"welcomeScreenStateString" replaceWith:status];
    
    if (!error) {
        [welcomeWebView loadHTMLString:aboutHTMLCode baseURL:baseURL];
    }
}

-(void) htmlTemplate:(NSMutableString *)templateString keyString:(NSString *)stringToReplace replaceWith:(NSString *)replacementString{
    
    if (replacementString != nil && [replacementString length] > 0) {
        NSString *replace = [NSString stringWithFormat:@"<%@>",stringToReplace];
        [templateString replaceOccurrencesOfString:replace withString:replacementString options:0 range:NSMakeRange(0, [templateString length])];
    }
}

#pragma mark webView delegate
-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    if ( SYSTEM_VERSION_LESS_THAN(@"7.0") ) {
        self.splashImageView.image = [UIImage imageNamed:@"iPhoneBlank"];
    }
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if ( !self.splashImageView.hidden && SYSTEM_VERSION_GREATER_THAN(@"7.0") ) {
        self.splashImageView.hidden = YES;
    }
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {

    if ([request.URL.scheme isEqualToString:@"inapp"]) {
        if ([request.URL.host isEqualToString:@"start"]) {
            
            UITabBarController *tabBar = (UITabBarController *)self.view.window.rootViewController;
            self.tabBarController.tabBar.hidden = NO;
            
            if ( SYSTEM_VERSION_LESS_THAN(@"7.0") ) {
                [self.tabBarController setHidden:NO];
            }
            
            tabBar.selectedIndex = 0;
        
        }
        return NO;
    
    } else if (navigationType == UIWebViewNavigationTypeLinkClicked) {
		[[UIApplication sharedApplication] openURL:[request mainDocumentURL]];
		return NO;
	}
	
	return YES;
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

#pragma mark building database

- (void)setupProgressView {
    
    self.tabBarController.tabBar.hidden = YES;
    CGRect htmlRect = welcomeWebView.frame;
    htmlRect.size.height = self.view.frame.size.height;
    welcomeWebView.frame = htmlRect;
    
    CGFloat width = [[UIScreen mainScreen]bounds].size.width;
    
    CGRect spacerViewFrame = self.spacerView.frame;
    spacerViewFrame.origin.x = width/2 - spacerViewFrame.size.width/2;
    self.spacerView.frame = spacerViewFrame;
    
    CGRect progressLabelFrame = self.progressLabel.frame;
    progressLabelFrame.origin.x = width/2 - progressLabelFrame.size.width/2;
    self.progressLabel.frame = progressLabelFrame;
    
    self.progressLabel.hidden = NO;
    self.progressView.hidden = NO;
    self.spacerView.hidden = NO;
    self.activityIndicator.hidden = NO;
    welcomeWebView.scrollView.scrollEnabled = NO;
    [self.activityIndicator startAnimating];
    [self loadHTMLwithStatus:@"building"];
}

- (void)updateProgressBar:(float)loadprogress {
    self.progressView.progress = loadprogress;
}

-  (void)hideProgress {
    [self.activityIndicator stopAnimating];
    self.loadingDatabase = NO;
    [UIView animateWithDuration:0.5 animations:^{
        
        self.progressLabel.alpha = 0;
        self.progressView.alpha = 0;
        
    } completion:^(BOOL finished){
        self.progressLabel.hidden = YES;
        self.progressView.hidden = YES;
        self.spacerView.hidden = YES;
        welcomeWebView.scrollView.scrollEnabled = YES;
        [self loadHTMLwithStatus:@"ready"];
    }];
}

#pragma mark splash page

- (void)updateSplashImageAndRotation {
    if ( self.splashImageView.alpha > 0 ) {
        if ( [[UIScreen mainScreen]bounds].size.height == 568 ) {
            self.splashImageView.image = [UIImage imageNamed:@"iPhoneLaunch5"];
        } else if ( [[UIScreen mainScreen]bounds].size.height == 480 ) {
            self.splashImageView.image = [UIImage imageNamed:@"iPhoneLaunch4"];
        } else {
            self.splashImageView.image = [UIImage imageNamed:@"iPhoneLaunch"];
        }
    }
}

@end
