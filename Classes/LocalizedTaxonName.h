//
//  LocalizedTaxonName.h
//  Field Guide 2010
//
//  Created by Ryan Maxwell on 1/10/12.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class SubTaxonGroup, TaxonGroup;

@interface LocalizedTaxonName : NSManagedObject

@property (nonatomic, strong) NSString *localeIdentifier;
@property (nonatomic, strong) NSString *taxonName;
@property (nonatomic, strong) TaxonGroup *taxonGroup;
@property (nonatomic, strong) SubTaxonGroup *subTaxonGroup;

@end
