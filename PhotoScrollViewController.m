//
//  PhotoScrollViewController.m
//  NZ Marine Life
//
//  Created by Judit Klein on 27/07/15.
//
//

#import "PhotoScrollViewController.h"
#import "XKPhotoScrollViewAnimatedTransitioning.h"

@interface XKTransitionFullScreenViewController : UIViewController <XKPhotoScrollViewDelegate>

@property (strong, nonatomic) id<XKPhotoScrollViewDataSource> dataSource;
@property (strong, nonatomic) id<XKPhotoScrollViewDelegate> delegate;
@property (strong, nonatomic) NSIndexPath *indexPath;

@property (weak, nonatomic) XKPhotoScrollView *photoScrollView;

@end

@interface XKTransitionPresentationController : UIPresentationController

@end

@interface PhotoScrollViewController() <XKPhotoScrollViewDataSource, XKPhotoScrollViewDelegate, UIViewControllerTransitioningDelegate>

@end

@interface MyTra : XKPhotoScrollViewAnimatedTransitioning

@end

@implementation PhotoScrollViewController {
    NSMutableArray *_images;
}

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSMutableArray *images = [NSMutableArray array];
    [images addObject:[UIImage imageNamed:@"missingthumbnail.jpg"]];
    _images = [NSMutableArray arrayWithArray:images];
    
    _photoScrollView.dataSource = self;
    _photoScrollView.delegate = self;
    _photoScrollView.fillMode = XKPhotoScrollViewFillModeAspectFit;
    _photoScrollView.clipsToBounds = YES;
    
    _photoScrollView.maximumZoomScale = _photoScrollView.minimumZoomScale;
    _photoScrollView.bouncesZoom = NO;
    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.spacerView.bounds;
    gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithWhite:1.0 alpha:0.85] CGColor], (id)[[UIColor colorWithWhite:1.0 alpha:1.0] CGColor], nil];
    [self.spacerView.layer insertSublayer:gradient atIndex:0];
}

-(void)setupArray:(NSArray *)animalImages
{
    self.imageSet = animalImages;
    
    if ( _images.count > 0 ) {
        [_images removeAllObjects];
    }
    
    for (Image *image in animalImages) {
        [_images addObject:[self imageForImage:image]];
    }
    
    if ( self.photoScrollView.currentIndexPath.col != 0) {
        self.photoScrollView.currentIndexPath =  [NSIndexPath indexPathForRow:0 inSection:0];
    }
    
    self.pageControl.numberOfPages = [_images count];
    self.pageControl.currentPage = 0;
    
    [self.photoScrollView reloadData];
}

- (UIImage *)imageForImage:(Image *)currentImage {
    NSString *type = currentImage.filename.pathExtension ? currentImage.filename.pathExtension : @"jpg";
    NSString *path = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@",[[currentImage filename] stringByDeletingPathExtension]] ofType:type];
    return [UIImage imageWithContentsOfFile:path];
}

- (void)setPageControlToCurrentPage:(NSIndexPath *)indexPath
{
    [self setImageCredit:(Image*)[self.imageSet objectAtIndex:indexPath.col]];
    self.pageControl.currentPage = indexPath.col;
}

- (void)setImageCredit:(Image*)currentImage
{
    if ( currentImage != nil ) {
        self.scrollViewImageCredit.text = [NSString stringWithFormat:NSLocalizedString(@"Credit: %@",nil), [currentImage credit]];
    }
}


#pragma mark - XKPhotoScrollView

#pragma mark XKPhotoScrollViewDataSource

- (void)photoScrollView:(XKPhotoScrollView *)photoScrollView requestViewAtIndexPath:(NSIndexPath *)indexPath
{
    UIImage *image = _images[indexPath.col];
    UIImageView *view;
    
//    if ( image.size.width <= image.size.height) {
//        view = [[UIImageView alloc] initWithFrame:self.view.frame];
//        view.contentMode = UIViewContentModeScaleAspectFit;
//        view.image = image;
//    } else {
        view = [[UIImageView alloc] initWithImage:image];
//    }
    
    [self setPageControlToCurrentPage:indexPath];
    
    [photoScrollView setView:view atIndexPath:indexPath placeholder:NO];
}

- (NSUInteger)photoScrollViewCols:(XKPhotoScrollView *)photoScrollView
{
    return _images.count;
}

