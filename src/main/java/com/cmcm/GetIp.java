package com.cmcm;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.net.InetAddress;
import java.net.URL;

/**
 * @author hongfei
 * @create 2018-02-07 下午3:21
 */
public class GetIp {
    /**
     * @param args
     * @throws Exception
     * @author liuwl
     */
    public static void main(String[] args) throws Exception {
        System.out.println("本机的外网IP是：" + GetIp.getWebIP("http://www.ip138.com/ip2city.asp"));
        System.out.println("本机的内网IP是：" + GetIp.getLocalIP());
    }


    /**
     * 获取外网地址
     *
     * @param strUrl
     * @return
     */
    public static String getWebIP(String strUrl) {
        try {
            //连接网页
            URL url = new URL(strUrl);
            BufferedReader br = new BufferedReader(new InputStreamReader(url.openStream()));
            String s = "";
            StringBuffer sb = new StringBuffer("");
            String webContent = "";
            //读取网页信息
            while ((s = br.readLine()) != null) {
                sb.append(s + "\r\n");
            }
            br.close();
            //网页信息
            webContent = sb.toString();
            int start = webContent.indexOf("[") + 1;
            int end = webContent.indexOf("]");
            //获取网页中  当前 的 外网IP
            webContent = webContent.substring(start, end);
            return webContent;

        } catch (Exception e) {
            e.printStackTrace();
            return "error open url:" + strUrl;
        }
    }

    public static String getLocalIP() throws Exception {
        String localIP = "";
        InetAddress addr = (InetAddress) InetAddress.getLocalHost();
        //获取本机IP
        localIP = addr.getHostAddress().toString();
        return localIP;
    }
}
