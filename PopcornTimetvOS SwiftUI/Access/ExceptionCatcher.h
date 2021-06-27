//
//  ExceptionCatcher.h
//  PopcornTime
//
//  Created by Alexandru Tudose on 25.06.2021.
//  Copyright © 2021 PopcornTime. All rights reserved.
//

//#ifndef ExceptionCatcher_h
//#define ExceptionCatcher_h

#import <Foundation/Foundation.h>

NS_INLINE NSException * _Nullable ExecuteWithObjCExceptionHandling(void(^_Nonnull tryBlock)(void)) {
    @try {
        tryBlock();
    }
    @catch (NSException *exception) {
        return exception;
    }
    return nil;
}

//#endif /* ExceptionCatcher_h */
