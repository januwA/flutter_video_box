## 0.11.0 - 2020-2-26

* 对网络的断开和重连进行了简单的优化
* 增加API`addConnectivityChangedListener`可以监听网络状态的变更,当然您也可以直接使用`connectivity`包

## 0.10.1 - 2020-2-19

* 日常维护，升级依赖，并无api变动
* 优化全屏时，监听设备的旋转

## 0.10.0 - 2020-1-25

- 增加API: 
  - `options` 可以设置自定义参数
  - `bottomViewBuilder` 用于自定义VideoBox底部视图

## 0.9.1 - 2020-1-14

* 删除平台差异 [#14](https://github.com/januwA/flutter_video_box/issues/14)
* 删除部分作用不大方法和减少对外部暴露无用的方法。
* 变更: `setLoop`=>`setLooping`，`loop`=>`looping`
* 检查example的每个示例

## 0.9.0 - 2020-1-9
* 增加Api: `customLoadingWidget`  `customBufferedWidget`  `customFullScreen` `controllerLayerDuration`
* 变更API: `onFullScreen`=>`onFullScreenSwitch` `controllerDuration`=> `controllerLiveDuration`
* 添加画中画example

## 0.8.2 - 2019-12-25

* `screen`依赖在打包时出现错误，删除此库，相关功能不可用
* 增加`addFullScreenChangeListener`用于监听全屏变化事件

## 0.8.1 - 2019-12-22

* 修复一个小错误

## 0.8.0 - 2019-12-22

* 更新依赖包
* Example迁移至AndroidX
* 修复部分错误
* 修改，增加部分API

## 0.7.2 - 2019-11-19

* 重新提交一个版本，没有任何更新

## 0.7.1 - 2019-11-18

* 优化大量问题

## 0.7.0 - 2019-11-8

* api更变，构建方式发生了改变
* 修复: 视频的原始尺寸
* 修复: `paly()`和`pause()`AnimatedIcon显示错误


## 0.6.0 - 2019-10-7

* 增加: [改变屏幕亮度]和[媒体音量功能]


## 0.5.2 - 2019-10-2

* 修复[children] [beforeChildren] [afterChildren] 的BUG

## 0.5.1 - 2019-9-23

* 优化buffer loading的显示

## 0.5.0 - 2019-9-22

* 默认ui改变

## 0.4.2 - 2019-9-6

* 增加缓冲进度条
* 自定义全屏页面


## 0.4.1 - 2019-9-5

* 更新video_player依赖版本


## 0.4.0 - 2019-9-1

* api 更改
* 代码优化
* 处理细微bug


## 0.3.1 - 2019-8-22

* 优化ui
* 使用'AnimatedSwitcher'代替'AnimatedCrossFade'

## 0.3.0 - 2019-8-6

* api变更
* 优化ui
* 优化视频播放完毕的处理事件


## 0.2.4 - 2019-7-9

* 修复 ui的BUG


## 0.2.3 - 2019-7-7

* 播放按钮bug显示
* buffers为空错误

## 0.2.2 - 2019-7-5

* 优化ui
* 暂无发现BUG

## 0.2.1 - 2019-7-4

* 优化ui


## 0.2.0 - 2019-7-4

* 更改api
* 更改ui

## [0.1.2] - 2019-7-1

* 更新依赖包

## [0.1.1] - 2019-6-26

* 优化全屏事件，用户好在外面调用
* 文档尽量使用英语
* 更新mobx依赖包的版本
* 优化setSource函数
* 增加videos的example

## [0.1.0] - 2019-6-24

* 更改了重要的api
* 删除了src

## [0.0.4] - 2019-6-24

* 只要改变了src，不管是否为空，都会结束掉当前播放的video，并开启loading状态，但是在插件内部并不会去加载空的src地址

## [0.0.3] - 2019-6-23

* 增加option选项
* 切换video的src

## [0.0.2] - 2019-6-23

* 增加option选项，和快进，快退功能

## [0.0.1] - 2019-6-22

* 使用[video_player](https://pub.flutter-io.cn/packages/video_player)包装的video播放器