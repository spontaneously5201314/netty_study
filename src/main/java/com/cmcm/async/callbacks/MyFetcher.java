package com.cmcm.async.callbacks;

/**
 * Created by Administrator on 2017/12/24.
 */
public class MyFetcher implements Fetcher {

    final Data data;

    public MyFetcher(Data data) {
        this.data = data;
    }

    public void fetchData(FetcherCallBack callBack) {
        try {
            callBack.onData(data);
        } catch (Exception e) {
            callBack.onErrow(e);
        }
    }
}
