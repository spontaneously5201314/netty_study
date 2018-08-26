package com.cmcm.netty.transports.channels;

import io.netty.channel.EventLoop;
import io.netty.channel.EventLoopGroup;
import io.netty.channel.socket.nio.NioServerSocketChannel;

/**
 * @author hongfei
 * @create 2018-01-08 下午2:05
 */
public class MyServerChannel extends NioServerSocketChannel {

    public MyServerChannel(EventLoop eventLoop, EventLoopGroup childGroup) {
        super(eventLoop, childGroup);
    }

    @Override
    public String toString() {
        return "MyServerChannel{}";
    }
}
