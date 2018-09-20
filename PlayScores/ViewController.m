//
//  ViewController.m
//  PlayScores
//
//  Created by Vadim Molchanov on 10/26/15.
//  Copyright © 2015 Vadim Molchanov. All rights reserved.
//

#import "ViewController.h"
#import "DataManager.h"
#import "Player.h"
#import "PlayerCell.h"

@interface ViewController () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (assign, nonatomic) CGFloat cellSide;
@property NSMutableArray *sectionChanges;
@property NSMutableArray *itemChanges;

@end

@implementation ViewController
@synthesize fetchedResultsController = _fetchedResultsController;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.collectionView.backgroundColor = [UIColor whiteColor];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        self.cellSide = (self.collectionView.frame.size.height - 64 - 40) / 3.0;  // UI player cell size for iPad screen proportion
        
    } else {
        
        switch ((int)self.collectionView.frame.size.height) {
            case 568:
            case 667:
                self.cellSide = (self.collectionView.frame.size.width - 30 - 32) / 2.0; // UI player cell size for iPhone 4" & 4.7" screen proportion
                break;
                
            case 736:
                self.cellSide = (self.collectionView.frame.size.width - 30 - 44) / 2.0; // UI player cell size for iPhone 5.5" screen proportion
                break;
                
            default:
                self.cellSide = (self.collectionView.frame.size.width - 30 - 40) / 2.0; // UI player cell size for iPhone 3.5" screen proportion
                break;
        }
    }
    
    self.collectionView.contentInset = UIEdgeInsetsMake(10.0, 10.0, 10.0, 10.0); // {top, left, bottom, right}
    
    UILongPressGestureRecognizer *longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    longPressGestureRecognizer.minimumPressDuration = 0.5; // in seconds
    longPressGestureRecognizer.delegate = self;
    longPressGestureRecognizer.delaysTouchesBegan = YES;
    [self.collectionView addGestureRecognizer:longPressGestureRecognizer];
    
    UISwipeGestureRecognizer *swipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeLeft:)];
    swipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.collectionView addGestureRecognizer:swipeGestureRecognizer];

}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.collectionView reloadData];
    
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[DataManager sharedManager] saveData];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (NSManagedObjectContext *)managedObjectContext {
    
    if (!_managedObjectContext) {
        _managedObjectContext = [[DataManager sharedManager] managedObjectContext];
    }
    return _managedObjectContext;
}

- (void) delayedReload:(float) delay {

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.collectionView reloadData];
    });

}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    
    _sectionChanges = [[NSMutableArray alloc] init];
    _itemChanges = [[NSMutableArray alloc] init];

}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
    NSMutableDictionary *change = [[NSMutableDictionary alloc] init];
    change[@(type)] = @(sectionIndex);
    [_sectionChanges addObject:change];

}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    
    NSMutableDictionary *change = [[NSMutableDictionary alloc] init];

    switch(type) {
        case NSFetchedResultsChangeInsert:
            change[@(type)] = newIndexPath;
            break;
            
        case NSFetchedResultsChangeDelete:
            change[@(type)] = indexPath;
            break;
            
        case NSFetchedResultsChangeUpdate:
            change[@(type)] = indexPath;
            break;
            
        case NSFetchedResultsChangeMove:
            change[@(type)] = @[indexPath, newIndexPath];
            break;
    }
    [_itemChanges addObject:change];

}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    
    [self.collectionView performBatchUpdates:^{
        for (NSDictionary *change in _sectionChanges) {
            [change enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                NSFetchedResultsChangeType type = [key unsignedIntegerValue];
                
                switch(type) {
                    case NSFetchedResultsChangeInsert:
                        [self.collectionView insertSections:[NSIndexSet indexSetWithIndex:[obj unsignedIntegerValue]]];
                        break;
                        
                    case NSFetchedResultsChangeDelete:
                        [self.collectionView deleteSections:[NSIndexSet indexSetWithIndex:[obj unsignedIntegerValue]]];
                        break;
                        
                    case NSFetchedResultsChangeMove:
                    case NSFetchedResultsChangeUpdate:
                        break;
                }
            }];
        }
        for (NSDictionary *change in _itemChanges) {
            [change enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                NSFetchedResultsChangeType type = [key unsignedIntegerValue];
                
                switch(type) {
                    case NSFetchedResultsChangeInsert:
                        [self.collectionView insertItemsAtIndexPaths:@[obj]];
                        break;
                        
                    case NSFetchedResultsChangeDelete:
                        [self.collectionView deleteItemsAtIndexPaths:@[obj]];
                        [self delayedReload:1.0];
                        break;
                        
                    case NSFetchedResultsChangeUpdate:
                        [self.collectionView reloadItemsAtIndexPaths:@[obj]];
                        break;
                        
                    case NSFetchedResultsChangeMove:
                        [self.collectionView moveItemAtIndexPath:obj[0] toIndexPath:obj[1]];
                        break;
                }
            }];
        }
    } completion:^(BOOL finished) {
        _sectionChanges = nil;
        _itemChanges = nil;
    }];

}


- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Player" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setFetchBatchSize:20];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"number" ascending:YES];
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil]; //@"Master"
    
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }

    return _fetchedResultsController;
}    



