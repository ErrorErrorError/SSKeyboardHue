//
//  SSKeyboardHue-Bridging-Header.h
//  SSKeyboardHue
//
//  Created by Erik Bautista on 10/9/19.
//  Copyright © 2019 ErrorErrorError. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import <SSKeyboard/sskeyboard.h>
#import <SSKeyboard/sskeys.h>

@interface KeysWrapper : NSObject
-(instancetype)initWithSteady:(uint8_t) keyCode : (char *) letter : (uint8_t) location :(struct RGB) steadyColor;
-(struct RGB) getMainColor;
-(struct RGB) getActiveColor;
-(uint8_t) getRegion;
-(char *)getKeyLetter;
-(uint8_t)getKeyCode;
-(void)setSteadyMode:(struct RGB) steadyColor;
-(void)setReactiveMode:(struct RGB) active : (struct RGB) rest : (uint16_t) duration;
-(void *)key;
-(enum PerKeyModes)getMode;
-(uint16_t)getSpeed;
-(void)setDisabled;
@end

@interface SSKeyboardWrapper : NSObject

-(IOReturn) sendColorKeys: (void *) keyArray : (bool) createOutputPackage;
-(IOReturn) closeKeyboardPort;
-(enum KeyboardModels) getKeyboardModel;
-(void) setSleepInMillis:(uint16_t) millis;
-(uint8_t) findKeyInRegion:(uint8_t) findThisKey;

@end
