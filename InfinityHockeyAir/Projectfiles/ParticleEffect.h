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
#import "GlobalEnum.m"
#import <Foundation/Foundation.h>

// link error並不一定是代表資料庫的問題，
//因為同一個interface被重新declare兩遍，所以他也沒辦法成功complile
//說真的就是想把

@interface ParticleEffect : CCNode
{
//    CCSprite* sharedSprite;
    NSMutableArray *arrayOfEffect;
    NSMutableArray *arrayOfEffectTTL;
    b2World* sharedWorld;
    CCSprite* sharedSprite;

    
}

+(id) ParticleEffectWith:(b2World*)world andSprite:(CCSprite*)spriteInput;

+(void) addEffect:(ballEffectType)ballEffectTypeInput andPosition:(CGPoint)positionInput;
@end
