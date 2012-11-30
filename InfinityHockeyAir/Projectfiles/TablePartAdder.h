//
//  Ball.h
//  PhysicsBox2d
//
//  Created by Steffen Itterheim on 20.09.10.
//  Copyright 2010 Steffen Itterheim. All rights reserved.
//

#import "BodySprite.h"
#import "Box2D.h"
#import "cocos2d.h"
#import "user_board.h"
#import "TablePart.h"//要注意不能循環import，就是我import你，你import我，這樣可能會有些問題
#import "Helper.h"





@interface TablePartAdder : BodySprite
{
    int TablePartNumber;
    b2World* sharedWorld;
    CCSpriteBatchNode* sharedSprite;
    BOOL toCheck;
    user_board_type ownerToCheck;
    TablePartsType typeInputToCheck;
    NSMutableArray * arrayOfTablePart;
    
    NSMutableArray *delay_toModifyTablePartsType;//為了配合動畫刻意儲存的值
    NSMutableArray *delay_newTablePartUpper;//為了配合動畫刻意儲存的值
    BOOL waitingForDelay;
}


+(id) TablePartAdderWithWorld:(b2World*)world andSprite:(CCSpriteBatchNode*)spriteInput;
+(void) specializeTablePart:(SpecialTablePartsType)specialTablePartsTypeInput andCaller:(user_board_type)caller;

@end
