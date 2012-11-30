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
#import "GlobalEnum.m"
#import "HockeyTableLayer.h"
#import "Constants.h"
#import <Foundation/Foundation.h>

// link error並不一定是代表資料庫的問題，
//因為同一個interface被重新declare兩遍，所以他也沒辦法成功complile
//說真的就是想把
@class Ball;

@interface ParticleEffectAdder : CCSprite
{
//    CCSprite* sharedSprite;
    NSMutableArray *arrayOfEffect;
    NSMutableArray *arrayOfEffectTTL;
    NSMutableArray *arrayOfEffectBall;
    NSMutableArray *arrayOfBall;
    NSMutableArray *arrayOfuserboard;
    b2World* sharedWorld;
    CCSprite* sharedSprite;
    
    float aSecondRatio;
    float aSecondMeter;//用來衡量TTLcheck執行幾次才要真正減一秒
    BodySprite *nullBall;//為了給一些要填空ball的effect用
    NSUInteger global_objIdx;//為了要傳說要刪掉哪個index
    BodySprite *global_bodyInput;
}

+(void) addEffectBall:(ballEffectType)ballEffectTypeInput andBall:(BodySprite*)BallInput andTTLtime:(TTLtime)TTLinput;
+(id) ParticleEffectAdderWith:(b2World*)world andSprite:(CCSprite*)spriteInput;
+(void) addEffect:(ballEffectType)ballEffectTypeInput andPosition:(CGPoint)positionInput;
+(void) ballRemover:(BodySprite*)bodyInput;
@end
