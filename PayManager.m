//
//  PayManager.m
//  WisdomSelect
//
//  Created by ff_gjm on 15/11/24.
//  Copyright © 2015年 com.fufang. All rights reserved.
//

#define ZHIFUBAO_PUBLIC_KEY @"MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCnxj/9qwVfgoUh/y2W89L6BkRAFljhNhgPdyPuBV64bfQNN1PjbCzkIM6qRdKBoLPXmKKMiFYnkd6rAoprih3/PrQEB/VsW8OoM8fxn67UDYuyBTqA23MML9q1+ilIZwBC2AQ2UBVOrFXfFl75p6/B5KsiNG9zpgmLCUYuLkxpLQIDAQAB"

typedef NS_ENUM(NSInteger,ZhifubaoReturnType){
    
    zhifubaoFail = 4000,
    zhibubaoSucceed = 9000,
    zhifubaoUserCancel = 6001,
    zhibubaoUserNetOffline = 6002
};


#import "PayManager.h"
//支付宝
#import <AlipaySDK/AlipaySDK.h>
#import "DataSigner.h"
#import "DataVerifier.h"
@implementation PayManager

+ (PayManager *)sharedManager
{
    static PayManager *sharedAccountManagerInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedAccountManagerInstance = [[self alloc] init];
    });
    return sharedAccountManagerInstance;
}



- (void)payGoodsWithPayType:(PayType)currentType goodsInfo:(NSString *)info succeed:(void (^)(NSDictionary *))succeed{

    switch (currentType) {
        case zhifubaoType:
            [self payWithzhifubaoWithGoodsInfo:info succeed:succeed];
            break;
            
        case weixinType:
            
            break;
            
        default:{
            [CustomClass showAlertMessage:@"目前不支持这种支付方式"];
        }
            break;
    }
    
}





- (void)payWithzhifubaoWithGoodsInfo:(NSString *)goodInfo
                           succeed:(void (^)(NSDictionary *))succeed{
    
    NSString *orderString = goodInfo;
    
    NSString *appScheme = @"wisdomSelect";
    
    [[AlipaySDK defaultService] payOrder:orderString fromScheme:appScheme callback:^(NSDictionary *resultDic) {
        
        NSLog(@"reslut = %@",resultDic);
    
        NSString *publicStr = ZHIFUBAO_PUBLIC_KEY;
        
        id<DataVerifier>publicSigner = CreateRSADataVerifier(publicStr);
    
        if ([[resultDic objectForKey:@"resultStatus"] intValue] == zhibubaoSucceed) {
            
            if ([resultDic objectForKey:@"result"]) {
                
                NSString *value = [resultDic objectForKey:@"result"];
                
                NSRange range = [value rangeOfString:@"success=\"true\""];
                
                NSRange range1 = [value rangeOfString:@"sign="];
                
                NSString *verifyString = @"";
                
                NSString *signString = @"";
                
                if (range.location && range.length) {
                    
                    verifyString = [value substringToIndex:range.location + range.length];
                    
                }
    
                if (range1.location && range1.length) {
                    
                    signString = [value substringFromIndex:range1.location + range1.length];
                    
                    signString = [signString substringWithRange:NSMakeRange(1, signString.length - 2)];
                }
    
                if ([verifyString length] && [signString length]) {
    
                    BOOL value = [publicSigner verifyString:verifyString withSign:signString];
    
                    NSDictionary *returnDict = @{
                                                 @"value"
                                                 :[NSNumber numberWithBool:value]                                                             };
    
                    succeed(returnDict);
                    
                }else{
                    succeed(nil);
                }
                
            }
        }else{
            succeed(resultDic);
        }
        
    }];
    
}


+ (NSString *)privateUft8StringWithString:(NSString *)privateString{
    NSString *signedString = privateString;
    signedString = (__bridge_transfer  NSString*) CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (__bridge CFStringRef)signedString, NULL, (__bridge CFStringRef)@"!*'();:@&=+$,/?%#[]", kCFStringEncodingUTF8 );
    return signedString;
}

@end
