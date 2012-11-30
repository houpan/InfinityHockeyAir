//
//  MouseListener.h
//  PhysicsBox2d
//
//  Created by Steffen Itterheim on 20.09.10.
//  Copyright 2010 Steffen Itterheim. All rights reserved.
//

#import "BodySprite.h"
#import "Box2D.h"

@interface MouseListener : BodySprite <CCTargetedTouchDelegate>
{
	BOOL moveToFinger;
	CGPoint fingerLocation;
}

/**
 * Creates a new MouseListener
 * @param world world to add the MouseListener to
 */
+(id) mouseListenerWithWorld:(b2World*)world;
@end
