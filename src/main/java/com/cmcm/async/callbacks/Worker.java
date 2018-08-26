package com.cmcm.async.callbacks;

/**
 * Created by Administrator on 2017/12/24.
 */
public class Worker {

    public void doWork() {
        Fetcher fetcher = new MyFetcher(new Data(1, 0));
        fetcher.fetchData(new FetcherCallBack() {
            public void onData(Data data) throws Exception {
                System.out.println("Data received: " + data);
            }

            public void onErrow(Throwable cause) {
                System.out.println("An error accour: " + cause.getMessage());
            }
        });
    }

    public static void main(String[] args) {
        Worker w = new Worker();
        w.doWork();
    }
}
