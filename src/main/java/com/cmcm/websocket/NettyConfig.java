package com.cmcm.websocket;

import io.netty.channel.group.ChannelGroup;
import io.netty.channel.group.DefaultChannelGroup;
import io.netty.util.concurrent.GlobalEventExecutor;

/**
 * 整个工程的全局配置类
 * Created by Administrator on 2018/3/20.
 */
public class NettyConfig {

    /**
     * 存储每一个客户端接入进来时的channel对象
     */
    public static final ChannelGroup group = new DefaultChannelGroup(GlobalEventExecutor.INSTANCE);
}
