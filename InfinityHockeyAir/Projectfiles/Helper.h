//
//  Helper.h
//  PhysicsBox2d
//
//  Created by Steffen Itterheim on 20.09.10.
//  Copyright 2010 Steffen Itterheim. All rights reserved.
//
//  Enhanced to use PhysicsEditor shapes and retina display
//  by Andreas Loew / http://www.physicseditor.de
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Box2D.h"
#import "Constants.h"


@interface Helper : NSObject 
{
}

+(b2Vec2) toMeters:(CGPoint)point;
+(CGPoint) toPixels:(b2Vec2)vec;

+(CGPoint) locationFromTouch:(UITouch*)touch;
+(CGPoint) locationFromTouches:(NSSet*)touches;


+(b2Vec2) transformToFar;
+(CGPoint) screenCenter;
+(b2Vec2) speedBooster:(b2Vec2)velocityInput andMultiplier:(int)multiplier;

+ (CGPoint) makeWithX: (float)x Y: (float)y;

+ (CGPoint) makeIdentity;
+ (CGPoint) add: (CGPoint) vec1 to: (CGPoint) vec2;
+ (CGPoint) truncate: (CGPoint) vec to: (float) max;
+ (CGPoint) multiply: (CGPoint) vec by: (float) factor;
+ (float) lengthSquared: (CGPoint) vec;
+ (float) length: (CGPoint) vec;
+ (CGPoint) invert: (CGPoint) vec;
+ (CGPoint) subtract: (CGPoint) vec2 of: (CGPoint) vec1;
+ (CGPoint) divide: (CGPoint) vec2 by: (double) under;
+(CGFloat) distanceBetweenPoints:(CGPoint)first between:(CGPoint) second;
+ (BOOL) compare: (CGPoint) vec2 with: (CGPoint) vec1;
+(CGPoint) normalization:(CGPoint)first;
@end
