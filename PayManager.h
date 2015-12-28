//
//  PayManager.h
//  WisdomSelect
//
//  Created by ff_gjm on 15/11/24.
//  Copyright © 2015年 com.fufang. All rights reserved.
//

typedef NS_ENUM(NSInteger,PayType){
    zhifubaoType = 1,
    weixinType = 2
};

#import <Foundation/Foundation.h>

@interface PayManager : NSObject

+ (PayManager *)sharedManager;

- (void)payGoodsWithPayType:(PayType)currentType goodsInfo:(NSString *)info succeed:(void (^)(NSDictionary *))succeed;

/*
 支付宝把私钥转成utf-8字符串 
 我们是后台做的签名
 */
+ (NSString *)privateUft8StringWithString:(NSString *)privateString;

@end
