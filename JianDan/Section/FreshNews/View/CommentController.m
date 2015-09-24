#import "CommentController.h"
#import "CommentViewModel.h"
#import "CommentsCell.h"
#import "UITableView+FDTemplateLayoutCell.h"
#import "FreshNewsComment.h"
#import "InsetsLabel.h"
#import "PushCommentController.h"
#import "LTAlertView.h"

static NSString *reuseIdentifier=@"CommentsCell";
static NSString *reuseIdentifierWithParent=@"CommentsCellWithParentComent";

@interface CommentController()<LTFloorViewDelegate>

@property(strong,nonatomic) NSMutableArray *commentsArray;
@property(assign,nonatomic) NSInteger hotCommentCount;
@property (nonatomic, strong) CommentsCell *prototypeCell;
@property (nonatomic, strong) CommentViewModel *viewModel;
@property (weak, nonatomic) IBOutlet UILabel *labelUserName;
@property (weak, nonatomic) IBOutlet UIButton *buttonReply;
@property (weak, nonatomic) IBOutlet UIButton *buttonCopy;

@end

@implementation CommentController

-(void)viewDidLoad{
    [super viewDidLoad];
  
    [self initView];
    [self bindingViewModel];
}

-(void)initView{
    self.title=@"评论";
    //设置tableView
    self.tableView.estimatedRowHeight = 180;
    UINib *nib=[UINib nibWithNibName:reuseIdentifier bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:reuseIdentifier];
    [self.tableView registerNib:nib forCellReuseIdentifier:reuseIdentifierWithParent];
    //设置菜单项
    UIBarButtonItem *rightItem=[self createButtonItem:@"ic_action_edit"];
    self.navigationItem.rightBarButtonItem=rightItem;
    [[(UIButton *)rightItem.customView rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        [self pushViewController:[PushCommentController class] object:self.sendObject];
    }];
}

-(void)bindingViewModel{
    self.viewModel=[CommentViewModel new];
    [[self.viewModel.sourceCommand.executionSignals switchToLatest] subscribeNext:^(RACTuple *turple) {
        self.commentsArray=turple.first;
        if (self.commentsArray.count) {
            self.hotCommentCount=[turple.second integerValue];
            [self.tableView reloadData];
        }else{
            self.tableView.tableFooterView=[UIView new];
        }
    }];
    [self.viewModel.sourceCommand execute:self.sendObject];
    
    [self.viewModel.sourceCommand.executing subscribeNext:^(id x) {
        [ToastHelper sharedToastHelper].simleProgressVisiable=[x boolValue];
    }];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //将该条数据插到评论区中
    if ([self.resultObject isKindOfClass:[Comments class]]) {
        [self.viewModel getParentComment:self.commentsArray comment:self.resultObject];
        [self.commentsArray insertObject:self.resultObject atIndex:self.hotCommentCount];
        NSIndexPath *indexPath=[NSIndexPath indexPathForRow:0 inSection:self.hotCommentCount?1:0];
        [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }
}

#pragma mark -tableView delegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.commentsArray.count?(self.hotCommentCount?2:1):0;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    InsetsLabel *label=[[InsetsLabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 44) andInsets:UIEdgeInsetsMake(16, 8, 16, 0)];
    label.textAlignment=NSTextAlignmentLeft;
    label.textColor=[UIColor redColor];
    label.backgroundColor=[UIColor whiteColor];
    
    //没有热门评论
    if (!self.hotCommentCount) {
        label.text=@"最新评价";
    }else{
        label.text=section?@"最新评价":@"热门评价";
    }
    return label;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 44;
}

//第section个分段有多少行
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //没有热门评论
    if (self.hotCommentCount==0) {
        return self.commentsArray.count;
    }
    //有热门评论
    return section?self.commentsArray.count-self.hotCommentCount:self.hotCommentCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CommentsCell *cell =(CommentsCell*)[tableView dequeueReusableCellWithIdentifier:[self reuseIdentifierAtIndexPath:indexPath]];
    [cell bindViewModel:[self commentAtIndexPath:indexPath] forIndexPath:indexPath];
    cell.floorView.delegate=self;
    cell.floorView.tag=indexPath.row+self.hotCommentCount*indexPath.section;
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [tableView fd_heightForCellWithIdentifier:[self reuseIdentifierAtIndexPath:indexPath] cacheByIndexPath:indexPath configuration:^(CommentsCell *cell) {
        [cell bindViewModel:[self commentAtIndexPath:indexPath] forIndexPath:indexPath];
    }];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self showAlertView:[self commentAtIndexPath:indexPath]];
}

- (Comments *)commentAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger index=indexPath.row+self.hotCommentCount*indexPath.section;
    return  self.commentsArray[index];
}

-(NSString *)reuseIdentifierAtIndexPath:(NSIndexPath *)indexPath{
     BOOL isHasParent=[self commentAtIndexPath:indexPath].parentCommentsArray.count;
    return isHasParent?reuseIdentifierWithParent:reuseIdentifier;
}

#pragma mark LTFloorView delegate
-(void)floorView:(LTFloorView *)floorView didSelectRowAtIndex:(NSInteger)index{
    if (floorView.tag>=self.commentsArray.count) {
        return;
    }
    Comments *comment=self.commentsArray[floorView.tag];
    if (index>=comment.parentCommentsArray.count) {
        return;
    }
    Comments *subComment=comment.parentCommentsArray[index];
    [self showAlertView:subComment];
}

-(void)showAlertView:(Comments*)comment{
    UIView *view=[[[NSBundle mainBundle] loadNibNamed:@"CommentClickAlertView" owner:self options:nil] lastObject];
     LTAlertView *alertView=[[LTAlertView alloc] initWithNib:view];
    [alertView show];
    self.labelUserName.text=comment.name;
    [[self.buttonReply rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        [alertView dismiss];
        RACTuple *turple=[RACTuple tupleWithObjects:comment,self.sendObject, nil];
        [self pushViewController:[PushCommentController class] object:turple];
    }];
    [[self.buttonCopy rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        [alertView dismiss];
        [UIPasteboard generalPasteboard].string=comment.content;
        if (comment.content.length) {
            [[ToastHelper sharedToastHelper] toast:copySuccess];
        }
    }];
}
@end
