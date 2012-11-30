//
//  HelloWorldLayer.mm
//  cocos2d-2.x-Box2D-ARC-iOS
//
//  Created by Steffen Itterheim on 18.05.12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//

#import "HockeyTableLayer.h"
#import "BodySprite.h"
#import "Constants.h"
#import "Helper.h"
#import "GB2ShapeCache.h"
#import "TableSetup.h"
#import "MagicRuler.h"
#import "SimpleAudioEngine.h"
#import "ScoreBoard.h"
#import "ItemAdder.h"
#import "GravityCenter.h"
#import "ParticleEffectAdder.h"

@implementation HockeyTableLayer


//讓其他人拿的到這個layer
static HockeyTableLayer* sharedHockeyTableLayer = nil;
static b2World* sharedHockeyTableLayerWorld=nil;
+(HockeyTableLayer*) sharedLayer
{
	NSAssert(sharedHockeyTableLayer != nil, @"MultiLayerScene not available!");
	return sharedHockeyTableLayer;
}

+(b2World*) sharedWorld
{

	return sharedHockeyTableLayerWorld;
}

+(CCScene*) scene
{
	CCScene* scene = [CCScene node];
	HockeyTableLayer* layer = [HockeyTableLayer node];
	[scene addChild:layer];
	return scene;
}




-(id) init
{
    if ((self = [super init]))
    {
        sharedHockeyTableLayer=self;
        sharedHockeyTableLayerWorld=world;
        //這邊都是先preload，之後就不會lag了，連聲音也是
        
		[[SimpleAudioEngine sharedEngine] preloadEffect:@"ballHit.wav"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"ballHit2.wav"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"dropIn.wav"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"getIn.wav"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"hitSide.wav"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"itemTouched.wav"];

//        [[SimpleAudioEngine sharedEngine] preloadBackgroundMusic:@"MBAABasillica.mp3"];
//        [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"MBAABasillica.mp3"];
        // pre load the sprite frames from the texture atlas
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"texture.plist"];


        // load physics definitions
        //把shape的檔案讀進來，並且把所有的骨架都塞好
        [[GB2ShapeCache sharedShapeCache] addShapesWithFile:@"texture-shapes.plist"];
        
        
        
        CCSprite *spback = [(CCSprite*)[CCSprite alloc] init];
        [self addChild:spback z:-3];
        //背景
        CCSprite *sp = [CCSprite spriteWithSpriteFrameName:@"pureBackground"];
        sp.position = ccp(0, 0);
        sp.anchorPoint=ccp(0,0);
        [spback addChild:sp z:-1];
        
        
        [GravityCenter GravityCenterWith:spback];
        [ScoreBoard ScoreBoardWith:spback];
        [MagicRuler MagicRulerWith:spback];
        
        CCSprite *spfront = [(CCSprite*)[CCSprite alloc] init];
        [self addChild:spfront z:3];
        [spfront addChild:[ParticleEffectAdder ParticleEffectAdderWith:world andSprite:spfront]];
        //這邊我試很久，為什麼要加成spfront的child呢？像上面的GravityCenter等三個，基本上只是在spback這個sprite上面貼東西，
        //這樣就沒辦法自己造scheduler來用了，因為他沒辦法拿到world的資訊，所以ParticleEffectAdder也還是要加到spfront下
        //至於傳給他的andSprite:spfront，就是給他自己貼特效上去用的
        
        self.isAccelerometerEnabled = YES;
        [[UIAccelerometer sharedAccelerometer] setUpdateInterval:2/3];
        

		
        
        // init the box2d world
        [self initPhysics];
        
//        mouseListener= [MouseListener initWithWorld:world];
		
        
        // Set up table elements
        TableSetup* tableSetup = [TableSetup setupTableWithWorld:world];
        sharedTableSetup=tableSetup;
        [self addChild:tableSetup z:-1];
        
        [self scheduleUpdate];
    }
    return self;
}

-(void) dealloc
{
	delete world;
	world = NULL;
	delete debugDraw;
	debugDraw = NULL;
	delete contactListener;
	contactListener = NULL;
    mouseListener=NULL;
	sharedHockeyTableLayer = nil;

}

