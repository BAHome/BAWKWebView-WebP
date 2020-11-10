//
//  NSObject+JKInvoker.m
//  JKInvoker
//
//  Created by XiFengLang on 2019/3/26.
//  Copyright © 2019 https://github.com/XiFengLang. All rights reserved.
//  modify from https://github.com/cyanzhong/RuntimeInvoker

#import "NSObject+RuntimeInvoker.h"
#import <UIKit/UIKit.h>



_Bool jk_equalChar(const char *s1, const char *s2) {
    return strcmp(s1, s2) == 0;
}


/**
 判断参数类型编码
 
 @param encode 参数类型编码
 @note https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtTypeEncodings.html#//apple_ref/doc/uid/TP40008048-CH100-SW1
 @return 参数类型
 */
JKMethodArgumentType jk_argumentTypeWithEncode(const char *encode) {
    if (jk_equalChar(encode, "@")) {
        return JKMethodArgumentTypeObject;         // @encode(id)
    } else if (jk_equalChar(encode, "B")) {
        return JKMethodArgumentTypeBool;           // @encode(_Bool)
    } else if (jk_equalChar(encode, "f")) {
        return JKMethodArgumentTypeFloat;          // @encode(float)
    } else if (jk_equalChar(encode, "d")) {
        return JKMethodArgumentTypeDouble;         // @encode(double)
    } else if (jk_equalChar(encode, "i")) {
        return JKMethodArgumentTypeInt;            // @encode(int)
    } else if (jk_equalChar(encode, "@?")) {
        return JKMethodArgumentTypeBlock;
    } else if (jk_equalChar(encode, @encode(CGPoint))) {
        return JKMethodArgumentTypeCGPoint;
    } else if (jk_equalChar(encode, @encode(CGSize))) {
        return JKMethodArgumentTypeCGSize;
    } else if (jk_equalChar(encode, @encode(CGRect))) {
        return JKMethodArgumentTypeCGRect;
    } else if (jk_equalChar(encode, "s")) {
        return JKMethodArgumentTypeShort;          // @encode(short)
    } else if (jk_equalChar(encode, "l")) {
        return JKMethodArgumentTypeLong;           // @encode(long)
    } else if (jk_equalChar(encode, "q")) {
        return JKMethodArgumentTypeLongLong;       // @encode(long long)
    } else if (jk_equalChar(encode, "C")) {
        return JKMethodArgumentTypeUnsignedChar;   // @encode(unsigned char)
    } else if (jk_equalChar(encode, "I")) {
        return JKMethodArgumentTypeUnsignedInt;    //  @encode(unsigned int)
    } else if (jk_equalChar(encode, "S")) {
        return JKMethodArgumentTypeUnsignedShort;  // @encode(unsigned short)
    } else if (jk_equalChar(encode, "L")) {
        return JKMethodArgumentTypeUnsignedLong;   // @encode(unsigned long)
    } else if (jk_equalChar(encode, "Q")) {
        return JKMethodArgumentTypeUnsignedLongLong;// @encode(unsigned long long)
    } else if (jk_equalChar(encode, "v")) {
        return JKMethodArgumentTypeVoid;           // @encode(void)
    } else if (jk_equalChar(encode, "c")) {
        return JKMethodArgumentTypeChar;           // @encode(char)
    } else if (jk_equalChar(encode, "*")) {
        return JKMethodArgumentTypeCharacterString;// @encode(char *)
    } else if (jk_equalChar(encode, "#")) {
        return JKMethodArgumentTypeClass;          // @encode(Class)
    } else if (jk_equalChar(encode, @encode(UIEdgeInsets))) {
        return JKMethodArgumentTypeUIEdgeInsets;
    } else if (jk_equalChar(encode, ":")) {
        return JKMethodArgumentTypeSEL;            // @encode(SEL)
    } else if (strcmp(encode, @encode(IMP))) {
        return JKMethodArgumentTypeIMP;
    }
    NSLog(@"JKRuntimeInvoker 未知的参数类型：%s",encode);
    return JKMethodArgumentTypeUnknown;
}


@implementation NSMethodSignature (JKRuntimeInvoker)

