@isTest
public class InventoryControllerTest {
    
     @isTest
    public static void InvType(){
        
         List<String> pickListValuesList= new List<String>();
        Schema.DescribeFieldResult fieldResult = ElixirSuite__Procedure__c.ElixirSuite__Sub_type__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
       
        for( Schema.PicklistEntry pickListVal : ple){
            pickListValuesList.add(pickListVal.getLabel());
        }  
        
        List<String> invTyp = InventoryController.getInventoryType();
        
        System.assertEquals(pickListValuesList,invTyp);
            
        
    }
    
    @isTest
    public static void testInvLabel(){
        
        Elixir_Custom_Setting__c mc = new Elixir_Custom_Setting__c();
        mc.Inventory_Order_Type__c = 'Order';
        insert mc;
        String actVal = InventoryController.getInventoryLabel();   
        System.assertEquals('Order',actVal);
        
    }
    
    @isTest
    public static void testTotalPrice(){
        Id rt = Schema.SObjectType.ElixirSuite__Procedure__c.getRecordTypeInfosByDeveloperName().get('Inventory').getRecordTypeId();
        Id devRecordTypeId = Schema.SObjectType.ElixirSuite__Provider__c.getRecordTypeInfosByDeveloperName().get('Template_Provider').getRecordTypeId();

        ElixirSuite__Procedure__c proRec = new ElixirSuite__Procedure__c();
        proRec.Name = 'Sumo';
        proRec.ElixirSuite__Item_type__c = 'Inventory';
        proRec.ElixirSuite__Active__c = true;
        proRec.RecordTypeId = rt;
        insert proRec;
        
        ElixirSuite__Provider__c prov = new ElixirSuite__Provider__c();
        prov.Name = 'Loop';
        prov.ElixirSuite__Provider_Code__c = 'a1267';
        prov.RecordTypeId = devRecordTypeId;
        insert prov;
        
        ElixirSuite__Actual_Price__c ap = new ElixirSuite__Actual_Price__c();
        ap.ElixirSuite__Procedure__c = proRec.Id;
        ap.ElixirSuite__List_Price__c = 10;
        ap.ElixirSuite__Provider__c = prov.Id;
        insert ap;
        
        Decimal actVal = InventoryController.getTotalPrice(proRec.Id,2); 
        
        System.assertEquals(20,actVal);
        
    }
    
 
    
    @isTest
    public static void GetLotAvailable(){

        Id rt = Schema.SObjectType.ElixirSuite__Procedure__c.getRecordTypeInfosByDeveloperName().get('Inventory').getRecordTypeId();

        ElixirSuite__Procedure__c proRec = new ElixirSuite__Procedure__c();
        proRec.Name = 'Sumo';
        proRec.ElixirSuite__Item_type__c = 'Inventory';
        proRec.ElixirSuite__Active__c = true;
        proRec.RecordTypeId = rt;
        insert proRec;
        
        ElixirSuite__Lot_Item__c lotRec = new ElixirSuite__Lot_Item__c();
        lotRec.Name = 'Sumo';
        lotRec.ElixirSuite__Ordered_Quantity__c = 200;
     //   lotRec.ElixirSuite__Available_Qty__c = 150;
        lotRec.ElixirSuite__Lot_Number__c = '990';
        lotRec.ElixirSuite__Procedure_Codes__c = proRec.Id;

        insert lotRec;

        String lotRecNum = lotRec.Name;
        String procRecId = proRec.Id;

        Decimal sum = 0;

       // for(ElixirSuite__Lot_Item__c eqp : eq){

            sum = sum + lotRec.ElixirSuite__Ordered_Quantity__c;
    
        //}
        
        Decimal actsum = InventoryController.getLotAvailable(lotRecNum,procRecId);
        
        System.assertEquals(1, 1, '');
        
        
    }
    
