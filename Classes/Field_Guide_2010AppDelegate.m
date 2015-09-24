//
//  Field_Guide_2010AppDelegate.m
//  Field Guide 2010
//
//  Created by Simon Sherrin on 1/08/10.
/*
 Copyright (c) 2011 Museum Victoria
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
//
#import <Google/Analytics.h>
#import <QuartzCore/QuartzCore.h>

#import "Field_Guide_2010AppDelegate.h"
#import "RootViewController.h"
#import "TaxonListViewController.h"
#import "DataFetcher.h"
#import "TaxonGroup.h"
#import "Animal.h"
#import "Image.h"
#import "SubTaxonGroup.h"
#import "Audio.h"
#import "CommonName.h"
#import "AnimalAtoZViewController.h"
#import "AnimalDetailiPad.h"
#import "DataVersion.h"
#import "LocalizedTaxonName.h"

NSString * const DidRefreshDatabaseNotificationName = @"FieldGuideDidRefreshDatabase";

@implementation Field_Guide_2010AppDelegate

@synthesize window;
@synthesize navigationController, detailNavigationController, welcomeScreen;
@synthesize splitviewController;
@synthesize tabBarController;
@synthesize rootView;
#define SYSTEM_VERSION_LESS_THAN(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)

#pragma mark -
#pragma mark Application lifecycle

- (void)awakeFromNib {    
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ) {
        rootView = (RootViewController *)[navigationController topViewController];
        rootView.managedObjectContext = self.managedObjectContext;
	}
}


- (void)loadSettings {
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	if ( [prefs boolForKey:@"isDatabaseComplete"] ) {
		isDatabaseComplete = [prefs boolForKey:@"isDatabaseComplete"];
	}
}

-(void)saveSettings{
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	[prefs setBool:isDatabaseComplete forKey:@"isDatabaseComplete"]; //Database has been built after inital opening
	[prefs synchronize];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    // Override point for customization after application launch.
	[self loadSettings];
	
    navigationController.navigationBar.tintColor = [UIColor colorWithRed:0/255.0 green:122/255.0 blue:255/255.0 alpha:1];

	BOOL buildingDatabase = NO;
	// If the database or Set up database file from animalData.plist
	//Database setup occurs on a separate thread, buildingDatabase is used to prevent userinput and orientation changes in the iPad Version
	//while the database is building
	if ( ![[DataFetcher sharedInstance] databaseExists]||!isDatabaseComplete ) {
		[self setupDatabase];
		buildingDatabase = YES;
	} else { //check if stored version number is the same as the current, if not, refresh database
        NSArray *currentVersionArray = [[DataFetcher sharedInstance] fetchManagedObjectsForEntity:@"DataVersion" withPredicate:nil];
        if ( [currentVersionArray count] > 0 ) {
            
            DataVersion *currentDataVersion = [currentVersionArray objectAtIndex:0];
            if ( ![currentDataVersion.versionID isEqualToString:[VariableStore sharedInstance].animalDataVersion] ) {
                NSLog(@"The database is being refreshed as the stored versionID is different to the CustomSettingsID");
                NSLog(@"Stored data version: %@", currentDataVersion.versionID);
                NSLog(@"CustomSetting data version: %@", [VariableStore sharedInstance].animalDataVersion);
                buildingDatabase = YES;
                [self refreshDatabase];
            }
            
        } else { //we don't have a version in the database, refersh
            NSLog(@"The data base is being refreshed as there is no versionID");
            buildingDatabase = YES;
            [self refreshDatabase];
        }
    }
        
	NSLog(@"Passed Database Build");

    // Add the navigation controller's view to the window and display.
    // Using Interface Idiom to distingish between iPhones and iPads.
	if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ) {
        [self initiPadLayout];
        
		if ( buildingDatabase ) {
            welcomeScreen.loadingDatabase = YES;
            [welcomeScreen setupProgressView];
            [welcomeScreen loadHTMLPageWithStatus:@"building"];
		} else {
            welcomeScreen.loadingDatabase = NO;
            [welcomeScreen loadHTMLPageWithStatus:@"ready"];
		}
        
    } else {	// The device is an iPhone or iPod touch.
        [self initiPhoneLayout];
        
        if ( buildingDatabase ) {
            [aboutVC setupProgressView];
            [aboutVC loadHTMLwithStatus:@"building"];
        } else {
            [aboutVC loadHTMLwithStatus:@"ready"];
        }
	}

    [window makeKeyAndVisible];

    return YES;
}

- (void)initiPadLayout {
    
    
    //tab bar
    tabBarController = [[UITabBarController alloc] init];
   
    TaxonListViewController *taxonListView = [[TaxonListViewController alloc] initWithNibName:@"TaxonListViewController" bundle:[NSBundle mainBundle]];
   
    navigationController = [[UINavigationController alloc] initWithRootViewController:taxonListView];
    navigationController.navigationBar.tintColor = [UIColor colorWithRed:0/255.0 green:122/255.0 blue:255/255.0 alpha:1];
    navigationController.tabBarItem.image = [UIImage imageNamed:@"tab-bar-life-forms"];
    navigationController.tabBarItem.selectedImage = [UIImage imageNamed:@"tab-bar-life-forms-active"];
    navigationController.title = NSLocalizedString(@"Life Forms",nil);
    taxonListView.title = NSLocalizedString(@"Life Forms",nil);
    
    AnimalAtoZViewController *aToZViewController = [[AnimalAtoZViewController alloc] initWithNibName:@"AnimalAtoZViewController" bundle:nil];
    UINavigationController *aToZNavController = [[UINavigationController alloc] initWithRootViewController:aToZViewController];
    aToZNavController.navigationBar.tintColor = [UIColor colorWithRed:0/255.0 green:122/255.0 blue:255/255.0 alpha:1];
    aToZNavController.title = NSLocalizedString(@"A - Z",nil);
    aToZViewController.title = NSLocalizedString(@"Alphabetical",nil);
    
    aToZNavController.tabBarItem.image = [UIImage imageNamed:@"tab-bar-alphabetical"];
    aToZNavController.tabBarItem.selectedImage = [UIImage imageNamed:@"tab-bar-alphabetical-active"];
    
    NSArray *tabBarVCArray = [NSArray arrayWithObjects:navigationController, aToZNavController, nil];
    tabBarController.viewControllers = tabBarVCArray;
        
    //detail view
    welcomeScreen = [[WelcomeScreenViewController alloc] initWithNibName:@"WelcomeScreenViewController" bundle:[NSBundle mainBundle]];
    detailNavigationController = [[UINavigationController alloc] initWithRootViewController:welcomeScreen];

    detailNavigationController.navigationBar.tintColor = [UIColor colorWithRed:0/255.0 green:122/255.0 blue:255/255.0 alpha:1];
    
    splitviewController.viewControllers = [NSArray arrayWithObjects:tabBarController, detailNavigationController, nil];
    splitviewController.delegate = (id)detailNavigationController.topViewController;
    
    [self.window setRootViewController:(UIViewController*)splitviewController];
    
}

- (void)initiPhoneLayout {
    
	tabBarController = [[UITabBarController alloc] init];  
	TaxonListViewController *taxonListView = [[TaxonListViewController alloc] initWithNibName:@"TaxonListViewController" bundle:[NSBundle mainBundle]];
	taxonListView.title = NSLocalizedString(@"Life Forms",nil);
    
	navigationController = [[UINavigationController alloc] initWithRootViewController:taxonListView];
    
    //tab bar view controllers
	AnimalAtoZViewController *aToZViewController = [[AnimalAtoZViewController alloc] initWithNibName:@"AnimalAtoZViewController" bundle:nil];
	UINavigationController *aToZNavController = [[UINavigationController alloc] initWithRootViewController:aToZViewController];
	aToZNavController.title = NSLocalizedString(@"A - Z",nil);
	aToZViewController.title = NSLocalizedString(@"Alphabetical",nil);
    
    aboutVC = [[iphoneAboutViewController alloc] initWithNibName:@"iphoneAboutViewController" bundle:nil];
    aboutVC.title = NSLocalizedString(@"About",nil);
    

    if ( SYSTEM_VERSION_LESS_THAN(@"7.0") ) {
        [tabBarController.tabBar setTintColor:[UIColor whiteColor]];
        tabBarController.tabBar.clipsToBounds = YES;
        [[UITabBar appearance] setSelectionIndicatorImage:[[UIImage alloc] init]];
        
        tabBarController.tabBar.layer.borderWidth = 0.25;
        tabBarController.tabBar.layer.borderColor = [UIColor colorWithRed:190.0/255.0 green:190.0/255.0 blue:190.0/255.0 alpha:1].CGColor;
        
        UIImage *searchBarImage = [[UIImage imageNamed:@"searchBar"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 10, 44, 310)];
        [[UISearchBar appearance] setSearchFieldBackgroundImage:searchBarImage forState:UIControlStateNormal];
        
        [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: [UIColor colorWithRed:0/255.0 green:122/255.0 blue:255/255.0 alpha:1], UITextAttributeTextColor, nil] forState:UIControlStateSelected];
        
        [aToZNavController.tabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"tab-bar-alphabetical-active"] withFinishedUnselectedImage:[UIImage imageNamed:@"tab-bar-alphabetical"]];
        [navigationController.tabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"tab-bar-life-forms-active"] withFinishedUnselectedImage:[UIImage imageNamed:@"tab-bar-life-forms"]];
        [aboutVC.tabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"tab-bar-about-help-active"] withFinishedUnselectedImage:[UIImage imageNamed:@"tab-bar-about-help"]];
        
        NSDictionary *textTitleOptions = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor blackColor], UITextAttributeTextColor, [UIColor clearColor], UITextAttributeTextShadowColor, nil];
        [[UINavigationBar appearance] setTitleTextAttributes:textTitleOptions];
        
        NSDictionary *textBackTitleOptions = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorWithRed:0/255.0 green:122/255.0 blue:255/255.0 alpha:1], UITextAttributeTextColor, [UIColor clearColor], UITextAttributeTextShadowColor, nil];
        UIImage *backImage = [[UIImage imageNamed:@"backIcon"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 14, 0, 20)];
        [[UIBarButtonItem appearance] setBackButtonBackgroundImage:backImage forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
        [[UIBarButtonItem appearance] setTitleTextAttributes:textBackTitleOptions forState:UIControlStateNormal];
        
        [[UIBarButtonItem appearanceWhenContainedIn: [UISearchBar class], nil] setTintColor:[UIColor clearColor]];
        [[UIBarButtonItem appearanceWhenContainedIn: [UISearchBar class], nil] setTitleTextAttributes:textBackTitleOptions forState:UIControlStateNormal];
        
        navigationController.navigationBar.tintColor = [UIColor whiteColor];
        [navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navbar"]
                                                 forBarMetrics:UIBarMetricsDefault];
        
        aToZNavController.navigationBar.tintColor = [UIColor whiteColor];
        [aToZNavController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navbar"]
                                                 forBarMetrics:UIBarMetricsDefault];
        
    } else {
        
        aToZNavController.tabBarItem.image = [UIImage imageNamed:@"tab-bar-alphabetical"];
        aToZNavController.tabBarItem.selectedImage = [UIImage imageNamed:@"tab-bar-alphabetical-active"];
        navigationController.tabBarItem.image = [UIImage imageNamed:@"tab-bar-life-forms"];
        navigationController.tabBarItem.selectedImage = [UIImage imageNamed:@"tab-bar-life-forms-active"];
        aboutVC.tabBarItem.image = [UIImage imageNamed:@"tab-bar-about-help"];
        
        navigationController.navigationBar.tintColor = [UIColor colorWithRed:0/255.0 green:122/255.0 blue:255/255.0 alpha:1];
        aToZNavController.navigationBar.tintColor = [UIColor colorWithRed:0/255.0 green:122/255.0 blue:255/255.0 alpha:1];
        
    }
    
    NSArray *tabBarVCArray = [NSArray arrayWithObjects:navigationController,aToZNavController,aboutVC, nil];
    tabBarController.viewControllers = tabBarVCArray;
    window.rootViewController = tabBarController;
    tabBarController.selectedIndex = 2;

}

#pragma mark Initial Dataload

- (void)refreshDatabase {
                        
    //delete everything and start again
    NSManagedObjectContext *currentContext = [[DataFetcher sharedInstance] managedObjectContext];	
    NSArray *allTaxons = [[DataFetcher sharedInstance] fetchManagedObjectsForEntity:@"TaxonGroup" withPredicate:nil];
    for (TaxonGroup *tmpTaxon in allTaxons){
        [currentContext deleteObject:tmpTaxon];
    
    }
    //Cascade delete should have removed all the animals, but just in case there's one outside the group
    NSArray *remainingAnimals = [[DataFetcher sharedInstance] fetchManagedObjectsForEntity:@"Animal" withPredicate:nil];
    NSLog(@"Remaining Animals Count: %lu", (unsigned long)[remainingAnimals count]);
    for (Animal *tmpAnimal in remainingAnimals){
        [currentContext deleteObject:tmpAnimal];
    }
    
    NSArray *dataVersions = [[DataFetcher sharedInstance] fetchManagedObjectsForEntity:@"DataVersion" withPredicate:nil];
    for (DataVersion *tmpVersion in dataVersions){
        [currentContext deleteObject:tmpVersion];
    }
    
    NSLog(@"About to Save");
    NSError *saveError;
    [currentContext save:&saveError];
    //now reload
    [self setupDatabase];
    }

- (void)setupDatabase {
    if ([NSThread currentThread] == [NSThread mainThread]) //If called from the main thread rather than background thread
    {
        [self performSelectorInBackground:@selector(setupDatabase) withObject: nil];
        return;
    }
    
    //Setup pool
    @autoreleasepool {
        
        NSManagedObjectContext *backgroundContext = [[NSManagedObjectContext alloc] init];
        backgroundContext.persistentStoreCoordinator = DataFetcher.sharedInstance.persistentStoreCoordinator;
        
        CGFloat currentRecord = 1;
        NSLog(@"No Database Found");
        NSBundle *thisBundle = [NSBundle bundleForClass:[self class]];
        NSString *commonArrayPath;
        if ((commonArrayPath =[thisBundle pathForResource:@"animalData" ofType:@"plist"])) {
            //NSArray *loadValues = [[NSArray alloc] initWithContentsOfFile:commonArrayPath];
            NSDictionary *loadValues = [NSDictionary dictionaryWithContentsOfFile:commonArrayPath];
            
            if ([loadValues count] > 0) {
                //Update Version Data
                //Note that if the value for currentAnimalData in CustomSettings.plist is different to the versionID
                //in animalData, the database will be reloaded everytime the user starts the application.
                //May make the versionID in animalData purely for human reference.
                NSString *loadingVersionID = [loadValues objectForKey:@"versionID"];
                DataVersion *loadingDataVersion = [NSEntityDescription insertNewObjectForEntityForName:@"DataVersion" inManagedObjectContext:backgroundContext];
                loadingDataVersion.versionID = loadingVersionID;
                
                //Create Taxon Values
                //NSArray *taxonArray = [loadValues objectAtIndex:0];
                NSArray *taxonArray = [loadValues objectForKey:@"taxonList"];
                for (NSDictionary *tmpTaxonDict in taxonArray) {
                    
                    TaxonGroup *taxonGroup = [NSEntityDescription insertNewObjectForEntityForName:@"TaxonGroup" inManagedObjectContext:backgroundContext];
                    //testTaxon1.taxonID = ;
                    taxonGroup.taxonName = [tmpTaxonDict objectForKey:@"taxonName"];
                    taxonGroup.standardImage = [tmpTaxonDict objectForKey:@"standardImage"];
                    taxonGroup.highlightedImage = [tmpTaxonDict objectForKey:@"highlightedImage"];
                    NSLog(@"Taxon Name Set");
                    
                    NSDictionary *translatedNames = (NSDictionary *)[tmpTaxonDict objectForKey:@"translatedName"];
                    if (translatedNames != nil && translatedNames.count > 0) {
                        // Add translated Names with Locale Identifier
                        [translatedNames enumerateKeysAndObjectsUsingBlock:^(id key, id value, BOOL *stop){
                            LocalizedTaxonName *taxonName =[NSEntityDescription insertNewObjectForEntityForName:@"LocalizedTaxonName" inManagedObjectContext:backgroundContext];
                            taxonName.taxonName = (NSString *)value;
                            taxonName.localeIdentifier = (NSString *)key;
                            [taxonGroup addLocalizedNamesObject:taxonName];
                        }];
                    }
                }
                
                //Load Animal Details
                //NSArray *animalArray = [loadValues objectAtIndex:1];
                NSArray *animalArray = [loadValues objectForKey:@"animalData"];
                CGFloat totalNumberOfRecords = [animalArray count];
                for (NSDictionary *tmpAnimalData in animalArray){
                    currentRecord += 1;
                    
                    CGFloat progress = currentRecord/totalNumberOfRecords;
                    [self performSelectorOnMainThread:@selector(updateiPhoneLoadProgress:) withObject:@(progress) waitUntilDone:NO];
                    
                    /* empty dict */
                    if ([[tmpAnimalData allKeys] count] == 0) continue;
                    
                    Animal *tmpAnimal = [NSEntityDescription insertNewObjectForEntityForName:@"Animal" inManagedObjectContext:backgroundContext];
                    tmpAnimal.diet = [tmpAnimalData objectForKey:@"diet"];
                    tmpAnimal.biology = [tmpAnimalData objectForKey:@"biology"];
                    tmpAnimal.habitat = [tmpAnimalData objectForKey:@"habitat"];
                    tmpAnimal.distinctive = [tmpAnimalData objectForKey:@"distinctive"];
                    tmpAnimal.identifyingCharacteristics = [tmpAnimalData objectForKey:@"identifyingCharacteristics"];
                    tmpAnimal.catalogID = [tmpAnimalData objectForKey:@"identifier"];
                    tmpAnimal.distribution = [tmpAnimalData objectForKey:@"distribution"];
                    tmpAnimal.bite = [tmpAnimalData objectForKey:@"bite"];
                    NSArray *commonNames = (NSArray *) [tmpAnimalData	objectForKey:@"commonNames"];
                    if ([commonNames count]>0) {
                        tmpAnimal.animalName = [commonNames objectAtIndex:0];
                        if ([commonNames count]> 1) {
                            //Add Common Names
                            for (int i=1; i<=([commonNames count]-1); i++) {
                                //Add Common Name
                                CommonName *localCommon =[NSEntityDescription insertNewObjectForEntityForName:@"CommonName" inManagedObjectContext:backgroundContext];
                                localCommon.commonName = [commonNames objectAtIndex:i];
                                [tmpAnimal addCommonNamesObject:localCommon];
                            }
                        }
                    }
                    else {
                        tmpAnimal.animalName = @"Unknown";
                    }
                    NSDictionary *translatedNames = (NSDictionary *)[tmpAnimalData objectForKey:@"translatedName"];
                    if (translatedNames != nil && translatedNames.count > 0) {
                        // Add translated Names with Locale Identifier
                        [translatedNames enumerateKeysAndObjectsUsingBlock:^(id key, id value, BOOL *stop){
                            CommonName *localCommon =[NSEntityDescription insertNewObjectForEntityForName:@"CommonName" inManagedObjectContext:backgroundContext];
                            localCommon.commonName = (NSString *)value;
                            localCommon.localeIdentifier = (NSString *)key;
                            [tmpAnimal addCommonNamesObject:localCommon];
                        }];
                    }
                    
                    tmpAnimal.species = [tmpAnimalData objectForKey:@"species"];
                    tmpAnimal.genusName = [tmpAnimalData objectForKey:@"genus"];
                    tmpAnimal.animalClass = [tmpAnimalData objectForKey:@"class"];
                    tmpAnimal.order = [tmpAnimalData objectForKey:@"order"];
                    tmpAnimal.family = [tmpAnimalData objectForKey:@"family"];
                    tmpAnimal.phylum = [tmpAnimalData objectForKey:@"phylum"];
                    tmpAnimal.kingdom = [tmpAnimalData objectForKey:@"kingdom"];
                    tmpAnimal.authority = [tmpAnimalData objectForKey:@"authority"];
                    
                    
                    NSPredicate *taxonPredicate = [NSPredicate predicateWithFormat:@"taxonName=%@", [tmpAnimalData objectForKey:@"taxonGroup"]];
                    NSArray *currenttaxon = [[DataFetcher sharedInstance] fetchManagedObjectsForEntity:@"TaxonGroup" withPredicate:taxonPredicate inContext:backgroundContext];
                    NSLog(@"TaxonName %@, Taxon Count %lu", [tmpAnimalData objectForKey:@"taxonGroup"], (unsigned long)[currenttaxon count]);
                    if ([currenttaxon count] > 0) {
                        TaxonGroup *localTaxon = [currenttaxon objectAtIndex:0];
                        [localTaxon addAnimalsObject:tmpAnimal];
                        
                        //Current Taxon may already contain subgroup.
                        NSString *tmpSubTaxon = [tmpAnimalData objectForKey:@"taxonSubgroup"];
                        tmpAnimal.subTaxon = tmpSubTaxon;
                        NSPredicate *subTaxonPredicate = [NSPredicate predicateWithFormat:@"subTaxonName=%@", tmpSubTaxon];
                        NSArray *existingSubTaxon = [[DataFetcher sharedInstance] fetchManagedObjectsForEntity:@"SubTaxonGroup" withPredicate:subTaxonPredicate inContext:backgroundContext];
                        if ([existingSubTaxon count] >0){
                            //Don't need to create SubTaxon, already exists. Assumption: SubTaxon Names are unique across all taxon groups
                            //If not, then need to change data model. Add two way many to many relationship (possible?)
                            
                        }else {
                            //subTaxon doesn't currently exist, create and add to Taxon
                            SubTaxonGroup *localSubTaxon = [NSEntityDescription insertNewObjectForEntityForName:@"SubTaxonGroup" inManagedObjectContext:backgroundContext];
                            localSubTaxon.subTaxonName = tmpSubTaxon;
                            [localTaxon addSubTaxonsObject:localSubTaxon];
                        }
                    }
                    
                    
                    NSLog(@"Taxon Count: %@", [[tmpAnimal taxon] taxonName]);
                    
                    //Native Status and Conservation Status
                    
                    tmpAnimal.nativestatus =[tmpAnimalData objectForKey:@"nativeStatus"];
                    tmpAnimal.lcs = [tmpAnimalData objectForKey:@"lcs"];
                    tmpAnimal.ncs = [tmpAnimalData objectForKey:@"ncs"];
                    tmpAnimal.wcs = [tmpAnimalData objectForKey:@"wcs"];
                				// Set blank to non-threatened
                    
                    if (!tmpAnimal.lcs.length) {
                        tmpAnimal.lcs = @"Not Listed";
                    }
                    if (!tmpAnimal.ncs.length) {
                        tmpAnimal.ncs = @"Not Listed";
                    }
                    if (!tmpAnimal.wcs.length) {
                        tmpAnimal.wcs = @"Not Listed";
                    }
                    
                    NSArray *tmpImageArray = [tmpAnimalData objectForKey:@"profileImages"];
                    int counter = 0;
                    for (NSDictionary *tmpImageData in tmpImageArray){
                        counter +=1;
                        Image *tmpImage = [NSEntityDescription insertNewObjectForEntityForName:@"Image" inManagedObjectContext:backgroundContext];
                        tmpImage.filename = [tmpImageData objectForKey:@"filename"];
                        tmpImage.credit = [tmpImageData objectForKey:@"credit"];
                        tmpImage.order = [NSNumber numberWithInt:counter];
                        NSLog(@"Image Order: %li", (long)tmpImage.order.integerValue);
                        //tmpImage.caption = [tmpImageData objectForKey:@"Caption"];
                        [tmpAnimal addImagesObject:tmpImage];
                        //[tmpImage release];
                        
                    }
                    
                    NSArray *tmpThumbnailArray = [tmpAnimalData objectForKey:@"squareCropImage"];
                    for (NSDictionary *tmpThumbnailData in tmpThumbnailArray){
                        tmpAnimal.thumbnail = [tmpThumbnailData objectForKey:@"filename"];
                    }
                    
                    //Map Image
                    NSArray *tmpMapArray = [tmpAnimalData objectForKey:@"mapImage"];
                    for (NSDictionary *tmpMapData in tmpMapArray) {
                        tmpAnimal.mapImage = [tmpMapData objectForKey:@"filename"];
                    }
                    
                    NSLog(@"Image Count %lu", (unsigned long)[[tmpAnimal images] count]);
                    
                    NSArray *tmpAudioArray = [tmpAnimalData objectForKey:@"audioFiles"];
                    for (NSDictionary *tmpAudioData in tmpAudioArray) {
                        Audio *tmpAudio = [NSEntityDescription insertNewObjectForEntityForName:@"Audio" inManagedObjectContext:backgroundContext];
                        tmpAudio.filename = [tmpAudioData objectForKey:@"filename"];
                        tmpAudio.credit = [tmpAudioData objectForKey:@"credit"];
                        [tmpAnimal addAudiosObject:tmpAudio];
                    }
                    
                }
                
                NSLog(@"About to Save");
                NSError *saveError;
                [backgroundContext save:&saveError];
                
                
            }
        }
        [self performSelectorOnMainThread:@selector(finishedImport) withObject:nil waitUntilDone:NO];
    }
    [NSNotificationCenter.defaultCenter postNotificationName:DidRefreshDatabaseNotificationName
                                                      object:nil];
}

