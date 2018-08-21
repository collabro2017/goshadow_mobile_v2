//
//  GoShadowAPIManager.m
//  GoShadow
//
//  Created by Shawn Wall on 7/28/15.
//  Copyright (c) 2015 Inquiri. All rights reserved.
//

#import "GoShadowAPIManager.h"
#import "GoShadowModels.h"
#import <Lockbox.h>
#import "AppDelegate.h"

//#warning STAGING
//static NSString * const kAFGoShadowAPIBaseURLString = @"http://staging.goshadow.org/api_v2/";
static NSString * const kAFGoShadowAPIBaseURLString = @"http://platform.goshadow.org/api_v2/";
static NSString * const kKeyGoShadowAPIAccessToken = @"goshadow-access-token";
static NSString * const kKeyGoShadowUserId = @"goshadow-current-user-id";

@implementation GoShadowAPIManager

+(instancetype)sharedManager {
    static GoShadowAPIManager *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[GoShadowAPIManager alloc] initWithBaseURL:[NSURL URLWithString:kAFGoShadowAPIBaseURLString]];
    });
    
    return _sharedClient;
}

-(instancetype)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if (!self) {
        return nil;
    }
    self.requestSerializer = [AFJSONRequestSerializer new];
    
    //wakeup
    if ([self isAuthenticated]) {
        [self setAccessToken:[Lockbox stringForKey:kKeyGoShadowAPIAccessToken]];
    }
    
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        if (status > 0) {
            //we are online, synch notes
            [self synchronizeNotes];
        }
    }];
    return self;
}

-(void)synchronizeNotes {
    RLMResults *dirtyNotes = [Note objectsWhere:@"localStatus != %d", NoteLocalStatusSynched];
    for (Note *note in dirtyNotes) {
        if (note.localStatus == NoteLocalStatusDelete) {
            [self deleteNoteWithId:note.noteId inSegmentId:note.segmentId withCallback:^(id result, NSError *error) {
                if (!error) {
                    RLMRealm *realm = [RLMRealm defaultRealm];
                    [realm beginWriteTransaction];
                    [realm deleteObject:note];
                    [realm commitWriteTransaction];
                }
            }];
        }
        else {
            if (note.noteId > 0) {
                //existing, put
                [self putNote:note withCallback:^(id result, NSError *error) {
                    if (!error) {
                        RLMRealm *realm = [RLMRealm defaultRealm];
                        [realm beginWriteTransaction];
                        [realm deleteObject:note];
                        [realm commitWriteTransaction];
                    }
                }];
            }
            else {
                //new, post
                [self postNote:note withCallback:^(id result, NSError *error) {
                    if (!error) {
                        RLMRealm *realm = [RLMRealm defaultRealm];
                        [realm beginWriteTransaction];
                        [realm deleteObject:note];
                        [realm commitWriteTransaction];
                    }
                }];
            }
        }
    }
}

-(Shadower*)getCurrentUser {
    NSString *currentUserId = [Lockbox stringForKey:kKeyGoShadowUserId];
    if (currentUserId) {
        Shadower *user = [Shadower objectForPrimaryKey:@([currentUserId integerValue])];
        return user;
    }
    return nil;
}

-(void)authenticateWithEmail:(NSString*)email
                    password:(NSString*)password
                    callback:(GoShadowCallback)callback {
    [self POST:@"authentication/login" parameters:@{@"email" : email, @"password" : password}
       success:^(AFHTTPRequestOperation *operation, id responseObject) {
           [self setAccessToken:responseObject[@"token"]];
           callback(nil,nil);
       }
       failure:^(AFHTTPRequestOperation *operation, NSError *error) {
           if (operation.responseObject) {
               callback(operation.responseObject[@"error_codes"], error);
           }
           else {
               callback(nil,error);
           }
       }];
}

