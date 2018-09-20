//
//  PlaySound.h
//  PlayScores
//
//  Created by Vadim Molchanov on 10/26/15.
//  Copyright © 2015 Vadim Molchanov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

@interface PlaySound : NSObject

-(void)playSound:(NSString *)file withExtension:(NSString *)ext;

@end
