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
#import <SSKeyboard/sseffect.h>

@interface KeysWrapper : NSObject
-(instancetype)initWithSteady:(uint8_t) keyCode : (uint8_t) location : (struct RGB) steadyColor;
-(instancetype)initWithReactive:(uint8_t) keyCode : (uint8_t) location : (struct RGB) active : (struct RGB) rest : (uint16_t) duration;
-(struct RGB)getMainColor;
-(struct RGB)getActiveColor;
-(uint8_t)getRegion;
-(uint8_t)getKeyCode;
-(void)setSteadyMode:(struct RGB) steadyColor;
-(void)setReactiveMode:(struct RGB) active : (struct RGB) rest : (uint16_t) duration;
-(void)setEffectKey:(uint8_t) _id : (enum PerKeyModes) breathOrShift;
-(void *)key;
-(enum PerKeyModes)getMode;
-(uint16_t)getSpeed;
-(void)setDisabled;
-(uint8_t)getEffectId;
@end

@interface KeyEffectWrapper : NSObject
-(instancetype)init;
-(instancetype)initKeyEffect:(uint8_t) _id : (struct KeyTransition *) keyTransition : (uint8_t) transitionSize;
-(void)setWaveMode:(struct KeyPoint) origin : (uint16_t) waveLength : (enum WaveRadControl) radControl : (enum  WaveDirection) direction;
-(void)disableWavemode;
-(void)setEffectId:(uint8_t) _id;
-(void)setTransitions:(struct KeyTransition *) keyTransition : (uint8_t) size;
-(struct RGB)getStartColor;
-(struct KeyTransition *)getTransitions;
-(uint8_t)getTransitionSize;
-(uint8_t)getEffectId;
-(bool)isWaveModeActive;
-(struct KeyPoint)getWaveOrigin;
-(enum WaveRadControl)getWaveRadControl;
-(uint16_t) getWaveLength;
-(enum WaveDirection)getWaveDirection;
-(void *)getEffect;
@end

@interface SSKeyboardWrapper : NSObject
-(instancetype)init;
-(IOReturn)sendColorKeys:(NSArray<KeysWrapper *> *) keyArray : (bool) createOutputPackage;
-(enum KeyboardModels)getKeyboardModel;
-(void)setSleepInMillis:(uint16_t) millis;
-(uint8_t)findRegionOfKey:(uint8_t) findThisKey;
-(IOReturn)sendEffect:(KeyEffectWrapper *) keyEffect : (bool) updateCommand;
-(IOReturn)exit;
@end
