//
//  Segment.h
//  GoShadow
//
//  Created by Shawn Wall on 7/28/15.
//  Copyright (c) 2015 Inquiri. All rights reserved.
//

#import "AutoDefaultsRLMObject.h"
#import "Shadower.h"
#import "Note.h"

@interface Segment : AutoDefaultsRLMObject

@property NSInteger     segmentId;
@property NSString      *name;
@property float         startLatitude;
@property float         endLatitude;
@property float         startLongitude;
@property float         endLongitude;
//@property NSString      *segmentNotes;
@property BOOL          isPublished;
//@property BOOL          isShowingDetails;
@property NSString      *locationStartName;
@property NSString      *locationStartUrl;
@property NSString      *locationEndName;
@property NSString      *locationEndUrl;
@property NSString      *requesterName;
//@property NSString      *status;
//@property NSString      *type;
@property NSString      *facility;
@property NSDate        *createdAt;
@property NSDate        *updatedAt;
@property NSInteger     experienceId;

@property RLMArray<Shadower> *shadowers;
@property RLMArray<Note> *notes;

@end

// This protocol enables typed collections. i.e.:
// RLMArray<Segment>
RLM_ARRAY_TYPE(Segment)
