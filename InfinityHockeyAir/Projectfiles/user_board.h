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
#import "GlobalEnum.m"



@interface user_board : BodySprite <CCStandardTouchDelegate>
{
	BOOL moveToFinger;
	CGPoint fingerLocation;

    specialBoardType specialBoardType_Object;
    BOOL dragEnabled;

    CFAbsoluteTime currentTouchTime;
    NSMutableArray * touchLocation;
    NSMutableArray * touchTime;
    CGPoint currentTouchLocation;
    CGPoint previousTouchLocation;
    double shouldTraveledDistance;
    

    int toNormalTTL;
}

@property BOOL dead;
@property user_board_type user_board_type_Object;
/**
 * Creates a new ball
 * @param world world to add the ball to
 */
+(id) user_boardWithWorld:(b2World*)world user_board_type:(user_board_type)user_board_type_input andSpecialBoardType:(specialBoardType)specialBoardTypeInput;
-(user_board_type) getuser_board_type;//這種給外面的人拿private參數的getter雖然是class method但是還是要宣告在外面
-(void) setPositionFromOutside:(b2Vec2)positionInput;
-(b2Vec2) getPosition;
-(void)user_boardDisabler;//把板子丟出場外
-(void)setDragEnable;
@end
