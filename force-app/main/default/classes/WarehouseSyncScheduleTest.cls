@isTest
private class WarehouseSyncScheduleTest {
    
        @isTest
    	static void testSchedulerExecution() {
        List<CronTrigger> existingJobs = [SELECT Id, CronJobDetail.Name, State FROM CronTrigger WHERE CronJobDetail.Name = 'WarehouseSyncScheduleJob'];
        for (CronTrigger job : existingJobs) {
            System.abortJob(job.Id);
        }
        String cronExp = '0 0 1 * * ?';       
        Test.startTest();
        System.schedule('WarehouseSyncScheduleJob', cronExp, new WarehouseSyncSchedule());        
        Test.stopTest(); 
        List<CronTrigger> jobs = [SELECT Id, CronJobDetail.Name, State FROM CronTrigger WHERE CronJobDetail.Name = 'WarehouseSyncScheduleJob'];
        System.assertEquals(1, jobs.size(), 'Se esperaba que haya un job llamado RickAndMortyBatchUpsert Job');
    }
    
}