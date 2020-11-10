//
//  NSObject+JKInvoker.h
//  JKInvoker
//
//  Created by XiFengLang on 2019/3/26.
//  Copyright © 2019 https://github.com/XiFengLang. All rights reserved.
//  modify from https://github.com/cyanzhong/RuntimeInvoker

#import <Foundation/Foundation.h>


///  Objective-C type encoding: http://nshipster.com/type-encodings/
typedef NS_ENUM(NSUInteger, JKMethodArgumentType) {
    JKMethodArgumentTypeUnknown        = 0,
    JKMethodArgumentTypeChar,
    JKMethodArgumentTypeInt,
    JKMethodArgumentTypeShort,
    JKMethodArgumentTypeLong,
    JKMethodArgumentTypeLongLong,
    JKMethodArgumentTypeUnsignedChar,
    JKMethodArgumentTypeUnsignedInt,
    JKMethodArgumentTypeUnsignedShort,
    JKMethodArgumentTypeUnsignedLong,
    JKMethodArgumentTypeUnsignedLongLong,
    JKMethodArgumentTypeFloat,
    JKMethodArgumentTypeDouble,
    JKMethodArgumentTypeBool,
    JKMethodArgumentTypeVoid,
    JKMethodArgumentTypeCharacterString,
    JKMethodArgumentTypeCGPoint,
    JKMethodArgumentTypeCGSize,
    JKMethodArgumentTypeCGRect,
    JKMethodArgumentTypeUIEdgeInsets,
    JKMethodArgumentTypeObject,
    JKMethodArgumentTypeClass,
    JKMethodArgumentTypeBlock,
    JKMethodArgumentTypeSEL,
    JKMethodArgumentTypeIMP,
};


/**    去除字符串中的`@*#`字符，还原接口名，以访问私有接口    */
static inline NSString * _Nonnull fOriginalInterfaceName(NSString * _Nonnull api) {
    NSString * result = [api stringByReplacingOccurrencesOfString:@"@" withString:@""];
    result = [result stringByReplacingOccurrencesOfString:@"*" withString:@""];
    return [result stringByReplacingOccurrencesOfString:@"#" withString:@""];
}



@interface NSMethodSignature (JKRuntimeInvoker)

- (JKMethodArgumentType)argumentTypeAtIndex:(NSUInteger)index;

@end






/// 方法调用，替换performSelector
@interface NSObject (RuntimeInvoker)

- (id _Nullable )invokeSelector:(nonnull NSString *)aSelectorName
                      arguments:(nullable NSArray *)arguments;
- (id _Nullable )invokeSelector:(nonnull NSString *)aSelectorName
                       argument:(nullable id)argument,... NS_REQUIRES_NIL_TERMINATION;
- (id _Nullable )invokeSelector:(nonnull NSString *)aSelectorName;


- (id _Nullable )invokeSEL:(nonnull SEL)aSelector
                 arguments:(nullable NSArray *)arguments;
- (id _Nullable )invokeSEL:(nonnull SEL)aSelector
                  argument:(nullable id)argument,... NS_REQUIRES_NIL_TERMINATION;
- (id _Nullable )invokeSEL:(nonnull SEL)aSelector;



@end
