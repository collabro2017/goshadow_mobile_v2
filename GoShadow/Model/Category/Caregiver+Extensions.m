//
//  Caregiver+Extensions.m
//  GoShadow
//
//  Created by Shawn Wall on 8/3/15.
//  Copyright (c) 2015 Inquiri. All rights reserved.
//

#import "Caregiver+Extensions.h"

@implementation Caregiver (Extensions)

+(instancetype)createOrUpdateWithValue:(NSDictionary*)value {
    Caregiver *caregiver = [Caregiver objectForPrimaryKey:@([value[@"id"] integerValue])];
    if (caregiver == nil) {
        caregiver = [[Caregiver alloc] init];
        caregiver.caregiverId = [value[@"id"] integerValue];
    }
    caregiver.name = value[@"name"];
//    caregiver.segmentId = [value[@"segment_id"] integerValue];
    caregiver.segmentId = 0;
    
    return caregiver;
}

-(NSDictionary*)dictionaryRepresentation {
    NSMutableDictionary *output = [NSMutableDictionary new];
    if (self.caregiverId) {
        [output setObject:@(self.caregiverId) forKey:@"id"];
    }
    [output setObject:self.name forKey:@"name"];
    [output setObject:@(self.segmentId) forKey:@"segment_id"];
    
    return output;
}


@end