- (NSInvocation *)invocationWithArguments:(NSArray *)arguments{
    NSInvocation * invocation = [NSInvocation invocationWithMethodSignature:self];
    [arguments enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSUInteger index = idx + 2;
        NSAssert(index < [self numberOfArguments], @"传递的参数过多");
        if (index >= [self numberOfArguments]) {
            *stop = true;
            return ;
        }
        
        JKMethodArgumentType argumentType = [self argumentTypeAtIndex:index];
        
        switch (argumentType) {
            case JKMethodArgumentTypeChar: {
                char value = [obj charValue];
                [invocation setArgument:&value atIndex:index];
            } break;
            case JKMethodArgumentTypeInt: {
                int value = [obj intValue];
                [invocation setArgument:&value atIndex:index];
            } break;
            case JKMethodArgumentTypeShort: {
                short value = [obj shortValue];
                [invocation setArgument:&value atIndex:index];
            } break;
            case JKMethodArgumentTypeLong: {
                long value = [obj longValue];
                [invocation setArgument:&value atIndex:index];
            } break;
            case JKMethodArgumentTypeLongLong: {
                long long value = [obj longLongValue];
                [invocation setArgument:&value atIndex:index];
            } break;
            case JKMethodArgumentTypeUnsignedChar: {
                unsigned char value = [obj unsignedCharValue];
                [invocation setArgument:&value atIndex:index];
            } break;
            case JKMethodArgumentTypeUnsignedInt: {
                unsigned int value = [obj unsignedIntValue];
                [invocation setArgument:&value atIndex:index];
            } break;
            case JKMethodArgumentTypeUnsignedShort: {
                unsigned short value = [obj unsignedShortValue];
                [invocation setArgument:&value atIndex:index];
            } break;
            case JKMethodArgumentTypeUnsignedLong: {
                unsigned long value = [obj unsignedLongValue];
                [invocation setArgument:&value atIndex:index];
            } break;
            case JKMethodArgumentTypeUnsignedLongLong: {
                unsigned long long value = [obj unsignedLongLongValue];
                [invocation setArgument:&value atIndex:index];
            } break;
            case JKMethodArgumentTypeFloat: {
                float value = [obj floatValue];
                [invocation setArgument:&value atIndex:index];
            } break;
            case JKMethodArgumentTypeDouble: {
                double value = [obj doubleValue];
                [invocation setArgument:&value atIndex:index];
            } break;
            case JKMethodArgumentTypeBool: {
                _Bool value = [obj boolValue];
                [invocation setArgument:&value atIndex:index];
            } break;
            case JKMethodArgumentTypeVoid: {
                
            } break;
            case JKMethodArgumentTypeCharacterString: {
                const char * value = [obj UTF8String];
                [invocation setArgument:&value atIndex:index];
            } break;
            case JKMethodArgumentTypeCGPoint: {
                CGPoint value = [obj CGPointValue];
                [invocation setArgument:&value atIndex:index];
            } break;
            case JKMethodArgumentTypeCGSize: {
                CGSize value = [obj CGSizeValue];
                [invocation setArgument:&value atIndex:index];
            } break;
            case JKMethodArgumentTypeCGRect: {
                CGRect value = [obj CGRectValue];
                [invocation setArgument:&value atIndex:index];
            } break;
            case JKMethodArgumentTypeUIEdgeInsets: {
                UIEdgeInsets value = [obj UIEdgeInsetsValue];
                [invocation setArgument:&value atIndex:index];
            } break;
            case JKMethodArgumentTypeObject: {
                [invocation setArgument:&obj atIndex:index];
            } break;
            case JKMethodArgumentTypeClass: {
                Class value = [obj class];
                [invocation setArgument:&value atIndex:index];
            } break;
            case JKMethodArgumentTypeBlock: {
                [invocation setArgument:&obj atIndex:index];
            } break;
            case JKMethodArgumentTypeSEL: {
                SEL value = [obj pointerValue];
                [invocation setArgument:&value atIndex:index];
            } break;
            case JKMethodArgumentTypeIMP: {
                IMP value = [obj pointerValue];
                [invocation setArgument:&value atIndex:index];
            } break;
            default: break;
        }
    }];
    return invocation;
}


- (JKMethodArgumentType)argumentTypeAtIndex:(NSUInteger)index {
    const char * encode = [self getArgumentTypeAtIndex:index];
    return jk_argumentTypeWithEncode(encode);
}



@end




@implementation NSInvocation (JKRuntimeInvoker)



- (id)invokeWithTarget:(id)target selector:(SEL)selector returnType:(JKMethodArgumentType)returnType {
    self.target = target;
    self.selector = selector;
    [self invoke];
    return [self getReturnValueForType:returnType];
}


