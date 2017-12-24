package com.cmcm.async.callbacks;

/**
 * Created by Administrator on 2017/12/24.
 */
public class Data {

    private int n;
    private int m;

    public int getN() {
        return n;
    }

    public void setN(int n) {
        this.n = n;
    }

    public int getM() {
        return m;
    }

    public void setM(int m) {
        this.m = m;
    }

    public Data(int n, int m) {
        this.n = n;
        this.m = m;
    }

    @Override
    public String toString() {
        return "Data{" +
                "n=" + n +
                ", m=" + m +
                '}';
    }
}

