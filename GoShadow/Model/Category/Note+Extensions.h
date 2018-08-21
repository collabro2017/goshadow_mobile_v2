//
//  Note+Extensions.h
//  GoShadow
//
//  Created by Shawn Wall on 8/3/15.
//  Copyright (c) 2015 Inquiri. All rights reserved.
//

#import "Note.h"

typedef NS_ENUM(NSInteger, NoteCategoryInteger) {
    NoteCategoryPositive = 1,
    NoteCategoryDialog = 2,
    NoteCategoryAnxiety = 3,
    NoteCategoryInventory = 4,
    NoteCategoryPhoto = 5,
    NoteCategoryAudio = 6,
    NoteCategoryGeneral = 7,
};

@interface Note (Extensions)

+(instancetype)createOrUpdateWithValue:(NSDictionary*)value;
-(NSDictionary*)dictionaryRepresentation;

-(BOOL)isTimer;
+ (NSString *)imageNameForCategoryImage:(NSInteger)category;

@end
