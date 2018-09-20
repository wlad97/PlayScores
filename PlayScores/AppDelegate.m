//
//  AppDelegate.m
//  PlayScores
//
//  Created by Vadim Molchanov on 10/26/15.
//  Copyright © 2015 Vadim Molchanov. All rights reserved.
//

#import "AppDelegate.h"
#import "DataManager.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    UIUserNotificationSettings *notificationSettings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeSound categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:notificationSettings];
    
    [[DataManager sharedManager] generateDefaultDataIfNeeded];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {

    [[DataManager sharedManager] saveData];
    [[DataManager sharedManager] saveContext];
    
}

- (void)applicationDidEnterBackground:(UIApplication *)application {

    NSDate *fireTime = [[DataManager sharedManager] getCurrentTimeStamp];
    if ([[fireTime laterDate:[NSDate date]] isEqualToDate:fireTime]) {
        UILocalNotification *localNotification = [[UILocalNotification alloc] init];
        localNotification.fireDate = fireTime;
        localNotification.alertBody = [NSString stringWithFormat:@"%@'s turn", [[DataManager sharedManager] getCurrentPlayerName]];
        localNotification.soundName = UILocalNotificationDefaultSoundName;
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
    }
}

-(void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {

}


- (void)applicationWillTerminate:(UIApplication *)application {

    [[DataManager sharedManager] saveData];
    [[DataManager sharedManager] saveContext];
}


@end
