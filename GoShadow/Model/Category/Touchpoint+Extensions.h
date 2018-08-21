//
//  Touchpoint+Extensions.h
//  GoShadow
//
//  Created by Shawn Wall on 8/3/15.
//  Copyright (c) 2015 Inquiri. All rights reserved.
//

#import "Touchpoint.h"

@interface Touchpoint (Extensions)

+(instancetype)createOrUpdateWithValue:(NSDictionary*)value;
-(NSDictionary*)dictionaryRepresentation;

@end
