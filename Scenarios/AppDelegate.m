//
//  AppDelegate.m
//  Scenarios
//
//  Created by Adam Burstein on 2/1/18.
//  Copyright © 2018 Adam Burstein. All rights reserved.
//

#import "AppDelegate.h"
#import "UIDevice+IdentifierAddition.h"

@interface AppDelegate ()

@end

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self copyXMLFileToDocuments];
    application.applicationIconBadgeNumber = 0;
    
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"errorMessage"];
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"errorXML"];

    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    center.delegate = self;

    [center requestAuthorizationWithOptions:(UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge) completionHandler:^(BOOL granted, NSError * _Nullable error)
    {
        if( !error )
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[UIApplication sharedApplication] registerForRemoteNotifications];
            });            NSLog( @"Push registration success." );
        }
        else
        {
            NSLog( @"Push registration FAILED" );
            NSLog( @"ERROR: %@ - %@", error.localizedFailureReason, error.localizedDescription );
            NSLog( @"SUGGESTIONS: %@ - %@", error.localizedRecoveryOptions, error.localizedRecoverySuggestion );
        }
    }
    ];
    
    return YES;
}

-(NSString *)GetDocumentDirectory{
//    NSFileManager *fileMgr = [NSFileManager defaultManager];
    NSString *homeDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    
    return homeDir;
}

-(void) copyXMLFileToDocuments
{
    NSString *filepath = [self.GetDocumentDirectory stringByAppendingPathComponent:@"scenarioData.xml"];
    NSError *error = nil;

    if ([[NSFileManager defaultManager] fileExistsAtPath:filepath])
        return;
    
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"scenarioData" ofType:@"xml"];
    [[NSFileManager defaultManager] copyItemAtPath:bundlePath toPath:filepath error:&error];
}

-(void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(nonnull NSData *)deviceToken
{
    NSString *tokenString = [[NSUserDefaults standardUserDefaults] valueForKey:@"DeviceTokenFinal"];
    
    if ((tokenString == nil) || ([tokenString isEqualToString:@""]))
    {
        NSString *tokenString = [[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
        tokenString = [tokenString stringByReplacingOccurrencesOfString:@" " withString:@""];
        NSLog(@"Push Notification tokenstring is %@",tokenString);


        NSString *deviceDetails = [[[UIDevice currentDevice] identifierForVendor] UUIDString];

        NSLog(@"%@", deviceDetails);
        
        // Write to web service
        // Test to make sure that it was successful
        [[NSUserDefaults standardUserDefaults]setObject:tokenString forKey:@"DeviceTokenFinal"];
        [[NSUserDefaults standardUserDefaults]synchronize];

        NSLog(@"Success");
    }
}

-(void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(nonnull NSError *)error
{
    NSLog(@"Failure");

}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    application.applicationIconBadgeNumber = 0;
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

-(void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler
{
    NSLog(@"User Info : %@",notification.request.content.userInfo);
    completionHandler(UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge);
    [self handleRemoteNotification:[UIApplication sharedApplication] userInfo:notification.request.content.userInfo];
}

-(void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void(^)(void))completionHandler
{
    NSLog(@"User Info : %@",response.notification.request.content.userInfo);
    completionHandler();
    [self handleRemoteNotification:[UIApplication sharedApplication] userInfo:response.notification.request.content.userInfo];
}

-(void) handleRemoteNotification:(UIApplication *) application   userInfo:(NSDictionary *) remoteNotif
{
    NSLog(@"handleRemoteNotification");
    NSLog(@"Handle Remote Notification Dictionary: %@", remoteNotif);
    
    // Handle Click of the Push Notification From Here…
    // You can write a code to redirect user to specific screen of the app here….
}
@end
