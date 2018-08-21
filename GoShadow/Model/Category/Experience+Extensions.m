//
//  Experience+Extensions.m
//  GoShadow
//
//  Created by Shawn Wall on 8/3/15.
//  Copyright (c) 2015 Inquiri. All rights reserved.
//

#import "Experience+Extensions.h"

@implementation Experience (Extensions)

+(instancetype)createOrUpdateWithValue:(NSDictionary*)value {
    Experience *experience = [Experience objectForPrimaryKey:@([value[@"id"] integerValue])];
    if (experience == nil) {
        experience = [[Experience alloc] init];
        experience.experienceId = [value[@"id"] integerValue];
    }
    if (value[@"end_location_longitude"] != [NSNull null]) {
        experience.endLongitude = [value[@"end_location_longitude"] floatValue];
    }
    else {
        experience.endLongitude = 0.0;
    }
    if (value[@"end_location_latitude"] != [NSNull null]) {
        experience.endLatitude = [value[@"end_location_latitude"] floatValue];
    }
    else {
        experience.endLatitude = 0.0;
    }
    if (value[@"start_location_longitude"] != [NSNull null]) {
        experience.startLongitude = [value[@"start_location_longitude"] floatValue];
    }
    else {
        experience.startLongitude = 0.0;
    }
    if (value[@"start_location_latitude"] != [NSNull null]) {
        experience.startLatitude = [value[@"start_location_latitude"] floatValue];
    }
    else {
        experience.startLatitude = 0.0;
    }
    
//    experience.experienceNotes = value[@"notes"];
    experience.isPublished = value[@"is_published"] != [NSNull null] ? [value[@"is_published"] boolValue] : false;
//    experience.isShowingDetails = value[@"is_showing_details"] != [NSNull null] ? [value[@"is_showing_details"] boolValue] : false;
    experience.locationStartName = value[@"start_location_name"] != [NSNull null] ? value[@"start_location_name"] : @"";
    experience.locationEndName = value[@"end_location_name"] != [NSNull null] ? value[@"end_location_name"] : @"";
    experience.locationStartUrl = value[@"start_location_url"] != [NSNull null] ? value[@"start_location_url"] : @"";
    experience.locationEndUrl = value[@"end_location_url"] != [NSNull null] ? value[@"end_location_url"] : @"";
    experience.name = value[@"name"];
    if (value[@"requester_name"] != [NSNull null]) {
        experience.requesterName = value[@"requester_name"];
    }
//    experience.status = value[@"status"];
//    experience.type = value[@"type"];
    experience.facility = value[@"facility"];
    experience.createdAt = [NSDate mt_dateFromISOString:value[@"created_at"]];
    experience.updatedAt = [NSDate mt_dateFromISOString:value[@"updated_at"]];
    
    experience.type = @"";
    return experience;
}

-(NSDictionary*)dictionaryRepresentation {
    NSMutableDictionary *output = [NSMutableDictionary new];
    if (self.experienceId) {
        [output setObject:@(self.experienceId) forKey:@"id"];
    }
    [output setObject:@(self.endLongitude) forKey:@"end_location_longitude"];
    [output setObject:@(self.startLongitude) forKey:@"start_location_longitude"];
    [output setObject:@(self.endLatitude) forKey:@"end_location_latitude"];
    [output setObject:@(self.startLatitude) forKey:@"start_location_latitude"];
//    [output setObject:self.experienceNotes forKey:@"notes"];
    [output setObject:@(self.isPublished) forKey:@"is_published"];
//    [output setObject:@(self.isShowingDetails) forKey:@"is_showing_details"];
    [output setObject:self.locationStartName forKey:@"start_location_name"];
    [output setObject:self.locationEndName forKey:@"end_location_name"];
    [output setObject:self.locationStartUrl forKey:@"start_location_url"];
    [output setObject:self.locationEndUrl forKey:@"end_location_url"];
    [output setObject:self.name forKey:@"name"];
    [output setObject:self.requesterName forKey:@"requester_name"];
//    [output setObject:self.status forKey:@"status"];
    [output setObject:self.type forKey:@"type"];
    [output setObject:self.facility forKey:@"facility"];
    
    [output setObject:[self.createdAt mt_stringFromDateWithFormat:@"yyyy-MM-dd HH:mm:ss Z" localized:false] forKey:@"created_at"];
    [output setObject:[self.updatedAt mt_stringFromDateWithFormat:@"yyyy-MM-dd HH:mm:ss Z" localized:false]  forKey:@"updated_at"];
    
    return output;
}

-(NSString*)cellSummary {
//    NSArray *segmentIds = [self.segments valueForKeyPath:@"segmentId"];
//    NSArray *notes = [self.segments valueForKeyPath:@"notes"];
    NSInteger shadowerCount = 0;
    NSInteger noteCount = 0;
    for (Segment *segment in self.segments) {
        shadowerCount += segment.shadowers.count;
        RLMResults *notes = [segment.notes objectsWithPredicate:[NSPredicate predicateWithFormat:@"localStatus != %d", NoteLocalStatusDelete]];
        noteCount += notes.count;
    }
    return [NSString stringWithFormat:@"%ld Notes | %ld Segments | %ld Shadowers", (long)noteCount, (unsigned long)self.segments.count, (long)shadowerCount];
}

+(NSArray*)experienceTypes {
    return @[@"Hospital Inpatient", @"Hospital Outpatient", @"Physician Office", @"Lab", @"Imaging/Radiology", @"Employee/Staff", @"Clinic", @"Home Health", @"SNF/Rehabilitation", @"Other"];
}

@end
