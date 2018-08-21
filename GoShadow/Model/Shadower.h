//
//  Shadower.h
//  GoShadow
//
//  Created by Shawn Wall on 7/28/15.
//  Copyright (c) 2015 Inquiri. All rights reserved.
//

#import "AutoDefaultsRLMObject.h"

@interface Shadower : AutoDefaultsRLMObject

@property NSInteger     userId;
@property NSString      *firstName;
@property NSString      *lastName;
@property NSString      *email;
@property NSString      *phone;
@property NSString      *title;

@end

// This protocol enables typed collections. i.e.:
// RLMArray<Shadower>
RLM_ARRAY_TYPE(Shadower)
