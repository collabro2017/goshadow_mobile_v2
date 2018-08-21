//
//  Experience.m
//  GoShadow
//
//  Created by Shawn Wall on 7/28/15.
//  Copyright (c) 2015 Inquiri. All rights reserved.
//

#import "Experience.h"

@implementation Experience

+ (NSString *)primaryKey {
    return @"experienceId";
}

+ (NSArray *)indexedProperties {
    return @[@"createdAt"];
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
