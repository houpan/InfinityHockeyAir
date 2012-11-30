//
//  Ball.h
//  PhysicsBox2d
//
//  Created by Steffen Itterheim on 20.09.10.
//  Copyright 2010 Steffen Itterheim. All rights reserved.
//

#import "Box2D.h"
#import "Helper.h"

//CCTargetedTouchDelegate：這個是接收單一touch
//CCStandardTouchDelegate：這個可以接收多touch
@interface MouseListener : NSObject<CCStandardTouchDelegate>{
//    NSArray *array
    
}
//+(id) initWithWorld:(b2World*)world;
//不知道為什麼一定要用static而不能是member funciton
/*
+(void) ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
//+(BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event;
+(void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
+(void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;
 */
+(BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event;
@end
