#import "PushCommentController.h"
#import "LTAlertView.h"
#import "CommentController.h"
#import "Comments.h"
#import "PushCommentViewModel.h"

@interface PushCommentController ()<UITextViewDelegate>
//对话框自定义view中的控件
@property (weak, nonatomic) IBOutlet UITextField *textFieldName;
@property (weak, nonatomic) IBOutlet UIView *lineName;
@property (weak, nonatomic) IBOutlet UITextField *textFieldEmail;
@property (weak, nonatomic) IBOutlet UIView *lineEmail;
@property (weak, nonatomic) IBOutlet UIButton *buttonRight;
@property (weak, nonatomic) IBOutlet UIButton *buttonLeft;

@property(strong,nonatomic) UITextView *textView;
@property (assign, nonatomic)  NSInteger textViewHeight;

@end

@implementation PushCommentController

-(void)viewDidLoad{
    [super viewDidLoad];
    [self initView];
    [self bindingViewModel];
}

- (void)initView {
    self.title=@"回复";
    //添加回复label
    UILabel *label=[UILabel new];
    label.text=@"回复：";
    if ([self.sendObject isKindOfClass:[RACTuple class]]) {
        Comments *comment=((RACTuple *)self.sendObject).first;
        label.text=[NSString stringWithFormat:@"回复：%@",comment.name];
    }
    
    label.textColor=[UIColor grayColor];
    CGSize textSize=[label.text sizeWithAttributes:@{NSFontAttributeName:label.font}];
    label.frame=CGRectMake(16, 16, textSize.width, textSize.height);
    [self.view addSubview:label];
    //添加分割线
    UIView *dividerView=[[UIView alloc] initWithFrame:CGRectMake(16, CGRectGetMaxY(label.frame)+8, SCREEN_WIDTH-32, 1)];
    dividerView.backgroundColor=[UIColor grayColor];
    [self.view addSubview:dividerView];
    //添加评论TextView
    self.textViewHeight=SCREEN_HEIGHT-(CGRectGetMaxY(dividerView.frame)+16+64);
    self.textView=[[UITextView alloc] initWithFrame:CGRectMake(16, CGRectGetMaxY(dividerView.frame)+8, dividerView.frame.size.width, self.textViewHeight)];
    self.textView.backgroundColor=[UIColor clearColor];
    self.textView.font=[UIFont systemFontOfSize:16];
    [self.textView becomeFirstResponder];
    [self.view addSubview:self.textView];
    //导航栏上的发送按钮
    UIBarButtonItem *pushCommentItem=[self createButtonItem:@"ic_action_send_now"];
    self.navigationItem.rightBarButtonItem=pushCommentItem;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.textView resignFirstResponder];
}

-(void)bindingViewModel{
    WS(ws);
    //在键盘弹出关闭时，调整textView的高度
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIKeyboardWillShowNotification object:nil] subscribeNext:^(NSNotification *notification) {
        [ws adjustTextViewHeight:notification];
    }];
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIKeyboardWillHideNotification object:nil] subscribeNext:^(NSNotification *notification) {
        [ws adjustTextViewHeight:nil];
    }];
    
#pragma mark -alertView
    //创建用户名，邮箱对话框
    UIView *view=[[[NSBundle mainBundle] loadNibNamed:@"TouristAlertView" owner:self options:nil] lastObject];
    LTAlertView *alertView=[[LTAlertView alloc] initWithNib:view];
    NSString *name=[[NSUserDefaults standardUserDefaults] objectForKey:kName];
    //已经保存过账号和邮箱
    if (name) {
        NSString *email=[[NSUserDefaults standardUserDefaults] objectForKey:kEmail];
        self.textFieldName.text=name;
        self.textFieldEmail.text=email;
    }
    
    //下划线的响应
    [self changeLineColorWhenEdit:self.textFieldName line:ws.lineName];
    [self changeLineColorWhenEdit:self.textFieldEmail line:ws.lineEmail];
    //点击发送按钮的事件
    UIButton *pushCommentButton=(UIButton *)self.navigationItem.rightBarButtonItem.customView;
    [[pushCommentButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        if (!self.textView.text.length) {
            [[ToastHelper sharedToastHelper] toast:commentTooShort];
            return ;
        }
        [self.textView resignFirstResponder];
        [alertView show];
    }];

    
#pragma mark -pushComment
    PushCommentViewModel *viewModel=[PushCommentViewModel modelWithSendObject:self.sendObject];
    RACCommand *pushCommand=[[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        if (!self.textFieldName.text.length||!self.textFieldEmail.text.length) {
            [[ToastHelper sharedToastHelper] toast:touristInfoNotEnough];
            return [RACSignal empty];
        }
        [alertView dismiss];
        [self.textView resignFirstResponder];
        [[NSUserDefaults standardUserDefaults] setObject:self.textFieldName.text forKey:kName];
        [[NSUserDefaults standardUserDefaults] setObject:self.textFieldEmail.text forKey:kEmail];
        return viewModel.pushCommentSignal;
    }];
    //发送评论后的返回结果
    [[pushCommand.executionSignals switchToLatest] subscribeNext:^(Comments *comment) {
        [self popViewController:[CommentController class] object:comment];
    }];
    
    [pushCommand.errors subscribeNext:^(NSError *error) {
        [[ToastHelper sharedToastHelper] toast:pushCommentError];
    }];
    self.buttonRight.rac_command=pushCommand;
    [[self.buttonLeft rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        [alertView dismiss];
    }];
   }

-(void)changeLineColorWhenEdit:(UITextField *)textField line:(UIView *)line{
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:UITextFieldTextDidBeginEditingNotification
                                                           object:textField] subscribeNext:^(id x) {
        line.backgroundColor = RGB(0, 167, 157);
    }];
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:UITextFieldTextDidEndEditingNotification
                                                           object:textField] subscribeNext:^(id x) {
        line.backgroundColor = [UIColor grayColor];
    }];
}

-(void)adjustTextViewHeight:(NSNotification *)notification{
     CGRect frame=self.textView.frame;
    //键盘关闭
    if (!notification) {
        frame.size.height=self.textViewHeight;
        self.textView.frame=frame;
        return;
    }
    //键盘弹出
    CGSize kbSize = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    frame.size.height=self.textViewHeight-kbSize.height;
    self.textView.frame=frame;
}

-(void)BackClick{
    if (!self.textView.text.length) {
        [super BackClick];
        return;
    }
   LTAlertView *alertView= [[LTAlertView alloc] initWithTitle:@"煎蛋" contentText:@"确定退出编辑" leftButtonTitle:@"取消" rightButtonTitle:@"确定"];
    [alertView show];
    alertView.rightBlock=^{
        [super BackClick];
    };
}

@end
