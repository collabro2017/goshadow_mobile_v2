//
//  GoShadowAPIManager.h
//  GoShadow
//
//  Created by Shawn Wall on 7/28/15.
//  Copyright (c) 2015 Inquiri. All rights reserved.
//

#import "AFHTTPRequestOperationManager.h"
@class Experience;
@class Segment;
@class Note;
@class Shadower;
@class Touchpoint;
@class Caregiver;

/**
 Block used by net operations passing a success status boolean
 and the result of the net operation
 */
typedef void(^GoShadowCallback)(id result, NSError *error);

@interface GoShadowAPIManager : AFHTTPRequestOperationManager

-(Shadower*)getCurrentUser;
-(BOOL)isAuthenticated;
+(instancetype)sharedManager;
-(void)authenticateWithEmail:(NSString*)email
                    password:(NSString*)password
                    callback:(GoShadowCallback)callback;
-(void)signupWithEmail:(NSString*)email
              password:(NSString*)password
              firstName:(NSString*)firstName
              lastName:(NSString*)lastName
              organization:(NSString*)organization
              callback:(GoShadowCallback)callback;
-(void)getCurrentUserWithCallback:(GoShadowCallback)callback;
-(void)resetPasswordWithEmail:(NSString*)email callback:(GoShadowCallback)callback;
-(void)updateDataWithCallback:(GoShadowCallback)callback;
-(void)getExperiencesWithCallback:(GoShadowCallback)callback;
-(void)postExperience:(Experience*)experience withCallback:(GoShadowCallback)callback;
-(void)putExperience:(Experience*)experience withCallback:(GoShadowCallback)callback;
-(void)deleteExperienceWithId:(NSInteger)experienceId withCallback:(GoShadowCallback)callback;
-(void)getSegmentsWithCallback:(GoShadowCallback)callback;
-(void)postSegment:(Segment*)segment withCallback:(GoShadowCallback)callback;
-(void)deleteSegmentWithId:(NSInteger)segmentId withCallback:(GoShadowCallback)callback;
-(void)getNotesWithCallback:(GoShadowCallback)callback;
-(void)getNotesForSegmentId:(NSInteger)segmentId withCallback:(GoShadowCallback)callback;
-(void)postNote:(Note*)note withCallback:(GoShadowCallback)callback;
-(void)putNote:(Note*)note withCallback:(GoShadowCallback)callback;
-(void)deleteNoteWithId:(NSInteger)noteId inSegmentId:(NSInteger)segmentId withCallback:(GoShadowCallback)callback;
-(void)getShadowersWithCallback:(GoShadowCallback)callback;
-(void)postShadower:(Shadower*)shadower withCallback:(GoShadowCallback)callback;
-(void)getTouchpointsWithCallback:(GoShadowCallback)callback;
-(void)postTouchpoint:(Touchpoint*)touchpoint withCallback:(GoShadowCallback)callback;
-(void)getCaregiversWithCallback:(GoShadowCallback)callback;
-(void)postCaregiver:(Caregiver*)caregiver withCallback:(GoShadowCallback)callback;
-(void)logout;

@end
