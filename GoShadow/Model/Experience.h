//
//  Experience.h
//  GoShadow
//
//  Created by Shawn Wall on 7/28/15.
//  Copyright (c) 2015 Inquiri. All rights reserved.
//

#import "AutoDefaultsRLMObject.h"
#import "Segment.h"

@interface Experience : AutoDefaultsRLMObject

@property NSInteger     experienceId;
@property NSString      *name;
@property float         startLatitude;
@property float         endLatitude;
@property float         startLongitude;
@property float         endLongitude;
//@property NSString      *experienceNotes;
@property BOOL          isPublished;
//@property BOOL          isShowingDetails;
@property NSString      *locationStartName;
@property NSString      *locationStartUrl;
@property NSString      *locationEndName;
@property NSString      *locationEndUrl;
@property NSString      *requesterName;
//@property NSString      *status;
@property NSString      *type;
@property NSString      *facility;
@property NSDate        *createdAt;
@property NSDate        *updatedAt;

@property RLMArray<Segment> *segments;

@end

// This protocol enables typed collections. i.e.:
// RLMArray<Experience>
RLM_ARRAY_TYPE(Experience)