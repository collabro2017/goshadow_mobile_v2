//
//  Note+Extensions.m
//  GoShadow
//
//  Created by Shawn Wall on 8/3/15.
//  Copyright (c) 2015 Inquiri. All rights reserved.
//

#import "Note+Extensions.h"
#import "Touchpoint.h"
#import "Caregiver.h"

@implementation Note (Extensions)

+(instancetype)createOrUpdateWithValue:(NSDictionary*)value {
    Note *note = [Note objectForPrimaryKey:@([value[@"id"] integerValue])];
    if (note == nil) {
        note = [[Note alloc] init];
        note.noteId = [value[@"id"] integerValue];
    }
    note.segmentId = [value[@"segment_id"] integerValue];
    if (value[@"note"] != [NSNull null]) {
        note.note = value[@"note"];
    }
    if (value[@"caregiver_id"] != [NSNull null]) {
        note.caregiverId = [value[@"caregiver_id"] integerValue];
    }
    if (value[@"touch_point_id"] != [NSNull null]) {
        note.touchpointId = [value[@"touch_point_id"] floatValue];
    }
    note.isHighlight = [value[@"highlight"] boolValue];
    note.isFavorite = [value[@"favorite"] boolValue];
    note.categoryId = [value[@"note_category_id"] integerValue];
    if (value[@"category_name"] != [NSNull null]) {
        note.categoryName = value[@"category_name"];
    }
    if (value[@"attachment_url"] != [NSNull null]) {
        note.attachmentUrl = value[@"attachment_url"];
        //clear out local file as we no longer need it
        note.attachmentFile = [NSData defaultData];
    }

    note.accumulatedTime = [value[@"accumulated_time"] integerValue];
    note.segmentId = [value[@"segment_id"] integerValue];
    if (value[@"user_id"] != [NSNull null]) {
        note.userId = [value[@"user_id"] integerValue];
    }
    if (value[@"start_time"] != [NSNull null]) {
        if ([value[@"start_time"] length]) {
            note.startDate = [NSDate mt_dateFromISOString:value[@"start_time"]];
        }
    }

    note.createdAt = [NSDate mt_dateFromISOString:value[@"created_at"]];
    note.updatedAt = [NSDate mt_dateFromISOString:value[@"updated_at"]];
    
    if (note.touchpointId > 0) {
        Touchpoint *touchpoint = [Touchpoint objectForPrimaryKey:@(note.touchpointId)];
        if (touchpoint) {
            note.touchpoint = touchpoint;
        }
    }
    if (note.caregiverId > 0) {
        Caregiver *caregiver = [Caregiver objectForPrimaryKey:@(note.caregiverId)];
        if (caregiver) {
            note.caregiver = caregiver;
        }
    }
    
    return note;
}

-(NSDictionary*)dictionaryRepresentation {
    NSMutableDictionary *output = [NSMutableDictionary new];
    if (self.noteId > 0) {
        [output setObject:@(self.noteId) forKey:@"id"];
    }
    [output setObject:@(self.segmentId) forKey:@"segment_id"];
    [output setObject:@(self.caregiverId) forKey:@"caregiver_id"];
    [output setObject:@(self.touchpointId) forKey:@"touch_point_id"];
    [output setObject:@(self.isHighlight) forKey:@"highlight"];
    [output setObject:@(self.isFavorite) forKey:@"favorite"];
    [output setObject:@(self.categoryId) forKey:@"id"];
    [output setObject:@(self.segmentId) forKey:@"segment_id"];
    [output setObject:@(self.userId) forKey:@"user_id"];
    [output setObject:@(self.accumulatedTime) forKey:@"accumulated_time"];
    [output setObject:@(self.categoryId) forKey:@"note_category_id"];
    [output setObject:self.note forKey:@"note"];
    if (![self.startDate isEqual:[NSDate defaultDate]]) {
        [output setObject:[self.startDate mt_stringFromDateWithFormat:@"yyyy-MM-dd HH:mm:ss Z" localized:false] forKey:@"start_time"];
    }
    else {
        [output setObject:[NSNull null] forKey:@"start_time"];
    }
    [output setObject:[self.createdAt mt_stringFromDateWithFormat:@"yyyy-MM-dd HH:mm:ss Z" localized:false] forKey:@"created_at"];
    [output setObject:[self.updatedAt mt_stringFromDateWithFormat:@"yyyy-MM-dd HH:mm:ss Z" localized:false]  forKey:@"updated_at"];
    
    if (self.attachmentFile) {
        NSString *base64Encoded = [self.attachmentFile base64EncodedStringWithOptions:0];
        [output setObject:base64Encoded forKeyedSubscript:@"attachment_data"];
    }
    //todo attachment_data
    
    return output;
}

-(BOOL)isTimer {
    if (self.caregiverId != 0 || self.touchpointId != 0) {
        return true;
    }
    else {
        return false;
    }
}

+ (NSString *)imageNameForCategoryImage:(NSInteger)category {
    switch (category) {
        case NoteCategoryDialog:
            return @"icon_discussion";
            break;
        case NoteCategoryPositive:
            return @"icon_emotion";
            break;
        case NoteCategoryPhoto:
            return @"icon_photo";
            break;
        case NoteCategoryAnxiety:
            return @"icon_anxiety";
            break;
        default:
            return @"icon_emotion";
            break;
    }
}

@end
