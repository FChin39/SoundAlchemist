# 炼音术士 SoundAlchemist

## 1. 基本功能

- 音色选择区
- 音频选择区
- 音调调整
- 开始转换
- 停止转换





## 2. 研发日志

#### Todo

1. 模型选择可以再改一下，改到SAModels文件夹下
2. 声卡输出，使用Jack作为虚拟输出设备，无需安装VB（放弃）
3. VC服务，使用FastAPI调用程序
   1. 完成前后端交互
      1. 推一条流到虚拟输出声卡上，替代VB（放弃）
4. 进行打包
   1. 
5. 模型处理
   1. 改名并合并模型与index





#### 6.26

1. 优化（将设备都只留下MME的）。
2. 将监听按钮取消。
3. 失败了！Jack好难用，不用了。
   - 使用 Jack，监听状态一直收听Jack的流
     - 虚拟声卡命名为SoundAlchemist Output
     - Conversion状态下
       - Jack的输入流为Conversion结果
     - 非Conversion状态下
       - Jack的输入流为输入设备
     - 监听设备一直监听Jack的流



#### 6.25

1. 完善了前端逻辑
2. 完成后端的逻辑，跑通前后端连接。
3. 要注意
   1. 算法只保留了rmvpe
   2. 需要选择正确的路径
4. 已经实现自定义前端啦哈哈。
5. 提交了api的pull request





#### 6.24

1. 完成VC服务API的雏形，还差将二者进行连接



#### 6.23

1. 完成了前端的UI Mock
2. 打通后端的Fast API接口



