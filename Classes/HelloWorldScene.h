//
//  HelloWorldLayer.h
//  swm
//
//  Created by Srihari Muthyala on 7/11/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//


// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"

// HelloWorld Layer
@interface HelloWorld : CCLayer
{
	CCColorLayer *zoombase;
	CCColorLayer *nozoombase;
	CCSprite *background;
	CGPoint ZB_last_posn;
}

// returns a Scene that contains the HelloWorld as the only child
+(id) scene;

@end