-(void)signupWithEmail:(NSString*)email
              password:(NSString*)password
             firstName:(NSString*)firstName
              lastName:(NSString*)lastName
          organization:(NSString*)organization
              callback:(GoShadowCallback)callback {
    [self POST:@"authentication/sign_up" parameters:@{@"user" : @{@"email" : email,
                                                      @"password" : password,
                                                      @"first_name" : firstName,
                                                      @"last_name" : lastName,
                                                      @"organization_name" : organization}}
       success:^(AFHTTPRequestOperation *operation, id responseObject) {
           callback(nil,nil);
       }
       failure:^(AFHTTPRequestOperation *operation, NSError *error) {
           if (operation.responseObject) {
               callback(operation.responseObject[@"error_codes"], error);
           }
           else {
               callback(nil,error);
           }
       }];
}

-(void)resetPasswordWithEmail:(NSString*)email callback:(GoShadowCallback)callback {
    [self POST:@"authentication/reset_password" parameters:@{@"email" : email}
       success:^(AFHTTPRequestOperation *operation, id responseObject) {
           callback(nil,nil);
       }
       failure:^(AFHTTPRequestOperation *operation, NSError *error) {
           callback(nil,error);
       }];
}

-(void)setAccessToken:(NSString*)token {
    if (token != nil) {
        [Lockbox setString:token forKey:kKeyGoShadowAPIAccessToken];
        [self.requestSerializer setValue:[NSString stringWithFormat:@"Token token=\"%@\"", token] forHTTPHeaderField:@"Authorization"];
    }
}

-(void)getCurrentUserWithCallback:(GoShadowCallback)callback {
    [self GET:@"users/self" parameters:nil
      success:^(AFHTTPRequestOperation *operation, id responseObject) {
          RLMRealm *defaultRealm = [RLMRealm defaultRealm];
          [defaultRealm beginWriteTransaction];
          Shadower *obj = [Shadower createOrUpdateWithValue:responseObject];
          [Lockbox setString:[@(obj.userId) stringValue] forKey:kKeyGoShadowUserId];
          [defaultRealm addOrUpdateObject:obj];
          [defaultRealm commitWriteTransaction];
          callback(obj,nil);
      }
      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
          [self handleError:error forOperation:operation];
          callback(nil,error);
      }];
}

-(void)updateDataWithCallback:(GoShadowCallback)callback {
    //we must get shadowers prior to other data to allow proper relationships
    [[GoShadowAPIManager sharedManager] getCurrentUserWithCallback:^(id user, NSError *error) {
        [[GoShadowAPIManager sharedManager] getShadowersWithCallback:^(id result, NSError *error) {
            [[GoShadowAPIManager sharedManager] getExperiencesWithCallback:^(id result, NSError *error) {
                [[GoShadowAPIManager sharedManager] getSegmentsWithCallback:^(id result, NSError *error) {
                    [[GoShadowAPIManager sharedManager] getTouchpointsWithCallback:^(id result, NSError *error) {
                        [[GoShadowAPIManager sharedManager] getCaregiversWithCallback:^(id result, NSError *error) {
                            [[GoShadowAPIManager sharedManager] getNotesWithCallback:^(id result, NSError *error) {
                                callback(nil,error);
                            }];
                        }];
                    }];
                }];
            }];
        }];
    }];
}

-(void)getExperiencesWithCallback:(GoShadowCallback)callback {
    [self GET:@"experiences" parameters:nil
      success:^(AFHTTPRequestOperation *operation, id responseObject) {
          NSMutableArray *results = [NSMutableArray new];
          if ([responseObject count]) {
              RLMRealm *defaultRealm = [RLMRealm defaultRealm];
              [defaultRealm beginWriteTransaction];
              for (NSDictionary *dictionary in responseObject) {
                  Experience *obj = [Experience createOrUpdateWithValue:dictionary];
                  [defaultRealm addOrUpdateObject:obj];
                  [results addObject:obj];
              }
              [defaultRealm commitWriteTransaction];
          }
          callback(results,nil);
      }
      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
          [self handleError:error forOperation:operation];
          callback(nil,error);
      }];
}

