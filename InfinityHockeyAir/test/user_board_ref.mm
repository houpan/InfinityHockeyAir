//
//  Flipper.mm
//  PhysicsBox2d
//
//  Created by Steffen Itterheim on 22.09.10.
//  Copyright 2010 Steffen Itterheim. All rights reserved.
//

#import "user_board.h"

@implementation user_board

-(id) initWithWorld:(b2World*)world user_board_which:(user_board_which)user_board_type
{
    
    
    self = [super initWithShape:@"user_board" inWorld:world];
	
	if (self)
	{
        //看傳進來的是玩家自己的還是敵人的板子
		type = user_board_type;
		
        // set the position depending on the left or right side
		CGPoint flipperPos = (type == user_board_player) ? ccp(500, 400) : ccp(0, 500);

		// attach the flipper to a static body with a revolute joint, so it can move up/down
		[self attachFlipperAt:[Helper toMeters:flipperPos]];

        // listen to touches
//		[[CCDirector sharedDirector].touchDispatcher addTargetedDelegate:self priority:0 swallowsTouches:NO];
	}
	return self;
}

+(id) user_boardWithWorld:(b2World*)world user_board_which:(user_board_which)user_board_which
{
	return [[self alloc] initWithWorld:world user_board_which:user_board_which];
}

-(void) cleanup
{
	[super cleanup];
	
    // stop listening to touches
	[[CCDirector sharedDirector].touchDispatcher removeDelegate:self];
}

-(void) attachFlipperAt:(b2Vec2)pos
{
    physicsBody->SetTransform(pos, 0);
    physicsBody->SetType(b2_dynamicBody);

    // the flippers move fast - in some cases
    // if the ball also moves fast it sometimes happens
    // that the flippers skip the ball
    // to avoid this we use continuous collision detection
    //用這個就可以擋掉穿透現象
    physicsBody->SetBullet(true);

	// create an invisible static body to attach to‘
	b2BodyDef bodyDef;
	bodyDef.position = pos;
	b2Body* staticBody = physicsBody->GetWorld()->CreateBody(&bodyDef);

    // setup joint parameters
	b2RevoluteJointDef jointDef;
	jointDef.Initialize(staticBody, physicsBody, staticBody->GetWorldCenter());
	jointDef.lowerAngle = 0.0f;
	jointDef.upperAngle = CC_DEGREES_TO_RADIANS(70);
	jointDef.enableLimit = true;
	jointDef.maxMotorTorque = 100.0f;
	jointDef.motorSpeed = -40.0f;
	jointDef.enableMotor = true;

    
    // create the joint
	joint = (b2RevoluteJoint*)physicsBody->GetWorld()->CreateJoint(&jointDef);
}

-(void) reverseMotor
{
    //把馬達轉反向

	joint->SetMotorSpeed(joint->GetMotorSpeed() * -1);
}
//
//-(bool) isTouchForMe:(CGPoint)location
//{
//	if ((type == kFlipperLeft) && (location.x < [Helper screenCenter].x))
//	{
//		return YES;
//	}
//	else if ((type == kFlipperRight) && (location.x > [Helper screenCenter].x))
//	{
//		return YES;
//	}
//	
//	return NO;
//}
//
//-(BOOL) ccTouchBegan:(UITouch*)touch withEvent:(UIEvent*)event
//{
//	BOOL touchHandled = NO;
//	
//	CGPoint location = [Helper locationFromTouch:touch];
//	if ([self isTouchForMe:location])
//	{
//		touchHandled = YES;
//		[self reverseMotor];
//	}
//	
//	return touchHandled;
//}
//
//-(void) ccTouchEnded:(UITouch*)touch withEvent:(UIEvent*)event
//{
//	CGPoint location = [Helper locationFromTouch:touch];
//	if ([self isTouchForMe:location])
//	{
//		[self reverseMotor];
//	}
//}
//
@end
