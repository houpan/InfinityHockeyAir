//
//  user_board.h
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

@interface user_boardAdder : BodySprite
{
    int user_boardNumber;
    b2World* sharedWorld;
    CCSpriteBatchNode* sharedSprite;
    CGPoint originuser_boardPosition;

    
    
    //用來達成動畫延遲效果
    NSMutableArray *delay_user_boardTypeInput;
    NSMutableArray *delay_newuser_board;
    NSMutableArray *user_boardToKill;
    NSMutableArray *user_boardToAdd;
    
    user_board_type transmit_user_boardTypeInput;
    specialBoardType transmit_specialBoardTypeInput;
}

@property BOOL user_board_enemyExist;
@property BOOL user_board_playerExist;

+(id) user_boardAdderWithWorld:(b2World*)world andSprite:(CCSpriteBatchNode*)spriteInput;
+(void) adduser_boardFromOutside:(user_board_type)user_boardTypeInput andSpecialBoardType:(specialBoardType)specialBoardTypeInput;
+(void) boardBiggerSmaller:(user_board_type)user_boardTypeInput andSpecialBoardType:(specialBoardType)specialBoardTypeInput;
+(void) setBoardExistance:(user_board_type)user_boar_type_input_ andBOOL:(BOOL)BOOL_;
-(user_board_type)invertBoardType:(user_board_type)user_boardTypeInput;
@end
