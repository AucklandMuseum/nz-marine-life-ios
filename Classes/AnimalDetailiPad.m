//
//  AnimalDetailiPad.m
//  Field Guide 2010
//
//  Created by Simon Sherrin on 5/09/10.
/*
 Copyright (c) 2011 Museum Victoria
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
//

#import "AnimalDetailiPad.h"
#import "Animal.h"
#import "Image.h"
#import "TaxonGroup.h"
#import "CommonName.h"

@interface AnimalDetailiPad ()

@property (nonatomic, assign) CGFloat initialImageHeight;
@property (nonatomic, assign) CGFloat initialScrollViewHeight;
@property (nonatomic, assign) CGFloat initialScrollViewY;
@property (nonatomic, assign) BOOL isShowing;
@property (nonatomic, strong) NSURL *baseURL;
@property (nonatomic, strong) NSString *currentFormattedHTML;

@end

@implementation AnimalDetailiPad

@synthesize animal;
@synthesize animalHTMLDetails;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib
- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ( [self respondsToSelector:@selector(setAutomaticallyAdjustsScrollViewInsets:)] ) {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    self.splitViewController.delegate = self;
    
    self.initialImageHeight = self.imageContainerView.frame.size.height;
    self.scrollView.delegate = self;
    self.animalHTMLDetails.delegate = self;
    
    CGRect scrollviewFrame = self.scrollView.frame;
    scrollviewFrame.origin.y = self.navigationController.navigationBar.frame.size.height + 20;
    self.scrollView.frame = scrollviewFrame;
    
    CGRect imageViewFrame = self.imageContainerView.frame;
    imageViewFrame.origin.y = 0;
    self.imageContainerView.frame = imageViewFrame;
    
    CGRect animalDetailRect = self.animalHTMLDetails.frame;
    animalDetailRect.origin.y = imageViewFrame.origin.y + imageViewFrame.size.height;
    self.animalHTMLDetails.frame = animalDetailRect;
    self.animalHTMLDetails.scrollView.scrollEnabled = NO;
        
    if ( self.backButtonTitle == nil ) {
        self.backButtonTitle = @"Life Forms";
    } else {
        self.backButton.title = self.backButtonTitle;
    }
    
    [self setUpBarButton];
    
    _photoScrollView = [[PhotoScrollViewController alloc]initWithNibName:@"PhotoScrollViewController" bundle:nil];
    self.photoScrollView.view.frame = self.imageContainerView.frame;
    self.photoScrollView.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self addChildViewController:_photoScrollView];
    [self.scrollView addSubview:self.photoScrollView.view];
    [_photoScrollView didMoveToParentViewController:self];
    
    if ( animal != nil ) {
        [self configureViewWithAnimal:animal];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    self.isShowing = true;
    CGRect scrollViewFrame = self.photoScrollView.view.frame;
    scrollViewFrame.size.height = self.initialImageHeight;
    self.photoScrollView.view.frame = self.imageContainerView.frame;
}

- (void)viewDidAppear:(BOOL)animated {
    [self correctLayout];
}

- (void)viewWillDisappear:(BOOL)animated {
    self.isShowing = false;
}

- (void)correctLayout {
    if (self.photoScrollView.view.frame.size.height != self.initialImageHeight) {
        CGRect currentImageRect = self.photoScrollView.view.frame;
        currentImageRect.size.height = self.initialImageHeight;

        CGSize contentSize = self.scrollView.contentSize;
        contentSize.width = self.view.frame.size.width;
        self.scrollView.contentSize = contentSize;

        [UIView animateWithDuration:0.2 animations:^{
            self.photoScrollView.view.frame = currentImageRect;
        }];
    }
}

-(void)splitViewController:(UISplitViewController *)svc
    willHideViewController:(UIViewController *)aViewController
         withBarButtonItem:(UIBarButtonItem *)barButtonItem
      forPopoverController:(UIPopoverController *)pc {
    
    UINavigationController *slaveNavigationViewController = svc.viewControllers[1];
    UIViewController *slaveViewController = slaveNavigationViewController.viewControllers[1];
    
    if ( self.backButton == nil) {
        self.backButton = barButtonItem;
    }
    
    [self.backButton setTitle:self.backButtonTitle];
    slaveViewController.navigationItem.leftBarButtonItem = self.backButton;
}

- (BOOL)detailViewIsVisible {
    return self.isShowing;
}

- (void)setUpBarButton {
    UIImage* amImage = [UIImage imageNamed:@"menu-bar-about-help"];
    UIButton *aboutButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, amImage.size.width, amImage.size.height)];
    [aboutButton setBackgroundImage:amImage forState:UIControlStateNormal];
    [aboutButton addTarget:self action:@selector(showAboutScreen)
          forControlEvents:UIControlEventTouchUpInside];
    [aboutButton setShowsTouchWhenHighlighted:YES];
    
    UIBarButtonItem *aboutBarItem = [[UIBarButtonItem alloc] initWithCustomView:aboutButton];
    self.navigationItem.rightBarButtonItem=aboutBarItem;
    
    [self loadHTMLPage:@"welcome" inWebView:aboutHTML];
    
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if ( orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown ) {
        [[self navigationItem] setLeftBarButtonItem:self.backButton];
    }
}

- (void)updateButtonTitle:(NSString *)title
{
    UINavigationController *slaveNavigationViewController = self.splitViewController.viewControllers[1];
    UIViewController *slaveViewController = slaveNavigationViewController.viewControllers[1];
    
    if ( title == nil ) {
        slaveViewController.navigationItem.leftBarButtonItem = nil;
    } else {
        slaveViewController.navigationItem.leftBarButtonItem.title = title;
        self.backButtonTitle = title;
    }    
}

- (void)showAboutScreen {
    if (aboutHTML.hidden) {
        aboutHTML.hidden = NO;
        self.navigationController.navigationBarHidden = YES;
    } else {
        aboutHTML.hidden = YES;
        self.navigationController.navigationBarHidden = NO;
    }
}

#pragma mark Managing the detail item

- (void)configureViewWithAnimal:(Animal *)newAnimal {
    // Update the user interface for the detail item.
    
//    self.scrollView.contentOffset = CGPointMake(0, 0);
    
    if ( self.navigationController.navigationBarHidden ) {
        self.navigationController.navigationBarHidden = NO;
        [UIApplication sharedApplication].statusBarHidden = NO;
    }
    
    self.scrollView.scrollEnabled = YES;
    
    if ( !aboutHTML.hidden ) {
        aboutHTML.hidden = YES;
    }
    
    if ( animal != newAnimal || !self.isShowing ) {
        
        animal = newAnimal;
        self.title = animal.animalName;
        
        animalHTMLDetails.hidden = NO;
        
        if ( animalHTMLDetails == nil) {
            animalHTMLDetails = [[UIWebView alloc]init];
        }
        
        commonName.text = animal.animalName;
        
        //Set up Scientific Name;
        if (animal.species != nil) {
            scientificName.text = [NSString stringWithFormat:@"%@ %@",[animal genusName], [animal species]];
        } else if ([animal genusName] != nil) {
            scientificName.text = [NSString stringWithFormat:@"%@ sp", [animal genusName] ];
        } else {
            scientificName.text = @" ";
        }
        
        //Set Up images controller
        [self.photoScrollView setupArray:self.animal.sortedImages];
        [self.photoScrollView setCurrentAnimal:animal.animalName];
        [self formatHtml];
    }
}

- (void)formatHtml {

    if ( self.baseURL == nil ) {
        NSString *path = [[NSBundle mainBundle] bundlePath];
        self.baseURL = [NSURL fileURLWithPath:path];
    }
    
    animalHTMLDetails.backgroundColor = [UIColor clearColor];
    
    //Code for checking for design versions
    NSString *htmlPath;
    if (animal.catalogID && [[NSFileManager defaultManager] fileExistsAtPath:[[NSBundle mainBundle] pathForResource:animal.catalogID ofType:@"html"]]) {
        htmlPath = [[NSBundle mainBundle] pathForResource:animal.catalogID ofType:@"html"];
    } else {
        htmlPath = [[NSBundle mainBundle] pathForResource:@"template-ipad" ofType:@"html"];
    }
    
    NSError *baseHTMLCodeError = nil;
    NSMutableString *baseHTMLCode = [[NSMutableString alloc] initWithContentsOfFile:htmlPath
                                                                           encoding:NSUTF8StringEncoding
                                                                              error:&baseHTMLCodeError];
    
    //Common Names is a set of strings
    NSMutableString *constructedCommonNames = [NSMutableString stringWithCapacity:1];
    
    for ( CommonName *tmpCommonName in animal.commonNames )
    {
        if ( !tmpCommonName.localeIdentifier ) {
            // Don't include the localized common names
            [constructedCommonNames appendFormat:@"%@, ",tmpCommonName.commonName];
        }
        
    }
    if ( [constructedCommonNames length]>0 ){
        [constructedCommonNames deleteCharactersInRange:NSMakeRange([constructedCommonNames length]-2, 2)];
    }
    
    if (!baseHTMLCodeError) {
        //Replace template fields in HTML with values.
        [self htmlTemplate:baseHTMLCode keyString:@"commonNames" replaceWith:[constructedCommonNames copy]];
        [self htmlTemplate:baseHTMLCode keyString:@"animalName" replaceWith:animal.animalName];
        [self htmlTemplate:baseHTMLCode keyString:@"translatedName" replaceWith:animal.translatedName];
        [self htmlTemplate:baseHTMLCode keyString:@"scientificName" replaceWith:[animal scientificName]];
        [self htmlTemplate:baseHTMLCode keyString:@"identifyingCharacteristics" replaceWith:animal.identifyingCharacteristics];
        [self htmlTemplate:baseHTMLCode keyString:@"distinctive" replaceWith:animal.distinctive];
        [self htmlTemplate:baseHTMLCode keyString:@"biology" replaceWith:animal.biology];
        [self htmlTemplate:baseHTMLCode keyString:@"habitat" replaceWith:animal.habitat];
        [self htmlTemplate:baseHTMLCode keyString:@"mapimage" replaceWith:animal.mapImage];
        [self htmlTemplate:baseHTMLCode keyString:@"distribution" replaceWith:animal.distribution];
        [self htmlTemplate:baseHTMLCode keyString:@"phylum" replaceWith:animal.phylum];
        [self htmlTemplate:baseHTMLCode keyString:@"class" replaceWith:animal.animalClass];
        [self htmlTemplate:baseHTMLCode keyString:@"order" replaceWith:animal.order];
        [self htmlTemplate:baseHTMLCode keyString:@"family" replaceWith:animal.family];
        [self htmlTemplate:baseHTMLCode keyString:@"genus" replaceWith:animal.genusName];
        [self htmlTemplate:baseHTMLCode keyString:@"species" replaceWith:animal.species];
        [self htmlTemplate:baseHTMLCode keyString:@"lcs" replaceWith:animal.lcs];
        [self htmlTemplate:baseHTMLCode keyString:@"ncs" replaceWith:animal.ncs];
        [self htmlTemplate:baseHTMLCode keyString:@"wcs" replaceWith:animal.wcs];
        [self htmlTemplate:baseHTMLCode keyString:@"native" replaceWith:animal.nativestatus];
        [self htmlTemplate:baseHTMLCode keyString:@"nativeBadge" replaceWith:[self nativeStatus:animal.nativestatus]];
        [self htmlTemplate:baseHTMLCode keyString:@"bite" replaceWith:animal.bite];
        [self htmlTemplate:baseHTMLCode keyString:@"diet" replaceWith:animal.diet];
        [self htmlTemplate:baseHTMLCode keyString:@"kingdom" replaceWith:animal.kingdom];
        [self htmlTemplate:baseHTMLCode keyString:@"authority" replaceWith:animal.authority];
        
        self.currentFormattedHTML = baseHTMLCode;
        [animalHTMLDetails loadHTMLString:self.currentFormattedHTML baseURL:self.baseURL];
    }
}

- (NSString *)nativeStatus: (NSString *)originalString
{
    NSCharacterSet *separators = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    
    NSString *formattedString = [originalString lowercaseString];
    formattedString = [formattedString stringByReplacingOccurrencesOfString:@"." withString:@""];
    formattedString = [formattedString stringByReplacingOccurrencesOfString:@"," withString:@""];
    NSArray *words = [formattedString componentsSeparatedByCharactersInSet:separators];
    
    if ( words.count == 0 || words == nil ) {
        return nil;
        
    } else if ( words.count == 1 ) {
        return [words firstObject];
        
    } else {
    
        NSSet *wordsArray = [[NSSet alloc] initWithObjects:@"native", @"endemic", @"introduced", @"non-native", @"invasive", @"introduced", @"Cosmopolitan", @"cosmopolitan", @"migrant", @"visitor", nil];
        
        NSMutableSet *intersection = [NSMutableSet setWithArray:words];
        [intersection intersectSet:wordsArray];
        NSArray *final = [intersection allObjects];
        
        if ( final.count > 0) {
            return [final firstObject];
        } else {
            return nil;
        }
    }
}

#pragma mark Split view support

- (BOOL)isFullScreen {
    if (imageTextLayoutControl.selectedSegmentIndex ==2) {
        return YES;
    } else {
        return NO;
    }
}

#pragma mark HTML Handlers

- (void)loadHTMLPage:(NSString *)pageName inWebView:(UIWebView *)webview {
    NSString *path = [[NSBundle mainBundle] bundlePath];
    NSURL *baseURL = [NSURL fileURLWithPath:path];
    
    NSString *pagePath = [[NSBundle mainBundle] pathForResource:pageName ofType:@"html"];
    NSError *pageHTMLCodeError = nil;
    NSMutableString *pageHTMLCode = [[NSMutableString alloc] initWithContentsOfFile:pagePath
                                                                           encoding:NSUTF8StringEncoding
                                                                              error:&pageHTMLCodeError];
    
    [pageHTMLCode replaceOccurrencesOfString:@"<welcomeScreenStateString>" withString:@"ready" options:0 range:NSMakeRange(0, [pageHTMLCode length])];
    
    if (!pageHTMLCodeError) {
        [webview loadHTMLString:pageHTMLCode baseURL:baseURL];
    }
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    if ( [request.URL.scheme isEqualToString:@"inapp"] ) {
        if ([request.URL.host isEqualToString:@"start"]) {
            [self showAboutScreen];
        }
        return NO;
     
    } else if ( [request.URL.scheme isEqualToString:@"ready"] ){
        
        float contentHeight = [request.URL.host floatValue];
        CGRect webviewRect = self.animalHTMLDetails.frame;
        webviewRect.size.height = contentHeight;
        self.animalHTMLDetails.frame = webviewRect;
        
        CGSize scrollViewContentSize = self.scrollView.contentSize;
        scrollViewContentSize.height = self.animalHTMLDetails.frame.size.height + self.initialImageHeight + 50;
        scrollViewContentSize.width = self.scrollView.frame.size.width;
        [self.scrollView setContentSize:scrollViewContentSize];
        
        return NO;
        
    } else if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        [[UIApplication sharedApplication] openURL:[request mainDocumentURL]];
        return NO;
    }
    return YES;
}

-(void) htmlTemplate:(NSMutableString *)templateString keyString:(NSString *)stringToReplace replaceWith:(NSString *)replacementString{
    
    if (replacementString != nil && [replacementString length] > 0) {
        [templateString replaceOccurrencesOfString:[NSString stringWithFormat:@"<%%%@%%>",stringToReplace] withString:replacementString options:0 range:NSMakeRange(0, [templateString length])];
        [templateString	replaceOccurrencesOfString:[NSString stringWithFormat:@"<%%%@Class%%>",stringToReplace] withString:@" " options:0 range:NSMakeRange(0, [templateString length])];
    } else {
        [templateString replaceOccurrencesOfString:[NSString stringWithFormat:@"<%%%@%%>",stringToReplace] withString:@"" options:0 range:NSMakeRange(0, [templateString length])];
        [templateString	replaceOccurrencesOfString:[NSString stringWithFormat:@"<%%%@Class%%>",stringToReplace] withString:@"invisible" options:0 range:NSMakeRange(0, [templateString length])];
        
    }
}

#pragma mark Rotation support

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [self correctLayout];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [animalHTMLDetails loadHTMLString:self.currentFormattedHTML baseURL:self.baseURL];
    if ( toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || toInterfaceOrientation == UIInterfaceOrientationLandscapeRight ) {
        [self updateButtonTitle:nil];
    }
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration {

}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}


#pragma mark - UIWebViewDelegate

- (void)webViewDidFinishLoad:(UIWebView *)webView {

}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    if (webView == animalHTMLDetails) {
        NSLog(@"There was an error loading the webview %@",error.localizedDescription);
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
//    CGFloat offset = scrollView.contentOffset.y;
//    CGFloat height = self.initialImageHeight - offset;
//    CGRect currentImageRect = self.photoScrollView.view.frame;
//        
//    if ( offset < 0 ) {
//        offset = 0;
//        height = self.initialImageHeight;
//    }
//    
//    currentImageRect.origin.y = offset;
//    currentImageRect.size.height = height;
//    self.photoScrollView.view.frame = currentImageRect;
//    
//    if ( height >= 0 && height <= self.initialImageHeight ) {
//        
//    }
}


@end
