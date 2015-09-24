//
//  WelcomeScreenViewController.m
//  NZ Marine Life
//
//  Created by Judit Klein on 19/06/15.
//
//

#import "WelcomeScreenViewController.h"

@interface WelcomeScreenViewController ()

@property (nonatomic, strong) IBOutlet UIWebView *welcomeHTML;
@property (nonatomic, strong) IBOutlet UIImageView *splashImageView;
@property (nonatomic, assign) BOOL showingWelcome;

@end

@implementation WelcomeScreenViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"Welcome",nil);

    if ( self.loadingDatabase ) {
        [self setupProgressView];
        [self loadHTMLPageWithStatus:@"building"];
    } else {
        [self loadHTMLPageWithStatus:@"ready"];
    }
    
    [self updateSplashImageAndRotation];
    self.welcomeHTML.delegate = self;
    self.welcomeHTML.scrollView.scrollEnabled = YES;
    self.welcomeHTML.scrollView.delegate = self;
    self.welcomeHTML.opaque = NO;
    self.welcomeHTML.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0];
    self.navigationController.navigationBarHidden = YES;
    [UIApplication sharedApplication].statusBarHidden = YES;
    
    self.showingWelcome = true;
}

- (BOOL)landscape {
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if ( orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight ) {
        return  YES;
    } else {
        return NO;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}


#pragma mark splitview

- (void)splitViewController:(UISplitViewController *)svc
    willHideViewController:(UIViewController *)aViewController
         withBarButtonItem:(UIBarButtonItem *)barButtonItem
      forPopoverController:(UIPopoverController *)pc {
    
    UINavigationController *slaveNavigationViewController = svc.viewControllers[1];
    UIViewController *slaveViewController = slaveNavigationViewController.viewControllers[0];
    [barButtonItem setTitle:@"Life Forms"];
    
    self.backButton = barButtonItem;

    slaveViewController.navigationItem.leftBarButtonItem = barButtonItem;
}

#pragma mark html

- (void)loadHTMLPageWithStatus:(NSString *)status {

    NSString *path = [[NSBundle mainBundle] bundlePath];
    NSURL *baseURL = [NSURL fileURLWithPath:path];
    
    NSString *pagePath = [[NSBundle mainBundle] pathForResource:@"welcome" ofType:@"html"];
    NSError *pageHTMLCodeError = nil;
    NSMutableString *pageHTMLCode = [[NSMutableString alloc] initWithContentsOfFile:pagePath
                                                                           encoding:NSUTF8StringEncoding
                                                                              error:&pageHTMLCodeError];
    
    [self htmlTemplate:pageHTMLCode keyString:@"welcomeScreenStateString" replaceWith:status];
    
    if (!pageHTMLCodeError) {
        [self.welcomeHTML loadHTMLString:pageHTMLCode baseURL:baseURL];
    }
}


-(void) htmlTemplate:(NSMutableString *)templateString keyString:(NSString *)stringToReplace replaceWith:(NSString *)replacementString{
    
    if (replacementString != nil && [replacementString length] > 0) {
        NSString *replace = [NSString stringWithFormat:@"<%@>",stringToReplace];
        [templateString replaceOccurrencesOfString:replace withString:replacementString options:0 range:NSMakeRange(0, [templateString length])];
    }
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if ([request.URL.scheme isEqualToString:@"inapp"]) {
        if ([request.URL.host isEqualToString:@"start"] &&  ![self landscape] ) {
            self.navigationController.navigationBarHidden = NO;
            [UIApplication sharedApplication].statusBarHidden = NO;
            
            SEL selector = self.backButton.action;
            ((void (*)(id, SEL))[self.splitViewController methodForSelector:selector])(self.splitViewController, selector);
        }
        return NO;
        
    } else if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        [[UIApplication sharedApplication] openURL:[request mainDocumentURL]];
        return NO;
    }
    return YES;
}


#pragma mark splash page

- (void)updateSplashImageAndRotation {
    if ( self.splashImageView.alpha > 0 ) {
        UIInterfaceOrientation currentOrientation = self.interfaceOrientation;
        NSString *splashImageName = (UIInterfaceOrientationIsPortrait(currentOrientation)) ? @"iPadPortrait" : @"iPadLandscape";
        UIImage *image = [UIImage imageNamed:splashImageName];
        self.splashImageView.frame = UIScreen.mainScreen.bounds;
        self.splashImageView.image = image;
    }
}


#pragma mark webview

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    if ( webView == self.welcomeHTML ) {
        double delayInSeconds = 0.5;
        self.welcomeHTML.scrollView.contentOffset = CGPointMake(0, 0);
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        });
    }
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"there was an error: %@",error.localizedDescription);
}

#pragma mark rotation support

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if ( toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || toInterfaceOrientation == UIInterfaceOrientationLandscapeRight ) {
        UINavigationController *slaveNavigationViewController = self.splitViewController.viewControllers[1];
        UIViewController *slaveViewController = slaveNavigationViewController.viewControllers[0];
        slaveViewController.navigationItem.leftBarButtonItem = nil;
    }
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [self updateSplashImageAndRotation];
}

- (NSUInteger)supportedInterfaceOrientations
{
    if ( self.loadingDatabase ) {
        return [[UIDevice currentDevice]orientation];
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}

- (BOOL)shouldAutorotate {
    return !self.loadingDatabase;
}

#pragma mark progress

- (void)setupProgressView
{
    self.progressLabel.hidden = NO;
    self.progressView.hidden = NO;
    self.activityIndicator.hidden = NO;
    self.welcomeHTML.scrollView.scrollEnabled = NO;
    [self.activityIndicator startAnimating];
}

- (void)updateProgressBar:(float)loadprogress {
    self.progressView.progress = loadprogress;
}

- (void)hideProgress {
    [self.activityIndicator stopAnimating];
    self.loadingDatabase = NO;
    [UIView animateWithDuration:0.5 animations:^{
        self.progressLabel.alpha = 0;
        self.progressView.alpha = 0;
    } completion:^(BOOL finished){
        self.progressLabel.hidden = YES;
        self.progressView.hidden = YES;
        self.welcomeHTML.scrollView.scrollEnabled = YES;
        [self loadHTMLPageWithStatus:@"ready"];
    }]; 
}


#pragma mark scrollview

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if ( !self.splashImageView.hidden ) {
        self.splashImageView.hidden = YES;
    }
}

@end
