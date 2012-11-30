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
#import "Items.h"

@interface ItemAdder : BodySprite
{
    int itemNumber;
    b2World* sharedWorld;
    CCSpriteBatchNode* sharedSprite;
    BOOL toCheck;
    user_board_type ownerToCheck;
    ItemType typeInputToCheck;
    NSMutableArray * arrayOfItem;
    
    
    int thunderTTL;//不知道要做在哪裡，就把閃電那個做在這邊囧
    CCSprite *thunderSprite;
    NSMutableArray *itemToKill;
    
}
+(id) ItemAdderWithWorld:(b2World*)world andSprite:(CCSpriteBatchNode*)spriteInput;
+(void) addItemFromOutside:(user_board_type)owner andType:(ItemType)typeInput;
+(void) activateItem:(user_board_type)owner andType:(ItemType)typeInput;

@end
