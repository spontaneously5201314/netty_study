package com.cmcm.netty.transports;

import com.cmcm.netty.transports.handler.MyInBoundHandler;
import com.cmcm.netty.transports.handler.MySimpleInBoundHandler;
import io.netty.bootstrap.ServerBootstrap;
import io.netty.buffer.ByteBuf;
import io.netty.buffer.Unpooled;
import io.netty.channel.*;
import io.netty.channel.nio.NioEventLoopGroup;
import io.netty.channel.socket.SocketChannel;
import io.netty.channel.socket.nio.NioServerSocketChannel;
import io.netty.util.CharsetUtil;

import java.net.InetSocketAddress;

/**
 * Created by Administrator on 2018/1/1.
 */
public class NettyNioServer {
    public void server(int port) throws Exception {
        final ByteBuf buf = Unpooled.unreleasableBuffer(Unpooled.copiedBuffer("Hi!\r\n", CharsetUtil.UTF_8));
        // 事件循环组
        EventLoopGroup group = new NioEventLoopGroup();
        try {
            // 用来引导服务器配置
            ServerBootstrap b = new ServerBootstrap();
            // 使用NIO异步模式
            b.group(group).channel(NioServerSocketChannel.class).localAddress(new InetSocketAddress(port))
                    /*.handler(new ChannelHandlerAdapter() {
                        @Override
                        public void handlerAdded(ChannelHandlerContext ctx) throws Exception {
                            super.handlerAdded(ctx);
                        }
                    })*/
                    // 指定ChannelInitializer初始化handlers
                    .childHandler(new ChannelInitializer<SocketChannel>() {
                        @Override
                        protected void initChannel(SocketChannel ch) throws Exception {
                            // 添加一个“入站”handler到ChannelPipeline
                            ch.pipeline()/*.addLast(new ChannelInboundHandlerAdapter() {
                                @Override
                                public void channelActive(ChannelHandlerContext ctx) throws Exception {
                                    // 连接后，写消息到客户端，写完后便关闭连接
                                    ctx.writeAndFlush(buf.duplicate()).addListener(ChannelFutureListener.CLOSE);
                                }
                            })*/
                                    .addLast(new MySimpleInBoundHandler(false))
                                    .addLast(new MyInBoundHandler());
                        }
                    })/*.childHandler(new ChannelInitializer<SocketChannel>() {
                @Override
                protected void initChannel(SocketChannel ch) throws Exception {
                    ch.pipeline().addLast(new SimpleChannelInboundHandler<String>() {
                        @Override
                        protected void channelRead0(ChannelHandlerContext ctx, String msg) throws Exception {
                            System.out.println("My NettyNioServer has receive msg : " + msg);
                        }
                    });
                }

                @Override
                public void channelReadComplete(ChannelHandlerContext ctx) throws Exception {
                    System.out.println("My NettyNioServer has complete deal, and quit");
                }
            })*/;
            // 绑定服务器接受连接
            ChannelFuture f = b.bind().sync();
            f.channel().closeFuture().sync();
        } catch (Exception e) {
            // 释放所有资源
            group.shutdownGracefully();
        }
    }

    public static void main(String[] args) {
        try {
            new NettyNioServer().server(8080);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
