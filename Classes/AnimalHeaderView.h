//
//  AnimalHeaderView.h
//  NZ Marine Life
//
//  Created by Judit Klein on 2/07/15.
//
//

#import <UIKit/UIKit.h>

@interface AnimalHeaderView : UITableViewHeaderFooterView

@property (nonatomic, strong) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) NSString *subtitle;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *fullName;
@property (nonatomic, assign) CGFloat width;

- (void)setTitleWithName:(NSString *)fullName;

@end
