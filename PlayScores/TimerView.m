//
//  TimerView.m
//  PlayScores
//
//  Created by Vadim Molchanov on 11/3/15.
//  Copyright © 2015 Vadim Molchanov. All rights reserved.
//

#import "TimerView.h"

@implementation TimerView

- (void)drawRect:(CGRect)rect {
    
    CGFloat midSize = (CGRectGetWidth(rect) + CGRectGetHeight(rect));
//    CGSize offsetShadow = CGSizeMake(midSize / 250.0, midSize / 500.0);
//    CGFloat blurRadius = midSize / 750.0;
    UIColor *currentColor = [UIColor colorWithRed:self.timePersent * 2 green:2 - self.timePersent * 2 blue:0.0 alpha:1.0];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, midSize / 80.0);
    
    CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextAddArc(context, CGRectGetMidX(rect), CGRectGetMidY(rect), (CGRectGetWidth(rect) + CGRectGetHeight(rect))/8, 3 * M_PI_2 + 2 * M_PI * self.timePersent, 3 * M_PI_2, NO);
    CGContextStrokePath(context);
    
    CGContextSetStrokeColorWithColor(context, currentColor.CGColor);
    CGContextAddArc(context, CGRectGetMidX(rect), CGRectGetMidY(rect), (CGRectGetWidth(rect) + CGRectGetHeight(rect))/8, 3 * M_PI_2, 3 * M_PI_2 + 2 * M_PI * self.timePersent, NO);
    CGContextStrokePath(context);
    
    NSString *text = [NSString stringWithFormat:@"%ld", (long)self.timeCount];
    UIFont *font = [UIFont systemFontOfSize:midSize / 10.0];
//    NSShadow *shadow = [[NSShadow alloc]init];
//    shadow.shadowOffset = offsetShadow;
//    shadow.shadowColor = [UIColor colorWithRed:0.7 green:0.5 blue:0.7 alpha:0.5];
//    shadow.shadowBlurRadius = blurRadius;
    NSDictionary *fontAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor blackColor], NSForegroundColorAttributeName, font, NSFontAttributeName, /*shadow, NSShadowAttributeName,*/ nil];
    
    CGSize textSize = [text sizeWithAttributes:fontAttributes];
    
    CGRect textRect = CGRectMake(CGRectGetMidX(rect) - textSize.width / 2, CGRectGetMidY(rect) - textSize.height / 2, textSize.width, textSize.height);
    textRect = CGRectIntegral(textRect);
    [text drawInRect:textRect withAttributes:fontAttributes];
    
}



@end
