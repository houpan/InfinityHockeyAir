//
//  Items.h
//  PhysicsBox2d
//
//  Created by Steffen Itterheim on 20.09.10.
//  Copyright 2010 Steffen Itterheim. All rights reserved.
//

#import "BodySprite.h"
#import "Box2D.h"
#import "user_board.h"
#import "GlobalEnum.m"


@interface Items : BodySprite
{
    user_board_type belong;
    ItemType instanceItemType;
    int timeToLive;
    ItemType randomSelectedType;
}

/**
 * Creates a new Items
 * @param world world to add the Items to
 */

+(id) ItemsWithWorld:(b2World*)world andCaller:(user_board_type)caller andNumber:(ItemType)numberInput;
-(int)getTTL;
@end
