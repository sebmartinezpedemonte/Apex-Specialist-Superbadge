@IsTest
private class WarehouseCalloutServiceTest {
        @isTest
    	static void testBatchExecutionSuccess() {
        Test.setMock(HttpCalloutMock.class, new WarehouseCalloutServiceMock());
        Test.startTest();
		WarehouseCalloutService.execute(null);
        Test.stopTest();
        List<Product2> upsertedEquipments = [SELECT Id FROM Product2];
        System.assertEquals(1, upsertedEquipments.size(), 'One item of equipment should have been inserted');   

        
  }

}