-(void)postExperience:(Experience *)experience withCallback:(GoShadowCallback)callback {
    [self POST:@"experiences" parameters:@{@"experience" : [experience dictionaryRepresentation]}
       success:^(AFHTTPRequestOperation *operation, id responseObject) {
           RLMRealm *defaultRealm = [RLMRealm defaultRealm];
           [defaultRealm beginWriteTransaction];
           Experience *obj = [Experience createOrUpdateWithValue:responseObject];
           [defaultRealm addOrUpdateObject:obj];
           [defaultRealm commitWriteTransaction];
           callback(obj,nil);
       } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
           [self handleError:error forOperation:operation];
          callback(nil,error);
       }];
}

-(void)putExperience:(Experience*)experience withCallback:(GoShadowCallback)callback {
    [self PUT:[NSString stringWithFormat:@"experiences/%ld",(long)experience.experienceId] parameters:@{@"experience" : [experience dictionaryRepresentation]}
       success:^(AFHTTPRequestOperation *operation, id responseObject) {
           RLMRealm *defaultRealm = [RLMRealm defaultRealm];
           if (!defaultRealm.inWriteTransaction) {
               [defaultRealm beginWriteTransaction];
           }
           Experience *obj = [Experience createOrUpdateWithValue:responseObject];
           [defaultRealm addOrUpdateObject:obj];
           [defaultRealm commitWriteTransaction];
           callback(obj,nil);
       } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
           if ([RLMRealm defaultRealm].inWriteTransaction) {
               [[RLMRealm defaultRealm] cancelWriteTransaction];
           }
           [self handleError:error forOperation:operation];
           callback(nil,error);
       }];
}

-(void)deleteExperienceWithId:(NSInteger)experienceId withCallback:(GoShadowCallback)callback {
    [self DELETE:[NSString stringWithFormat:@"experiences/%ld", (long)experienceId] parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             callback(nil,nil);
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             [self handleError:error forOperation:operation];
             callback(nil,error);
         }];
}

-(void)getSegmentsWithCallback:(GoShadowCallback)callback {
    [self GET:@"segments" parameters:nil
      success:^(AFHTTPRequestOperation *operation, id responseObject) {
          NSMutableArray *results = [NSMutableArray new];
          if ([responseObject count]) {
              RLMRealm *defaultRealm = [RLMRealm defaultRealm];
              [defaultRealm beginWriteTransaction];
              for (NSDictionary *dictionary in responseObject) {
                  Segment *obj = [Segment createOrUpdateWithValue:dictionary];
                  //in order for the exp relationship to work, the experiences must be retrieved first
                  [defaultRealm addOrUpdateObject:obj];
                  Experience *experience = [Experience objectInRealm:defaultRealm forPrimaryKey:@(obj.experienceId)];
                  if (experience && [experience.segments indexOfObject:obj] == NSNotFound) {
                      [experience.segments addObject:obj];
                  }
                  [results addObject:obj];
              }
              [defaultRealm commitWriteTransaction];
          }
          callback(results,nil);
      }
      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
          [self handleError:error forOperation:operation];
          callback(nil,error);
      }];
}

-(void)postSegment:(Segment *)segment withCallback:(GoShadowCallback)callback {
    [self POST:@"segments" parameters:@{@"segment" : [segment dictionaryRepresentation]}
       success:^(AFHTTPRequestOperation *operation, id responseObject) {
           RLMRealm *defaultRealm = [RLMRealm defaultRealm];
           [defaultRealm beginWriteTransaction];
           Segment *obj = [Segment createOrUpdateWithValue:responseObject];
           Experience *experience = [Experience objectInRealm:defaultRealm forPrimaryKey:@(obj.experienceId)];
           if (experience && [experience.segments indexOfObject:obj] == NSNotFound) {
               [experience.segments addObject:obj];
           }
           [defaultRealm addOrUpdateObject:obj];
           [defaultRealm commitWriteTransaction];
           return callback(obj,nil);
       } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
           [self handleError:error forOperation:operation];
           callback(nil,error);
       }];
}

-(void)deleteSegmentWithId:(NSInteger)segmentId withCallback:(GoShadowCallback)callback {
    [self DELETE:[NSString stringWithFormat:@"segments/%ld", (long)segmentId] parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             callback(nil,nil);
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             [self handleError:error forOperation:operation];
             callback(nil,error);
         }];
}

