package com.cmcm.netty.transports.handler;

import io.netty.channel.ChannelHandler;
import io.netty.channel.ChannelHandlerContext;
import io.netty.channel.SimpleChannelInboundHandler;

/**
 * @author hongfei
 * @create 2018-01-05 下午1:47
 */
@ChannelHandler.Sharable
public class MySimpleInBoundHandler extends SimpleChannelInboundHandler<String> {

    public MySimpleInBoundHandler(boolean autoRelease) {
        super(autoRelease);
    }

    protected void messageReceived(ChannelHandlerContext channelHandlerContext, String s) throws Exception {

    }

    protected void channelRead0(ChannelHandlerContext ctx, String msg) throws Exception {
        System.out.println("MySimpleInBoundHandler has receive msg : " + msg);
    }
}
