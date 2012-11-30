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




@interface MagicRuler : CCNode
{
    int userMagic;
    int enemyMagic;
    CCSprite* sharedSprite;
}
+(id) MagicRulerWith:(CCSprite*)spriteInput;
+(void) magicIncrementFromOutside:(user_board_type)caller andNumber:(int)numberInput;
@end
