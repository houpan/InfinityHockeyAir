//
//  user_board.mm
//  PhysicsBox2d
//
//  Created by Steffen Itterheim on 20.09.10.
//  Copyright 2010 Steffen Itterheim. All rights reserved.
//

#import "GravityCenter.h"
#import "HockeyTableLayer.h"
#import "Constants.h"
#import "ItemAdder.h"
#import "BallAdder.h"


static GravityCenter* sharedGravityCenterInstance=nil;
@implementation GravityCenter




-(id) initWithSpriteU:(CCSprite*)spriteInput
{
    
    CGSize screenSize = [CCDirector sharedDirector].winSize;
    
    sharedSprite=spriteInput;
    
    //水平線
    horiziontalLine = [CCSprite spriteWithSpriteFrameName:@"gravityCenter"];
    horiziontalLine.position = ccp(screenSize.width/2, screenSize.height/2);
    horiziontalLine.anchorPoint=ccp(0.5f,0.5f);
    [sharedSprite addChild:horiziontalLine z:0 tag:gravityLineTypeHorizontal];
    
    
    //垂直線
    verticalLine = [CCSprite spriteWithSpriteFrameName:@"gravityCenter"];
    verticalLine.position = ccp(screenSize.width/2, screenSize.height/2);
    verticalLine.rotation=90;
    verticalLine.anchorPoint=ccp(0.5f,0.5f);
    [sharedSprite addChild:verticalLine z:0 tag:gravityLineTypeVertical];
    
    
    previousX=0;
    previousY=0;
    
    sharedGravityCenterInstance=self;
    
    return self;
}
//傳進來的時候不能access變數，所以要另外再init一次
+(id) GravityCenterWith:(CCSprite*)spriteInput
{
	return [[self alloc] initWithSpriteU:spriteInput];
}

+(GravityCenter*) sharedGravityCenter
{
    return sharedGravityCenterInstance;
}



+(void) centerChangeFromOutside:(float)xIn andY:(float)yIn andZ:(float)zIn
{
    [sharedGravityCenterInstance centerChange:xIn andY:yIn  andZ:zIn];
}


-(void) centerChange:(float)xIn andY:(float)yIn  andZ:(float)zIn
{
    
    CGSize screenSize = [CCDirector sharedDirector].winSize;
    
    if(zIn>0){//強烈shock
        CCLOG(@"陣到了！");
        [BallAdder ballFaster:fasterTypeShock];
    }
    if(fabsf(xIn-previousX)>0.05){
//        NSLog(@"近來ㄌ");
        CCMoveTo* horizontalMoveO = [CCMoveTo actionWithDuration:0.8 position:ccp((1+xIn)*screenSize.width/2, screenSize.height/2)];
        [horiziontalLine runAction:horizontalMoveO];
        previousX=xIn;

    }

    if(fabsf(yIn-previousY)>0.05){
//        NSLog(@"近來ㄌ2");
        CCMoveTo* verticalMoveO = [CCMoveTo actionWithDuration:0.8 position:ccp(screenSize.width/2,(1+yIn)*screenSize.height/2)];
        [verticalLine runAction:verticalMoveO];
        previousY=yIn;
    }

}
@end