//
//  WelcomeScreenViewController.h
//  NZ Marine Life
//
//  Created by Judit Klein on 19/06/15.
//
//

#import <UIKit/UIKit.h>

@interface WelcomeScreenViewController : UIViewController <UIWebViewDelegate, UISplitViewControllerDelegate, UIScrollViewDelegate>

@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) IBOutlet UILabel *progressLabel;
@property (nonatomic, strong) IBOutlet UIProgressView *progressView;
@property (nonatomic, assign) BOOL loadingDatabase;
@property (nonatomic, strong) UIBarButtonItem *backButton;

- (void)loadHTMLPageWithStatus:(NSString *)status;
- (void)updateProgressBar:(float)loadprogress;
- (void)hideProgress;
- (void)setupProgressView;

@end
