//
//  SSKeyboard_SwiftWrapper.m
//  SSKeyboardHue
//
//  Created by Erik Bautista on 10/9/19.
//  Copyright © 2019 ErrorErrorError. All rights reserved.
//

#import "SSKeyboardHue-Bridging-Header.hpp"

@implementation SSKeyboardWrapper
{
    SSKeyboard keyboard;
}
-(IOReturn) sendColorKeys: (void *) keyArray : (bool) createOutputPackage
{
    //Keys *regionKey = static_cast<Keys *>(region);
    Keys **keyArrayPointer = static_cast<Keys **>(keyArray);
    return keyboard.sendColorKeys(keyArrayPointer, createOutputPackage);
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


