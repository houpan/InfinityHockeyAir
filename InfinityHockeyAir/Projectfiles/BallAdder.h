//
//  Ball.h
//  PhysicsBox2d
//
//  Created by Steffen Itterheim on 20.09.10.
//  Copyright 2010 Steffen Itterheim. All rights reserved.
//

#import "BodySprite.h"
#import "Box2D.h"
#import "cocos2d.h"
#import "user_board.h"
#import "Ball.h"
#import "ParticleEffectAdder.h"



@interface BallAdder : BodySprite
{
    int BallNumber;
    b2World* sharedWorld;
    CCSpriteBatchNode* sharedSprite;
    NSMutableArray *arrayOfBall;
    CGPoint originBallPosition;
    NSMutableArray *ballToKill;
    
    ballType transmit_ballTypeInput;
}

+(id) BallAdderWithWorld:(b2World*)world andSprite:(CCSpriteBatchNode*)spriteInput;
+(void) addBallFromOutside:(ballType)ballTypeInput;
+(void) ballSmaller;
+(void) ballFaster:(fasterType)fasterTypeInput;
+(void) ballMultiply:(int)numberInput;
+(void) ballFaster;
+(void) ballFire;
+(void) ballSpecial:(ballType)ballTypeInput;
+(void) ballSucked:(user_board_type)user_boardTypeInput;
@end
