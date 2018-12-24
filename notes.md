### NioEventLoop
#### 三个问题
> 1.默认情况下,Netty服务端起多少线程？何时启动？   
2.Netty是如何解决jdk空轮询的bug的？    
3.Netty如何保证异步串行无锁化？

#### 重点
>1.NioEventLoop创建   

2.NioEventLoop启动
```
启动触发器：
    服务端启动绑定端口
    新连接接入通过chooser绑定一个NioEventLoop
```
3.NioEventLoop执行逻辑
```
1.deadline以及人物穿插逻辑处理
2.阻塞式select
3.避免jdk空轮询的bug
```