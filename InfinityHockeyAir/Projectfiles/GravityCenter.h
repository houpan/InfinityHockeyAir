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



@interface GravityCenter : NSObject
{
    int userMagic;
    int enemyMagic;
    CCSprite* sharedSprite;
    
    
    CCSprite *horiziontalLine;
    CCSprite *verticalLine;
    float previousX;
    float previousY;
    
}
+(id) GravityCenterWith:(CCSprite*)spriteInput;
+(void) centerChangeFromOutside:(float)xIn andY:(float)yIn andZ:(float)zIn;
@end
