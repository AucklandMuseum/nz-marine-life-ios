//
//  AnimalDetailsiPhoneViewController.m
//  Field Guide 2010
//
//  Created by Simon Sherrin on 30/01/11.
/*
 Copyright (c) 2011 Museum Victoria
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
//

#import "AnimalDetailsiPhoneViewController.h"
#import "Animal.h"
#import "CommonName.h"
#import <QuartzCore/QuartzCore.h>

@interface AnimalDetailsiPhoneViewController ()

@property (nonatomic, assign) CGFloat initialImageHeight;
@property (nonatomic, assign) CGFloat initialScrollViewHeight;
@property (nonatomic, assign) CGFloat initialScrollViewY;

@end

@implementation AnimalDetailsiPhoneViewController

#define SYSTEM_VERSION_GREATER_THAN(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)

- (BOOL)hidesBottomBarWhenPushed{
	return TRUE;
}
@synthesize animal, animalDetails, distributionWebView, scarcityWebView, tabBar, detailsTab, distributionTab, rarityTab, imageView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.initialImageHeight = 250;
    
    if ( [self respondsToSelector:@selector(setAutomaticallyAdjustsScrollViewInsets:)] )
    {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    CGRect mainFrame = self.view.frame;
    mainFrame.size.width = [[UIScreen mainScreen]bounds].size.width;
    self.view.frame = mainFrame;
    
	self.navigationController.navigationBar.translucent = YES;
    self.scrollView.delegate = self;
    self.animalDetails.delegate = self;
    self.animalDetails.scrollView.scrollEnabled = NO;
    
    CGRect scrollviewFrame = self.scrollView.frame;
    if ( SYSTEM_VERSION_GREATER_THAN(@"7.0") ) {
        scrollviewFrame.origin.y = self.navigationController.navigationBar.frame.size.height + self.navigationController.navigationBar.frame.origin.y;
    } else {
        scrollviewFrame.origin.y = self.navigationController.navigationBar.frame.size.height - 6;
    }
    scrollviewFrame.size.height = self.view.frame.size.height - scrollviewFrame.origin.y - self.tabBar.frame.size.height;
    self.scrollView.frame = scrollviewFrame;
    
	//Setup ImageView
    _photoScrollView = [[PhotoScrollViewController alloc]initWithNibName:@"PhotoScrollViewController" bundle:nil];
    self.photoScrollView.view.frame = self.placeHolderView.frame;
    self.photoScrollView.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self addChildViewController:_photoScrollView];
    [self.photoScrollView setupArray:self.animal.sortedImages];
    [self.photoScrollView setCurrentAnimal:animal.animalName];
    
    [self.scrollView addSubview:self.photoScrollView.view];
    [_photoScrollView didMoveToParentViewController:self];
	
    [self setUpHtml];

	animalDetails.opaque = NO;
	animalDetails.backgroundColor = [UIColor clearColor];
	distributionWebView.opaque = NO;
	distributionWebView.backgroundColor = [UIColor clearColor];
	scarcityWebView.opaque = NO;
	scarcityWebView.backgroundColor = [UIColor clearColor];
    
	//Set up initial state.
	scarcityWebView.hidden = YES;
	distributionWebView.hidden = YES;
	tabBar.selectedItem = detailsTab;
    
    if ( SYSTEM_VERSION_GREATER_THAN(@"7.0") ) {
        detailsTab.image = [UIImage imageNamed:@"tab-bar-details"];
        distributionTab.image = [UIImage imageNamed:@"tab-bar-habitat"];
        rarityTab.image = [UIImage imageNamed:@"tab-bar-scarcity"];
        detailsTab.selectedImage = [UIImage imageNamed:@"tab-bar-details-active"];
        distributionTab.selectedImage = [UIImage imageNamed:@"tab-bar-habitat-active"];
    } else {
        [tabBar setBackgroundColor:[UIColor whiteColor]];
        [detailsTab setFinishedSelectedImage:[UIImage imageNamed:@"tab-bar-details-active"] withFinishedUnselectedImage:[UIImage imageNamed:@"tab-bar-details"]];
        [distributionTab setFinishedSelectedImage:[UIImage imageNamed:@"tab-bar-habitat-active"] withFinishedUnselectedImage:[UIImage imageNamed:@"tab-bar-habitat"]];
        [rarityTab setFinishedSelectedImage:[UIImage imageNamed:@"tab-bar-scarcity-active"] withFinishedUnselectedImage:[UIImage imageNamed:@"tab-bar-scarcity"]];
        
        self.tabBar.layer.borderWidth = 0.25;
        self.tabBar.layer.borderColor = self.tabBar.backgroundColor.CGColor;
        self.tabBar.clipsToBounds = YES;
        self.tabBar.shadowImage = [[UIImage alloc]init];
    }
    
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(resetImageSize) name:@"resizeImage" object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
    
    CGRect imageViewFrame = self.photoScrollView.view.frame;
    imageViewFrame.size.height = 250;
    self.photoScrollView.view.frame = imageViewFrame;
    
    CGRect animalDetailRect = self.animalDetails.frame;
    animalDetailRect.origin.y = imageViewFrame.origin.y + imageViewFrame.size.height;
    self.animalDetails.frame = animalDetailRect;
}

- (void)resetImageSize
{
//    CGRect currentImageRect = self.photoScrollView.view.frame;
//    currentImageRect.size.height = self.initialImageHeight;
//
//    [UIView animateWithDuration:0.2 animations:^{
//        self.photoScrollView.view.frame = currentImageRect;
//    }];
}

#pragma mark html

- (void)setUpHtml
{
    self.view.backgroundColor = [UIColor whiteColor];
    //Display Web Content
    NSString *path = [[NSBundle mainBundle] bundlePath];
    NSURL *baseURL = [NSURL fileURLWithPath:path];
    
    NSString *htmlPath;
    NSString *distributionPath;
    NSString *scarcityPath;
    htmlPath = [[NSBundle mainBundle] pathForResource:@"template-iphone-details" ofType:@"html"];
    distributionPath = [[NSBundle mainBundle] pathForResource:@"template-habitat" ofType:@"html"];
    scarcityPath =[[NSBundle mainBundle] pathForResource:@"template-iphone-scarcity" ofType:@"html"];
    
    NSError *baseHTMLCodeError = nil;
    NSMutableString *baseHTMLCode = [[NSMutableString alloc] initWithContentsOfFile:htmlPath
                                                                           encoding:NSUTF8StringEncoding
                                                                              error:&baseHTMLCodeError];
    
    NSError *distributionHTMLCodeError = nil;
    NSMutableString *distributionHTMLCode = [[NSMutableString alloc] initWithContentsOfFile:distributionPath
                                                                                   encoding:NSUTF8StringEncoding
                                                                                      error:&distributionHTMLCodeError];
    
    NSError *scarcityHTMLCodeError = nil;
    NSMutableString *scarcityHTMLCode = [[NSMutableString alloc] initWithContentsOfFile:scarcityPath
                                                                               encoding:NSUTF8StringEncoding
                                                                                  error:&scarcityHTMLCodeError];
    
    
    //Common Names is a set of strings
    NSMutableString *constructedCommonNames = [NSMutableString stringWithCapacity:1];
    
    for ( CommonName *tmpCommonName in animal.commonNames )
    {
        if ( !tmpCommonName.localeIdentifier ) {
            // Don't include the localized common names
            [constructedCommonNames appendFormat:@"%@, ",tmpCommonName.commonName];
        }
    }
    if ([constructedCommonNames length]>0){
        [constructedCommonNames deleteCharactersInRange:NSMakeRange([constructedCommonNames length]-2, 2)];
    }
    
    if ( !baseHTMLCodeError ) {
        [self htmlTemplate:baseHTMLCode keyString:@"commonNames" replaceWith:[constructedCommonNames copy]];
        [self htmlTemplate:baseHTMLCode keyString:@"animalName" replaceWith:animal.animalName];
        [self htmlTemplate:baseHTMLCode keyString:@"translatedName" replaceWith:animal.translatedName];
        [self htmlTemplate:baseHTMLCode keyString:@"scientificName" replaceWith:animal.scientificName];
        [self htmlTemplate:baseHTMLCode keyString:@"identifyingCharacteristics" replaceWith:animal.identifyingCharacteristics];
        [self htmlTemplate:baseHTMLCode keyString:@"distinctive" replaceWith:animal.distinctive];
        [self htmlTemplate:baseHTMLCode keyString:@"biology" replaceWith:animal.biology];
        [self htmlTemplate:baseHTMLCode keyString:@"habitat" replaceWith:animal.habitat];
        [self htmlTemplate:baseHTMLCode keyString:@"phylum" replaceWith:animal.phylum];
        [self htmlTemplate:baseHTMLCode keyString:@"class" replaceWith:animal.animalClass];
        [self htmlTemplate:baseHTMLCode keyString:@"order" replaceWith:animal.order];
        [self htmlTemplate:baseHTMLCode keyString:@"family" replaceWith:animal.family];
        [self htmlTemplate:baseHTMLCode keyString:@"genus" replaceWith:animal.genusName];
        [self htmlTemplate:baseHTMLCode keyString:@"species" replaceWith:animal.species];
        [self htmlTemplate:baseHTMLCode keyString:@"nativeBadge" replaceWith:[self nativeStatus:animal.nativestatus]];
        [self htmlTemplate:baseHTMLCode keyString:@"native" replaceWith:animal.nativestatus];
        [self htmlTemplate:baseHTMLCode keyString:@"bite" replaceWith:animal.bite];
        [self htmlTemplate:baseHTMLCode keyString:@"diet" replaceWith:animal.diet];
        [self htmlTemplate:baseHTMLCode keyString:@"kingdom" replaceWith:animal.kingdom];
        [self htmlTemplate:baseHTMLCode keyString:@"authority" replaceWith:animal.authority];
        
        [animalDetails loadHTMLString:baseHTMLCode baseURL:baseURL];
    }
    
    if ( !distributionHTMLCodeError ) {
        [self htmlTemplate:distributionHTMLCode keyString:@"mapimage" replaceWith:animal.mapImage];
        [self htmlTemplate:distributionHTMLCode keyString:@"habitat" replaceWith:animal.distribution];
        
        [distributionWebView loadHTMLString:distributionHTMLCode baseURL:baseURL];
    }
    
    if ( !scarcityHTMLCodeError ) {
        [self htmlTemplate:scarcityHTMLCode keyString:@"lcs" replaceWith:animal.lcs];
        [self htmlTemplate:scarcityHTMLCode keyString:@"ncs" replaceWith:animal.ncs];
        [self htmlTemplate:scarcityHTMLCode keyString:@"wcs" replaceWith:animal.wcs];
        
        [scarcityWebView loadHTMLString:scarcityHTMLCode baseURL:baseURL];
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

- (void)htmlTemplate:(NSMutableString *)templateString keyString:(NSString *)stringToReplace replaceWith:(NSString *)replacementString
{

	if ( replacementString != nil && [replacementString length] > 0 ) {
		[templateString replaceOccurrencesOfString:[NSString stringWithFormat:@"<%%%@%%>",stringToReplace] withString:replacementString options:0 range:NSMakeRange(0, [templateString length])];
		[templateString	replaceOccurrencesOfString:[NSString stringWithFormat:@"<%%%@Class%%>",stringToReplace] withString:@" " options:0 range:NSMakeRange(0, [templateString length])];
	} else {
		[templateString replaceOccurrencesOfString:[NSString stringWithFormat:@"<%%%@%%>",stringToReplace] withString:@"" options:0 range:NSMakeRange(0, [templateString length])];
		[templateString	replaceOccurrencesOfString:[NSString stringWithFormat:@"<%%%@Class%%>",stringToReplace] withString:@"invisible" options:0 range:NSMakeRange(0, [templateString length])];
	}
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {

	if (navigationType == UIWebViewNavigationTypeLinkClicked) {
		[[UIApplication sharedApplication] openURL:[request mainDocumentURL]];
		return NO;
	}
	
	return YES;
}

-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    if ( webView == animalDetails) {

        self.initialScrollViewHeight = self.animalDetails.frame.size.height;
        self.initialScrollViewY = self.animalDetails.frame.origin.y;

        CGRect webviewRect = self.animalDetails.frame;
        webviewRect.size.height = self.animalDetails.scrollView.contentSize.height;
        self.animalDetails.frame = webviewRect;

        CGSize scrollViewContentSize = self.scrollView.contentSize;
        scrollViewContentSize.height = webviewRect.size.height + self.initialImageHeight;
        scrollViewContentSize.width = self.scrollView.frame.size.width;
        [self.scrollView setContentSize:scrollViewContentSize];
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
//    }
}


#pragma mark tab bar

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item{

	if ( item == detailsTab ) {
        self.navigationController.navigationBar.translucent = YES;
        
		self.photoScrollView.view.hidden = NO;
		scarcityWebView.hidden = YES;
		distributionWebView.hidden = YES;
		animalDetails.hidden = NO;
        self.scrollView.hidden = NO;
        self.scrollView.scrollEnabled = YES;
	} else if ( item == distributionTab ) {
        self.navigationController.navigationBar.translucent = NO;

		self.photoScrollView.view.hidden = YES;
		scarcityWebView.hidden = YES;
		distributionWebView.hidden = NO;
		animalDetails.hidden = YES;
        self.scrollView.hidden = YES;
        self.scrollView.scrollEnabled = NO;
		
	} else if ( item == rarityTab ) {
        self.navigationController.navigationBar.translucent = NO;

		self.photoScrollView.view.hidden = YES;
		scarcityWebView.hidden = NO;
		distributionWebView.hidden = YES;
		animalDetails.hidden = YES;
        self.scrollView.hidden = YES;
        self.scrollView.scrollEnabled = NO;
  	}
}
					 
- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}


@end
