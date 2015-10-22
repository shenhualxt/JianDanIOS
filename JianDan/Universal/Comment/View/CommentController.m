#import "CommentController.h"
#import "CommentViewModel.h"
#import "CommentsCell.h"
#import "UITableView+FDTemplateLayoutCell.h"
#import "InsetsLabel.h"
#import "PushCommentController.h"
#import "LTAlertView.h"
#import "Comments.h"

static NSString *reuseIdentifier = @"CommentsCell";
static NSString *reuseIdentifierWithParent = @"CommentsCellWithParentComent";

@interface CommentController () <LTFloorViewDelegate>

@property(nonatomic, strong) NSMutableArray *commentsArray;
@property(nonatomic, strong) CommentsCell *prototypeCell;
@property(nonatomic, strong) CommentViewModel *viewModel;
@property(nonatomic, strong) NSString *thread_id;

@end

@implementation CommentController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
    [self bindingViewModel];
}

- (void)initView {
    self.title = @"评论";
    //设置tableView
    self.tableView.estimatedRowHeight = 140;
    UINib *nib = [UINib nibWithNibName:reuseIdentifier bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:reuseIdentifier];
    [self.tableView registerNib:nib forCellReuseIdentifier:reuseIdentifierWithParent];
    //设置菜单项
    UIBarButtonItem *rightItem = [self createButtonItem:@"ic_action_edit"];
    self.navigationItem.rightBarButtonItem = rightItem;
    [[(UIButton *) rightItem.customView rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        [self pushViewController:[PushCommentController class] object:self.thread_id];
    }];
}

- (void)bindingViewModel {
    self.thread_id = [NSString stringWithFormat:@"%@", self.sendObject];
    BOOL isFreshNewsComment = self.thread_id.length == 5;
    self.viewModel = [[CommentViewModel alloc] initWithType:isFreshNewsComment ? CommentsTypeFreshNews : CommentsTypeBoredPicture];
    [[self.viewModel.sourceCommand.executionSignals switchToLatest] subscribeNext:^(id result) {
        self.commentsArray = result;
        if ([result isKindOfClass:[RACTuple class]]) {
            self.commentsArray = [(RACTuple *) result first];
            self.thread_id = [(RACTuple *) result second]; //thread_id在这里被更换
        }

        if (self.commentsArray.count) {
            [self.tableView reloadData];
        } else {
            self.tableView.tableFooterView = [UIView new];
        }
    }];
    [self.viewModel.sourceCommand execute:self.thread_id];

    [self.viewModel.sourceCommand.executing subscribeNext:^(id x) {
        [ToastHelper sharedToastHelper].simleProgressVisiable = [x boolValue];
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //将该条数据插到评论区中
    if ([self.resultObject isKindOfClass:[Comments class]]) {
        NSString * threadId = [NSString stringWithFormat:@"%@", self.sendObject];
        BOOL isFreshNewsComment = threadId.length == 5;
        if (isFreshNewsComment) {
            [self.viewModel getParentComment:self.commentsArray comment:self.resultObject];
        }
        BOOL hasHotComments = self.commentsArray.count == 2;
        [[self.commentsArray objectAtIndex:hasHotComments ? 1 : 0] insertObject:self.resultObject atIndex:0];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:hasHotComments ? 1 : 0];
        [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }
}

#pragma mark -tableView delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.commentsArray.count;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    InsetsLabel *label = [[InsetsLabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 44) andInsets:UIEdgeInsetsMake(16, 8, 16, 0)];
    label.textAlignment = NSTextAlignmentLeft;
    label.textColor = [UIColor redColor];
    label.backgroundColor = [UIColor whiteColor];

    //没有热门评论
    if (self.commentsArray.count == 1) {
        label.text = @"最新评价";
    } else {
        label.text = section ? @"最新评价" : @"热门评价";
    }
    return label;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 44;
}

//第section个分段有多少行
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.commentsArray[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BOOL isHasParent = [self.commentsArray[indexPath.section][indexPath.row] parentCommentsArray].count;
    CommentsCell *cell = (CommentsCell *) [tableView dequeueReusableCellWithIdentifier:isHasParent ? reuseIdentifierWithParent : reuseIdentifier];
    [cell bindViewModel:self.commentsArray[indexPath.section][indexPath.row] forIndexPath:indexPath];
    if (isHasParent) {
        cell.floorView.delegate = self;
        cell.floorView.superview.tag = indexPath.section;
        cell.floorView.tag = indexPath.row;
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (IOS8) {
        return UITableViewAutomaticDimension;
    } else {
        Comments *comment = self.commentsArray[indexPath.section][indexPath.row];
        BOOL isHasParent = comment.parentCommentsArray.count;
        return [tableView fd_heightForCellWithIdentifier:isHasParent ? reuseIdentifierWithParent : reuseIdentifier cacheByKey:comment.post_id configuration:^(CommentsCell *cell) {
            [cell bindViewModel:comment forIndexPath:indexPath];
        }];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self showAlertView:self.commentsArray[indexPath.section][indexPath.row]];
}

#pragma mark LTFloorView delegate

- (void)floorView:(LTFloorView *)floorView didSelectRowAtIndex:(NSInteger)index {
    NSInteger row = floorView.tag;
    NSInteger selection = floorView.superview.tag;
    Comments *comment = self.commentsArray[selection][row];
    Comments *subComment = comment.parentCommentsArray[index];
    [self showAlertView:subComment];
}

- (void)showAlertView:(Comments *)comment {
    UIView *view = [[[NSBundle mainBundle] loadNibNamed:@"CommentClickAlertView" owner:self options:nil] lastObject];
    LTAlertView *alertView = [[LTAlertView alloc] initWithNib:view];
    [alertView show];
    UILabel *labelUserName = (UILabel *) [alertView viewWithTag:1];
    labelUserName.text = comment.name;
    UIButton *buttonReply = (UIButton *) [alertView viewWithTag:2];
    [[buttonReply rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        [alertView dismiss];
        RACTuple *turple = [RACTuple tupleWithObjects:comment, self.thread_id, nil];
        [self pushViewController:[PushCommentController class] object:turple];
    }];
    UIButton *buttonCopy = (UIButton *) [alertView viewWithTag:3];
    [[buttonCopy rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        [alertView dismiss];
        [UIPasteboard generalPasteboard].string = comment.content;
        if (comment.content.length) {
            [[ToastHelper sharedToastHelper] toast:copySuccess];
        }
    }];
}
@end
