//
//  DataManager.h
//  PlayScores
//
//  Created by Vadim Molchanov on 10/30/15.
//  Copyright © 2015 Vadim Molchanov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface DataManager : NSObject

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

+ (DataManager *)sharedManager;

- (void)generateDefaultDataIfNeeded;
- (void)deleteAllObjects;
- (NSArray *)fetchedResultsWithPredicate:(NSPredicate *)predicate;
- (UIColor *)getNextColor;
- (void)clearScores;
- (void)changeScore:(NSNumber *)scoreFromLabel forIndex:(NSNumber *)index;
- (void)deletePlayerNumber:(NSNumber *)index;
- (void)changeName:(NSString *)newName forPlayerNumber:(NSNumber *)index;
- (void)cyclicShift;
- (void)saveData;
- (void)setTimerStampForCurrentPlayer:(NSTimeInterval)timeInterval;
- (NSString *)getCurrentPlayerName;
- (NSDate *)getCurrentTimeStamp;

@end
