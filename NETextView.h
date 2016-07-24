//
//
//  Created by 欧阳志鑫 on 16/5/23.
//  Copyright © 2016年 欧阳志鑫. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NETextView : UIView

/**
 *  textView 中的提示语
 */
@property (strong, nonatomic) NSString * placeholder;

/**
 *  textView 中提示语的颜色
 */
@property (strong, nonatomic)UIColor * placeholderColor;

/**
 *  textView 中提示语的字号
 */
@property (strong, nonatomic)UIFont * placeholderFont;

/**
 *  可输入字数个数
 */
@property (nonatomic, assign) NSInteger maxLength;

@end
