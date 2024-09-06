public with sharing class MaintenanceRequestHelper {
    public static void updateWorkOrders(List<Case> updWorkOrders) {
        List<Case> validCases = new List<Case>();

        // Filter valid cases directly using only Trigger.New data
        for (Case c : updWorkOrders) {
            if (c.Status == 'Closed' && (c.Type == 'Repair' || c.Type == 'Routine Maintenance')) {
                validCases.add(c);
            }
        }
		if (validCases.isEmpty()) {
            return; // Exit early if there are no valid cases
        }

        // Corrected query to include Equipment__r.Maintenance_Cycle__c explicitly
        List<Case> closedCases = [SELECT Id, Vehicle__c, Equipment__c, Equipment__r.Maintenance_Cycle__c,
            (SELECT Id, Equipment__c, Quantity__c, Equipment__r.Maintenance_Cycle__c FROM Equipment_Maintenance_Items__r)
            FROM Case WHERE Id IN :validCases];

        List<Case> newCases = new List<Case>();

        for (Case closedCase : closedCases) {
            Integer minCycle = null;
            for (Equipment_Maintenance_Item__c item : closedCase.Equipment_Maintenance_Items__r) {
                Integer cycle = (Integer) item.Equipment__r.Maintenance_Cycle__c;
                if (minCycle == null || cycle < minCycle) {
                    minCycle = cycle;
                }
            }

            Integer dueDays = minCycle != null ? minCycle : (Integer) closedCase.Equipment__r.Maintenance_Cycle__c;

            Case newCase = new Case(
                ParentId = closedCase.Id,
                Status = 'New',
                Subject = 'Routine Maintenance',
                Type = 'Routine Maintenance',
                Vehicle__c = closedCase.Vehicle__c,
                Equipment__c = closedCase.Equipment__c,
                Origin = 'Web',
                Date_Reported__c = Date.Today(),
                Date_Due__c = Date.Today().addDays(dueDays)
            );

            newCases.add(newCase);
        }
        insert newCases;

        List<Equipment_Maintenance_Item__c> clonedItems = new List<Equipment_Maintenance_Item__c>();
        for (Case newCase : newCases) {
            for (Case closedCase : closedCases) {
                if (closedCase.Id == newCase.ParentId) {
                    for (Equipment_Maintenance_Item__c item : closedCase.Equipment_Maintenance_Items__r) {
                        Equipment_Maintenance_Item__c clonedItem = item.clone();
                        clonedItem.Maintenance_Request__c = newCase.Id;
                        clonedItems.add(clonedItem);
                    }
                    break;
                }
            }
        }
        insert clonedItems;
    }
}