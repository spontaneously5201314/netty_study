package com.cmcm.netty.transports;

import java.io.IOException;
import java.io.OutputStream;
import java.net.ServerSocket;
import java.net.Socket;
import java.nio.charset.Charset;

/**
 * Blocking networking without Netty
 * Created by Administrator on 2018/1/1.
 */
public class PlainOioServer {

    public void server(int port) throws IOException {
        //bind server to port
        final ServerSocket socket = new ServerSocket(port);
        try {
            while (true) {
                //accept connection
                final Socket clientSocket = socket.accept();
                System.out.println("Accepted connection from " + clientSocket);
                //create new thread to handle connection
                new Thread(() -> {
                    OutputStream out;
                    try {
                        out = clientSocket.getOutputStream();
                        //write message to connected client
                        out.write("Hi!\r\n".getBytes(Charset.forName("UTF-8")));
                        out.flush();
                        //close connection once message written and flushed
                        clientSocket.close();
                    } catch (IOException e) {
                        try {
                            clientSocket.close();
                        } catch (IOException e1) {
                            e1.printStackTrace();
                        }
                    }
                    //start thread to begin handling
                }).start();
            }
        } catch (IOException e) {
            e.printStackTrace();
            socket.close();
        }
    }
}
