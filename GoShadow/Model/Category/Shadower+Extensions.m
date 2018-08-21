//
//  Shadower+Extensions.m
//  GoShadow
//
//  Created by Shawn Wall on 8/3/15.
//  Copyright (c) 2015 Inquiri. All rights reserved.
//

#import "Shadower+Extensions.h"

@implementation Shadower (Extensions)

+(instancetype)createOrUpdateWithValue:(NSDictionary*)value {
    Shadower *shadower = [Shadower objectForPrimaryKey:@([value[@"id"] integerValue])];
    if (shadower == nil) {
        shadower = [[Shadower alloc] init];
        shadower.userId = [value[@"id"] integerValue];
    }
    if (value[@"first_name"] != [NSNull null]) {
        shadower.firstName = value[@"first_name"];
    }
    if (value[@"last_name"] != [NSNull null]) {
        shadower.lastName = value[@"last_name"];
    }
   
    shadower.email = value[@"email"];
    
//    shadower.phone = value[@"phone"];
//    shadower.title = value[@"title"];
    return shadower;
}

-(NSDictionary*)dictionaryRepresentation {
    NSMutableDictionary *output = [NSMutableDictionary new];
    if (self.userId) {
        [output setObject:@(self.userId) forKey:@"id"];
    }
    [output setObject:self.firstName forKey:@"first_name"];
    [output setObject:self.lastName forKey:@"last_name"];
    [output setObject:self.email forKey:@"email"];
    
    [output setObject:self.phone forKey:@"phone"];
    [output setObject:self.title forKey:@"title"];
    
    return output;
}

-(NSString*)name {
    if (self.firstName != nil && self.firstName.length) {
        return [NSString stringWithFormat:@"%@ %@", self.firstName, self.lastName];
    }
    else {
        return self.email;
    }

}

@end
