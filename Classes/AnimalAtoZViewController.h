//
//  AnimalAtoZViewController.h
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

#import <UIKit/UIKit.h>

@class AnimalDetailiPad;
@class AnimalTableViewCell;

@interface AnimalAtoZViewController : UITableViewController <UISearchBarDelegate, UIScrollViewDelegate> {
	NSArray *animalArray;
	AnimalDetailiPad *rightViewReference;
	NSMutableArray *sectionsArray;
	UILocalizedIndexedCollation *collation;
}

@property (strong) NSArray *animalArray;
@property (nonatomic, strong) AnimalDetailiPad *rightViewReference;
@property (nonatomic, strong) NSMutableArray *sectionsArray;
@property (nonatomic,strong) UILocalizedIndexedCollation *collation;
@property (nonatomic, strong) IBOutlet AnimalTableViewCell *animalTableViewCell;
@property (nonatomic, strong) NSArray *searchResults;
@property (nonatomic, assign) BOOL searching;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, assign) SEL selector;


-(void) configureSections;

@end
