//
//  TimerViewController.m
//  PlayScores
//
//  Created by Vadim Molchanov on 11/3/15.
//  Copyright © 2015 Vadim Molchanov. All rights reserved.
//

#import "TimerViewController.h"
#import "DataManager.h"

@interface TimerViewController () <UINavigationBarDelegate>

@property (assign, nonatomic) NSTimeInterval timeSet;
@property (assign, nonatomic) NSTimeInterval timeToFire;

@property (assign, nonatomic) BOOL stopTimer;

@end

@implementation TimerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.timerView.backgroundColor = [UIColor clearColor];
    NSString *timePreference = [[NSUserDefaults standardUserDefaults] objectForKey:@"time_preference"];
    self.timeSet = self.timerView.timeCount = [timePreference doubleValue];

    self.playerNameLabel.text = [[[DataManager sharedManager] getCurrentPlayerName] stringByAppendingString:@"'s time"];
    
    self.timerView.timePersent = 0.00001;
    [self.timerView setNeedsDisplay];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma mark - Orientation

- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [self.timerView setNeedsDisplay];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration / 2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.timerView setNeedsDisplay];
    });
}

#pragma mark - Timer


- (void)timerTick:(NSTimer *)timer {
    
    if (self.stopTimer) {
        [timer invalidate];
    }
    NSTimeInterval timeInterval = [[[DataManager sharedManager] getCurrentTimeStamp] timeIntervalSinceDate:[NSDate date]];
    if (timeInterval < 0) {
        timeInterval = 0.0;
    }
    self.timerView.timeCount = timeInterval;
    if (self.timerView.timeCount <= 0) {
        self.timerView.timePersent = 1.0;
        [timer invalidate];
        [self.startFinishButtonState setSelected:NO];
        [self.startFinishButtonState setEnabled:NO];
        [self.pauseResumeButtonState setEnabled:NO];
        
        [[DataManager sharedManager] cyclicShift];
        [[PlaySound alloc] playSound:@"Glass" withExtension:@"aiff"];
        self.navigationController.navigationBarHidden = NO;
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.navigationController popToRootViewControllerAnimated:YES];
        });
        
    } else {
        
        self.timerView.timePersent = (self.timeSet - self.timerView.timeCount) / self.timeSet;
    }
    [self.timerView setNeedsDisplay];
}


#pragma mark - Actions

- (IBAction)startFinishAction:(UIButton *)sender {
    
    if (self.startFinishButtonState.selected) {
        [[DataManager sharedManager] setTimerStampForCurrentPlayer:0];
        self.timerView.timeCount = 1;
        self.timerView.timePersent = 1.0;
        
        if (self.pauseResumeButtonState.isSelected) {
            [self timerTick:nil];
        }
        
        [self.startFinishButtonState setSelected:NO];
        [self.startFinishButtonState setEnabled:NO];
        [self.pauseResumeButtonState setSelected:NO];
        [self.pauseResumeButtonState setEnabled:NO];
        
    } else {
        
        [[PlaySound alloc] playSound:@"Submarine" withExtension:@"aiff"];
        [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(timerTick:) userInfo:nil repeats:YES];
        [[DataManager sharedManager] setTimerStampForCurrentPlayer:self.timeSet];
        
        [self.startFinishButtonState setSelected:YES];
        [self.pauseResumeButtonState setEnabled:YES];
        self.navigationController.navigationBarHidden = YES;

    }
}


- (IBAction)pauseResumeAction:(UIButton *)sender {
    
    if (self.pauseResumeButtonState.selected) {
        [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(timerTick:) userInfo:nil repeats:YES];
        [self.pauseResumeButtonState setSelected:NO];
        self.stopTimer = NO;
        [[DataManager sharedManager] setTimerStampForCurrentPlayer:self.timeToFire]; //Resumed
        
    } else {
        [self.pauseResumeButtonState setSelected:YES];
        self.stopTimer = YES;
        self.timeToFire = [[[DataManager sharedManager] getCurrentTimeStamp] timeIntervalSinceDate:[NSDate date]]; //Paused
    }

}


#pragma mark - UINavigationBarDelegate

- (void)setHidesBackButton:(BOOL)hidesBackButton animated:(BOOL)animated {
}



@end
