//
//  AnimalTableViewCell.h
//  Field Guide 2010
//
//  Created by Ryan Maxwell on 28/09/12.
//
//

#import <UIKit/UIKit.h>

@interface AnimalTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *translatedNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *secondaryLabel;
@property (strong, nonatomic) IBOutlet UIImageView *animalImageView;
@property (strong, nonatomic) IBOutlet UIView *divider;

@end
