//
//  TableSetup.m
//  PhysicsBox2d
//
//  Created by Steffen Itterheim on 22.09.10.
//  Copyright 2010 Steffen Itterheim. All rights reserved.
//
//  Enhanced to use PhysicsEditor shapes and retina display
//  by Andreas Loew / http://www.physicseditor.de
//

#import "TableSetup.h"
#import "Constants.h"
#import "TablePart.h"
#import "Ball.h"
#import "user_board.h"
#import "MouseListener.h"
#import "ItemAdder.h"
#import "BallAdder.h"
#import "user_boardAdder.h"
#import "TablePartAdder.h"
#import "ParticleEffectAdder.h"

@implementation TableSetup
-(id) initTableWithWorld:(b2World*)world
{
	if ((self = [super initWithFile:@"texture.png" capacity:10]))
	{
        CGSize screenSize = [CCDirector sharedDirector].winSize;
        
//        //把tablepart加進去畫面中
        [self addChild:[TablePartAdder TablePartAdderWithWorld:world andSprite:self] z:-1];

		

//        BallAdder* ballAdderInstance =;

        [self addChild:[BallAdder BallAdderWithWorld:world andSprite:self] z:-1];
        [BallAdder addBallFromOutside:ballTypeNormal];

        
        //ItemAdder也必須要被加到這個Sprite底下，否則沒辦法讀取到world所送來的時間訊息
        //這樣就沒辦法使用updateschedule了
        [self addChild:[ItemAdder ItemAdderWithWorld:world andSprite:self] z:2];
        
        

        [self addChild:[user_boardAdder user_boardAdderWithWorld:world andSprite:self] z:2];
        [user_boardAdder adduser_boardFromOutside:user_board_type_player andSpecialBoardType:specialBoardTypeNormal];
        [user_boardAdder adduser_boardFromOutside:user_board_type_enemy andSpecialBoardType:specialBoardTypeNormal];



        
        
    }
	
	return self;
}

-(void)accelerationInput:(UIAcceleration*)accelerationInput
{
    NSLog(@"Input是:%f",accelerationInput.x);
}


+(id) setupTableWithWorld:(b2World*)world
{
	return [[self alloc] initTableWithWorld:world];
}


@end
