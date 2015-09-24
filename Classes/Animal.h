//
//  Animal.h
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

@class Audio;
@class CommonName;
@class Genus;
@class Image;
@class StatusTypes;
@class TaxonGroup;

@interface Animal :  NSManagedObject  
{
}

@property (nonatomic, strong) NSString * distribution;
@property (nonatomic, strong) NSString * animalName;
@property (weak, nonatomic, readonly) NSString *translatedName;
@property (nonatomic, strong) NSString * biology;
@property (nonatomic, strong) NSString * species;
@property (nonatomic, strong) NSString * identifyingCharacteristics;
@property (nonatomic, strong) NSString * size;
@property (nonatomic, strong) NSString * distinctive;
@property (nonatomic, strong) NSString * habitat;
@property (nonatomic, strong) NSNumber * nocturnal;
@property (nonatomic, strong) NSString * diet;
@property (nonatomic, strong) NSString * bite;
@property (nonatomic, strong) NSString * thumbnail;
@property (nonatomic, strong) NSString * nativestatus;
@property (nonatomic, strong) NSString * foodplant;
@property (nonatomic, strong) NSString * mapImage;
@property (nonatomic, strong) NSString * subTaxon;
@property (nonatomic, strong) NSString * catalogID;
@property (nonatomic, strong) NSString * lcs;
@property (nonatomic, strong) NSString * ncs;
@property (nonatomic, strong) NSString * wcs;
@property (nonatomic, strong) NSSet* commonNames;
@property (nonatomic, strong) NSSet* audios;
@property (nonatomic, strong) NSSet* images;
@property (nonatomic, strong) TaxonGroup * taxon;
@property (nonatomic, strong) NSString * order;
@property (nonatomic, strong) NSString * animalClass;
@property (nonatomic, strong) NSString * family;
@property (nonatomic, strong) NSString * phylum;
@property (nonatomic, strong) NSString * genusName;
@property (nonatomic, strong) NSString * kingdom;
@property (nonatomic, strong) NSString * authority;

@end


@interface Animal (CoreDataGeneratedAccessors)

- (void)addCommonNamesObject:(CommonName *)value;
- (void)removeCommonNamesObject:(CommonName *)value;
- (void)addCommonNames:(NSSet *)value;
- (void)removeCommonNames:(NSSet *)value;

- (void)addAudiosObject:(Audio *)value;
- (void)removeAudiosObject:(Audio *)value;
- (void)addAudios:(NSSet *)value;
- (void)removeAudios:(NSSet *)value;

- (void)addImagesObject:(Image *)value;
- (void)removeImagesObject:(Image *)value;
- (void)addImages:(NSSet *)value;
- (void)removeImages:(NSSet *)value;


- (NSString *) scientificName;
- (NSArray * ) sortedImages;
- (NSString *)nameForLocaleIdentifier:(NSString *)localeIdentifier;
@end