-(void)getNotesWithCallback:(GoShadowCallback)callback {
    [self GET:@"notes" parameters:nil
      success:^(AFHTTPRequestOperation *operation, id responseObject) {
          NSMutableArray *results = [NSMutableArray new];
          if ([responseObject count]) {
              RLMRealm *defaultRealm = [RLMRealm defaultRealm];
              [defaultRealm beginWriteTransaction];
              for (NSDictionary *dictionary in responseObject) {
                  Note *obj = [Note createOrUpdateWithValue:dictionary];
                  [defaultRealm addOrUpdateObject:obj];
                  //in order for the relationships to work, the data must be retrieved first
                  Segment *segment = [Segment objectInRealm:defaultRealm forPrimaryKey:@(obj.segmentId)];
                  if (segment && [segment.notes indexOfObject:obj] == NSNotFound) {
                      [segment.notes addObject:obj];
                  }
                  if (obj.touchpointId > 0) {
                      Touchpoint *touchpoint = [Touchpoint objectInRealm:defaultRealm forPrimaryKey:@(obj.touchpointId)];
                      if (touchpoint) {
                          obj.touchpoint = touchpoint;
                      }
                  }
                  if (obj.caregiverId > 0) {
                      Caregiver *caregiver = [Caregiver objectInRealm:defaultRealm forPrimaryKey:@(obj.caregiverId)];
                      if (caregiver) {
                          obj.caregiver = caregiver;
                      }
                  }
                  [results addObject:obj];
              }
              [defaultRealm commitWriteTransaction];
          }
          callback(results,nil);
      }
      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
          [self handleError:error forOperation:operation];
          callback(nil,error);
      }];
}

-(void)getNotesForSegmentId:(NSInteger)segmentId withCallback:(GoShadowCallback)callback {
    [self GET:[NSString stringWithFormat:@"segments/%ld/notes", (long)segmentId] parameters:nil
      success:^(AFHTTPRequestOperation *operation, id responseObject) {
          NSMutableArray *results = [NSMutableArray new];
          if ([responseObject count]) {
              RLMRealm *defaultRealm = [RLMRealm defaultRealm];
              [defaultRealm beginWriteTransaction];
              for (NSDictionary *dictionary in responseObject) {
                  Note *obj = [Note createOrUpdateWithValue:dictionary];
                  //in order for the relationships to work, the data must be retrieved first
                  Segment *segment = [Segment objectInRealm:defaultRealm forPrimaryKey:@(obj.segmentId)];
                  if (segment && [segment.notes indexOfObject:obj] == NSNotFound) {
                      [segment.notes addObject:obj];
                  }
                  if (obj.touchpointId > 0) {
                      Touchpoint *touchpoint = [Touchpoint objectInRealm:defaultRealm forPrimaryKey:@(obj.touchpointId)];
                      if (touchpoint) {
                          obj.touchpoint = touchpoint;
                      }
                  }
                  if (obj.caregiverId > 0) {
                      Caregiver *caregiver = [Caregiver objectInRealm:defaultRealm forPrimaryKey:@(obj.caregiverId)];
                      if (caregiver) {
                          obj.caregiver = caregiver;
                      }
                  }
                  [defaultRealm addOrUpdateObject:obj];
                  [results addObject:obj];
              }
              [defaultRealm commitWriteTransaction];
          }
          callback(results,nil);
      }
      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
          [self handleError:error forOperation:operation];
          callback(nil,error);
      }];
}

