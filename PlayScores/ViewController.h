//
//  ViewController.h
//  PlayScores
//
//  Created by Vadim Molchanov on 10/26/15.
//  Copyright © 2015 Vadim Molchanov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DataManager.h"
#import "PlayerCell.h"

@interface ViewController : UICollectionViewController <NSFetchedResultsControllerDelegate, UIGestureRecognizerDelegate>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;


- (IBAction)newGameAction:(UIBarButtonItem *)sender;

- (IBAction)addNewPlayerAction:(UIBarButtonItem *)sender;


@end
