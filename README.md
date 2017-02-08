# LYSideslipCell

高仿微信侧滑效果, 兼容代码和xib创建, 屏幕翻转.

#### 首页消息Cell
![image](http://oad5jrdyg.bkt.clouddn.com/LYSideslipCell_Snapshot1.gif)


#### 联系人Cell
![image](http://oad5jrdyg.bkt.clouddn.com/LYSideslipCell_Snapshot2.gif)

#### 收藏Cell
![image](http://oad5jrdyg.bkt.clouddn.com/LYSideslipCell_Snapshot3.gif)


## Podfile
支持[CocoaPods](http://cocoapods.org/). 只要在`Podfile`文件中加入一行代码

```
pod 'LYSideslipCell'
```

接着在终端输入`pod install`即可



## How to use

1.继承该类

```
@interface LYHomeCell : LYSideslipCell
@end
```

2.在`tableView:cellForRowAtIndexPath:`方法中设置代理:

```
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LYHomeCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(LYSideslipCell.class)];
    if (!cell) {
        cell = [[LYHomeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NSStringFromClass(LYSideslipCell.class)];
        cell.delegate = self;
    }
    return cell;
}
```

3.实现`LYSideslipCellDelegate`协议`sideslipCell:editActionsForRowAtIndexPath:`方法，返回侧滑按钮事件数组。

```
#pragma mark - LYSideslipCellDelegate
- (NSArray<LYSideslipCellAction *> *)sideslipCell:(LYSideslipCell *)sideslipCell editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    LYSideslipCellAction *action = [LYSideslipCellAction rowActionWithStyle:LYSideslipCellActionStyleNormal title:@"备注" handler:^(LYSideslipCellAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        [sideslipCell hiddenAllSideslip];
    }];
    return @[action];
}
```

4.更多细节请看demo