#pragma mark XKPhotoScrollViewDelegate

- (void)photoScrollView:(XKPhotoScrollView *)photoScrollView didTapView:(UIView *)view atPoint:(CGPoint)pt atIndexPath:(NSIndexPath *)indexPath
{
    [self goFullScreen];
}

#pragma mark - Internal

- (void)goFullScreen
{
    if (self.presentedViewController) {
        /* Prevent multiple simultaneous presentations */
        return;
    }
    
    XKTransitionFullScreenViewController *fullScreen = [XKTransitionFullScreenViewController new];
    fullScreen.dataSource = self;
    fullScreen.delegate = fullScreen;
    fullScreen.indexPath = self.photoScrollView.currentIndexPath;
    
    if ( SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0") ) {
        fullScreen.modalPresentationStyle = UIModalPresentationCustom;
        fullScreen.transitioningDelegate = self;
    }
    [self presentViewController:fullScreen animated:YES completion:NULL];
}

#pragma mark - UIViewControllerTransitioningDelegate

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
{
    return [MyTra new];
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    return [MyTra new];
}

- (UIPresentationController *)presentationControllerForPresentedViewController:(UIViewController *)presented presentingViewController:(UIViewController *)presenting sourceViewController:(UIViewController *)source
{
    return [[XKTransitionPresentationController alloc] initWithPresentedViewController:presented presentingViewController:presenting];
}

@end

@implementation MyTra

- (XKPhotoScrollView *)photoScrollViewForViewController:(UIViewController *)viewController
{
    if ([viewController isKindOfClass:[UISplitViewController class]]) {
        UISplitViewController *split = (UISplitViewController *)viewController;
        return [self photoScrollViewForViewController:split.viewControllers[1]];
    } else if ([viewController respondsToSelector:@selector(photoScrollView)]) {
        PhotoScrollViewController *psvc = [viewController performSelector:@selector(photoScrollView) withObject:nil];
        if ([psvc isKindOfClass:[PhotoScrollViewController class]]) {
            return psvc.photoScrollView;
        } else if ([psvc isKindOfClass:[XKPhotoScrollView class]]) {
            return (XKPhotoScrollView *)psvc;
        }
    } else if ([viewController isKindOfClass:[UITabBarController class]]) {
        
        UITabBarController *tab = (UITabBarController *)viewController;
        return [self photoScrollViewForViewController:tab.viewControllers[0]];
    }
    
    return [super photoScrollViewForViewController:viewController];
}

@end

@implementation XKTransitionPresentationController

- (BOOL)shouldRemovePresentersView
{
    /* We need to remove the presenter's view in order to take over control of the supported interface orientations */
    return YES;
}

@end

#pragma mark -

@implementation XKTransitionFullScreenViewController

- (void)loadView
{
    XKPhotoScrollView *photoScrollView = [XKPhotoScrollView new];
    photoScrollView.currentIndexPath = self.indexPath;
    photoScrollView.dataSource = self.dataSource;
    photoScrollView.delegate = self.delegate;
    photoScrollView.backgroundColor = [UIColor blackColor];
    
    self.photoScrollView = photoScrollView;
    self.view = photoScrollView;
}

/** Allow the full-screen view to rotate upside down */
- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

- (BOOL)shouldAutorotate {

    if (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        UIInterfaceOrientation orientation = [[UIDevice currentDevice]orientation];
        
        if ( orientation != UIInterfaceOrientationPortraitUpsideDown ) {
            self.photoScrollView.orientation = orientation;
        }
    }
    
    return YES;
}

#pragma mark - XKPhotoScrollView

#pragma mark XKPhotoScrollViewDelegate

- (void)photoScrollView:(XKPhotoScrollView *)photoScrollView didTapView:(UIView *)view atPoint:(CGPoint)pt atIndexPath:(NSIndexPath *)indexPath
{
    [self dismissViewControllerAnimated:YES completion:NULL];
    [NSNotificationCenter.defaultCenter postNotificationName:@"resizeImage"
                                                      object:nil];
}

- (void)photoScrollView:(XKPhotoScrollView *)photoScrollView didPinchDismissView:(UIView *)view atIndexPath:(NSIndexPath *)indexPath
{
    [self dismissViewControllerAnimated:YES completion:NULL];
    [NSNotificationCenter.defaultCenter postNotificationName:@"resizeImage"
                                                      object:nil];
}

@end
