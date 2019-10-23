//
//  Keys-Wrapper.m
//  SSKeyboardHue
//
//  Created by Erik Bautista on 10/15/19.
//  Copyright © 2019 ErrorErrorError. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SSKeyboardHue-Bridging-Header.hpp"

@interface KeysWrapper()
@property (nonatomic, readonly) Keys keys;
@end

@implementation KeysWrapper

-(instancetype)initWithSteady:(uint8_t) keyCode : (char *) letter : (uint8_t) location : (struct RGB) steadyColor {
    self = [super init];
    if (self) {
        _keys = Keys(keyCode, location, steadyColor);
        _keys.keyLetter = letter;
    }
    return self;
}

-(instancetype)initWithReactive:(uint8_t) keyCode : (char *) letter : (uint8_t) location : (struct RGB) active : (struct RGB) rest : (uint16_t) duration {
    self = [super init];
    if (self) {
        _keys = Keys(keyCode, location, active, rest, duration);
        _keys.keyLetter = letter;
    }
    return self;
}

-(void) setReactiveMode:(struct RGB) active : (struct RGB) rest : (uint16_t) duration {
    _keys.setReactiveKey(active, rest, duration);
}
-(void) setSteadyMode: (struct RGB) steadyColor {
    _keys.setSteadyKey(steadyColor);
}
-(struct RGB) getMainColor {
    return _keys.getMainColor();
}
-(struct RGB) getActiveColor {
    return _keys.getActiveColor();
}
-(uint8_t) getRegion {
    return _keys.region;
}
-(char *)getKeyLetter {
    return _keys.keyLetter;
}
-(uint8_t)getKeyCode {
    return _keys.keycode;
}
-(void *)key{
    return &_keys;
}
-(PerKeyModes)getMode{
    return _keys.getMode();
}
-(uint16_t)getSpeed{
    return _keys.duration;
}

-(void)setDisabled{
    _keys.disableKey();
}
@end