- (id)getReturnValueForType:(JKMethodArgumentType)type {
    __unsafe_unretained id returnValue = nil;
    switch (type) {
        case JKMethodArgumentTypeChar: {
            char value;
            [self getReturnValue:&value];
            returnValue = @(value);
        } break;
        case JKMethodArgumentTypeInt: {
            int value;
            [self getReturnValue:&value];
            returnValue = @(value);
        } break;
        case JKMethodArgumentTypeShort: {
            short value;
            [self getReturnValue:&value];
            returnValue = @(value);
        } break;
        case JKMethodArgumentTypeLong: {
            long value;
            [self getReturnValue:&value];
            returnValue = @(value);
        } break;
        case JKMethodArgumentTypeLongLong: {
            long long value;
            [self getReturnValue:&value];
            returnValue = @(value);
        } break;
        case JKMethodArgumentTypeUnsignedChar: {
            unsigned char value;
            [self getReturnValue:&value];
            returnValue = @(value);
        } break;
        case JKMethodArgumentTypeUnsignedInt: {
            unsigned int value;
            [self getReturnValue:&value];
            returnValue = @(value);
        } break;
        case JKMethodArgumentTypeUnsignedShort: {
            unsigned short value;
            [self getReturnValue:&value];
            returnValue = @(value);
        } break;
        case JKMethodArgumentTypeUnsignedLong: {
            unsigned long value;
            [self getReturnValue:&value];
            returnValue = @(value);
        } break;
        case JKMethodArgumentTypeUnsignedLongLong: {
            unsigned long long value;
            [self getReturnValue:&value];
            returnValue = @(value);
        } break;
        case JKMethodArgumentTypeFloat: {
            float value;
            [self getReturnValue:&value];
            returnValue = @(value);
        } break;
        case JKMethodArgumentTypeDouble: {
            double value;
            [self getReturnValue:&value];
            returnValue = @(value);
        } break;
        case JKMethodArgumentTypeBool: {
            _Bool value;
            [self getReturnValue:&value];
            returnValue = @(value);
        } break;
        case JKMethodArgumentTypeVoid: {
            
        } break;
        case JKMethodArgumentTypeCharacterString: {
            const char * value;
            [self getReturnValue:&value];
            returnValue = [NSString stringWithUTF8String:value];
        } break;
        case JKMethodArgumentTypeCGPoint: {
            CGPoint value;
            [self getReturnValue:&value];
            returnValue = [NSValue valueWithCGPoint:value];
        } break;
        case JKMethodArgumentTypeCGSize: {
            CGSize value;
            [self getReturnValue:&value];
            returnValue = [NSValue valueWithCGSize:value];
        } break;
        case JKMethodArgumentTypeCGRect: {
            CGRect value;
            [self getReturnValue:&value];
            returnValue = [NSValue valueWithCGRect:value];
        } break;
        case JKMethodArgumentTypeUIEdgeInsets: {
            UIEdgeInsets value;
            [self getReturnValue:&value];
            returnValue = [NSValue valueWithUIEdgeInsets:value];
        } break;
        case JKMethodArgumentTypeObject: {
            [self getReturnValue:&returnValue];
        } break;
        case JKMethodArgumentTypeClass: {
            [self getReturnValue:&returnValue];
        } break;
        case JKMethodArgumentTypeBlock: {
            [self getReturnValue:&returnValue];
        } break;
        case JKMethodArgumentTypeSEL: {
            SEL value;
            [self getReturnValue:&value];
            returnValue = [NSValue valueWithPointer:value];
        } break;
        case JKMethodArgumentTypeIMP: {
            IMP value;
            [self getReturnValue:&value];
            returnValue = [NSValue valueWithPointer:value];
        } break;
        default: break;
    }
    return returnValue;
}



@end






@implementation NSObject (JKRuntimeInvoker)
#define AnalysisArgument(argument)\
va_list argList;\
NSMutableArray * arguments = [[NSMutableArray alloc] initWithCapacity:3];\
if (argument) {\
[arguments addObject:argument];\
va_start(argList, argument);\
id nextArgument = nil;\
while ((nextArgument = va_arg(argList, id))) {\
[arguments addObject:nextArgument];\
}\
}\


#define JKParameterAssert(condition, desc)\
if (!(condition)) {\
NSLog(@"JKRuntimeInvoker Error⚠️: %@",desc);\
return nil;\
}\


- (id)invokeSelector:(NSString *)aSelectorName {
    return [self invokeSelector:aSelectorName arguments:nil];
}

- (id)invokeSelector:(NSString *)aSelectorName argument:(id)argument, ... {
    AnalysisArgument(argument)
    return [self invokeSelector:aSelectorName arguments:arguments];
}


- (id)invokeSelector:(NSString *)aSelectorName arguments:(NSArray *)arguments {
    JKParameterAssert(!(arguments && ![arguments isKindOfClass:NSArray.class]), @"无效的arguments");
    
    SEL method = NSSelectorFromString(aSelectorName);
    return [self invokeSEL:method arguments:arguments];
}


- (id)invokeSEL:(SEL)aSelector {
    return [self invokeSEL:aSelector arguments:nil];
}


- (id)invokeSEL:(SEL)aSelector argument:(id)argument, ... {
    AnalysisArgument(argument)
    return [self invokeSEL:aSelector arguments:arguments];
}





- (id)invokeSEL:(SEL)aSelector arguments:(NSArray *)arguments {
    JKParameterAssert(aSelector, @"无效的selector");
    
    NSMethodSignature * signature = [self methodSignatureForSelector:aSelector];
    JKParameterAssert(signature, @"无效的方法签名");
    
    NSInvocation * invocation = [signature invocationWithArguments:arguments];
    JKMethodArgumentType returnType = jk_argumentTypeWithEncode(signature.methodReturnType);
    return [invocation invokeWithTarget:self selector:aSelector returnType:returnType];
}



@end
