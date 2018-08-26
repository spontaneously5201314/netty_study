package com.cmcm.javase;

/**
 * @author hongfei
 * @create 2018-01-05 下午4:07
 */
public class AssertTest {

    public static void main(String[] args) {
        assert args == null || args.length == 0 : "args is null";
        System.out.println(args.toString());
    }
}
