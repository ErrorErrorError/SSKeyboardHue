//
//  KeyEffect - Wrapper.m
//  SSKeyboardHue
//
//  Created by Erik Bautista on 10/29/19.
//  Copyright © 2019 ErrorErrorError. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SSKeyboardHue-Bridging-Header.hpp"
@interface KeyEffectWrapper()
@property (nonatomic, readonly) KeyEffect keyEffect;
@property (nonatomic, readonly) KeyTransition *transitions;
@end

@implementation KeyEffectWrapper

-(instancetype)init {
    self = [super init];
    if (self) {
        _keyEffect = KeyEffect();
    }
    return self;
}

-(instancetype)initKeyEffect:(uint8_t) _id : (struct KeyTransition *) keyTransition : (uint8_t) transitionSize {
    self = [super init];
    if (self) {
        _transitions = new KeyTransition[transitionSize];
        for (uint8_t i = 0; i < transitionSize; i++) {
            _transitions[i] = keyTransition[i];
        }
        _keyEffect = KeyEffect(_id, _transitions, transitionSize);
    }
    return self;
}

-(void)setWaveMode:(struct KeyPoint) origin : (uint16_t) waveLength : (enum WaveRadControl) radControl : (enum  WaveDirection) direction {
    _keyEffect.setWaveMode(origin, waveLength, radControl, direction);
}

-(void)disableWavemode {
    _keyEffect.disableWavemode();
}

-(void)setEffectId:(uint8_t) _id {
    _keyEffect.setEffectId(_id);
}

-(void)setTransitions:(struct KeyTransition *) keyTransition : (uint8_t) size {
    if (_transitions) {
        delete [] _transitions;
        _transitions = new KeyTransition[size];
        for (uint8_t i = 0; i < size; i++) {
            _transitions[i] = keyTransition[i];
        }
    }
    _keyEffect.setTransitions(_transitions, size);
}

-(struct RGB) getStartColor {
    return _keyEffect.getStartColor();
}

-(struct KeyTransition *)getTransitions {
    return _transitions;
}

-(uint8_t) getTransitionSize {
    return _keyEffect.getTransitionSize();
}

-(uint8_t) getEffectId {
    return _keyEffect.getEffectId();
}
-(bool) isWaveModeActive {
    return _keyEffect.isWaveModeActive();
}
-(struct KeyPoint) getWaveOrigin {
    return _keyEffect.getWaveOrigin();
}
-(enum WaveRadControl) getWaveRadControl{
    return _keyEffect.getWaveRadControl();
}
-(uint16_t) getWaveLength {
    return _keyEffect.getWaveLength();
}
-(enum WaveDirection) getWaveDirection {
    return _keyEffect.getWaveDirection();
}

-(void *)getEffect{
    return &_keyEffect;
}

-(BOOL)isEqual:(id) object {
    if(![object isKindOfClass:[KeyEffectWrapper class]]) return NO;

    KeyEffectWrapper *obj = (KeyEffectWrapper *) object;
    if (!(self.getStartColor.r == obj.getStartColor.r && self.getStartColor.g == obj.getStartColor.g && self.getStartColor.b == obj.getStartColor.b)) {
        return false;
    }
    
    if (!(self.getTransitionSize == obj.getTransitionSize)) {
        return false;
    }

    if (!(self.isWaveModeActive == obj.isWaveModeActive)) {
        return false;
    }

    if (!(self.getWaveOrigin.x == obj.getWaveOrigin.x && self.getWaveOrigin.y == obj.getWaveOrigin.y)) {
        return false;
    }
    
    if (!(self.getWaveRadControl == obj.getWaveRadControl)) {
        return false;
    }
    
    if (!(self.getWaveLength == obj.getWaveLength)) {
        return false;
    }
    
    if (!(self.getWaveDirection == obj.getWaveDirection)) {
        return false;
    }
    
    
    for (uint8_t i = 0; i < self.getTransitionSize; i++) {
        if (!(self.getTransitions[i].color.r == obj.getTransitions[i].color.r &&
              self.getTransitions[i].color.g == obj.getTransitions[i].color.g &&
              self.getTransitions[i].color.b == obj.getTransitions[i].color.b &&
              self.getTransitions[i].duration == obj.getTransitions[i].duration))
            return false;
    }
    return true;
}

-(NSUInteger)hash{
    NSUInteger prime = 31;
    NSUInteger result = 1;
    result = prime * result + self.getTransitionSize;
    result = prime * result + self.getStartColor.r;
    result = prime * result + self.getStartColor.g;
    result = prime * result + self.getStartColor.b;
    result = prime * result + self.getWaveLength;
    result = prime * result + self.getWaveOrigin.x;
    result = prime * result + self.getWaveOrigin.y;
    result = prime * result + self.getWaveDirection;
    result = prime * result + self.getWaveRadControl;
    result = prime * result + ((self.isWaveModeActive) ? 1231:1237);

    for (uint8_t i = 0; i < self.getTransitionSize; i++) {
        result = prime * result + self.getTransitions[i].color.r;
        result = prime * result + self.getTransitions[i].color.g;
        result = prime * result + self.getTransitions[i].color.b;
        result = prime * result + self.getTransitions[i].duration;
    }
    
    return result;
}

-(void) dealloc {
    free(_transitions);
}
@end
