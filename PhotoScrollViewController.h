//
//  PhotoScrollViewController.h
//  NZ Marine Life
//
//  Created by Judit Klein on 27/07/15.
//
//

#import <UIKit/UIKit.h>
#import <XKPhotoScrollView/XKPhotoScrollView.h>
#import "Image.h"
#import "AnimalPageControl.h"

@interface PhotoScrollViewController : UIViewController

- (void)setupArray:(NSArray* )animalImages;

@property (strong, nonatomic) IBOutlet AnimalPageControl *pageControl;
@property (strong, nonatomic) NSString *currentAnimal;
@property (weak, nonatomic) IBOutlet XKPhotoScrollView *photoScrollView;
@property (strong, nonatomic) IBOutlet UIView *spacerView;
@property (strong, nonatomic) IBOutlet UILabel *scrollViewImageCredit;
@property (strong, nonatomic) NSArray *imageSet;

@end
