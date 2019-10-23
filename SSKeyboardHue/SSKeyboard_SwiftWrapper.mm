//
//  SSKeyboard_SwiftWrapper.m
//  SSKeyboardHue
//
//  Created by Erik Bautista on 10/9/19.
//  Copyright © 2019 ErrorErrorError. All rights reserved.
//

#import "SSKeyboardHue-Bridging-Header.hpp"
@interface SSKeyboardWrapper()
@property (nonatomic, readonly) SSKeyboard keyboard;
@end

@implementation SSKeyboardWrapper

-(instancetype)init {
    self = [super init];
    if (self) {
        _keyboard = SSKeyboard();
    }
    return self;
}

-(IOReturn) sendColorKeys: (void *) keyArray : (bool) updateKeys
{
    Keys **keyArrayPointer = static_cast<Keys **>(keyArray);
    return _keyboard.sendColorKeys(keyArrayPointer, updateKeys);
}

-(enum KeyboardModels) getKeyboardModel {
    return _keyboard.getKeyboardModel();
}
-(void) setSleepInMillis:(uint16_t) millis {
    _keyboard.setSleepInMillis(millis);
}


-(uint8_t) findRegionOfKey:(uint8_t) findThisKey {
    return _keyboard.findRegionOfKey(findThisKey);
}
@end


