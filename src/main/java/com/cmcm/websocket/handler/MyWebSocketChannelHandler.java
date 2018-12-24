package com.cmcm.websocket.handler;

import io.netty.channel.ChannelInitializer;
import io.netty.channel.socket.SocketChannel;
import io.netty.handler.codec.http.HttpObjectAggregator;
import io.netty.handler.codec.http.HttpServerCodec;
import io.netty.handler.stream.ChunkedWriteHandler;

/**
 * 初始化连接时候的各个组件
 * Created by Administrator on 2018/3/20.
 */
public class MyWebSocketChannelHandler extends ChannelInitializer<SocketChannel> {
    @Override
    protected void initChannel(SocketChannel ch) throws Exception {
        ch.pipeline().addLast("http-codec", new HttpServerCodec())
                .addLast("aggregator", new HttpObjectAggregator(65536))
                .addLast("http-chunked", new ChunkedWriteHandler())
                .addLast("handler", new MyWebSocketChannelHandler());
    }
}
