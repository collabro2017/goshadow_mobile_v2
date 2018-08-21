//
//  Note.m
//  GoShadow
//
//  Created by Shawn Wall on 7/28/15.
//  Copyright (c) 2015 Inquiri. All rights reserved.
//

#import "Note.h"

@implementation Note

+ (NSString *)primaryKey {
    return @"noteId";
}

+ (NSArray *)indexedProperties {
    return @[@"createdAt",@"touchpointId",@"caregiverId",@"segmentId"];
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
