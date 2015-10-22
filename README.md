# JianDanIOS
一个仿煎蛋项目的iOS程序(性能和代码优雅兼顾)


# 开发模式
  ![开发模式](https://github.com/shenhualxt/JianDanIOS/blob/master/image/QQ20151022-1%402x.png)
  
# 项目架构
 ![ 项目架构](https://github.com/shenhualxt/JianDanIOS/blob/master/image/QQ20151022-2%402x.png)


# 项目描述

## 1、开发模式及要求：
  
+ ReactiveCocoa,MVVM开发模式，逻辑层和视图层高度分离；
+ 代码高度复用：逻辑层，模块的复用
+ 代码简练，每个类150行左右；
+ 代码可测试，对剥离出的逻辑层进行单用测试；
+  涉及的设计模式：单例，观察者，构建者；

##2、涉及到的知识点：
+ UIWebView的处理，引用CSS,添加进度条,车赢项目中设计JS交互；
+ 友盟分享，键盘处理，字数统计，复制粘贴；
+ 自定义控件，支持AutoLayoutt和代码两种方式创建；
+ quartz 2d，优化UITableViewCell层级（有11个变为3个子View）；
+ UITableView的优化（图片，cell，滑动等方面）；
+ 图片处理方面：切割，等比例缩放，GIF缓存，手势放大，下载，FastImageCache；
+ 数据处理：分页加载，缓存（sqlite3，支持分页,线程安全）；
+ GCD:group（队列组）,dispatch_semaphore_t，dispatch_once，dispatch_after等；
+ Runtime:动态获取对象的属性，initWithCoder中；
+ 动画：转场动画，帧动画（车赢项目中），CABasicAnimation（图片的缓缓加载），自动布局+动画，SpringAnimation；
+ ReactiveCocoa的深入使用：配合MVVM,解决MVC的问题、RACCommand、RACSignal+Operations、配合AFNetWorking网络访问工具类的封装、配合FMDB数据库的封装、响应式替代代理,notification,target-action,KVO,block；
+ 持续在改善中


##3、相关博客（持续更新）：
![Objective-C代码规范（1）](http://blog.csdn.net/shenhualxt/article/details/48053045)

![高仿煎蛋iOS项目基础配置（2）](http://blog.csdn.net/shenhualxt/article/details/48057169)


![使用AFNetWorking和ReactiveCocoa对网络请求进行封装（仿煎蛋iOS）（3）](http://blog.csdn.net/shenhualxt/article/details/48087147)

![UITableView数据绑定的简化，及性能优化（4）](http://blog.csdn.net/shenhualxt/article/details/48264811)

![一句代码解决UITableView的数据加载，点击事件，自定义cell,摆脱代理方法（5）](http://blog.csdn.net/shenhualxt/article/details/48265065)

![iOS项目的列表数据缓存，通用解决方案（sqllite）（6）](http://blog.csdn.net/shenhualxt/article/details/48266229)

