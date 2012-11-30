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



@interface ScoreBoard : CCNode
{
    int userScore;
    int enemyScore;
    CCSprite* sharedSprite;
}
+(id) ScoreBoardWith:(CCSprite*)spriteInput;
+(void) scoreIncrementFromOutside:(user_board_type)hitFrom;
@end
