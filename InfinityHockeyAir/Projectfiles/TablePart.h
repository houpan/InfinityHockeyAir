//
//  Bumper.h
//  PhysicsBox2d
//
//  Created by Steffen Itterheim on 22.09.10.
//  Copyright 2010 Steffen Itterheim. All rights reserved.
//
//  Enhanced to use PhysicsEditor shapes and retina display
//  by Andreas Loew / http://www.physicseditor.de
//

#import "BodySprite.h"
#import "GlobalEnum.m"


@interface TablePart : BodySprite
{
    TablePartsType TablePartsType_object;
    SpecialTablePartsType SpecialTablePartsType_object;
    int smallerTTL;
    int widerTTL;
    int dissapearTTL;
}

+(id) tablePartInWorld:(b2World*)world position:(CGPoint)pos name:(NSString*)name andSpecialType:(SpecialTablePartsType)specialTypeInput;
-(SpecialTablePartsType)getSpecialType;
-(int) getSpecialTTL:(SpecialTablePartsType)specialTTLType;
@end
