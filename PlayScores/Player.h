//
//  Player.h
//  PlayScores
//
//  Created by Vadim Molchanov on 10/29/15.
//  Copyright © 2015 Vadim Molchanov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface Player : NSManagedObject

@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSNumber *number;
@property (nullable, nonatomic, retain) NSData *colour;
@property (nullable, nonatomic, retain) NSNumber *score;
@property (nullable, nonatomic, retain) NSDate *timerStamp;

@end
