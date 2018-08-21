//
//  Touchpoint+Extensions.m
//  GoShadow
//
//  Created by Shawn Wall on 8/3/15.
//  Copyright (c) 2015 Inquiri. All rights reserved.
//

#import "Touchpoint+Extensions.h"

@implementation Touchpoint (Extensions)

+(instancetype)createOrUpdateWithValue:(NSDictionary*)value {
    Touchpoint *touchpoint = [Touchpoint objectForPrimaryKey:@([value[@"id"] integerValue])];
    if (touchpoint == nil) {
        touchpoint = [[Touchpoint alloc] init];
        touchpoint.touchpointId = [value[@"id"] integerValue];
    }
    touchpoint.name = value[@"name"];
    if (value[@"segment_id"] != [NSNull null]) {
        touchpoint.segmentId = [value[@"segment_id"] integerValue];
    }
    else {
        touchpoint.segmentId = 0;
    }
    return touchpoint;
}

-(NSDictionary*)dictionaryRepresentation {
    NSMutableDictionary *output = [NSMutableDictionary new];
    if (self.touchpointId) {
        [output setObject:@(self.touchpointId) forKey:@"id"];
    }
    [output setObject:self.name forKey:@"name"];
    [output setObject:@(self.segmentId) forKey:@"segment_id"];
    
    return output;
}

@end
