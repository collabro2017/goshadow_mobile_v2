//
//  Touchpoint.h
//  GoShadow
//
//  Created by Shawn Wall on 7/28/15.
//  Copyright (c) 2015 Inquiri. All rights reserved.
//

#import "AutoDefaultsRLMObject.h"

@interface Touchpoint : AutoDefaultsRLMObject

@property NSInteger     touchpointId;
@property NSString      *name;
@property NSInteger     segmentId;

@end

// This protocol enables typed collections. i.e.:
// RLMArray<Touchpoint>
RLM_ARRAY_TYPE(Touchpoint)
