//
//  AnimalDetailiPad.h
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

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "XKPhotoScrollView.h"
#import "PhotoScrollViewController.h"

@class Animal;
@class PagingScrollView;

@interface AnimalDetailiPad : UIViewController <UIScrollViewDelegate, UIWebViewDelegate, UISplitViewControllerDelegate>  {
    UILabel *detailDescriptionLabel;
	UILabel *commonName;
	UILabel *scientificName;
	UILabel *otherCommonNames;
	
	Animal *animal;
	UIImageView *mainImage;
	UILabel *markingsText;
	UILabel *identifyingText;
	UILabel *biologyText;
	UIWebView *detailsHTML;
	NSMutableArray *animalImageControllers;
	UIImageView *mapImage;
	// To be used when scrolls originate from the UIPageControl
    BOOL pageControlUsed;
	UIWebView *animalHTMLDetails;
	int imageViewBottomLeft;
	UISegmentedControl *imageTextLayoutControl;
	IBOutlet UIWebView *aboutHTML;
}

@property (nonatomic, strong) Animal *animal;
@property (nonatomic, strong) IBOutlet UIView *imageContainerView;
@property (nonatomic, strong) IBOutlet UIWebView *animalHTMLDetails;
@property (nonatomic, strong) PhotoScrollViewController *photoScrollView;
@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) NSString *backButtonTitle;
@property (nonatomic, strong) UIBarButtonItem *backButton;

//-(NSMutableString *)constructHTML;
//-(NSMutableString	*)loadHTML;
- (void)htmlTemplate:(NSMutableString *)templateString keyString:(NSString *)stringToReplace replaceWith:(NSString *)replacementString;
- (BOOL)isFullScreen;
- (BOOL)detailViewIsVisible;
- (void)configureViewWithAnimal:(Animal *)newAnimal;
- (void)updateButtonTitle:(NSString *)title;

@end
