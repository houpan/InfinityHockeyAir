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



@interface Item : NSObject
{
    user_board_type belong;
    ItemType instanceItemType;
    int timeToLive;
    CCSprite* sharedSprite;
}
+(id) ItemWith:(CCSprite*)spriteInput;
+(void) magicIncrementFromOutside:(user_board_type)caller andNumber:(int)numberInput;
@end
