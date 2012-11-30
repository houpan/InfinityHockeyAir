//
//  user_board.mm
//  PhysicsBox2d
//
//  Created by Steffen Itterheim on 20.09.10.
//  Copyright 2010 Steffen Itterheim. All rights reserved.
//

#import "TablePartAdder.h"
#import "HockeyTableLayer.h"
#import "Constants.h"
#import "BallAdder.h"
#import <Foundation/Foundation.h>
#import "user_boardAdder.h"
#import "ParticleEffectAdder.h"


static TablePartAdder* sharedTablePartAdderInstance=nil;
@implementation TablePartAdder





-(id) initWithWorld:(b2World*)worldInput andSprite:(CCSpriteBatchNode*)spriteInput
{
    if ((self = [super initWithShape:@"nothing" inWorld:worldInput])){
        sharedWorld=worldInput;
        sharedSprite=spriteInput;
        sharedTablePartAdderInstance=self;
        toCheck=NO;
        arrayOfTablePart=[[NSMutableArray alloc] init];
        //直接在裡面順便初始化了，反正都是知道的東西


        waitingForDelay=NO;
        delay_toModifyTablePartsType=[[NSMutableArray alloc] init];
        delay_newTablePartUpper=[[NSMutableArray alloc] init];
        [self addTablePartAll];
        [self schedule: @selector(checkSpecialTTL:) interval:0.05 ];
        
    }
    return self;
}


+(id) TablePartAdderWithWorld:(b2World*)world andSprite:(CCSpriteBatchNode*)spriteInput
{
	return [[self alloc] initWithWorld:world andSprite:spriteInput];
}





//update函數一定要:(ccTime)delta，不然會錯

-(void) cleanup
{
    [super cleanup];
//     [self unscheduleAllSelectors];
}




-(void) addTablePartAll
{
    TablePartsType i;
    for(i=TablePartsTypeUpper;i<TablePartsTypeRight+1;i++){
        TablePart* newTablePart=[TablePart tablePartInWorld:sharedWorld
                                                   position:[sharedTablePartAdderInstance positionMapping:i] name:[sharedTablePartAdderInstance nameMapping:i] andSpecialType:SpecialTablePartsTypeNormal];
        [sharedSprite addChild:newTablePart z:1 tag:i];
//        [arrayOfTablePart addObject:newTablePart];
    }
    
}

+(void) specializeTablePart:(SpecialTablePartsType)specialTablePartsTypeInput andCaller:(user_board_type)caller{

    [sharedTablePartAdderInstance specializeTablePartI:specialTablePartsTypeInput andCaller:caller];
}
//多加一個I就是class method
-(void) specializeTablePartI:(SpecialTablePartsType)specialTablePartsTypeInput andCaller:(user_board_type)caller{
        TablePartsType toModifyTablePartsType;//用來決定是哪個要被換成新的(上面還是下面)
    
    CGSize screenSize = [CCDirector sharedDirector].winSize;
    
    
    if(specialTablePartsTypeInput==SpecialTablePartsTypeWider){//攻擊型
        if(caller==user_board_type_player){//自己caller，別人受害
            [ParticleEffectAdder addEffect:ballEffectTypeTableChange andPosition:ccp(screenSize.width/2, screenSize.height)];
            toModifyTablePartsType=TablePartsTypeUpper;
            
        }else{
            [ParticleEffectAdder addEffect:ballEffectTypeTableChange andPosition:ccp(screenSize.width/2, 0)];
            toModifyTablePartsType=TablePartsTypeLower;
        }
    }else{//防禦型
        if(caller==user_board_type_player){//自己caller，別人受害
            [ParticleEffectAdder addEffect:ballEffectTypeTableChange andPosition:ccp(screenSize.width/2, 0)];
            toModifyTablePartsType=TablePartsTypeLower;
        }else{
            toModifyTablePartsType=TablePartsTypeUpper;
            [ParticleEffectAdder addEffect:ballEffectTypeTableChange andPosition:ccp(screenSize.width/2, screenSize.height)];
        }
    }

    TablePart* newTablePartUpper=[TablePart tablePartInWorld:sharedWorld
                                                    position:[sharedTablePartAdderInstance positionMapping:toModifyTablePartsType] name:[sharedTablePartAdderInstance nameMapping:toModifyTablePartsType] andSpecialType:specialTablePartsTypeInput];
    waitingForDelay=YES;
    [delay_toModifyTablePartsType addObject:[NSNumber numberWithInt:toModifyTablePartsType]];
    [delay_newTablePartUpper addObject:newTablePartUpper];

    
    [self schedule: @selector(delayForAnimation:) interval:0.5 ];
}

