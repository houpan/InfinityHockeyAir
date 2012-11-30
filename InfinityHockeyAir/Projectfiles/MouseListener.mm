//
//  MouseListener.mm
//  PhysicsBox2d
//
//  Created by Steffen Itterheim on 20.09.10.
//  Copyright 2010 Steffen Itterheim. All rights reserved.
//

#import "MouseListener.h"
#import "SimpleAudioEngine.h"
#import "ContactListener.h"
#import "HockeyTableLayer.h"

class QueryCallback : public b2QueryCallback
{
public:
    QueryCallback(const b2Vec2& point)
    {
        m_point = point;
        m_object = nil;
    }
    
    bool ReportFixture(b2Fixture* fixture)
    {
        if (fixture->IsSensor()) return true; //ignore sensors
        
        bool inside = fixture->TestPoint(m_point);
        if (inside)
        {
            // We are done, terminate the query.
            m_object = fixture->GetBody();
            return false;
        }
        
        // Continue the query.
        return true;
    }
    
    b2Vec2  m_point;
    b2Body* m_object;
};

//    b2World *temp_world;

@implementation MouseListener
-(id) initWithWorld:(b2World*)world
{
	if ((self = [super initWithShape:@"ball" inWorld:world]))
	{
        // set the parameters
        physicsBody->SetType(b2_dynamicBody);
        //控制讓他比較不容易旋轉
        physicsBody->SetAngularDamping(0.9f);

        // set random starting point
        [self setMouseListenerStartPosition];


        //temp_world=world;
        
        // enable handling touches
		[[CCDirector sharedDirector].touchDispatcher addTargetedDelegate:self priority:3 swallowsTouches:NO];

        // schedule updates
		[self scheduleUpdate];
	}
	return self;
}






+(id) mouseListenerWithWorld:(b2World*)world
{
	return [[self alloc] initWithWorld:world];
}

-(void) cleanup
{
	[super cleanup];
	[[CCDirector sharedDirector].touchDispatcher removeDelegate:self];
}

-(void) setMouseListenerStartPosition
{
    // set the MouseListener's position
//    float randomOffset = CCRANDOM_0_1() * 10.0f - 5.0f;
    CGPoint startPos = CGPointMake(-1000, -1000);
    
    physicsBody->SetTransform([Helper toMeters:startPos], 0.0f);
    physicsBody->SetLinearVelocity(b2Vec2_zero);
    physicsBody->SetAngularVelocity(0.0f);
}

-(void) applyForceTowardsFinger
{
	b2Vec2 bodyPos = physicsBody->GetWorldCenter();
	b2Vec2 fingerPos = [Helper toMeters:fingerLocation];
	
	b2Vec2 bodyToFingerDirection = fingerPos - bodyPos;
	bodyToFingerDirection.Normalize();
	
	b2Vec2 force = 50.0f * bodyToFingerDirection;
	
	// "Real" gravity falls off by the square over distance. Uncomment this code to see the effect:
	
//	float distance = bodyToFingerDirection.Length();
//	bodyToFingerDirection.Normalize();
//	float distanceSquared = distance * distance;
//	force = ((1.0f / distanceSquared) * 20.0f) * bodyToFingerDirection;
	
	
	physicsBody->ApplyForce(force, physicsBody->GetWorldCenter());
}

-(void) update:(ccTime)delta
{
	if (moveToFinger == YES)
	{
		[self applyForceTowardsFinger];
	}
	
	//CCLOG(@"posY = %.1f", self.position.y);
	if (self.position.y < -(self.contentSize.height * 10))
	{
		// restart at a random position
		[self setMouseListenerStartPosition];
	}

    // limit speed of the MouseListener
    const float32 maxSpeed = 50.0f;
    b2Vec2 velocity = physicsBody->GetLinearVelocity();
    float32 speed = velocity.Length();
    if (speed > maxSpeed)
    {
		velocity.Normalize();
		physicsBody->SetLinearVelocity(maxSpeed * velocity);
		//CCLOG(@"reset speed %f to %f", speed, (maxSpeed * velocity).Length());
    }

    // reset rotation of the MouseListener to keep
    // highlight and shadow in the same place
    physicsBody->SetTransform(physicsBody->GetWorldCenter(), 0.0f);
}

-(void) mousePressedMouseListener:(id)null{
    NSLog(@"球被按到");
    [self playSound];
}


-(BOOL) ccTouchBegan:(NSSet *)touches withEvent:(UIEvent *)event;
{
    
    //不知道為什麼從touches拔東西出來就是拔不到，所以從event硬拿
    NSSet *allTouches = [event allTouches];

    //檢查這個地方有沒有這個物體存在
    int i=0;
    for (UITouch* touch in allTouches)
	{
         NSLog(@"檢查");   
        i++;
        b2Vec2 pos = [Helper toMeters:[Helper locationFromTouch:touch]];
        // Make a small box.
        b2AABB aabb;
        b2Vec2 d;
        d.Set(0.001f, 0.001f);
        aabb.lowerBound = pos - d;
        aabb.upperBound = pos + d;
        
        // Query the world for overlapping shapes.
        QueryCallback callback(pos);

        [HockeyTableLayer sharedWorld]->QueryAABB(&callback, aabb);
        
        b2Body *body = callback.m_object;
        if (body)
        {
            
            NSObject* selectedObj = (__bridge NSObject*)body->GetUserData();
            NSString* otherClassName = NSStringFromClass([selectedObj class]);
            NSString* format = @"mousePressed%@:";//用reflection選出哪個物體是被press到的
            NSString* selectorString = [NSString stringWithFormat:format, otherClassName];
            SEL selector_mouseSelected = NSSelectorFromString(selectorString);
            
            if ([selectedObj respondsToSelector:selector_mouseSelected])
            {
                //其實是不用傳值，但是函數規定要傳值所以還是寫一下
                id idNull=nil;
                [selectedObj performSelector:selector_mouseSelected withObject:idNull];
            }
            //pick the body
            
        }
    }
    
}

-(void)ccTouchMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    
    NSLog(@"移動~");
    NSSet *allTouches = [event allTouches];
    //檢查這個地方有沒有這個物體存在
    int i=0;
    for (UITouch* touch in allTouches)
	{
        NSLog(@"移動!:%d",i);
        i=i+1;
    }
}

-(void)ccTouchEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    NSLog(@"停止~");
    NSSet *allTouches = [event allTouches];
    //檢查這個地方有沒有這個物體存在
    int i=0;
    for (UITouch* touch in allTouches)
	{
        NSLog(@"結束移動:%d",i);
        i=i+1;
    }
}


-(void) playSound
{
	float pitch = 0.9f + CCRANDOM_0_1() * 0.2f;
	float gain = 1.0f + CCRANDOM_0_1() * 0.3f;
	[[SimpleAudioEngine sharedEngine] playEffect:@"bumper.wav" pitch:pitch pan:0.0f gain:gain];
}

-(void) endContactWithBumper:(Contact*)contact
{
	[self playSound];
}

-(void) endContactWithPlunger:(Contact*)contact
{
	[self playSound];
}

@end
