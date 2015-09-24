//
//  Field_Guide_2010AppDelegate.h
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

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "WelcomeScreenViewController.h"
#import "iphoneAboutViewController.h"


@class AnimalDetailiPad;
@class RootViewController;

@interface Field_Guide_2010AppDelegate : NSObject <UIApplicationDelegate> {
    
    UIWindow *window;
    UINavigationController *navigationController;
    UINavigationController *detailNavigationController;
	UISplitViewController *splitviewController;
	UITabBarController *tabBarController;
    
@private
    NSManagedObjectContext *managedObjectContext_;
    NSManagedObjectModel *managedObjectModel_;
    NSPersistentStoreCoordinator *persistentStoreCoordinator_;
    RootViewController *rootView;
    iphoneAboutViewController *aboutVC;
	BOOL isDatabaseComplete;
}

extern NSString * const DidRefreshDatabaseNotificationName;

@property (nonatomic, strong) IBOutlet UIWindow *window;
@property (nonatomic, strong) IBOutlet UINavigationController *navigationController;
@property (nonatomic, strong) IBOutlet UINavigationController *detailNavigationController;
@property (nonatomic, strong) IBOutlet UISplitViewController *splitviewController;
@property (nonatomic, strong) UITabBarController *tabBarController;
@property (nonatomic, strong) RootViewController *rootView;
@property (nonatomic, strong) WelcomeScreenViewController *welcomeScreen;
@property (nonatomic, strong, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, strong, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (NSString *)applicationDocumentsDirectory;
- (void) setupDatabase;
- (void) refreshDatabase;
- (void) updateiPhoneLoadProgress:(id)value;
- (void) loadSettings;
- (void) saveSettings;
- (void) initiPhoneLayout;

@end

