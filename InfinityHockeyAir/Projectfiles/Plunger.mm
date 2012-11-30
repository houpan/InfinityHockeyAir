//
//  Plunger.m
//  PhysicsBox2d
//
//  Created by Steffen Itterheim on 25.09.10.
//  Copyright 2010 Steffen Itterheim. All rights reserved.
//

#import "Plunger.h"
#import "ContactListener.h"

@implementation Plunger

-(id) initWithWorld:(b2World*)world
{
	if ((self = [super initWithShape:@"plunger" inWorld:world]))
	{
		CGSize screenSize = [CCDirector sharedDirector].winSize;
		CGPoint plungerPos = CGPointMake(screenSize.width - 13, -32);
		
		physicsBody->SetTransform([Helper toMeters:plungerPos], 0);
        physicsBody->SetType(b2_dynamicBody);

		[self attachPlunger];
	}
	return self;
}

+(id) plungerWithWorld:(b2World*)world
{
	return [[self alloc] initWithWorld:world];
}

-(void) attachPlunger
{
	// create an invisible static body to attach joint to
	b2BodyDef bodyDef;
	bodyDef.position = physicsBody->GetWorldCenter();
	b2Body* staticBody = physicsBody->GetWorld()->CreateBody(&bodyDef);
	
	// Create a prismatic joint to make plunger go up/down
    //把發射器擋住
	b2PrismaticJointDef jointDef;
    //發射器的軸向(現在是垂直)
	b2Vec2 worldAxis(0.0f, 1.0f);
	jointDef.Initialize(staticBody, physicsBody, physicsBody->GetWorldCenter(), worldAxis);
	jointDef.lowerTranslation = 0.0f;
    //活塞可向上移動0.35米，一米=32像素
	jointDef.upperTranslation = 0.35f;
	jointDef.enableLimit = true;
    //最高能到達的速度
	jointDef.maxMotorForce = 1000.0f;
    //推動的加速度
	jointDef.motorSpeed = 100.0f;
    //這個為true他就會開始動作
	jointDef.enableMotor = false;
	
	joint = (b2PrismaticJoint*)physicsBody->GetWorld()->CreateJoint(&jointDef);
}
 
-(void) endPlunge:(ccTime)delta
{
    // stop the motor
	joint->EnableMotor(NO);
}

-(void) beginContactWithBall:(Contact*)contact
{
    // start the motor
    joint->EnableMotor(YES);

    // schedule motor to come back, unschedule in case the plunger is hit repeatedly within a short time
    //隔0.5秒就把活塞再關掉
    [self scheduleOnce:@selector(endPlunge:) delay:0.5f];
}

@end
