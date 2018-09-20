//
//  PlayerCell.h
//  PlayScores
//
//  Created by Vadim Molchanov on 10/26/15.
//  Copyright © 2015 Vadim Molchanov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewController.h"

@interface PlayerCell : UICollectionViewCell

@property (assign, nonatomic) NSInteger index;

@property (weak, nonatomic) IBOutlet UILabel *playerLabel;
@property (weak, nonatomic) IBOutlet UILabel *scoreLabel;

@property (weak, nonatomic) IBOutlet UIButton *scoreDecreaseButton;
@property (weak, nonatomic) IBOutlet UIButton *scoreIncreaseButton;

- (IBAction)scoreDecreaseAction:(UIButton *)sender;
- (IBAction)scoreIncreaseAction:(UIButton *)sender;

@end