-(void) initPhysics
{
	b2Vec2 gravity;
	gravity.Set(0.0f, 0.0f);
    //全域的b2 world
	world = new b2World(gravity);
	world->SetAllowSleeping(true);

	world->SetContinuousPhysics(true);
	
    
	contactListener = new ContactListener();
	world->SetContactListener(contactListener);
    

    
	
	debugDraw = new GLESDebugDraw(PTM_RATIO);
	world->SetDebugDraw(debugDraw);
	
    
    
	uint32 flags = 0;
	flags += b2Draw::e_shapeBit;
	flags += b2Draw::e_jointBit;
    flags += b2Draw::e_aabbBit;
    flags += b2Draw::e_pairBit;
    flags += b2Draw::e_centerOfMassBit;
	
    //這行是決定要不要出debug的邊緣
    debugDraw->SetFlags(flags);
	
	// Define the ground body.
	b2BodyDef groundBodyDef;
	
	// Call the body factory which allocates memory for the ground body
	// from a pool and creates the ground box shape (also from a pool).
	// The body is also added to the world.
	b2Body* groundBody = world->CreateBody(&groundBodyDef);
	
	// Define the ground box shape.
	CGSize screenSize = [CCDirector sharedDirector].winSize;
	float boxWidth = screenSize.width / PTM_RATIO;
	float boxHeight = screenSize.height / PTM_RATIO;
	b2EdgeShape groundBox;
	int density = 0;

    //把左右包起來
	// left
	groundBox.Set(b2Vec2(0, boxHeight), b2Vec2(0, 0));
	b2Fixture* left = groundBody->CreateFixture(&groundBox, density);
	// right
	groundBox.Set(b2Vec2(boxWidth, boxHeight), b2Vec2(boxWidth, 0));
	b2Fixture* right = groundBody->CreateFixture(&groundBox, density);
	
    
	// set the collision flags: category and mask
    b2Filter collisonFilter;
    collisonFilter.groupIndex = 0;
    collisonFilter.categoryBits = 0x0010; // category = Wall
    collisonFilter.maskBits = 0x0001;     // mask = Ball
	
    left->SetFilterData(collisonFilter);
    right->SetFilterData(collisonFilter);
}

#if DEBUG
-(void) draw
{
	[super draw];
	
	ccGLEnableVertexAttribs(kCCVertexAttribFlag_Position);
	kmGLPushMatrix();
	world->DrawDebugData();	
	kmGLPopMatrix();
}
#endif

-(void) createBodyFixture:(b2Body*)body
{
	// Define another box shape for our dynamic body.
	b2PolygonShape dynamicBox;
	dynamicBox.SetAsBox(0.5f, 0.5f);
	
	// Define the dynamic body fixture.
	b2FixtureDef fixtureDef;
	fixtureDef.shape = &dynamicBox;
	fixtureDef.density = 1.0f;
	fixtureDef.friction = 0.3f;
	body->CreateFixture(&fixtureDef);
}

-(void) addNewSpriteAtPosition:(CGPoint)pos
{
	// Define the dynamic body.
	//Set up a 1m squared box in the physics world
	b2BodyDef bodyDef;
	bodyDef.type = b2_dynamicBody;
	bodyDef.position = [Helper toMeters:pos];
	b2Body* body = world->CreateBody(&bodyDef);

	[self createBodyFixture:body];

	/*
	PhysicsSprite* sprite = [self createPhysicsSpriteAt:pos];
	[sprite setPhysicsBody:body];
	body->SetUserData((__bridge void*)sprite);
	 */
}

-(void) update:(ccTime)delta
{
	//It is recommended that a fixed time step is used with Box2D for stability
	//of the simulation, however, we are using a variable time step here.
	//You need to make an informed choice, the following URL is useful
	//http://gafferongames.com/game-physics/fix-your-timestep/
	
	int32 velocityIterations = 8;
	int32 positionIterations = 1;
	
	// Instruct the world to perform a single step of simulation. It is
	// generally best to keep the time step and iterations fixed.
	world->Step(delta, velocityIterations, positionIterations);	
}


//只有layer這層接的到加速度，所以就只能用selector把值傳給下面要用的人
-(void) accelerometer:(UIAccelerometer *)accelerometer
        didAccelerate:(UIAcceleration *)acceleration
{
    
    [GravityCenter centerChangeFromOutside:acceleration.x andY:acceleration.y andZ:acceleration.z];
    
    b2Vec2 gravity( acceleration.x * 20,acceleration.y*20);
    
    world->SetGravity( gravity );
    
}


-(void) ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	//Add a new body/atlas sprite at the touched location
	for (UITouch* touch in touches)
	{
		CGPoint location = [touch locationInView:touch.view];
		location = [[CCDirector sharedDirector] convertToGL:location];
		[self addNewSpriteAtPosition:location];
	}
}

@end
