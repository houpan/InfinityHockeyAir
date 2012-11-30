//
//  Flipper.h
//  PhysicsBox2d
//
//  Created by Steffen Itterheim on 22.09.10.
//  Copyright 2010 Steffen Itterheim. All rights reserved.
//

#import "BodySprite.h"

typedef enum
{
	user_board_player,
	user_board_enemy,
} user_board_which;

@interface user_board : BodySprite <CCTargetedTouchDelegate>
{
	user_board_which type;
	b2RevoluteJoint* joint;
	float totalTime;
}

+(id) user_boardWithWorld:(b2World*)world user_board_which:(user_board_which)user_board_which;
@end
