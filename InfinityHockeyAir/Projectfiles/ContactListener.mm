/*
 *  ContactListener.mm
 *  PhysicsBox2d
 *
 *  Created by Steffen Itterheim on 17.09.10.
 *  Copyright 2010 Steffen Itterheim. All rights reserved.
 *
 */

#import "ContactListener.h"

@implementation Contact
-(id) initWithObject:(NSObject*)otherObject_
		otherFixture:(b2Fixture*)otherFixture_
		  ownFixture:(b2Fixture*)ownFixture_
            b2Contact:(b2Contact*)b2contact_
        contactPoint:(CGPoint)relativeContactPoint_
{
	self = [super init];
    if (self)
    {
        otherObject = otherObject_;
        otherFixture = otherFixture_;
        ownFixture = ownFixture_;
        b2contact = b2contact_;
        relativeContactPoint=relativeContactPoint_;
    }
    return self;
}

-(NSObject *)getObjectB
{
    return otherObject;
};

-(CGPoint)getrelativeConatactPoint
{
    return relativeContactPoint;
};

-(CGPoint)getContactPosistion
{
    b2WorldManifold worldManifold;
    b2contact->GetWorldManifold(&worldManifold);
    
    //now you can use these properties for whatever you need
//    worldManifold.normal //b2Vec2
    if(worldManifold.points[0].x!=0&&worldManifold.points[0].y!=0)
    {
        b2Vec2 ya2=worldManifold.points[0];
        CGPoint ya=[Helper toPixels:ya2];
        NSLog(@"fuck");
        return ya;
    }
//
//    
//    b2WorldManifold *worldManifold;
//    b2contact->GetWorldManifold(&worldManifold);
//    b2ManifoldPoint tempManifoldPoint= worldManifold->points[0];
//    b2Vec2 b2temp=tempManifoldPoint.localPoint;
//    return 
    


};

@end

// notify the listener
void ContactListener::notifyAB(b2Contact* contact, 
							   NSString* contactType, 
							   b2Fixture* fixture,
							   NSObject* obj, 
							   b2Fixture* otherFixture, 
							   NSObject* otherObj)
{
	NSString* format = @"%@ContactWith%@:";//用reflection選出可以執行的contactListener，
                                            //e.g. Plugger的beginContactWithBall, Ball就是plunger撞到的另外一個物體。
	NSString* otherClassName = NSStringFromClass([otherObj class]);
	NSString* selectorString = [NSString stringWithFormat:format, contactType, otherClassName];
	//CCLOG(@"notifyAB selector: %@", selectorString);
    //看能不能找到這樣的function（以selectorString為名），可以的話就執行他
    SEL contactSelector = NSSelectorFromString(selectorString);

    float fixtureRadius= fixture->GetShape()->m_radius*PTM_RATIO;

    b2Vec2 objectPosition= fixture->GetBody()->GetPosition();
    b2Vec2 otherObjectPosition = otherFixture->GetBody()->GetPosition();;
    
    
    float otherFixtureRadius;
    if(otherFixture->GetType()==b2Shape::e_polygon){//碰到矩型，大概就是邊邊角角的狀況
        //用來解決矩型的邊跟球碰撞時的position不是在碰撞點
        if(objectPosition.x>43||objectPosition.x<5){//x差距比較小，代表是碰到左右邊
            otherObjectPosition.y=objectPosition.y;
        }else{
            otherObjectPosition.x=objectPosition.x;
        }
            otherFixtureRadius= otherFixture->GetShape()->m_radius*PTM_RATIO;
    }else{//碰到球
        otherFixtureRadius= otherFixture->GetShape()->m_radius*PTM_RATIO;

    }



    CGPoint vectorSubstracted= [Helper subtract:[Helper toPixels:otherObjectPosition] of:[Helper toPixels:objectPosition]];
    CGPoint vectorSubstractedNormalization= [Helper normalization:vectorSubstracted];
    CGPoint vectorMultiplied=[Helper multiply:vectorSubstractedNormalization by:fixtureRadius];

    
//    -(void) beginContactWithBall:(Contact*)contact
    
    //去查查看被撞的物體有沒有什麼話想說(有沒有這個function)
    if ([obj respondsToSelector:contactSelector])
    {
//		CCLOG(@"notifyAB performs selector: %@", selectorString);
		//完整包裝contact物件
        Contact* contactInfo = [[Contact alloc] initWithObject:otherObj
												  otherFixture:otherFixture
													ownFixture:fixture
													 b2Contact:contact
                                                  contactPoint:vectorMultiplied];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        
        //再把內容給選到的function
        [obj performSelector:contactSelector withObject:contactInfo];
#pragma clang diagnostic pop
		contactInfo = nil;
    }
}

void ContactListener::notifyObjects(b2Contact* contact, NSString* contactType)
{
    //由於是兩個力交互作用，所以雙方都要通知，還要告訴他們是什麼類型
    b2Fixture* fixtureA = contact->GetFixtureA();
    b2Fixture* fixtureB = contact->GetFixtureB();
    b2Body* bodyA = fixtureA->GetBody();
    b2Body* bodyB = fixtureB->GetBody();
	
    
    

    
    //now you can use these properties for whatever you need
//    worldManifold.normal; //b2Vec2
//    worldManifold.points[1]; //b2Vec2[2]
//
//    b2ManifoldPoint tempManifoldPoint= worldManifold->points[0];
//    b2Vec2 b2temp=tempManifoldPoint.localPoint;
//    CGPoint yeah=[Helper toPixels:b2temp];
//    NSLog(@"%f,%f",yeah.x,yeah.y);
//    
    NSObject* objA = (__bridge NSObject*)bodyA->GetUserData();
    NSObject* objB = (__bridge NSObject*)bodyB->GetUserData();
	
    if ((objA != nil) && (objB != nil))
    {
        notifyAB(contact, contactType, fixtureA, objA, fixtureB, objB);
        notifyAB(contact, contactType, fixtureB, objB, fixtureA, objA);
    }
}

/// Called when two fixtures begin to touch.
void ContactListener::BeginContact(b2Contact* contact)
{
//    NSLog(@"開始");
    notifyObjects(contact, @"begin");
}

/// Called when two fixtures cease to touch.
void ContactListener::EndContact(b2Contact* contact)
{
//    NSLog(@"結束");
    notifyObjects(contact, @"end");
}

void ContactListener::PreSolve(b2Contact* contact, const b2Manifold* oldManifold)
{
	// do nothing (yet)
}

void ContactListener::PostSolve(b2Contact* contact, const b2ContactImpulse* impulse)
{
	// do nothing (yet)
}
