//
//  AutoDefaultsRLMObject.m
//  GoShadow
//
//  Created by Shawn Wall on 7/29/15.
//  Copyright (c) 2015 Inquiri. All rights reserved.
//

#import "AutoDefaultsRLMObject.h"
#import <objc/runtime.h>

@implementation AutoDefaultsRLMObject

+ (NSDictionary *)defaultPropertyValues
{
    NSMutableDictionary *defaultValues = [NSMutableDictionary dictionary];
    unsigned int numberOfProperties = 0;
    objc_property_t *propertyArray = class_copyPropertyList([self class], &numberOfProperties);
    //go trough the properties
    for (NSUInteger i = 0; i < numberOfProperties; i++)
    {
        objc_property_t property = propertyArray[i];
        //aquire name
        NSString *name = [[NSString alloc] initWithUTF8String:property_getName(property)];
        //find the type attribute
        unsigned int numOfAttributes;
        objc_property_attribute_t *propertyAttributes = property_copyAttributeList(property, &numOfAttributes);
        for ( unsigned int ai = 0; ai < numOfAttributes; ai++ ) {
            switch (propertyAttributes[ai].name[0]) {
                    //type of the property
                case 'T':
                {
                    //add the default value
                    NSString *propertyType = [[NSString alloc] initWithUTF8String:propertyAttributes[ai].value];
                    if([propertyType isEqualToString:@"@\"NSString\""]){
                        [defaultValues setObject:[NSString defaultString] forKey:name];
                    }else if([propertyType isEqualToString:@"@\"NSDate\""]){
                        [defaultValues setObject:[NSDate defaultDate] forKey:name];
                    }else if([propertyType isEqualToString:@"@\"NSData\""]){
                        [defaultValues setObject:[NSData defaultData] forKey:name];
                    }
                    break;
                }
                default:
                    break;
            }
        }
        free(propertyAttributes);
    }
    free(propertyArray);
    
    return defaultValues;
}

@end


#pragma mark - Defaults implementations

@implementation NSString (Defaults)

+ (NSString *)defaultString{
    return [NSString new];
}

- (BOOL)isDefault{
    return [self isEqualToString:[NSString defaultString]];
}

@end

@implementation NSDate (Defaults)

+ (NSDate *)defaultDate{
    return [NSDate dateWithTimeIntervalSince1970:0];
}

- (BOOL)isDefault{
    return [self isEqualToDate:[NSDate defaultDate]];
}

@end

@implementation NSData (Defaults)

+ (NSData *)defaultData{
    return [NSData new];
}

- (BOOL)isDefault{
    return [self isEqualToData:[NSData defaultData]];
}

@end