-(void)postNote:(Note*)note withCallback:(GoShadowCallback)callback {
    [self POST:[NSString stringWithFormat:@"segments/%ld/notes", (long)note.segmentId]
    parameters:@{@"note" : [note dictionaryRepresentation]}
       success:^(AFHTTPRequestOperation *operation, id responseObject) {
           RLMRealm *defaultRealm = [RLMRealm defaultRealm];
           if (!defaultRealm.inWriteTransaction) {
               [defaultRealm beginWriteTransaction];
           }
           Note *obj = [Note createOrUpdateWithValue:responseObject];
           obj.localStatus = NoteLocalStatusSynched;
           [defaultRealm addOrUpdateObject:obj];
           Segment *segment = [Segment objectInRealm:defaultRealm forPrimaryKey:@(obj.segmentId)];
           if (segment && [segment.notes indexOfObject:obj] == NSNotFound) {
               [segment.notes addObject:obj];
           }
           [defaultRealm commitWriteTransaction];
           return callback(obj,nil);
       } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
           if (!operation.response && note.noteId == 0 && !note.isTimer) {
               //no response, offline
               //only do this for non-timers
               RLMRealm *defaultRealm = [RLMRealm defaultRealm];
               [defaultRealm beginWriteTransaction];
               //use made up negative PK
               NSInteger min = [[[Note allObjects] minOfProperty:@"noteId"] integerValue];
               min--;
               note.noteId = min;
               [defaultRealm addOrUpdateObject:note];
               [defaultRealm commitWriteTransaction];
               [self handleError:error forOperation:operation];
               callback(note,error);
           }
           else {
               [self handleError:error forOperation:operation];
               callback(nil,error);
           }
       }];
}

-(void)putNote:(Note*)note withCallback:(GoShadowCallback)callback {
    [self PUT:[NSString stringWithFormat:@"segments/%ld/notes/%ld", (long)note.segmentId, (long)note.noteId]
   parameters:@{@"note":[note dictionaryRepresentation]}
       success:^(AFHTTPRequestOperation *operation, id responseObject) {
           RLMRealm *defaultRealm = [RLMRealm defaultRealm];
           if (!defaultRealm.inWriteTransaction) {
               [defaultRealm beginWriteTransaction];
           }
           Note *obj = [Note createOrUpdateWithValue:responseObject];
           obj.localStatus = NoteLocalStatusSynched;
           [defaultRealm commitWriteTransaction];
           return callback(obj,nil);
       } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
           RLMRealm *defaultRealm = [RLMRealm defaultRealm];
           if ([defaultRealm inWriteTransaction]) {
               [defaultRealm commitWriteTransaction];
           }
           if (!operation.response) {
               callback(note,error);
           }
           [self handleError:error forOperation:operation];
           callback(nil,error);
       }];
}

-(void)deleteNoteWithId:(NSInteger)noteId inSegmentId:(NSInteger)segmentId withCallback:(GoShadowCallback)callback {
    [self DELETE:[NSString stringWithFormat:@"segments/%ld/notes/%ld", (long)segmentId, (long)noteId] parameters:nil
     success:^(AFHTTPRequestOperation *operation, id responseObject) {
         callback(nil,nil);
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         [self handleError:error forOperation:operation];
         callback(nil,error);
     }];
}

-(void)getShadowersWithCallback:(GoShadowCallback)callback {
    [self GET:@"shadowers" parameters:nil
      success:^(AFHTTPRequestOperation *operation, id responseObject) {
          NSMutableArray *results = [NSMutableArray new];
          if ([responseObject count]) {
              RLMRealm *defaultRealm = [RLMRealm defaultRealm];
              [defaultRealm beginWriteTransaction];
              for (NSDictionary *dictionary in responseObject) {
                  Shadower *obj = [Shadower createOrUpdateWithValue:dictionary];
                  [defaultRealm addOrUpdateObject:obj];
                  [results addObject:obj];
              }
              [defaultRealm commitWriteTransaction];
          }
          callback(results,nil);
      }
      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
          [self handleError:error forOperation:operation];
          callback(nil,error);
      }];
}

-(void)postShadower:(Shadower*)shadower withCallback:(GoShadowCallback)callback {
    [self POST:@"shadowers"
    parameters:@{@"shadower" :[shadower dictionaryRepresentation]}
       success:^(AFHTTPRequestOperation *operation, id responseObject) {
           RLMRealm *defaultRealm = [RLMRealm defaultRealm];
           [defaultRealm beginWriteTransaction];
           Shadower *obj = [Shadower createOrUpdateWithValue:responseObject];
           [defaultRealm addOrUpdateObject:obj];
           [defaultRealm commitWriteTransaction];
           return callback(obj,nil);
       } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
           [self handleError:error forOperation:operation];
           callback(nil,error);
       }];
}

