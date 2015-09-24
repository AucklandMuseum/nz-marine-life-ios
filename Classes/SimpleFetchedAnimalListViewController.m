//
//  SimpleFetchedAnimalListViewController.m
//  Field Guide 2010
//
//  Created by VC N on 1/03/11.
/*
 Copyright (c) 2011 Museum Victoria
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
//

#import "SimpleFetchedAnimalListViewController.h"
#import "TaxonGroup.h"
#import "Animal.h"
#import "AnimalDetailiPad.h"
#import "SubTaxonGroup.h"
#import "AnimalDetailsiPhoneViewController.h"
#import "DataFetcher.h"
#import "AnimalTableViewCell.h"
#import "AnimalHeaderView.h"
#import "WelcomeScreenViewController.h"

@implementation SimpleFetchedAnimalListViewController

#define SYSTEM_VERSION_LESS_THAN(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)

#pragma mark View lifecycle

@synthesize selectedTaxon, rightViewReference;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.backBarButtonItem.title = @"Life Forms";
    
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, 44.0)];
    self.searchBar.delegate = self;
    self.searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
    self.searchBar.showsCancelButton = NO;
    self.searchBar.placeholder = NSLocalizedString(@"Search", nil);
    
    if ( SYSTEM_VERSION_LESS_THAN(@"7.0") ) {
        self.searchBar.backgroundColor = [UIColor colorWithRed:201.0/255.0 green:201.0/255.0 blue:206.0/255.0 alpha:1];
        for ( id img in self.searchBar.subviews ) {
            if ( [img isKindOfClass:NSClassFromString(@"UISearchBarBackground")] ) {
                [img removeFromSuperview];
            }
        }
    } else {
        self.tabBarController.tabBar.translucent = NO;
    }
    
    self.tableView.tableHeaderView = self.searchBar;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"AnimalHeaderView" bundle:nil] forCellReuseIdentifier:@"headerView"];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
		self.clearsSelectionOnViewWillAppear = NO;
	}
	NSString *searchTerm = [NSString stringWithFormat:@"taxon.taxonName ='%@'",selectedTaxon.taxonName];
	NSPredicate *searchPredicate = [NSPredicate predicateWithFormat:searchTerm];
	animalController = [[DataFetcher sharedInstance] fetchedResultsControllerForEntity:@"Animal" withPredicate:searchPredicate sortField:@"animalName" sectionNameKeyPath:@"subTaxon"  ];
	
	NSError *fetchError;
	[animalController performFetch:&fetchError];
    
    self.tableView.rowHeight = 80;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    self.navigationController.navigationBar.translucent = NO;
    CGPoint contentOffset = self.tableView.contentOffset;
    
    NSIndexPath *selectedCell = [self.tableView indexPathForSelectedRow];
    if ( selectedCell ) {
        [self.tableView cellForRowAtIndexPath:selectedCell].selected = YES;
    }
    
    if ( contentOffset.y < self.searchBar.frame.size.height ) {
        contentOffset.y += CGRectGetHeight(self.tableView.tableHeaderView.frame);
        self.tableView.contentOffset = contentOffset;
    }
    
     [self.tableView scrollToNearestSelectedRowAtScrollPosition:UITableViewScrollPositionNone animated:NO];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    if ( self.searching ) {
        return  1;
    } else {
        return [[animalController sections] count];
    }
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    if ( self.searching ) {
        return self.searchResults.count;
    } else {
        id <NSFetchedResultsSectionInfo> sectionInfo = [[animalController sections] objectAtIndex:section];
        return [sectionInfo numberOfObjects];
    }
}

- (NSString *) tableView:(UITableView *)sender titleForHeaderInSection:(NSInteger)section {
    if ( self.searching ) {
        return @"Search Result";
    } else {
        
    id <NSFetchedResultsSectionInfo> sectionInfo = [[animalController sections] objectAtIndex:section];
		return [sectionInfo name];
    }
}

#pragma mark layout

- (void)configureCell:(AnimalTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath{
    
    Animal *tmpAnimal;
    
    if ( self.searching ) {
        tmpAnimal = (Animal *)[self.searchResults objectAtIndex:indexPath.row];
    } else {
        tmpAnimal = [animalController objectAtIndexPath:indexPath];
    }
    
    cell.nameLabel.text = tmpAnimal.animalName;
    cell.nameLabel.font = [UIFont boldSystemFontOfSize:19.0];
    
    if ( tmpAnimal.scientificName != nil && ![tmpAnimal.scientificName isEqualToString:@" "] ) {
        cell.secondaryLabel.text = tmpAnimal.scientificName;
        cell.secondaryLabel.font = [UIFont italicSystemFontOfSize:13];
    } else {
        cell.secondaryLabel.font = [UIFont systemFontOfSize:13];
        
        if ( tmpAnimal.family.length ) {
            cell.secondaryLabel.text = [NSString stringWithFormat:@"Family: %@", tmpAnimal.family];
        } else if (tmpAnimal.order.length) {
            cell.secondaryLabel.text = [NSString stringWithFormat:@"Order: %@", tmpAnimal.order];
        } else if (tmpAnimal.animalClass.length) {
            cell.secondaryLabel.text = [NSString stringWithFormat:@"Class: %@", tmpAnimal.animalClass];
        } else if (tmpAnimal.phylum.length) {
            cell.secondaryLabel.text = [NSString stringWithFormat:@"Phylum: %@", tmpAnimal.phylum];
        } else {
            cell.secondaryLabel.text = nil;
        }
    }
    
    // Translation
    NSString *translationLocale = VariableStore.sharedInstance.translationLocaleIdentifier;
    if (translationLocale) {
        NSString *translatedName = [tmpAnimal nameForLocaleIdentifier:translationLocale];
        cell.translatedNameLabel.text = (translatedName.length) ? translatedName : nil;
        cell.translatedNameLabel.font = [UIFont systemFontOfSize:15];
    }
    
    if ([[tmpAnimal images] count]>0) {

        NSString *path = [[NSBundle mainBundle] pathForResource:[tmpAnimal.thumbnail stringByDeletingPathExtension] ofType:@"jpg"];
        
        UIImage *theImage;
        if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
            theImage = [UIImage imageWithContentsOfFile:path];
        } else {
            theImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"missingthumbnail" ofType:@"jpg"]];
        }
        
        cell.animalImageView.image = theImage;
        
    } else {
        cell.animalImageView.image = nil;
    }
    
    [cell setNeedsLayout];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  
    static NSString *CellIdentifier = @"AnimalCell";

    AnimalTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        [[NSBundle mainBundle] loadNibNamed:@"AnimalTableViewCell" owner:self options:nil];
        cell = self.animalTableViewCell;
        self.animalTableViewCell = nil;
    }
    
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}

- (BOOL)shouldAutorotate {
    return YES;
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    NSIndexPath *selectedCell = [self.tableView indexPathForSelectedRow];
    if ( selectedCell ) {
        [self.tableView cellForRowAtIndexPath:selectedCell].selected = YES;
    }
}

#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
     Animal *tmpAnimal;
        
    if ( self.searching ) {
        NSUInteger index = [indexPath indexAtPosition:[indexPath length] - 1];
        tmpAnimal  = [self.searchResults objectAtIndex:index];
        [self.searchBar resignFirstResponder];
    } else {
        tmpAnimal  = [animalController objectAtIndexPath:indexPath];
    }
	
	if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ) {
        
        UINavigationController *nav = [self.splitViewController.viewControllers objectAtIndex:1];
        
        if ( nav.viewControllers.count > 1 ) {
            rightViewReference = [nav.viewControllers lastObject];
            [rightViewReference configureViewWithAnimal:tmpAnimal];
            [rightViewReference updateButtonTitle:tmpAnimal.taxon.taxonName];
        } else {
            rightViewReference = [[AnimalDetailiPad alloc]initWithNibName:@"AnimalDetailiPad" bundle:[NSBundle mainBundle]];
            rightViewReference.animal = tmpAnimal;
            [rightViewReference updateButtonTitle:tmpAnimal.taxon.taxonName];
            [nav pushViewController:rightViewReference animated:NO];
            [rightViewReference.navigationItem setHidesBackButton:YES animated:NO];
        }
        
        if ( self.selector == nil ) {
            for (UIViewController *viewController in nav.viewControllers) {
                if ( [viewController isKindOfClass:[WelcomeScreenViewController class]] ) {
                    WelcomeScreenViewController *welcome = (WelcomeScreenViewController *)viewController;
                    rightViewReference.backButton = welcome.backButton;
                    self.selector = welcome.backButton.action;
                }
            }
        }
        
        if ( ![self landscape] && self.selector != nil ) {
            ((void (*)(id, SEL))[self.splitViewController methodForSelector:self.selector])(self.splitViewController, self.selector);
        }
        
	} else {
        
		AnimalDetailsiPhoneViewController *detailViewController = [[AnimalDetailsiPhoneViewController alloc] initWithNibName:@"AnimalDetailsiPhoneViewController" bundle:nil];
		detailViewController.animal = tmpAnimal;
		detailViewController.title = tmpAnimal.animalName;
        
        self.navigationItem.backBarButtonItem =
        [[UIBarButtonItem alloc] initWithTitle:@" "
                                         style:UIBarButtonItemStyleBordered
                                        target:nil
                                        action:nil];
        
        [self.navigationController pushViewController:detailViewController animated:YES];
	}
    
}

- (BOOL)landscape {
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if ( orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight ) {
        return  YES;
    } else {
        return NO;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {

    if ( self.searching ) {
        return 22;
    } else {
        
        NSString *title = [[[animalController sections] objectAtIndex:section]name];

        
        if ( self.view.frame.size.width <= 320 ) {
        CGSize labelSize = [title sizeWithFont:[UIFont boldSystemFontOfSize:16]
                                   constrainedToSize:CGSizeMake(self.view.frame.size.width-32, 44)
                                       lineBreakMode:NSLineBreakByWordWrapping];
        return ceilf(labelSize.height)+5;
            
        } else {
            return 22;
        }
    }
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    NSString *title;
    
    if ( self.searching ) {
         title = @"Search Result";
    } else {
        id <NSFetchedResultsSectionInfo> sectionInfo = [[animalController sections] objectAtIndex:section];
        title = [sectionInfo name];
    }
  
    AnimalHeaderView *header = [[[NSBundle mainBundle] loadNibNamed:@"AnimalHeaderView"
                                                  owner:self
                                                options:nil] objectAtIndex:0];
    
    [header setTitleWithName:title];
    [self tableView:tableView heightForHeaderInSection:section];
    
    return header;
    
}

#pragma mark search

-(void) searchBarTextDidBeginEditing: (UISearchBar *) theSearchBar
{
    [self.searchBar setShowsCancelButton:YES animated:YES];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if (searchText.length > 0) {
        self.searching = YES;
        [self searchAnimals:searchText];
        [searchBar setShowsCancelButton:YES animated:YES];
    } else {
        self.searching = NO;
    }
    
    [self.tableView reloadData];
}

- (void)searchAnimals:(NSString *)searchText
{
    NSArray *searchTerms = [[searchText stringByTrimmingCharactersInSet: [NSCharacterSet characterSetWithCharactersInString:@" "]] componentsSeparatedByString:@" "];
    NSMutableString *searchString = [NSMutableString stringWithCapacity:1];
    
    //Potentially better search can be constructed. Need to search across Name, Common Names, Genus and Species for an Animal
    //Searches is always "or" for words in the search list.
    
    [searchString appendString: [NSString stringWithFormat:@"(animalName MATCHES[cd] '(.* )?%@.*'", [searchTerms objectAtIndex:0]]];
    if ([searchTerms count] > 1) {
        //build or statements
        for (int i = 1; i < [searchTerms count]; i++) {
            [searchString appendString: [NSString stringWithFormat:@" AND animalName MATCHES[cd] '(.* )?%@.*'", [searchTerms objectAtIndex:i]]];
        }
    }
    
    //search on Common Names
    //OR (ANY commonNames.commonName == "red" AND ANY commonNames.commonName == "snake")
    [searchString appendString: [NSString stringWithFormat:@") OR (ANY commonNames.commonName MATCHES[cd] '(.* )?%@.*'", [searchTerms objectAtIndex:0]]];
    if ([searchTerms count] > 1) {
        //build or statements
        for (int i = 1; i < [searchTerms count]; i++) {
            [searchString appendString: [NSString stringWithFormat:@" AND ANY commonNames.commonName MATCHES[cd] '(.* )?%@.*'", [searchTerms objectAtIndex:i]]];
        }
    }
    //OR there is a species or genus match
    [searchString appendString: [NSString stringWithFormat:@") OR ( genusName BEGINSWITH[cd] '%@'", [searchTerms objectAtIndex:0]]];
    if ([searchTerms count] > 1) {
        //build or statements
        for (int i = 1; i < [searchTerms count]; i++) {
            [searchString appendString: [NSString stringWithFormat:@" OR genusName BEGINSWITH[cd] '%@'", [searchTerms objectAtIndex:i]]];
        }
    }
    [searchString appendString: [NSString stringWithFormat:@") OR (species BEGINSWITH[cd] '%@'", [searchTerms objectAtIndex:0]]];
    if ([searchTerms count] > 1) {
        //build or statements
        for (int i = 1; i < [searchTerms count]; i++) {
            [searchString appendString: [NSString stringWithFormat:@" OR species BEGINSWITH[cd] '%@'", [searchTerms objectAtIndex:i]]];
        }
    }
    
    [searchString appendString:@")"];
    
    //Search on genus or species
    NSString *searchTerm = [NSString stringWithString:searchString];
    NSPredicate *searchPredicate = [NSPredicate predicateWithFormat:searchTerm];
    
    NSArray *results = [[DataFetcher sharedInstance] fetchManagedObjectsForEntity:@"Animal" withPredicate:searchPredicate withSortField:@"animalName"];
    NSMutableArray *filteredResults = [[NSMutableArray alloc]init];
    for (Animal *animal in results) {
        if ( [animal.taxon.taxonName isEqualToString:selectedTaxon.taxonName] ) {
            [filteredResults addObject:animal];
        }
    }
    self.searchResults = [NSArray arrayWithArray:filteredResults];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:NO animated:YES];
    [self.searchBar resignFirstResponder];
    self.searchBar.text = @"";
    self.searching = NO;
    [self.tableView reloadData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

#pragma mark scroll View

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.searchBar resignFirstResponder];
    [self.searchBar setShowsCancelButton:NO animated:YES];
}



@end

