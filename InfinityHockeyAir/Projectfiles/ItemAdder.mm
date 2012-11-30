//
//  user_board.mm
//  PhysicsBox2d
//
//  Created by Steffen Itterheim on 20.09.10.
//  Copyright 2010 Steffen Itterheim. All rights reserved.
//

#import "ItemAdder.h"
#import "HockeyTableLayer.h"
#import "Constants.h"
#import "BallAdder.h"
#import <Foundation/Foundation.h>
#import "user_boardAdder.h"
#import "TablePartAdder.h"


static ItemAdder* sharedItemAdderInstance=nil;
@implementation ItemAdder





-(id) initWithWorld:(b2World*)worldInput andSprite:(CCSpriteBatchNode*)spriteInput
{
    if ((self = [super initWithShape:@"nothing" inWorld:worldInput])){
        sharedWorld=worldInput;
        sharedSprite=spriteInput;
        sharedItemAdderInstance=self;
        toCheck=NO;
        arrayOfItem=[[NSMutableArray alloc] init];
        itemToKill=[[NSMutableArray alloc] init];//如果一個array沒有經過初始化程序，裡面是沒辦法儲存東西的...
        [self schedule: @selector(checkActivateItem:) interval:0.05 ];
        [self schedule: @selector(addEnvironmentalItemPeriodically:) interval:7 ];
        thunderSprite=[CCSprite spriteWithSpriteFrameName:@"pureBackground"];
        thunderSprite.position = ccp(0, 0);
        thunderSprite.color=ccBLACK;
        thunderSprite.anchorPoint=ccp(0.0,0.0);

        [self schedule: @selector(itemKiller:) interval:0.2 ];
        
    }
    return self;
}

-(void)itemKiller:(ccTime)delta
{   
    int length=[itemToKill count];
//    NSLog(@"長度:%d",length);
    if(length!=0){
        int i;
        NSLog(@"來摟");
        for(i=0;i<length;i++){
            Items *temp=[itemToKill objectAtIndex:i];
            [arrayOfItem removeObject:temp];
            [sharedSprite removeChild:temp cleanup:YES];
        }
        for (i=0; i<length; i++) {
            [itemToKill removeObjectAtIndex:0];
        }
    }
}



+(id) ItemAdderWithWorld:(b2World*)world andSprite:(CCSpriteBatchNode*)spriteInput
{
	return [[self alloc] initWithWorld:world andSprite:spriteInput];
}
-(void) addEnvironmentalItemPeriodically:(ccTime)delta
{
//    [self addItem:user_board_type_nobody andType:environmentalRandom];

    [self addItem:user_board_type_player andType:itemBoardBigger];
//    [self addItem:user_board_type_player andType:itemBallSmaller];

}

-(void) thunderTTL:(ccTime)delta
{
    if(thunderTTL>0){
        thunderTTL--;
    }else{
        if([sharedSprite getChildByTag:999])
        {
            [sharedSprite removeChildByTag:999 cleanup:YES];
        }
        CCLOG(@"結束一切");
        [self unschedule:@selector(thunderComes:) ];
        [self unschedule:@selector(thunderTTL:)];
    }
}

-(void) thunderComes:(ccTime)delta
{
    if(![sharedSprite getChildByTag:999])
    {
        CCLOG(@"近來");
        [sharedSprite addChild:thunderSprite z:5 tag:999];
    }
    if(CCRANDOM_MINUS1_1()>0)
    {
                CCLOG(@"近來2");
        [sharedSprite removeChildByTag:999 cleanup:YES];
    }
    


}

//這個功能只有CCNode可以用，所以不要宣告成NSObject
-(void) checkActivateItem:(ccTime)delta
{

//    NSLog(@"check once");
    for(Items* fetchedItem in arrayOfItem){
//            NSLog(@"TTL=%d",[fetchedItem getTTL]);
        if([fetchedItem getTTL]<=0&&[itemToKill indexOfObject:fetchedItem]==NSNotFound){
//            NSLog(@"++");
            [itemToKill addObject:fetchedItem];
        }
    }
    
    if(toCheck){
        switch (typeInputToCheck) {
            case itemBallFaster:
                [BallAdder ballFaster:fasterTypeItem];
                break;
            case itemBallSmaller:
                [BallAdder ballSpecial:ballTypeSmall];
                break;
            case itemBallSucked:
                [BallAdder ballSucked:ownerToCheck];
                break;
            case itemBoardBigger:
                [user_boardAdder boardBiggerSmaller:ownerToCheck andSpecialBoardType:specialBoardTypeBigger];
                break;
            case itemBoardSmaller:
                [user_boardAdder boardBiggerSmaller:ownerToCheck andSpecialBoardType:specialBoardTypeSmaller];
                break;
            case itemFireBall:
                [BallAdder ballSpecial:ballTypeFire];
                break;
            case itemFreezeBoard:
                [user_boardAdder boardBiggerSmaller:ownerToCheck andSpecialBoardType:specialBoardTypeFreezed];
                break;
            case itemSplit2:
                [BallAdder ballMultiply:1];
                break;
            case itemSplit10:
                [BallAdder ballMultiply:9];
                break;
            case itemTableDissapear:
                [TablePartAdder specializeTablePart:SpecialTablePartsTypeDissapear andCaller:ownerToCheck];
                break;
            case itemTableSmaller:
                [TablePartAdder specializeTablePart:SpecialTablePartsTypeSmaller andCaller:ownerToCheck];
                break;
            case itemTableWider:
                [TablePartAdder specializeTablePart:SpecialTablePartsTypeWider andCaller:ownerToCheck];
                break;
            case itemThunder:
                thunderTTL=3;
                [self schedule:@selector(thunderTTL:) interval:1];
                [self schedule:@selector(thunderComes:) interval:0.3];
                break;
        }
    }
    toCheck=NO;
    
}



//update函數一定要:(ccTime)delta，不然會錯

-(void) cleanup
{
    [super cleanup];
     [self unscheduleAllSelectors];
}


+(void) addItemFromOutside:(user_board_type)owner andType:(ItemType)typeInput
{
    [sharedItemAdderInstance addItem:owner andType:typeInput];
}

-(void) addItem:(user_board_type)owner andType:(ItemType)typeInput
{
    Items* newItem=[Items ItemsWithWorld:sharedWorld andCaller:owner andNumber:typeInput];
    [sharedSprite addChild:newItem z:1];
    [arrayOfItem addObject:newItem];
}

+(void) activateItem:(user_board_type)owner andType:(ItemType)typeInput{
    [sharedItemAdderInstance activateItemI:owner andType:typeInput];
}

//統籌分配
-(void) activateItemI:(user_board_type)owner andType:(ItemType)typeInput
{
    //要用update的原因是，cocos2d不允許在callbackFunction(像是contact listener)裡面呼叫創造physics body
    ownerToCheck=owner;
    typeInputToCheck=typeInput;
    toCheck=YES;
}


@end