-(void)getTouchpointsWithCallback:(GoShadowCallback)callback {
    [self GET:@"touch_points" parameters:nil
      success:^(AFHTTPRequestOperation *operation, id responseObject) {
          NSMutableArray *results = [NSMutableArray new];
          if ([responseObject count]) {
              RLMRealm *defaultRealm = [RLMRealm defaultRealm];
              [defaultRealm beginWriteTransaction];
              for (NSDictionary *dictionary in responseObject) {
                  Touchpoint *obj = [Touchpoint createOrUpdateWithValue:dictionary];
                  [defaultRealm addOrUpdateObject:obj];
                  [results addObject:obj];
              }
              [defaultRealm commitWriteTransaction];
          }
          callback(results,nil);
      }
      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
          [self handleError:error forOperation:operation];
          callback(nil,error);
      }];
}

-(void)postTouchpoint:(Touchpoint*)touchpoint withCallback:(GoShadowCallback)callback {
    [self POST:@"touch_points"
    parameters:@{@"touch_point":[touchpoint dictionaryRepresentation]}
       success:^(AFHTTPRequestOperation *operation, id responseObject) {
           RLMRealm *defaultRealm = [RLMRealm defaultRealm];
           [defaultRealm beginWriteTransaction];
           Touchpoint *obj = [Touchpoint createOrUpdateWithValue:responseObject];
           [defaultRealm addOrUpdateObject:obj];
           [defaultRealm commitWriteTransaction];
           return callback(obj,nil);
       } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
           [self handleError:error forOperation:operation];
           callback(nil,error);
       }];
}

-(void)getCaregiversWithCallback:(GoShadowCallback)callback {
    [self GET:@"caregivers" parameters:nil
      success:^(AFHTTPRequestOperation *operation, id responseObject) {
          NSMutableArray *results = [NSMutableArray new];
          if ([responseObject count]) {
              RLMRealm *defaultRealm = [RLMRealm defaultRealm];
              [defaultRealm beginWriteTransaction];
              for (NSDictionary *dictionary in responseObject) {
                  Caregiver *obj = [Caregiver createOrUpdateWithValue:dictionary];
                  [defaultRealm addOrUpdateObject:obj];
                  [results addObject:obj];
              }
              [defaultRealm commitWriteTransaction];
          }
          callback(results,nil);
      }
      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
           [self handleError:error forOperation:operation];
          callback(nil,error);
      }];
}

-(void)postCaregiver:(Caregiver*)caregiver withCallback:(GoShadowCallback)callback {
    [self POST:@"caregivers"
    parameters:@{@"caregiver" :[caregiver dictionaryRepresentation]}
       success:^(AFHTTPRequestOperation *operation, id responseObject) {
           RLMRealm *defaultRealm = [RLMRealm defaultRealm];
           [defaultRealm beginWriteTransaction];
           Caregiver *obj = [Caregiver createOrUpdateWithValue:responseObject];
           [defaultRealm addOrUpdateObject:obj];
           [defaultRealm commitWriteTransaction];
           return callback(obj,nil);
       } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
           [self handleError:error forOperation:operation];
           callback(nil,error);
       }];
}

-(void)logout {
    [self.requestSerializer clearAuthorizationHeader];
    [Lockbox setString:nil forKey:kKeyGoShadowAPIAccessToken];
    [Lockbox setString:nil forKey:kKeyGoShadowUserId];
}

-(void)handleError:(NSError*)error forOperation:(AFHTTPRequestOperation*)operation {
    if (operation.response.statusCode >= 400 && operation.response.statusCode < 500) {
        //log out user if bad auth
        [(AppDelegate*)[UIApplication sharedApplication].delegate logout];
    }
}

-(BOOL)isAuthenticated {
    if ([Lockbox stringForKey:kKeyGoShadowAPIAccessToken]) {
        return true;
    }
    else {
        return false;
    }
}

@end