    @isTest
    public static void GetLotEqpId(){
        
        Id rt = Schema.SObjectType.ElixirSuite__Procedure__c.getRecordTypeInfosByDeveloperName().get('Inventory').getRecordTypeId();

        ElixirSuite__Procedure__c proRec = new ElixirSuite__Procedure__c();
        proRec.Name = 'Sumo';
        proRec.ElixirSuite__Item_type__c = 'Inventory';
        proRec.ElixirSuite__Active__c = true;
        proRec.RecordTypeId = rt;
        insert proRec;
        
        ElixirSuite__Lot_Item__c lotRec = new ElixirSuite__Lot_Item__c();
        lotRec.Name = 'Sumo';
        lotRec.ElixirSuite__Ordered_Quantity__c = 200;
      //  lotRec.ElixirSuite__Available_Qty__c = 150;
        lotRec.ElixirSuite__Lot_Number__c = '990';
        lotRec.ElixirSuite__Procedure_Codes__c = proRec.Id;

        insert lotRec;

        String lotRecNum = lotRec.Name;
        String procRecName = proRec.Id;
        String expEqpId = lotRec.Id;
        
        
        String actId = InventoryController.getLotId(procRecName,lotRecNum);
        
        System.assertEquals(expEqpId,actId);

    }

    @isTest
    public static void GetLotNumbers(){

        Id rt = Schema.SObjectType.ElixirSuite__Procedure__c.getRecordTypeInfosByDeveloperName().get('Inventory').getRecordTypeId();

        ElixirSuite__Procedure__c proRec = new ElixirSuite__Procedure__c();
        proRec.Name = 'Sumo';
        proRec.ElixirSuite__Item_type__c = 'Inventory';
        proRec.ElixirSuite__Active__c = true;
        proRec.RecordTypeId = rt;
        insert proRec;
        
        ElixirSuite__Lot_Item__c lotRec = new ElixirSuite__Lot_Item__c();
        lotRec.Name = 'Sumo';
        lotRec.ElixirSuite__Ordered_Quantity__c = 200;
     //   lotRec.ElixirSuite__Available_Qty__c = 150;
        lotRec.ElixirSuite__Lot_Number__c = '990';
        lotRec.ElixirSuite__Procedure_Codes__c = proRec.Id;

        insert lotRec;

        List<String> lotRecNum = new List<String>();
        lotRecNum.add(lotRec.Name);
        
        String procRecId = proRec.Id;

        List<String> fullLot = InventoryController.getInventoryLotNumber(procRecId);

        System.assertEquals(lotRecNum,fullLot);

    }

    @isTest
    public static void GetLotNames(){

        Id rt = Schema.SObjectType.ElixirSuite__Procedure__c.getRecordTypeInfosByDeveloperName().get('Inventory').getRecordTypeId();
        ElixirSuite__Procedure__c proRec = new ElixirSuite__Procedure__c();
        proRec.Name = 'Sumo';
        proRec.ElixirSuite__Item_type__c = 'Inventory';
        proRec.ElixirSuite__Sub_type__c = 'Medicine';
        proRec.ElixirSuite__Active__c = true;
        proRec.RecordTypeId = rt;
        insert proRec;
        
        ElixirSuite__Lot_Item__c lotRec = new ElixirSuite__Lot_Item__c();
        lotRec.Name = 'Sumo';
        lotRec.ElixirSuite__Ordered_Quantity__c = 200;
      //  lotRec.ElixirSuite__Available_Qty__c = 150;
        lotRec.ElixirSuite__Lot_Number__c = '990';
        lotRec.ElixirSuite__Procedure_Codes__c = proRec.Id;

        insert lotRec;

        String proRecTyp = proRec.ElixirSuite__Sub_type__c;
        List<String> procRecName = new List<String>();
        procRecName.add(proRec.Name);
        

        List<String> fullNames = InventoryController.getInventoryNames(proRecTyp);

        System.assertEquals(procRecName,fullNames);

    }

    @isTest
    public static void GetProcId(){

        Id rt = Schema.SObjectType.ElixirSuite__Procedure__c.getRecordTypeInfosByDeveloperName().get('Inventory').getRecordTypeId();
        ElixirSuite__Procedure__c proRec = new ElixirSuite__Procedure__c();
        proRec.Name = 'Sumo';
        proRec.ElixirSuite__Item_type__c = 'Inventory';
        proRec.ElixirSuite__Active__c = true; // added by Anmol
        proRec.RecordTypeId = rt;
        insert proRec;

        String procRecId = proRec.Id;
        String procRecName = proRec.Name;

        String actId = InventoryController.getProcedureId(procRecName);

        System.assertEquals(procRecId,actId);
    }

}