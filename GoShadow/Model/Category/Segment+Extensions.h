//
//  Segment+Extensions.h
//  GoShadow
//
//  Created by Shawn Wall on 8/3/15.
//  Copyright (c) 2015 Inquiri. All rights reserved.
//

#import "Segment.h"

@interface Segment (Extensions)

+(instancetype)createOrUpdateWithValue:(NSDictionary*)value;
-(NSDictionary*)dictionaryRepresentation;
-(NSString*)cellSummary;

@end
