//
//  PlaySound.m
//  PlayScores
//
//  Created by Vadim Molchanov on 10/26/15.
//  Copyright © 2015 Vadim Molchanov. All rights reserved.
//

#import "PlaySound.h"

@implementation PlaySound

-(void)playSound:(NSString *)file withExtension:(NSString *)ext {
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"sound_preference"]) {
        NSString *soundPath = [[NSBundle mainBundle] pathForResource:file ofType:ext];
        SystemSoundID soundID;
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath: soundPath], &soundID);
        AudioServicesPlaySystemSound (soundID);
    }
}

@end
