//
//  DataManager.m
//  PlayScores
//
//  Created by Vadim Molchanov on 10/30/15.
//  Copyright © 2015 Vadim Molchanov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DataManager.h"
#import "Player.h"

@interface DataManager ()

@property (strong, nonatomic) NSMutableDictionary *delayedScoreData;
@property (assign, nonatomic) BOOL timerFlag;

@end

@implementation DataManager

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;


+ (DataManager *)sharedManager {

    static DataManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[DataManager alloc] init];
    });
    
    return manager;
}

- (void)generateDefaultDataIfNeeded {
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    if (![userDefaults boolForKey:@"launched_prior"]) {
        [userDefaults setBool:YES forKey:@"launched_prior"];
        [userDefaults setObject:@"120" forKey:@"time_preference"];
        [userDefaults setInteger:0 forKey:@"multi_preference"];
        [userDefaults setBool:YES forKey:@"sound_preference"];
        [userDefaults setBool:NO forKey:@"negative_preference"];
        [userDefaults synchronize];
                
        for (int i = 0; i < 2; i++) {
            UIColor *playerColor = [self getNextColor];
            Player *newPlayer = [NSEntityDescription insertNewObjectForEntityForName:@"Player" inManagedObjectContext:self.managedObjectContext];
            newPlayer.number = @(i);
            newPlayer.name = [NSString stringWithFormat:@"Player%d", i + 1];
            newPlayer.score = @(0); //arc4random_uniform(50)
            newPlayer.colour = [NSKeyedArchiver archivedDataWithRootObject:playerColor];
            newPlayer.timerStamp = [NSDate date];
        }

        NSError *error = nil;
        [self.managedObjectContext save:&error];
        if (error) {
            NSLog(@"%@", [error localizedDescription]);
        }
    }
//        NSLog(@"%@", [self applicationDocumentsDirectory]);
    
}


- (NSArray *)fetchedResultsWithPredicate:(NSPredicate *)predicate {
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"Player" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entityDesc];
    [fetchRequest setPredicate:predicate];
    NSSortDescriptor *numberDescriptor = [[NSSortDescriptor alloc] initWithKey:@"number" ascending:YES];
    [fetchRequest setSortDescriptors:@[numberDescriptor]];

    NSError *error = nil;
    NSArray *resultArray = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (error) {
        NSLog(@"%@", [error localizedDescription]);
    }
    
    return resultArray;
}

-(UIColor *)getNextColor {

    static int colorMatrix [6][3] = {
        {227, 146, 125},
        { 92, 205, 185},
        {255, 214, 122},
        {205, 167, 154},
        {149, 174, 181},
        { 62, 114, 148},
    };
    static int redOrder [6] = {0, 0, 1, 1, 2, 2};
    static int greenOrder [6] = {1, 2, 0, 2, 0, 1};
    static int blueOrder [6] = {2, 1, 2, 0, 1, 0};
    
    NSInteger count = [[self fetchedResultsWithPredicate:nil] count];
    NSInteger colorIndex = count % 6;
    NSInteger colorReorder = (count / 6) % 6;
    NSInteger colorR = redOrder[colorReorder];
    NSInteger colorG = greenOrder[colorReorder];
    NSInteger colorB = blueOrder[colorReorder];
    
    UIColor *nextColor = [UIColor colorWithRed:colorMatrix[colorIndex][colorR] / 255.0 green:colorMatrix[colorIndex][colorG] / 255.0 blue:colorMatrix[colorIndex][colorB] / 255.0 alpha:0.85];
    
    return nextColor;
}


#pragma mark - Data Manipulations

- (void)clearScores {
    
    [self saveData];

    NSArray *allPlayers = [self fetchedResultsWithPredicate:nil];
    
    for (Player *iPlayer in allPlayers) {
        iPlayer.score = @0;
    }
    
    NSError *error = nil;
    [self.managedObjectContext save:&error];
    if (error) {
        NSLog(@"%@", [error localizedDescription]);
    }

}


- (void)changeScore:(NSNumber *)scoreFromLabel forIndex:(NSNumber *)index {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        self.delayedScoreData = [[NSMutableDictionary alloc] init];
    });
    
    if (!self.timerFlag) {
        [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(timerSave:) userInfo:nil repeats:NO];
        self.timerFlag = YES;
    }
    
    [self.delayedScoreData setValue:scoreFromLabel forKey:[NSString stringWithFormat:@"Label%@", [index stringValue]]];
    
}

