public with sharing class WarehouseSyncSchedule implements Schedulable {

    public static void execute(SchedulableContext ctx) {
        System.enqueueJob(new WarehouseCalloutService()) ;
    }
    
    // System.schedule('WarehouseSyncScheduleJob', '0 0 1 * * ?', new WarehouseSyncSchedule());
    }