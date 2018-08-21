//
//  Caregiver.h
//  GoShadow
//
//  Created by Shawn Wall on 7/28/15.
//  Copyright (c) 2015 Inquiri. All rights reserved.
//

#import "AutoDefaultsRLMObject.h"

@interface Caregiver : AutoDefaultsRLMObject

@property NSInteger     caregiverId;
@property NSString      *name;
@property NSInteger     segmentId;

@end

// This protocol enables typed collections. i.e.:
// RLMArray<Caregiver>
RLM_ARRAY_TYPE(Caregiver)
