package com.cmcm;

import java.net.Inet4Address;
import java.net.InetAddress;
import java.net.UnknownHostException;

/**
 * @author hongfei
 * @create 2018-01-10 下午2:16
 */
public class kafka {

    public static void main(String[] args) throws UnknownHostException {
//        System.out.println(java.net.InetAddress.getCanonicalHostName());
        InetAddress address = InetAddress.getLocalHost();
        System.out.println(address.getCanonicalHostName());
    }
}
