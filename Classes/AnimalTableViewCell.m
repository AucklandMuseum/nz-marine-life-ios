//
//  AnimalTableViewCell.m
//  Field Guide 2010
//
//  Created by Ryan Maxwell on 28/09/12.
//
//

#import "AnimalTableViewCell.h"

@implementation AnimalTableViewCell

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect dividerFrame = self.divider.frame;
    dividerFrame.size.height = 0.5;
    dividerFrame.origin.y = 79.5;
    self.divider.frame = dividerFrame;
    
    if (self.nameLabel.text.length && self.translatedNameLabel.text.length && self.secondaryLabel.text.length) {
        // layout 3 labels
        
        self.nameLabel.frame = CGRectMake(self.nameLabel.frame.origin.x, 11.0f, self.nameLabel.frame.size.width, self.nameLabel.frame.size.height);
        self.translatedNameLabel.frame = CGRectMake(self.translatedNameLabel.frame.origin.x, 30.0f, self.translatedNameLabel.frame.size.width, self.translatedNameLabel.frame.size.height);
        self.secondaryLabel.frame = CGRectMake(self.secondaryLabel.frame.origin.x, 48.0f, self.secondaryLabel.frame.size.width, self.secondaryLabel.frame.size.height);
        
    } else if (self.nameLabel.text.length && self.secondaryLabel.text.length) {
        // layout 2 labels
        
        self.nameLabel.frame = CGRectMake(self.nameLabel.frame.origin.x, 20.0f, self.nameLabel.frame.size.width, self.nameLabel.frame.size.height);
        self.secondaryLabel.frame = CGRectMake(self.secondaryLabel.frame.origin.x, 40.0f, self.secondaryLabel.frame.size.width, self.secondaryLabel.frame.size.height);
        
    } else {
        // layout 1 label
        
        self.nameLabel.frame = CGRectMake(self.nameLabel.frame.origin.x, 26.0f, self.nameLabel.frame.size.width, self.nameLabel.frame.size.height);
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    UIView * selectedBackgroundView = [[UIView alloc] init];
    [selectedBackgroundView setBackgroundColor:[UIColor colorWithRed:0/255.0 green:122/255.0 blue:255/255.0 alpha:1]];
    [self setSelectedBackgroundView:selectedBackgroundView];
}



@end
