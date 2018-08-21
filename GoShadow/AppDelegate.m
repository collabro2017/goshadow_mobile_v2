//
//  AppDelegate.m
//  GoShadow
//
//  Created by Shawn Wall on 7/28/15.
//  Copyright (c) 2015 Inquiri. All rights reserved.
//

#import "AppDelegate.h"
#import "GoShadowModels.h"
#import <AFNetworkActivityLogger.h>
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import "GoShadowAPIManager.h"
#import "TimerManager.h"
#import <AFNetworkActivityIndicatorManager.h>
#import <AFNetworkReachabilityManager.h>
#import <Intercom/Intercom.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [Fabric with:@[CrashlyticsKit]];
    #ifdef  DEBUG
    [[AFNetworkActivityLogger sharedLogger] setLevel:AFLoggerLevelDebug];
    [[AFNetworkActivityLogger sharedLogger] startLogging];
    #endif
    
    [Intercom setApiKey:@"ios_sdk-f7018cb07b53ae858564d218caccb6a342397288" forAppId:@"tueqthiq"];
    
    //testing
//    [[NSFileManager defaultManager] removeItemAtPath:[RLMRealm defaultRealmPath] error:nil];
//    Experience *experience = [[Experience alloc] init];
//    experience.name = @"Experience Name";
//    experience.experienceId = 1;
//    Segment *segment = [[Segment alloc] init];
//    segment.name = @"Segment Name";
//    segment.experienceId = 1;
//    segment.segmentId = 1;
//    Note *note = [[Note alloc] init];
//    note.noteId = 1;
//    note.note = @"Timer";
//    note.segmentId = 1;
//    note.startDate = [NSDate mt_dateFromYear:2015 month:8 day:7];
//    note.accumulatedTime = 60*32;
//    Note *note2 = [[Note alloc] init];
//    note.noteId = 2;
//    note2.note = @"Note text 2";
//    note2.segmentId = 1;
//    Touchpoint *touchpoint = [[Touchpoint alloc] init];
//    touchpoint.touchpointId = 1;
//    touchpoint.name = @"Touchpoint name";
//    Caregiver *caregiver = [[Caregiver alloc] init];
//    caregiver.caregiverId = 1;
//    caregiver.name = @"Caregiver name";
//    note.touchpointId = 1;
//    note.touchpoint = touchpoint;
//    Shadower *shadower = [[Shadower alloc] init];
//    shadower.name = @"Shawn Wall";
//    
//    RLMRealm *realm = [RLMRealm defaultRealm];
//    [realm beginWriteTransaction];
////    [realm addObject:experience];
//    [realm addObject:segment];
////    [realm addObject:touchpoint];
////    [realm addObject:caregiver];
////    [realm addObject:note];
////    [realm addObject:note2];
////    [realm addObject:shadower];
//    [realm commitWriteTransaction];
//    
    [self setupAppearance];
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    
    if ([GoShadowAPIManager sharedManager].isAuthenticated) {
        [self showMainStoryboard];
    }
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    if ([GoShadowAPIManager sharedManager].isAuthenticated) {
        Shadower *user = [[GoShadowAPIManager sharedManager] getCurrentUser];
        if (user) {
            NSString *userId = [@(user.userId) stringValue];
            [Intercom registerUserWithUserId:userId];
        }

        [[GoShadowAPIManager sharedManager] updateDataWithCallback:^(id result, NSError *error) {
        }];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)showMainStoryboard {
    UIStoryboard *main = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    self.window.rootViewController = [main instantiateInitialViewController];
}

- (void)showAuthStoryboard {
    UIStoryboard *main = [UIStoryboard storyboardWithName:@"Authentication" bundle:nil];
    self.window.rootViewController = [main instantiateInitialViewController];
}

- (void)clearDatabase {
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    [realm deleteAllObjects];
    [realm commitWriteTransaction];
}

- (void)setupAppearance {
    [[UINavigationBar appearance] setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIColor whiteColor],
      NSForegroundColorAttributeName,
      [[NSShadow alloc] init],
      NSShadowAttributeName,
      [UIFont boldSystemFontOfSize:20.0],
      NSFontAttributeName,
      nil]];
    
    [[UINavigationBar appearance] setBarTintColor:[UIColor gsDarkBlueTransparentColor]];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];

    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    [[UIBarButtonItem appearanceWhenContainedIn: [UINavigationController class], nil] setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIColor whiteColor],
      NSForegroundColorAttributeName,
      [[NSShadow alloc] init],
      NSShadowAttributeName,
      [UIFont systemFontOfSize:16.0],
      NSFontAttributeName,
      nil] forState:UIControlStateNormal];
}

-(void)logout {
    [[GoShadowAPIManager sharedManager] logout];
    [Intercom reset];
    [self clearDatabase];
    [self showAuthStoryboard];
}

@end
