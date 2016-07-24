# NETextView
# 可以设置输入的长度和placeholder
  设置限制N长度

NETextView *textView =[[NETextView alloc]initFrame:CGRectMakeFrame(0,100,200,200)];
textView.placeholder= @"placeholder";
textView.maxLength = 20;