#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    
    return [sectionInfo numberOfObjects];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    PlayerCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PlayerCell" forIndexPath:indexPath];
    cell.index = indexPath.item;
    
    cell.layer.cornerRadius = self.cellSide / 15;
    
    NSData *colorData = [[self.fetchedResultsController objectAtIndexPath:indexPath] colour];
    cell.backgroundColor = (UIColor *)[NSKeyedUnarchiver unarchiveObjectWithData:colorData];
    
    [cell.playerLabel setFont:[UIFont systemFontOfSize:self.cellSide / 3.5]];
    cell.playerLabel.text = [[self.fetchedResultsController objectAtIndexPath:indexPath] name]; //indexPath.item
    [cell.scoreLabel setFont:[UIFont systemFontOfSize:self.cellSide / 2.5]];
    cell.scoreLabel.text = [NSString stringWithFormat:@"%@", [[self.fetchedResultsController objectAtIndexPath:indexPath] score]];
    [cell.scoreDecreaseButton.titleLabel setFont:[UIFont systemFontOfSize:self.cellSide / 2.0]];
    [cell.scoreIncreaseButton.titleLabel setFont:[UIFont systemFontOfSize:self.cellSide / 2.5]];
    
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
}


#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {

    return CGSizeMake(self.cellSide, self.cellSide);
}


#pragma mark - Actions

- (IBAction)newGameAction:(UIBarButtonItem *)sender {
    
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:@"Warning!"
                                message:@"All scores will be cleared!"
                                preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *ok = [UIAlertAction
                         actionWithTitle:@"OK"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction *action) {
                             
                             [[DataManager sharedManager] clearScores];
                             
                             [alert dismissViewControllerAnimated:YES completion:nil];
                             
                         }];
    UIAlertAction *cancel = [UIAlertAction
                             actionWithTitle:@"Cancel"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction *action) {
                                 
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                             }];
    
    [alert addAction:ok];
    [alert addAction:cancel];
    
    [self presentViewController:alert animated:YES completion:nil];
    
}



- (IBAction)addNewPlayerAction:(UIBarButtonItem *)sender {
    
    UIColor *playerColor = [[DataManager sharedManager] getNextColor];
    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
    NSEntityDescription *entityDesc = [[self.fetchedResultsController fetchRequest] entity];
    NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:[entityDesc name] inManagedObjectContext:context];
    
    [newManagedObject setValue:[NSKeyedArchiver archivedDataWithRootObject:playerColor] forKey:@"colour"];
    
    [newManagedObject setValue:@"Player" forKey:@"name"];
    [newManagedObject setValue:@([[self.fetchedResultsController sections][0] numberOfObjects]) forKey:@"number"];
    [newManagedObject setValue:@0 forKey:@"score"];
    [newManagedObject setValue:[NSDate date] forKey:@"timerStamp"];
        
    NSError *error = nil;
    if (![context save:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            
    }

}

#pragma mark - UIGestureRecognizerDelegate

-(void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer {
    
    DataManager *dataManager = [DataManager sharedManager];
    
    CGPoint tapPoint = [gestureRecognizer locationInView:self.collectionView];
    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:tapPoint];
    
    if (indexPath == nil){
        
        NSLog(@"couldn't find index path");
        
    } else {
        
        if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        
            return;
        }

        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Edit Player"
                                                                                 message:@"Change player name or delete player"
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        
        [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            
             [textField addTarget:self action:@selector(alertControllerTextFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
             textField.placeholder = @"Enter name";
             
             NSPredicate *predicate = [NSPredicate predicateWithFormat:@"number == %@", @(indexPath.item)];
             NSArray *resultsArray = [dataManager fetchedResultsWithPredicate:predicate];
             Player *player = [resultsArray objectAtIndex:0];

             textField.text = player.name;
             textField.autocapitalizationType = UITextAutocapitalizationTypeWords;
             textField.clearButtonMode = UITextFieldViewModeWhileEditing;
         }];
        
        UIAlertAction *okAction = [UIAlertAction
                                   actionWithTitle:@"OK"
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction *action) {
                                       
                                       UITextField *playerName = alertController.textFields.firstObject;
                                       [dataManager changeName:playerName.text forPlayerNumber:@(indexPath.item)];
                                   }];
        
        UIAlertAction *cancelAction = [UIAlertAction
                                       actionWithTitle:@"Cancel"
                                       style:UIAlertActionStyleCancel
                                       handler:^(UIAlertAction *action) {
                                           //NSLog(@"Cancel action");
                                       }];
        
        UIAlertAction *deleteAction = [UIAlertAction
                                      actionWithTitle:@"Delete"
                                      style:UIAlertActionStyleDestructive
                                      handler:^(UIAlertAction *action) {
                                          
                                          [dataManager deletePlayerNumber:@(indexPath.item)];
                                      }];
        
        if ([[dataManager fetchedResultsWithPredicate:nil] count] < 3) {
            deleteAction.enabled = NO;
        }
        
        [alertController addAction:okAction];
        [alertController addAction:cancelAction];
        [alertController addAction:deleteAction];
        
        [self presentViewController:alertController animated:YES completion:nil];

    }
}

-(void)handleSwipeLeft:(UISwipeGestureRecognizer *)gestureRecognizer {
    
    [[DataManager sharedManager] cyclicShift];
}


- (void)alertControllerTextFieldDidChange:(UITextField *)sender {
    UIAlertController *alertController = (UIAlertController *)self.presentedViewController;
    if (alertController) {
        UITextField *someTextField = alertController.textFields.firstObject;
        UIAlertAction *okAction = alertController.actions.firstObject;
        okAction.enabled = someTextField.text.length > 0;
    }
}




@end
