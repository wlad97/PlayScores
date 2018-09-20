//
//  SettingsViewController.m
//  PlayScores
//
//  Created by Vadim Molchanov on 10/26/15.
//  Copyright © 2015 Vadim Molchanov. All rights reserved.
//

#import "SettingsViewController.h"
#import "PlaySound.h"
#import "DataManager.h"

static NSString *kSettingsTimer = @"time_preference";
static NSString *kSettingsIncrement = @"multi_preference";
static NSString *kSettingsSound = @"sound_preference";
static NSString *kSettingsNegative = @"negative_preference";

@interface SettingsViewController ()

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithRed:200 / 255.0 green:199 / 255.0  blue:204 / 255.0  alpha:1.0];
    
    [[PlaySound alloc] playSound:@"Bottle" withExtension:@"aiff"];
    
    [self preferencesToChange:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self // if "Preferences" changed in "iOS Settings" system app
                                             selector:@selector(preferencesToChange:)
                                                 name:NSUserDefaultsDidChangeNotification
                                               object:nil];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 3;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    
    if (!component) {
        return 24;
        
    } else {
        return 60;
    }
}


#pragma mark - UIPickerViewDelegate

- (nullable NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [NSString stringWithFormat:@"%ld", (long)row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {

    NSInteger timerInterval = [pickerView selectedRowInComponent:0] * 3600 + [pickerView selectedRowInComponent:1] * 60 + [pickerView selectedRowInComponent:2];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:[NSString stringWithFormat:@"%ld", (long)timerInterval] forKey:kSettingsTimer];
    [userDefaults synchronize];

}


#pragma mark - Actions

- (IBAction)scoreIncrementDidChangeAction:(UISegmentedControl *)sender {
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setInteger:self.scoreIncrementSegmentedControl.selectedSegmentIndex forKey:kSettingsIncrement];
    [userDefaults synchronize];
}

- (IBAction)soundSwitchDidChangeAction:(UISwitch *)sender {
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:self.soundSwitch.isOn forKey:kSettingsSound];
    [userDefaults synchronize];

}

- (IBAction)negativeScoreDidChangeAction:(UISwitch *)sender {
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:self.negativeScoreSwitch.isOn forKey:kSettingsNegative];
    [userDefaults synchronize];

}


- (IBAction)clearAllDataSettingsAction:(UIButton *)sender {
    
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:@"Warning!"
                                message:@"All data will be cleared!"
                                preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancel = [UIAlertAction
                             actionWithTitle:@"Cancel"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction *action) {
                                 
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                             }];

    UIAlertAction *reset = [UIAlertAction
                            actionWithTitle:@"Reset"
                            style:UIAlertActionStyleDestructive
                            handler:^(UIAlertAction *action) {
                             
                             NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                             [userDefaults setBool:NO forKey:@"launched_prior"];
                             [userDefaults synchronize];
                             
                             DataManager *dataManager = [DataManager sharedManager];
                             [dataManager deleteAllObjects];
                             [dataManager generateDefaultDataIfNeeded];

                             [alert dismissViewControllerAnimated:YES completion:nil];
                         }];
    
    [alert addAction:cancel];
    [alert addAction:reset];
    
    [self presentViewController:alert animated:YES completion:nil];

}




#pragma mark - NSUserDefaultsDidChangeNotification

- (void)preferencesToChange:(NSNotification *)aNotification {
        
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSInteger timerInterval = [[userDefaults stringForKey:kSettingsTimer] integerValue];
    
    if (!timerInterval || timerInterval >= 86400) {
        timerInterval = 120;
        [userDefaults setObject:[NSString stringWithFormat:@"%ld", (long)timerInterval] forKey:kSettingsTimer];
        [userDefaults synchronize];
    }
    
    self.scoreIncrementSegmentedControl.selectedSegmentIndex = [userDefaults integerForKey:kSettingsIncrement];
    self.soundSwitch.on = [userDefaults boolForKey:kSettingsSound];
    self.negativeScoreSwitch.on = [userDefaults boolForKey:kSettingsNegative];
    
    NSInteger hours = timerInterval / 3600;
    [self.timerPicker selectRow:hours inComponent:0 animated:NO];
    
    NSInteger minutes = (timerInterval - hours * 3600) / 60;
    [self.timerPicker selectRow:minutes inComponent:1 animated:NO];
    
    NSInteger seconds = timerInterval - (hours * 3600 + minutes * 60);
    [self.timerPicker selectRow:seconds inComponent:2 animated:NO];

}



@end
