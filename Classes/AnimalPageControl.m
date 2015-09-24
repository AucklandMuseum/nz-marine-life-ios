//
//  AnimalPageControl.m
//  NZ Marine Life
//
//  Created by Judit Klein on 6/07/15.
//
//

#import "AnimalPageControl.h"

@implementation AnimalPageControl

- (void)setCurrentPage:(NSInteger)page {
    [super setCurrentPage:page];
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    for( UIView *view in self.subviews ) {
        view.alpha = 0.0;
    }
        
    if( self.hidesForSinglePage && self.numberOfPages == 1 ) {
        return;
    }
    
    NSInteger padding = (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad) ? 30 : 12;
    
    if (self.numberOfPages > 1) {
        for( int i = 0; i < self.numberOfPages; i++ ) {
            CGRect dotRect = CGRectMake((i * 24) + padding, 12, 8, 8);
            
            if( i == self.currentPage ) {
                [[UIImage imageNamed:@"carousel-dot-on"] drawInRect:dotRect];
            } else {
                [[UIImage imageNamed:@"carousel-dot"] drawInRect:dotRect];
            }
        }        
    }
}

@end
