//
//  Experience+Extensions.h
//  GoShadow
//
//  Created by Shawn Wall on 8/3/15.
//  Copyright (c) 2015 Inquiri. All rights reserved.
//

#import "Experience.h"

@interface Experience (Extensions)

+(instancetype)createOrUpdateWithValue:(NSDictionary*)value;
-(NSDictionary*)dictionaryRepresentation;
-(NSString*)cellSummary;
+(NSArray*)experienceTypes;

@end