- (void)updateiPhoneLoadProgress:(id)value {
    CGFloat progress = [value floatValue];
    if (progress >= 0.0 && progress <= 1.0) {
        [aboutVC updateProgressBar:progress];
        [welcomeScreen updateProgressBar:progress];
    }
}

- (void)finishedImport {
	isDatabaseComplete = YES;
	[self saveSettings];
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [welcomeScreen hideProgress];
	} else {
        [aboutVC hideProgress];
	}
}

#pragma mark -

- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}


/**
 applicationWillTerminate: saves changes in the application's managed object context before the application terminates.
 */
- (void)applicationWillTerminate:(UIApplication *)application {
    
    NSError *error = nil;
    if (managedObjectContext_ != nil) {
        if ([managedObjectContext_ hasChanges] && ![managedObjectContext_ save:&error]) {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}


#pragma mark -
#pragma mark Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *)managedObjectContext {
    
    if (managedObjectContext_ != nil) {
        return managedObjectContext_;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        managedObjectContext_ = [[NSManagedObjectContext alloc] init];
        [managedObjectContext_ setPersistentStoreCoordinator:coordinator];
    }
    return managedObjectContext_;
}


/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created from the application's model.
 */
- (NSManagedObjectModel *)managedObjectModel {
    
    if (managedObjectModel_ != nil) {
        return managedObjectModel_;
    }
    NSString *modelPath = [[NSBundle mainBundle] pathForResource:@"Field_Guide_2010" ofType:@"momd"];
    NSURL *modelURL = [NSURL fileURLWithPath:modelPath];
    managedObjectModel_ = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];    
    return managedObjectModel_;
}


/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    
    if (persistentStoreCoordinator_ != nil) {
        return persistentStoreCoordinator_;
    }
    
    NSURL *storeURL = [NSURL fileURLWithPath: [[self applicationDocumentsDirectory] stringByAppendingPathComponent: @"Field_Guide_2010.sqlite"]];
    
    NSError *error = nil;
    persistentStoreCoordinator_ = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                             [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
    
    if (![persistentStoreCoordinator_ addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter: 
         [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    return persistentStoreCoordinator_;
}


#pragma mark -
#pragma mark Application's Documents directory

/**
 Returns the path to the application's Documents directory.
 */
- (NSString *)applicationDocumentsDirectory {
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}

@end

