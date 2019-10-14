//
//  SSKeyboard_SwiftWrapper.m
//  SSKeyboardHue
//
//  Created by Erik Bautista on 10/9/19.
//  Copyright © 2019 ErrorErrorError. All rights reserved.
//

#import "SSKeyboardHue-Bridging-Header.hpp"
// #import "SSKeyboard/sskeyboard.h"

@implementation SSKeyboardWrapper
{
    SSKeyboard keyboard;
}
-(IOReturn) setSteadyMode:(uint8_t) region : (RGB) regionColor : (RGB *) colorArray : (bool) createOutputPackage
{
    return keyboard.setSteadyMode(region, regionColor, colorArray, createOutputPackage);
}

-(IOReturn) closeKeyboardPort {
    return keyboard.closeKeyboardPort();
}

-(enum KeyboardModels) getKeyboardModel {
    return keyboard.getKeyboardModel();
}
-(void) setSleepInMillis:(uint16_t) millis {
    keyboard.setSleepInMillis(millis);
}


-(uint8_t) findKeyInRegion:(uint8_t) findThisKey {
    return keyboard.findKeyInRegion(findThisKey);
}
@end
