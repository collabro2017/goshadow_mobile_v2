//
//  AutoDefaultsRLMObject.h
//  GoShadow
//
//  Created by Shawn Wall on 7/29/15.
//  Copyright (c) 2015 Inquiri. All rights reserved.
//

#import <Realm/RLMObject.h>

@interface AutoDefaultsRLMObject : RLMObject

@end

//Categories for easier default value handling
@interface NSString (Defaults)

+ (NSString *)defaultString;
- (BOOL)isDefault;

@end

@interface NSDate (Defaults)

+ (NSDate *)defaultDate;
- (BOOL)isDefault;

@end

@interface NSData (Defaults)

+ (NSData *)defaultData;
- (BOOL)isDefault;

@end
