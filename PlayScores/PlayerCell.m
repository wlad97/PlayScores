//
//  PlayerCell.m
//  PlayScores
//
//  Created by Vadim Molchanov on 10/26/15.
//  Copyright © 2015 Vadim Molchanov. All rights reserved.
//

#import "PlayerCell.h"

@implementation PlayerCell

- (IBAction)scoreDecreaseAction:(UIButton *)sender {
    
    NSInteger step = [[NSUserDefaults standardUserDefaults] integerForKey:@"multi_preference"];
    step = -[self stepCase:step];
    [self changeScoreLabelData:step];

}

- (IBAction)scoreIncreaseAction:(UIButton *)sender {
    
    NSInteger step = [[NSUserDefaults standardUserDefaults] integerForKey:@"multi_preference"];
    step = [self stepCase:step];
    [self changeScoreLabelData:step];

}

- (NSInteger)stepCase:(NSInteger)step {
    
    switch (step) {
        case 0:
            step = 1;
            break;
        case 1:
            step = 2;
            break;
        case 2:
            step = 5;
            break;
        case 3:
            step = 10;
            break;
        case 4:
            step = 25;
            break;
            
        default:
            step = 1;
            break;
    }
    
    return step;
}


- (void)changeScoreLabelData:(NSInteger)step {
    
    NSNumber *scoreFromLabel = @([self.scoreLabel.text integerValue] + step);
    
    if ([scoreFromLabel integerValue] < 0) {
        if (![[NSUserDefaults standardUserDefaults] boolForKey:@"negative_preference"]) {
            scoreFromLabel = @(0);
        }
    }
    
    self.scoreLabel.text = [NSString stringWithFormat:@"%@", [scoreFromLabel stringValue]];
    
    [[DataManager sharedManager] changeScore:scoreFromLabel forIndex:@(self.index)];
    
}


@end

