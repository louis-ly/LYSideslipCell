# LYSideslipCell

高仿微信侧滑效果, 兼容代码和xib创建, 屏幕翻转.

#### 首页消息Cell
![image](http://oad5jrdyg.bkt.clouddn.com/Snapshot1.gif)


#### 联系人Cell
![image](http://oad5jrdyg.bkt.clouddn.com/Snapshot2.gif)

#### 收藏Cell
![image](http://oad5jrdyg.bkt.clouddn.com/Snapshot3.gif)


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

2.在`tableView:cellForRowAtIndexPath:`方法中调用设置侧滑按钮方法:

```
[cell setRightButtons:@[button2]];
```

侧滑按钮可自行创建, 本库也提供`rowActionWithStyle:title`方法来创建常用的两种按钮`LYSideslipCellActionStyleNormal(灰色)`和`LYSideslipCellActionStyleDestructive(红色)`

```
UIButton *button1 = [cell rowActionWithStyle:LYSideslipCellActionStyleNormal title:@"取消关注"];
    UIButton *button2 = [cell rowActionWithStyle:LYSideslipCellActionStyleDestructive title:@"删除"];
```

3.设置代理 遵守`LYSideslipCellDelegate`协议, 实现用户按钮点击回调

```
cell.delegate = self;
```

```
@protocol LYSideslipCellDelegate <NSObject>
@optional;
/**
 *  选中了侧滑按钮
 *
 *  @param sideslipCell 当前响应的cell
 *  @param indexPath    cell在tableView中的位置
 *  @param index        选中的是第几个action
 */
- (void)sideslipCell:(LYSideslipCell *)sideslipCell rowAtIndexPath:(NSIndexPath *)indexPath didSelectedAtIndex:(NSInteger)index;
/**
 *  告知当前位置的cell是否需要侧滑按钮
 *
 *  @param sideslipCell 当前响应的cell
 *  @param indexPath    cell在tableView中的位置
 *
 *  @return YES 表示当前cell可以侧滑, NO 不可以
 */
- (BOOL)sideslipCell:(LYSideslipCell *)sideslipCell canSideslipRowAtIndexPath:(NSIndexPath *)indexPath;
@end
```

4.更多细节请看demo
