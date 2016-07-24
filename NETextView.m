//
//
//  Created by oyzhx on 16/5/23.
//  Copyright © 2016年 oyzhx. All rights reserved.
//

#import "NETextView.h"

@interface NETextView ()<UITextViewDelegate>
@property (strong, nonatomic) UILabel * placeholderLabel;
@property (strong, nonatomic) UITextView * textView;
@end


@implementation NETextView

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initSet];
    }
    return self;
}

//初始化sb
- (void)awakeFromNib
{
    [self initSet];

}

- (id)init {
    if (self = [super init]) {
        [self initSet];
    }
    return self;
}

-(void)initSet
{
    _textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    _textView.delegate = self;
    [self addSubview:_textView];

    //设置placeholderLabel
    self.placeholderLabel = [[UILabel alloc]init];
    self.placeholderLabel.backgroundColor = [UIColor clearColor];
    self.placeholderLabel.numberOfLines = 0;
    [self addSubview:self.placeholderLabel];
    self.placeholderColor = [UIColor lightGrayColor]; //设置 颜色
    self.placeholderFont = [UIFont systemFontOfSize:15]; //设置字体大小
    self.textView.font = self.placeholderFont;

    self.maxLength = MAXFLOAT;

}

#pragma mark 设置占位字符
- (void)setPlaceholder:(NSString *)placeholder{
    _placeholder = placeholder;
    _placeholderLabel.text = placeholder;

    // 计算子控件
    [self setNeedsLayout];
}

#pragma mark 颜色
- (void)setPlaceholderColor:(UIColor *)placeholderColor
{
    _placeholderColor = placeholderColor;
    _placeholderLabel.textColor = placeholderColor;
}

#pragma mark  字体
- (void)setPlaceholderFont:(UIFont *)placeholderFont
{
    _placeholderFont = placeholderFont;
    _placeholderLabel.font = placeholderFont;
    _textView.font = placeholderFont;
    [self setNeedsLayout];
}

#pragma 布局加载时设置Label的frame
- (void)layoutSubviews
{
    // 设置坐标
    CGFloat labelX = 5;
    CGFloat labelY = 8;
    CGFloat labelW = self.frame.size.width - labelX*2;
    // 根据文字计算高度
    CGSize maxSize = CGSizeMake(labelW, MAXFLOAT);

    CGSize textSize = [_placeholder boundingRectWithSize:maxSize options:NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:_placeholderFont} context:nil].size;
    CGFloat labelH = textSize.height;

    // 设置Frame
    _placeholderLabel.frame = CGRectMake(labelX, labelY, labelW, labelH);
}

#pragma mark UITextViewDelegate
//当用户按下return键或者按回车键，keyboard消失
- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    [textView resignFirstResponder];
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView
{
    _placeholderLabel.hidden = [textView.text length];

    UITextRange *selectedRange = [textView markedTextRange];
    //获取高亮部分
    UITextPosition *pos = [textView positionFromPosition:selectedRange.start offset:0];

    //如果在变化中是高亮部分在变，就不要计算字符了
    if (selectedRange && pos) {
        return;
    }


    NSInteger length = [self countInputWordNum:textView.text];
    NSRange cursorRange=textView.selectedRange;
    if(length >self.maxLength){
        textView.text=[textView.text substringToIndex:[self lastInputIndex:textView.text]];
    }
    else{
        //删除emoji符号，输入框内图形残留
        textView.text=textView.text;
    }
    textView.selectedRange = cursorRange;


}

// 对输入字数进行控制
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {

        [textView resignFirstResponder];
        return NO;
    }

    UITextRange *selectedRange = [textView markedTextRange];
    //获取高亮部分
    UITextPosition *pos = [textView positionFromPosition:selectedRange.start offset:0];
    //获取高亮部分内容
    //NSString * selectedtext = [textView textInRange:selectedRange];

    //如果有高亮且当前字数开始位置小于最大限制时允许输入
    if (selectedRange && pos) {
        NSInteger startOffset = [textView offsetFromPosition:textView.beginningOfDocument toPosition:selectedRange.start];
        NSInteger endOffset = [textView offsetFromPosition:textView.beginningOfDocument toPosition:selectedRange.end];
        NSRange offsetRange = NSMakeRange(startOffset, endOffset - startOffset);
        NSString *preTextViewStr = [textView.text substringToIndex:offsetRange.location];
        if ([self countInputWordNum:preTextViewStr] < self.maxLength) {
            return YES;
        }
        else
        {
            return NO;
        }
    }

    NSString *comcatstr = [textView.text stringByReplacingCharactersInRange:range withString:text];
    //caninputlen 还可以输入多少个字
    NSInteger caninputlen = self.maxLength -[self countInputWordNum:comcatstr];

    if (caninputlen >= 0)
    {
        return YES;
    }
    else
    {
        NSInteger len = [self countInputWordNum:text] + caninputlen;
        //防止当text.length + caninputlen < 0时，使得rg.length为一个非法最大正数出错
        NSRange rg = {0,MAX(len,0)};

        if (rg.length > 0)
        {
            NSString *s = @"";
            //判断是否只普通的字符或asc码(对于中文和表情返回NO)
            BOOL asc = [text canBeConvertedToEncoding:NSASCIIStringEncoding];
            if (asc) {
                s = [text substringWithRange:rg];//因为是ascii码直接取就可以了不会错
            }
            else
            {
                __block NSInteger idx = 0;
                __block NSString  *trimString = @"";//截取出的字串
                //使用字符串遍历，这个方法能准确知道每个emoji是占一个unicode还是两个
                [text enumerateSubstringsInRange:NSMakeRange(0, [text length])
                                         options:NSStringEnumerationByComposedCharacterSequences
                                      usingBlock: ^(NSString* substring, NSRange substringRange, NSRange enclosingRange, BOOL* stop) {

                                          if (idx >= rg.length) {
                                              *stop = YES; //取出所需要就break，提高效率
                                              return ;
                                          }

                                          trimString = [trimString stringByAppendingString:substring];
                                          idx++;
                                      }];

                s = trimString;
            }
            //rang是指从当前光标处进行替换处理(注意如果执行此句后面返回的是YES会触发didchange事件)
            [textView setText:[textView.text stringByReplacingCharactersInRange:range withString:s]];
        }

        return NO;
    }
}


//字符,字和表情都算一个字
- (NSInteger)countInputWordNum:(NSString*)text{
    __block NSInteger count = 0;
    [text enumerateSubstringsInRange:NSMakeRange(0, [text length])
                             options:NSStringEnumerationByComposedCharacterSequences
                          usingBlock: ^(NSString* substring, NSRange substringRange, NSRange enclosingRange, BOOL* stop) {
                              if (*stop) {
                                  return;
                              }
                              count++;
                          }];

    return count;
}

//获取最后个字的下标
- (NSInteger)lastInputIndex:(NSString*)text{
    __block NSInteger count = 0;
    __block NSInteger lastIndex = 0;
    [text enumerateSubstringsInRange:NSMakeRange(0, [text length])
                             options:NSStringEnumerationByComposedCharacterSequences
                          usingBlock: ^(NSString* substring, NSRange substringRange, NSRange enclosingRange, BOOL* stop) {
                              if (count >=self.maxLength) {
                                  *stop = YES;
                                  return;
                              }
                              count++;
                              lastIndex = substringRange.location+substringRange.length;
                          }];

    return lastIndex;
}
@end
