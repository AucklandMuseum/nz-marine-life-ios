//
//  TaxonListViewController.m
//  Field Guide 2010
//
//  Created by VC N on 1/08/10.
/*
 Copyright (c) 2011 Museum Victoria
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
//

#import "TaxonListViewController.h"
#import "DataFetcher.h"
#import "TaxonGroup.h"
#import "SimpleFetchedAnimalListViewController.h"
#import "Field_Guide_2010AppDelegate.h"

@implementation TaxonListViewController

#pragma mark View lifecycle

@synthesize rightViewReference;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Life Forms";
    
    taxonController = [[DataFetcher sharedInstance] fetchedResultsControllerForEntity:@"TaxonGroup" withPredicate:nil sortField:@"taxonName"];
	NSError *fetchError;
	[taxonController performFetch:&fetchError];
    
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(refresh) name:DidRefreshDatabaseNotificationName object:nil];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.translucent = NO;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[taxonController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	id <NSFetchedResultsSectionInfo> sectionInfo = [[taxonController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    
	TaxonGroup *managedTaxon = [taxonController objectAtIndexPath:indexPath];
	cell.textLabel.text = managedTaxon.taxonName;
    cell.textLabel.font = [UIFont boldSystemFontOfSize:19.0];
    cell.detailTextLabel.text = managedTaxon.translatedName;
    cell.detailTextLabel.font = [UIFont systemFontOfSize:15.0];
    UIImage *theImage = [UIImage imageNamed:managedTaxon.taxonName];

    if ( !theImage )
    {
		theImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"missingthumbnail" ofType:@"jpg"]];
	}
    
	NSString *highlightString = [NSString stringWithFormat:@"%@highlighted",managedTaxon.taxonName];
	
    UIImage *theHighlightedImage = [UIImage imageNamed:highlightString];
    
    if ( !theHighlightedImage )
    {
		theHighlightedImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"missingthumbnail" ofType:@"jpg"]];
	}
	
	cell.imageView.image = theImage;
    cell.imageView.highlightedImage = theHighlightedImage;
    cell.textLabel.highlightedTextColor = [UIColor whiteColor];
    cell.detailTextLabel.highlightedTextColor = [UIColor whiteColor];
	
    return cell;
}

#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

	SimpleFetchedAnimalListViewController *newAnimalList = [[SimpleFetchedAnimalListViewController alloc] initWithNibName:@"SimpleFetchedAnimalListViewController" bundle:nil];
	newAnimalList.selectedTaxon = [taxonController objectAtIndexPath:indexPath];
	newAnimalList.title = [NSString stringWithFormat:@"%@", newAnimalList.selectedTaxon.taxonName];
	
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		newAnimalList.rightViewReference = self.rightViewReference;	
	}
    
    UIView * selectedBackgroundView = [[UIView alloc] init];
    [selectedBackgroundView setBackgroundColor:[UIColor colorWithRed:0/255.0 green:122/255.0 blue:255/255.0 alpha:1]];
    [[tableView cellForRowAtIndexPath:indexPath] setSelectedBackgroundView:selectedBackgroundView];
    
	[self.navigationController pushViewController:newAnimalList animated:YES];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ( self.tableView.frame.size.height < 667) {
        return 76;
    } else {
        return 80;
    }
}

#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

- (void)refresh {
    [taxonController performFetch:nil];
    [self.tableView reloadData];
}

- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

@end