- (void)deletePlayerNumber:(NSNumber *)index {
    
    [self saveData];
    
    NSArray *allPlayers = [self fetchedResultsWithPredicate:nil];
    
    for (NSInteger i = [index integerValue]; i < [allPlayers count]; i++) {
        Player *player = [allPlayers objectAtIndex:i];
        player.number = @(i - 1);
    }
    
    [self.managedObjectContext deleteObject:[allPlayers objectAtIndex:[index integerValue]]];
    
    NSError *error = nil;
    [self.managedObjectContext save:&error];
    if (error) {
        NSLog(@"%@", [error localizedDescription]);
    }

}

- (void)changeName:(NSString *)newName forPlayerNumber:(NSNumber *)index {
    
    NSArray *resultArray = [self fetchedResultsWithPredicate:[NSPredicate predicateWithFormat:@"number == %@", index]];

    Player *player = [resultArray objectAtIndex:0];
    player.name = newName;
    
    NSError *error = nil;
    [self.managedObjectContext save:&error];
    if (error) {
        NSLog(@"%@", [error localizedDescription]);
    }

}


- (void)cyclicShift {

    [self saveData];

    NSArray *allPlayers = [self fetchedResultsWithPredicate:nil];
    
    Player *player = [allPlayers objectAtIndex:0];
    player.number = @([allPlayers count] - 1);
    
    for (NSInteger i = 1; i < [allPlayers count]; i++) {
        player = [allPlayers objectAtIndex:i];
        player.number = @(i - 1);
    }

    NSError *error = nil;
    [self.managedObjectContext save:&error];
    if (error) {
        NSLog(@"%@", [error localizedDescription]);
    }

}

- (void)saveData {
    
    NSArray *allPlayers = [self fetchedResultsWithPredicate:nil];
    NSInteger scoreIndex;
    Player *player;
    
    for (NSString *iKey in self.delayedScoreData) {
        scoreIndex = [[iKey substringFromIndex:5] integerValue];

        player = [allPlayers objectAtIndex:scoreIndex];
        player.score = [self.delayedScoreData objectForKey:iKey];
    }
    [self.delayedScoreData removeAllObjects];
    
    NSError *error = nil;
    [self.managedObjectContext save:&error];
    if (error) {
        NSLog(@"%@", [error localizedDescription]);
    }
    
}

- (void)deleteAllObjects {
    
    NSArray *allPlayers = [self fetchedResultsWithPredicate:nil];
    NSError *error = nil;
        
    for (Player *iPlayer in allPlayers) {
        [self.managedObjectContext deleteObject:iPlayer];
        
        [self.managedObjectContext save:&error]; // anti-crash temporary fix
        if (error) {
            NSLog(@"%@", [error localizedDescription]);
        }
    }
/*
    [self.managedObjectContext save:&error]; // An exception was caught from the delegate of NSFetchedResultsController during a call to -controllerDidChangeContent:. Crashes on real devices only, when some cells is out of the screen
    if (error) {
        NSLog(@"%@", [error localizedDescription]);
    } */
}


#pragma mark - Delayed changes timer


- (void)timerSave:(NSTimer *)timer {

    [self saveData];
    [timer invalidate];
    self.timerFlag = NO;

}

- (void)setTimerStampForCurrentPlayer:(NSTimeInterval)timeInterval {
    
    NSArray *resultArray = [self fetchedResultsWithPredicate:[NSPredicate predicateWithFormat:@"number == %@", @(0)]];
    Player *player = [resultArray objectAtIndex:0];
    player.timerStamp = [NSDate dateWithTimeIntervalSinceNow:timeInterval];

    NSError *error = nil;
    [self.managedObjectContext save:&error];
    if (error) {
        NSLog(@"%@", [error localizedDescription]);
    }    
}

- (NSString *)getCurrentPlayerName {

    NSArray *resultArray = [self fetchedResultsWithPredicate:[NSPredicate predicateWithFormat:@"number == %@", @(0)]];
    Player *player = [resultArray objectAtIndex:0];
    return player.name;
}

- (NSDate *)getCurrentTimeStamp {
    
    NSArray *resultArray = [self fetchedResultsWithPredicate:[NSPredicate predicateWithFormat:@"number == %@", @(0)]];
    Player *player = [resultArray objectAtIndex:0];
    return player.timerStamp;
}


#pragma mark - Core Data stack

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.vadimmolchanov.PlayScores" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"PlayScores" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"PlayScores.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        //        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            
        }
    }
}


@end


