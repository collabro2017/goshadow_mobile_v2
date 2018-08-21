//
//  Segment+Extensions.m
//  GoShadow
//
//  Created by Shawn Wall on 8/3/15.
//  Copyright (c) 2015 Inquiri. All rights reserved.
//

#import "Segment+Extensions.h"

@implementation Segment (Extensions)

+(instancetype)createOrUpdateWithValue:(NSDictionary*)value {
    Segment *segment = [Segment objectForPrimaryKey:@([value[@"id"] integerValue])];
    if (segment == nil) {
        segment = [[Segment alloc] init];
        segment.segmentId = [value[@"id"] integerValue];
    }
    segment.experienceId = [value[@"experience_id"] integerValue];
    if (value[@"end_location_longitude"] != [NSNull null]) {
        segment.endLongitude = [value[@"end_location_longitude"] floatValue];
    }
    else {
        segment.endLongitude = 0.0;
    }
    if (value[@"end_location_latitude"] != [NSNull null]) {
        segment.endLatitude = [value[@"end_location_latitude"] floatValue];
    }
    else {
        segment.endLatitude = 0.0;
    }
    if (value[@"start_location_longitude"] != [NSNull null]) {
        segment.startLongitude = [value[@"start_location_longitude"] floatValue];
    }
    else {
        segment.startLongitude = 0.0;
    }
    if (value[@"start_location_latitude"] != [NSNull null]) {
        segment.startLatitude = [value[@"start_location_latitude"] floatValue];
    }
    else {
        segment.startLatitude = 0.0;
    }
//    segment.segmentNotes = value[@"notes"] != [NSNull null] ? value[@"notes"] : @"";
    segment.isPublished = [value[@"is_published"] boolValue];
//    segment.isShowingDetails = value[@"is_showing_details"] != [NSNull null] ? [value[@"is_showing_details"] boolValue] : false;
    
    segment.locationStartName = value[@"start_location_name"] != [NSNull null] ? value[@"start_location_name"] : @"";
    segment.locationEndName = value[@"end_location_name"] != [NSNull null] ? value[@"end_location_name"] : @"";
    segment.locationStartUrl = value[@"start_location_url"] != [NSNull null] ? value[@"start_location_url"] : @"";
    segment.locationEndUrl = value[@"end_location_url"] != [NSNull null] ? value[@"end_location_url"] : @"";
    
    segment.name = value[@"name"];
    segment.requesterName = value[@"requester_name"];
    if ([value objectForKey:@"facility"] && value[@"facility"] != [NSNull null]) {
        segment.facility = value[@"facility"];
    }
    segment.createdAt = [NSDate mt_dateFromISOString:value[@"created_at"]];
    segment.updatedAt = [NSDate mt_dateFromISOString:value[@"updated_at"]];
//    segment.status = value[@"status"] != [NSNull null] ? value[@"status"] : @"";
    
    [segment.shadowers removeAllObjects];
    for (NSNumber *shadowerId in value[@"shadowers"]) {
        Shadower *shadower = [Shadower objectForPrimaryKey:shadowerId];
        if (shadower && [segment.shadowers indexOfObject:shadower] == NSNotFound) {
            [segment.shadowers addObject:shadower];
        }
    }
    
    return segment;
}

-(NSDictionary*)dictionaryRepresentation {
    NSMutableDictionary *output = [NSMutableDictionary new];
    if (self.experienceId) {
        [output setObject:@(self.segmentId) forKey:@"id"];
    }
    [output setObject:@(self.experienceId) forKey:@"experience_id"];
    [output setObject:@(self.endLongitude) forKey:@"end_location_longitude"];
    [output setObject:@(self.startLongitude) forKey:@"start_location_longitude"];
    [output setObject:@(self.endLatitude) forKey:@"end_location_latitude"];
    [output setObject:@(self.startLatitude) forKey:@"start_location_latitude"];
//    [output setObject:self.segmentNotes forKey:@"notes"];
    [output setObject:@(self.isPublished) forKey:@"is_published"];
//    [output setObject:@(self.isShowingDetails) forKey:@"is_showing_details"];
    [output setObject:self.locationStartName forKey:@"start_location_name"];
    [output setObject:self.locationEndName forKey:@"end_location_name"];
    [output setObject:self.locationStartUrl forKey:@"start_location_url"];
    [output setObject:self.locationEndUrl forKey:@"end_location_url"];
    [output setObject:self.name forKey:@"name"];
    [output setObject:self.requesterName forKey:@"requester_name"];
    [output setObject:self.facility forKey:@"facility"];
    [output setObject:[self.createdAt mt_stringFromDateWithFormat:@"yyyy-MM-dd HH:mm:ss Z" localized:false] forKey:@"created_at"];
    [output setObject:[self.updatedAt mt_stringFromDateWithFormat:@"yyyy-MM-dd HH:mm:ss Z" localized:false]  forKey:@"updated_at"];
    
    NSMutableArray *shadowerIds = [NSMutableArray new];
    for (Shadower *shadower in self.shadowers) {
        [shadowerIds addObject:@(shadower.userId)];
    }
    if (shadowerIds.count) {
        [output setObject:shadowerIds forKey:@"shadowers"];
    }
    
    return output;
}

-(NSString*)cellSummary {
    RLMResults *notes = [self.notes objectsWithPredicate:[NSPredicate predicateWithFormat:@"localStatus != %d", NoteLocalStatusDelete]];
    return [NSString stringWithFormat:@"%ld Notes | %ld Shadowers", (unsigned long)notes.count, (unsigned long)self.shadowers.count];
}

@end
