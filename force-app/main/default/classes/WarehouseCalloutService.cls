public with sharing class WarehouseCalloutService implements Queueable , Database.AllowsCallouts {


    private static final String WAREHOUSE_URL = 'https://th-superbadge-apex.herokuapp.com/equipment';
    
    public static void execute(QueueableContext context) {
        runWarehouseEquipmentSync();
    }

    @future(callout=true)
    public static void runWarehouseEquipmentSync() {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(WAREHOUSE_URL);

        request.setMethod('GET');
        HttpResponse response = http.send(request);
        
        if(response.getStatusCode() == 200) {
            List<Object> equipments = (List<Object> )JSON.deserializeUntyped(response.getBody());
            List<Product2> newEquipments = new List<Product2>();
            for(Object o:equipments) {
                Map<String, Object> mapProduct = (Map<String, Object> )o;
                newEquipments.add(new Product2(
                    Replacement_Part__c = (Boolean)mapProduct.get('replacement'),
                    Current_Inventory__c = (Integer)mapProduct.get('quantity'),
                    Name = (String)mapProduct.get('name'),
                    Maintenance_Cycle__c = (Integer)mapProduct.get('maintenanceperiod'),
                    Lifespan_Months__c = (Integer)mapProduct.get('lifespan'),
                    Cost__c = (Decimal)mapProduct.get('cost'),
                    Warehouse_SKU__c = (String)mapProduct.get('sku')
                ));
            }
            if(newEquipments.size() > 0) {
                upsert newEquipments Warehouse_SKU__c;
            }
        }
    }
}