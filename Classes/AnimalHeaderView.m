//
//  AnimalHeaderView.m
//  NZ Marine Life
//
//  Created by Judit Klein on 2/07/15.
//
//

#import "AnimalHeaderView.h"

@implementation AnimalHeaderView

- (void)awakeFromNib {
    if (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        self.width = 320;
    } else {
        self.width = [[UIScreen mainScreen]bounds].size.width;
    }
}

- (void)setTitleWithName:(NSString *)fullName {
    
    self.fullName = fullName;
//    self.contentView.backgroundColor = [UIColor colorWithRed:235.0/255.0 green:235.0/255.0 blue:235.0/255.0 alpha:1.0];
    
    NSUInteger numberOfOccurrences = [[fullName componentsSeparatedByString:@"("] count] - 1;
    
    NSRange range = [fullName rangeOfString:@"("];
    
    if ( numberOfOccurrences >= 2 ) {
        [self formatComplexString:fullName];
        
    } else if (range.location != NSNotFound ) {

        self.title = [fullName substringToIndex:range.location];
        
        NSString *maoriName = [fullName substringFromIndex:range.location];
        NSString *stringWithoutLeftBracket = [maoriName stringByReplacingOccurrencesOfString:@"(" withString:@""];
        NSString *stringWithoutRightBracket = [stringWithoutLeftBracket stringByReplacingOccurrencesOfString:@")" withString:@""];
        self.subtitle = stringWithoutRightBracket;
    } else {
        self.title = fullName;
        self.subtitle = @"";
    }
    
    NSString *finalString = [[NSString alloc]initWithFormat:@"%@%@ ", self.title, self.subtitle];
    [self finalTextToCell:finalString];
}

- (void)formatComplexString:(NSString *)complexString
{
    NSCharacterSet *delimiters = [NSCharacterSet characterSetWithCharactersInString:@"()"];
    NSArray *splitString = [complexString componentsSeparatedByCharactersInSet:delimiters];
    
    NSMutableString *titleString = [[NSMutableString alloc]initWithString:@""];
    NSMutableString *subtitleString = [[NSMutableString alloc]initWithString:@""];
    
    for (int i = 0; i < splitString.count; i++) {
        if ( i % 2) {
            if ( i == splitString.count-2 && ![splitString[i] isEqualToString:@""] ) {
                [subtitleString appendString:[NSString stringWithFormat:@"%@",splitString[i]]];
            } else {
                [subtitleString appendString:[NSString stringWithFormat:@"%@ ",splitString[i]]];
            }
            
        } else {
            [titleString appendString:[NSString stringWithFormat:@"%@",splitString[i]]];
        }
    }
    
    self.title = [titleString stringByReplacingOccurrencesOfString:@"  " withString:@" "];
    self.subtitle = [subtitleString stringByReplacingOccurrencesOfString:@" " withString:@" & "];
    
    NSString *finalString = [[NSString alloc]initWithFormat:@"%@%@ ", self.title, self.subtitle];
    [self finalTextToCell:finalString];

}

- (void)finalTextToCell:(NSString *)finalString {

    NSMutableAttributedString *formattedString = [[NSMutableAttributedString alloc] initWithString:finalString];
    
    [formattedString addAttribute:NSFontAttributeName
                       value:[UIFont boldSystemFontOfSize:17]
                       range:NSMakeRange(0, self.title.length)];
    self.titleLabel.attributedText = formattedString;
    
    if ( self.width <= 320 ) {

        CGSize labelSize = [self.fullName sizeWithFont:[UIFont boldSystemFontOfSize:16]
                             constrainedToSize:CGSizeMake(self.titleLabel.frame.size.width, 44)
                                 lineBreakMode:NSLineBreakByWordWrapping];
        
        CGRect labelRect = self.titleLabel.frame;
        labelRect.size.height = ceilf(labelSize.height);
        self.titleLabel.frame = labelRect;
    }
}

@end