//這個只是為了讓入口能在動畫播放結束之後再默默消失所以才把本來可以寫在上面的code搬到下面來寫
-(void)delayForAnimation:(ccTime)delta
{
    NSUInteger i;
    for(i=0;i<[delay_newTablePartUpper count];i++){
            [sharedSprite removeChildByTag:[[delay_toModifyTablePartsType objectAtIndex:i] intValue] cleanup:YES];
            [sharedSprite addChild:[delay_newTablePartUpper objectAtIndex:i] z:1 tag:[[delay_toModifyTablePartsType objectAtIndex:i] intValue]];
    }
    delay_toModifyTablePartsType=[[NSMutableArray alloc] init];
    delay_newTablePartUpper=[[NSMutableArray alloc] init];
    waitingForDelay=NO;
    [self unschedule:@selector(delayForAnimation:)];
}


-(CGPoint) positionMapping:(TablePartsType)TablePartsTypeInput
{
    CGSize screenSize = [CCDirector sharedDirector].winSize;
    switch (TablePartsTypeInput) {
        case TablePartsTypeUpper:
            return [Helper makeWithX:screenSize.width/2 Y:screenSize.height];
            break;
        case TablePartsTypeLower:
            return [Helper makeWithX:screenSize.width/2 Y:0];
            break;
        case TablePartsTypeLeft:
            return [Helper makeWithX:0 Y:screenSize.height/2];
            break;
        case TablePartsTypeRight:
            return [Helper makeWithX:screenSize.width Y:screenSize.height/2];
            break;
            
        default:
            break;
    }

}
-(NSString*) nameMapping:(TablePartsType)TablePartsTypeInput
{
    switch (TablePartsTypeInput) {
        case TablePartsTypeUpper:
            return @"boardUpper";
            break;
        case TablePartsTypeLower:
            return @"boardLower";
            break;
        case TablePartsTypeLeft:
            return @"boardLeft";
            break;
        case TablePartsTypeRight:
            return @"boardRight";
            break;
            
        default:
            break;
    }
}


-(void)checkSpecialTTL:(ccTime)delta
{
    TablePartsType i;//用來iteration
    for (i=TablePartsTypeUpper;i<=TablePartsTypeLower;i++){
        TablePart* tempTablePart=(TablePart*)[sharedSprite getChildByTag:i];
        if([tempTablePart getSpecialType]!=SpecialTablePartsTypeNormal){//看看是不是特殊型別
            if((
               ([tempTablePart getSpecialType]==SpecialTablePartsTypeDissapear
               &&[tempTablePart getSpecialTTL:SpecialTablePartsTypeDissapear]<=0)
                ||
               ([tempTablePart getSpecialType]==SpecialTablePartsTypeSmaller
                &&[tempTablePart getSpecialTTL:SpecialTablePartsTypeSmaller]<=0)
                ||
               ([tempTablePart getSpecialType]==SpecialTablePartsTypeWider
                &&[tempTablePart getSpecialTTL:SpecialTablePartsTypeWider]<=0))
               &&(!waitingForDelay)
               ){
                [sharedTablePartAdderInstance ULnormalization:i];
            }
        }
    }
}
-(void) ULnormalization:(TablePartsType)tablePartsTypeInput//把現有的特別入口踢掉，載入最原始的版本
{
    waitingForDelay=YES;
    CGSize screenSize = [CCDirector sharedDirector].winSize;
    
    if(tablePartsTypeInput==TablePartsTypeUpper){
        [ParticleEffectAdder addEffect:ballEffectTypeTableChange andPosition:ccp(screenSize.width/2, screenSize.height)];
        TablePart* newTablePartUpper=[TablePart tablePartInWorld:sharedWorld
                                                        position:[sharedTablePartAdderInstance positionMapping:TablePartsTypeUpper] name:[sharedTablePartAdderInstance nameMapping:TablePartsTypeUpper] andSpecialType:SpecialTablePartsTypeNormal];
        [delay_toModifyTablePartsType addObject:[NSNumber numberWithInt:TablePartsTypeUpper]];
        [delay_newTablePartUpper addObject:newTablePartUpper];


    }else{
        [ParticleEffectAdder addEffect:ballEffectTypeTableChange andPosition:ccp(screenSize.width/2, 0)];
        TablePart* newTablePartLower=[TablePart tablePartInWorld:sharedWorld
                                                        position:[sharedTablePartAdderInstance positionMapping:TablePartsTypeLower] name:[sharedTablePartAdderInstance nameMapping:TablePartsTypeLower] andSpecialType:SpecialTablePartsTypeNormal];

        [delay_toModifyTablePartsType addObject:[NSNumber numberWithInt:TablePartsTypeLower]];
        [delay_newTablePartUpper addObject:newTablePartLower];
        
    }
    [self schedule: @selector(delayForAnimation:) interval:0.5 ];
}


@end