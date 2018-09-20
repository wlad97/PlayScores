//
//  TimerViewController.h
//  PlayScores
//
//  Created by Vadim Molchanov on 11/3/15.
//  Copyright © 2015 Vadim Molchanov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TimerView.h"
#import "PlaySound.h"


@interface TimerViewController : UIViewController

@property (weak, nonatomic) IBOutlet TimerView *timerView;

@property (weak, nonatomic) IBOutlet UIButton *startFinishButtonState;
@property (weak, nonatomic) IBOutlet UIButton *pauseResumeButtonState;
@property (weak, nonatomic) IBOutlet UILabel *playerNameLabel;


- (IBAction)startFinishAction:(UIButton *)sender;
- (IBAction)pauseResumeAction:(UIButton *)sender;


@end
