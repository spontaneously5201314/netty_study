package com.cmcm.async.callbacks;

/**
 * Created by Administrator on 2017/12/24.
 */
public interface FetcherCallBack {

    void onData(Data data) throws Exception;

    void onErrow(Throwable cause);
}
