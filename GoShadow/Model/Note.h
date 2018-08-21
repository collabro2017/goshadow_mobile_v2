//
//  Note.h
//  GoShadow
//
//  Created by Shawn Wall on 7/28/15.
//  Copyright (c) 2015 Inquiri. All rights reserved.
//

#import "AutoDefaultsRLMObject.h"
@class Touchpoint;
@class Caregiver;

typedef NS_ENUM(NSInteger, NoteLocalStatus) {
    NoteLocalStatusSynched,
    NoteLocalStatusAdd,
    NoteLocalStatusUpdate,
    NoteLocalStatusDelete
};

@interface Note : AutoDefaultsRLMObject

@property NSInteger     noteId;
@property NSString      *note;
@property NSInteger     caregiverId;
@property NSInteger     touchpointId;
@property BOOL          isHighlight;
@property BOOL          isFavorite;
@property NSInteger     categoryId;
@property NSString      *categoryName;
@property NSDate        *createdAt;
@property NSDate        *updatedAt;
@property NSString      *attachmentUrl;
@property NSInteger     segmentId;
@property NSInteger     userId;
@property NSDate        *startDate;
@property NSInteger     accumulatedTime;
@property NSData        *attachmentFile;

@property Touchpoint    *touchpoint;
@property Caregiver     *caregiver;

//changed locally but not published to server
@property NoteLocalStatus localStatus;

@end

// This protocol enables typed collections. i.e.:
// RLMArray<Note>
RLM_ARRAY_TYPE(Note)
