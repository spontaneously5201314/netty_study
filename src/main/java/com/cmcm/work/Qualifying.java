package com.cmcm.work;

import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.atomic.AtomicBoolean;

/**
 * @author hongfei
 * @create 2018-01-10 下午7:10
 */
public class Qualifying {
    private volatile Map<Long, AtomicBoolean> qualifyingSettlement = new ConcurrentHashMap<>();
    /**
     * 判断排位赛中一个房间是否已经正在结算
     *
     * @param roomId
     * @return false表示该房间没有结算，true表示该房间已经结算
     */
    public synchronized boolean isQualifyingSettlement(Long roomId) {
        if(qualifyingSettlement == null){
            qualifyingSettlement = new ConcurrentHashMap<>();
        }
        if(qualifyingSettlement.size() == 0){
            AtomicBoolean atomicBoolean = new AtomicBoolean(true);
            qualifyingSettlement.put(roomId, atomicBoolean);
            return false;
        }
        AtomicBoolean atomicBoolean = qualifyingSettlement.get(roomId);
        if(atomicBoolean == null){
            atomicBoolean = new AtomicBoolean(true);
            qualifyingSettlement.put(roomId, atomicBoolean);
            return false;
        }
        return atomicBoolean.get();
    }

    public static void main(String[] args) {
        Qualifying qualifying = new Qualifying();
        System.out.println(qualifying.isQualifyingSettlement(1L));
        System.out.println(qualifying.isQualifyingSettlement(2L));
        System.out.println(qualifying.isQualifyingSettlement(1L));
        System.out.println(qualifying.isQualifyingSettlement(3L));
        System.out.println(qualifying.isQualifyingSettlement(4L));
        System.out.println(qualifying.isQualifyingSettlement(2L));
        System.out.println(qualifying.isQualifyingSettlement(4L));
        System.out.println(qualifying.isQualifyingSettlement(3L));
    }
}
