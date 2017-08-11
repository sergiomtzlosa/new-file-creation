//
//  SMLog.h
//
//

#import <Foundation/Foundation.h>

/**
 #ifdef clause evaluates PRINTLOG variable and if it is defined in PREPROCESSOR MACROS the program will print all log.
 
 You can explore this class to check printing actions. This class behaves like a normal SMLog function, indeed it uses SMLog!!!
 */

#ifdef PRINTLOG
    #define kDebug YES
#else
    #define kDebug NO
#endif

#define SMLog(FORMAT, ...) [SMLog log:[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] debug:kDebug] //permite habilitar o deshabilitar el modo debug para mostrar o no los comentarios

@interface SMLog : NSObject

+ (void)log:(NSString *)strLog debug:(BOOL)debug;

@end

