//
//  Segment.m
//  GoShadow
//
//  Created by Shawn Wall on 7/28/15.
//  Copyright (c) 2015 Inquiri. All rights reserved.
//

#import "Segment.h"

@implementation Segment

+ (NSString *)primaryKey {
    return @"segmentId";
}

+ (NSArray *)indexedProperties {
    return @[@"createdAt",@"experienceId"];
}

// Specify default values for properties

//+ (NSDictionary *)defaultPropertyValues
//{
//    return @{};
//}

// Specify properties to ignore (Realm won't persist these)

//+ (NSArray *)ignoredProperties
//{
//    return @[];
//}

@end
