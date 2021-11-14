## 0.16.1 2021-11-14

- 修复过期的api
- 更新example

## 0.16.0 2021-8-4

- 升级到现代 flutter，api 可能也会随着发生变化
- api change: 删除了 `aspectRatio` 选项，使用它时总是出现未知错误，所以删除了

## 0.15.6 2021-3-12

- refactor: flutter 2.0

## 0.15.5 2021-1-18

- fix: `Overflow.visible` to `Clip.none`

## 0.15.4 2021-1-6

- 修复在Android上出现的错误

## 0.15.3 2021-1-6

- 优化了fullScreen在Web上的行为

## 0.15.2 2020-12-1

* update packages and example video url

## 0.15.1 2020-10-14

* 修复若干BUG

## 0.15.0 2020-10-9

- API 重大变更
- 将大量VideoController的参数迁移到VideoBox上
- 删除大量无用的属性
- 优化了在极差网络下播放视频，导致解码器自动关闭，需要切换网络后才能继续播放
- 更多详情可以看源码和example

## 0.14.2 2020-10-8

* fix: "setState() or markNeedsBuild() called when widget tree was locked." error

## 0.14.1 2020-10-8

- fix: BoxConstraints error

## 0.14.0 2020-10-8

* update packages
* add: `setPlaybackSpeed`
* 修复了部分错误(可能修复了)

## 0.13.0 2020-6-14

* add: `addAccelerometerEventsListenner`钩子，可以监听屏幕的旋转，然后自定义事件 [#28](https://github.com/januwA/flutter_video_box/issues/28)
* 就增加了一个api，其它无任何变更

## 0.12.0 2020-4-15

* 少量api变更
* 优化了代码
* 修改了buffer loading显示逻辑

## 0.11.4 2020-4-6

* 当断网进入buffer loading状态时，隐藏play/pause按钮，网络恢复时在显示
* 修改buffer laoding视图和mask的叠加层顺序 (应该不会造成BUG 🦄)

## 0.11.3 2020-4-3

* 无api变更

## 0.11.2 2020-4-1

* update mobx package
* 为快进和快退动作增加了icon动画

## 0.11.1 2020-3-19

* Prepare for 1.0.0 version of sensors and package_info. ([dart_lsc](http://github.com/amirh/dart_lsc))
* 优化部分代码，并无API变动.

## 0.11.0 - 2020-2-26

* 对网络的断开和重连进行了简单的优化
* 增加API`addConnectivityChangedListener`可以监听网络状态的变更,当然您也可以直接使用`connectivity`包

## 0.10.1 - 2020-2-19

* 日常维护，升级依赖，并无api变动
* 优化全屏时，监听设备的旋转

## 0.10.0 - 2020-1-25

- add: 
  - `options` 可以设置自定义参数
  - `bottomViewBuilder` 用于自定义VideoBox底部视图

## 0.9.1 - 2020-1-14

* 删除平台差异 [#14](https://github.com/januwA/flutter_video_box/issues/14)
* 删除部分作用不大方法和减少对外部暴露无用的方法。
* 变更: `setLoop`=>`setLooping`，`loop`=>`looping`
* 检查example的每个示例

## 0.9.0 - 2020-1-9
* add: `customLoadingWidget`  `customBufferedWidget`  `customFullScreen` `controllerLayerDuration`
* change: `onFullScreen`=>`onFullScreenSwitch` `controllerDuration`=> `controllerLiveDuration`
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
* fix: 视频的原始尺寸
* fix: `paly()`和`pause()`AnimatedIcon显示错误


## 0.6.0 - 2019-10-7

* add: "改变屏幕亮度"和"媒体音量功能" (之后已废弃)


## 0.5.2 - 2019-10-2

* fix: `children` `beforeChildren` `afterChildren`

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

* update packages

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