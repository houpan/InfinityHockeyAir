//
//  Ball.h
//  PhysicsBox2d
//
//  Created by Steffen Itterheim on 20.09.10.
//  Copyright 2010 Steffen Itterheim. All rights reserved.
//

#import "BodySprite.h"
#import "Box2D.h"
#import "user_board.h"





@interface Ball : BodySprite
{
    ballType selfBallType;
    int smallerTTL;
    int fasterTTL;
    int fireTTL;
    int suckedTTL;
    BOOL fasterActivated;
    BOOL isCloned;
    BOOL isClonedGetIn;
    
    BOOL suckedActivated;
    b2Vec2 suckedDestination;
    
    BOOL ballDead;//標示球是不是被海放到外面去了，因為如果一次一堆球被海放，但是又在場外瘋狂碰撞，那程式就爛了，所以開這個可以防止球跟其他東西碰撞
}


/**
 * Creates a new ball
 * @param world world to add the ball to
 */
+(id) ballWithWorld:(b2World*)world andBallType:(ballType)ballTypeInput andBallPosition:(CGPoint)ballPosition_input;
-(void)ballFasterActivate:(fasterType)fasterTypeInput;

-(ballType)getBallType;
-(int)getTTL:(ballType)ballTypeInput;
-(void)setVelocity:(b2Vec2)velocityInput;
-(void)setIsCloned;
-(BOOL)checkCloneGetIn;
-(BOOL)checkIsCloned;
-(void)ballSuckedActivate:(user_board_type)caller;
-(void)ballSuckedDeactivate;
-(BOOL)checkSuckedActivated;
-(void)ballDisabler;
@end
