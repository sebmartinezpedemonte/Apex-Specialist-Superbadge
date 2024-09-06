@isTest
public with sharing class MaintenanceRequestHelperTest {

    
    @isTest
    static void testPositiveCase() {
        // Create test Vehicle
        Vehicle__c vehicle = new Vehicle__c(Name = 'Teardrop Camper');
        insert vehicle;
        String vehicleId = vehicle.Id;

        // Create test Product2 (Equipment)
        Product2 equipment = new Product2(Name = 'Ball Valve 10 cm', Maintenance_Cycle__c = 30, Replacement_Part__c = true, lifespan_months__c = 10);
        insert equipment;
        
        // Create Maintenance Request
        Case maintenanceRequest = new Case(
                Status = 'New',
                Type = 'Routine Maintenance',
                Origin = 'Web',
                Subject = 'Repair test ',
                Vehicle__c = vehicle.Id,
                Equipment__c = equipment.Id,
                Date_Due__c = Date.today());
        insert maintenanceRequest;
        
        //Create Equipment Maintenance Item
        Equipment_Maintenance_Item__c equipMaintItem = new Equipment_Maintenance_Item__c(Equipment__c = equipment.Id, Maintenance_Request__c = maintenanceRequest.Id);
        insert equipMaintItem;
        
        // Perform test
        Test.startTest();
		maintenanceRequest.Status='Closed';
        update maintenanceRequest;
        Test.stopTest();

        // Assert results
		List<Case> maintenanceRequestsUpdated = [SELECT Id FROM Case WHERE Status = 'New']; 
		System.AssertEquals(1, maintenanceRequestsUpdated.size(), 'A new request should have been created with Status New');        
    }
    
    @isTest
    static void testNegativeCase() {
        // Create test Vehicle
        Vehicle__c vehicle = new Vehicle__c(Name = 'Teardrop Camper');
        insert vehicle;

        // Create test Product2 (Equipment)
        Product2 equipment = new Product2(Name = 'Ball Valve 10 cm', Maintenance_Cycle__c = 30, Replacement_Part__c = true, lifespan_months__c = 10);
        insert equipment;
        
        // Create Maintenance Request
        Case maintenanceRequest = new Case(
                Status = 'New',
                Type = 'Routine Maintenance',
                Origin = 'Web',
                Subject = 'Repair test ',
                Vehicle__c = vehicle.Id,
                Equipment__c = equipment.Id,
                Date_Due__c = Date.today());
        insert maintenanceRequest;
        
        //Create Equipment Maintenance Item
        Equipment_Maintenance_Item__c equipMaintItem = new Equipment_Maintenance_Item__c(Equipment__c = equipment.Id, Maintenance_Request__c = maintenanceRequest.Id);
        insert equipMaintItem;
        
        // Perform test
        Test.startTest();
		maintenanceRequest.Status='Working';
        update maintenanceRequest;
        Test.stopTest();

        // Assert results
		List<Case> maintenanceRequestsUpdated = [SELECT Id FROM Case]; 
		System.AssertEquals(1, maintenanceRequestsUpdated.size(), 'The list should have 1 record');        
    }
    
    @isTest
    static void testBulk() {
        List<Vehicle__C> vehicleList = new List<Vehicle__C>();
        List<Product2> equipmentList = new List<Product2>();
        List<Equipment_Maintenance_Item__c> workPartList = new List<Equipment_Maintenance_Item__c>();
        List<Case> requestList = new List<case>();
        List<Id> oldRequestIds = new List<id>();
        
        for(integer i = 0; i < 300; i++){
           vehicleList.add(new Vehicle__c(Name = 'Teardrop Camper'));
            equipmentList.add(new Product2(Name = 'Ball Valve 10 cm', Maintenance_Cycle__c = 30, Replacement_Part__c = true, lifespan_months__c = 10));
        }
        
        insert vehicleList;
        insert equipmentList;
        
        for(integer i = 0; i < 300; i++){
            requestList.add(new Case(
                Status = 'New',
                Type = 'Routine Maintenance',
                Origin = 'Web',
                Subject = 'Repair test ',
                Vehicle__c = vehicleList.get(i).Id,
                Equipment__c = equipmentList.get(i).Id,
                Date_Due__c = Date.today()));
        }
        insert requestList;
                              
        
       for(integer i = 0; i < 300; i++){
           workPartList.add(new Equipment_Maintenance_Item__c(Equipment__c = equipmentList.get(i).Id, Maintenance_Request__c = requestList.get(i).Id));
        }
        insert workPartList;                    
                            

        // Perform test
        Test.startTest();
        for(case req : requestList){
            req.Status = 'Closed';
            oldRequestIds.add(req.Id);
        }
        update requestList;
        Test.stopTest();

        // Assert results
		        list<case> allRequests = [select id
                                 from case
                                 where status = 'New'];
		system.assert(allRequests.size() == 300);    
    }
    
}