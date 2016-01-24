Teameeting iOS 客户端
编译环境
Xcode 6＋

运行项目
安装CocoaPods (关于CocoaPods的安装和使用，可参考这个教程)
在终端下打开项目所在的目录，执行pod install (若是首次使用CocoaPods，需先执行pod setup)
pod install命令执行成功后，通过新生成的xcworkspace文件打开工程运行项目
目录简介
AppDelegate： 存放AppDelegate和API定义
Model： 数据实体类
Resources： 存放除图片以外的资源文件，如html、css文件（图片资源存放在images.xcassets中)
Three： 存放非CocoaPods管理的第三方库
ViewCons： 存放所有的view controller
Views： 存放一些定制的视图
Tool： 存放工具类以及一些类扩展

项目用到的开源类库、组件
AFNetworking： 网络请求
DxPopover： 弹出视图
DZNEmpytDataSet： 空列表的提醒
MBProgressHUD： 显示提示或加载进度
MJRefresh： 刷新控件
mp3lame-for-ios： 录音
SSKeychain： 账号密码的存取
TTTAttributedLabel： 支持富文本显示的label

开源协议
OSChina iOS app is under the GPL license. See the LICENSE file for more details.
