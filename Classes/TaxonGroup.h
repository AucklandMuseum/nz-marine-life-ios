//
//  TaxonGroup.h
//  Field Guide 2010
//
//  Created by VC N on 1/08/10.
/*
 Copyright (c) 2011 Museum Victoria
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
//

#import <CoreData/CoreData.h>

@class Animal;
@class SubTaxonGroup;
@class LocalizedTaxonName;

@interface TaxonGroup :  NSManagedObject  
{
}

@property (nonatomic, strong) NSNumber * taxonID;
@property (nonatomic, strong) NSString * taxonName;
@property (weak, nonatomic, readonly) NSString *translatedName;
@property (nonatomic, strong) NSString * standardImage;
@property (nonatomic, strong) NSString * highlightedImage;
@property (nonatomic, strong) NSSet* animals;
@property (nonatomic, strong) NSSet* subTaxons;
@property (nonatomic, strong) NSSet* localizedNames;

- (NSString *)nameForLocaleIdentifier:(NSString *)localeIdentifier;
@end


@interface TaxonGroup (CoreDataGeneratedAccessors)
- (void)addAnimalsObject:(Animal *)value;
- (void)removeAnimalsObject:(Animal *)value;
- (void)addAnimals:(NSSet *)value;
- (void)removeAnimals:(NSSet *)value;

- (void)addSubTaxonsObject:(SubTaxonGroup *)value;
- (void)removeSubTaxonsObject:(SubTaxonGroup *)value;
- (void)addSubTaxons:(NSSet *)value;
- (void)removeSubTaxons:(NSSet *)value;

- (void)addLocalizedNamesObject:(LocalizedTaxonName *)value;
- (void)removeLocalizedNamesObject:(LocalizedTaxonName *)value;
- (void)addLocalizedNames:(NSSet *)value;
- (void)removeLocalizedNames:(NSSet *)value;
@end

