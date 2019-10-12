//
//  SSKeyboardHue-Bridging-Header.h
//  SSKeyboardHue
//
//  Created by Erik Bautista on 10/9/19.
//  Copyright © 2019 ErrorErrorError. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SSKeyboard/sskeyboard.h>
@interface SSKeyboardWrapper : NSObject

-(IOReturn) setSteadyMode:(uint8_t) region : (struct RGB) regionColor : (struct RGB *) colorArray : (bool) createOutputPackage;
-(IOReturn) closeKeyboardPort;
-(enum KeyboardModels) getKeyboardModel;
-(void) setSleepInMillis:(uint16_t) millis;
@end

