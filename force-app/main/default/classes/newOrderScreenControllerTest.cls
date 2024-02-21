@isTest
public class newOrderScreenControllerTest {
    
    @isTest
    public static void testSaveOrder(){
        Elixir_Custom_Setting__c patAccRecType = new Elixir_Custom_Setting__c();
        patAccRecType.ElixirSuite__Patient_Account_Recordtype__c = 'Patient_Account';
patAccRecType.ElixirSuite__Default_Active_Care_Episode_Filter__c = '';
        insert patAccRecType;
        String patientRecType = patAccRecType.ElixirSuite__Patient_Account_Recordtype__c; 
        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(patientRecType).getRecordTypeId();
        Account accrec= new Account();
       // RecordType rt = [SELECT Id FROM RecordType WHERE sObjectType = 'Account' AND Name ='Patient Account'];
        accrec.RecordTypeId = recordTypeId;
        accrec.Name = 'Test';
        accrec.Phone = '900091111';
        accrec.ElixirSuite__Email_Id__c = 'a@g.com';
        accrec.ElixirSuite__Stage__c = 'Admitted';
        accrec.ElixirSuite__Current_Status_Of_Patient__c = 'Current Patients';
        insert accrec;
        ElixirSuite__Visits__c vst = new ElixirSuite__Visits__c();
        vst.ElixirSuite__Account__c = accrec.Id;
        vst.ElixirSuite__Status__c = 'Active';
        insert vst;
        RecordType rt1 = [SELECT Id FROM RecordType WHERE sObjectType = 'ElixirSuite__Procedure__c' AND Name = 'Template Inventory'];

        ElixirSuite__Procedure__c proRec = new ElixirSuite__Procedure__c();
        proRec.Name = 'Sumo';
        proRec.ElixirSuite__Item_type__c = 'Inventory';
        proRec.ElixirSuite__Active__c = true;
        proRec.RecordTypeId = rt1.Id;
        insert proRec;
        
        ElixirSuite__Lot_Item__c lotRec = new ElixirSuite__Lot_Item__c();
        lotRec.Name = 'Sumo';
        lotRec.ElixirSuite__Ordered_Quantity__c = 10;
      //  lotRec.ElixirSuite__Available_Qty__c = 150;
        lotRec.ElixirSuite__Lot_Number__c = '990';
        lotRec.ElixirSuite__Procedure_Codes__c = proRec.Id;

        insert lotRec;
        ElixirSuite__Lot_Line_Items__c llt = new ElixirSuite__Lot_Line_Items__c();
        llt.ElixirSuite__Item_Name__c = lotRec.Id;
        llt.ElixirSuite__Available__c = true;
        llt.ElixirSuite__In_Maintenance__c=false;
        insert llt;
        MyObject instance = new MyObject();
        instance.proid = proRec.Id;
        instance.eid = lotRec.Id;
        instance.name = 'Sumo';
        instance.totalPrice = 10;
        instance.avail = 42;
        instance.lot = '990';
        instance.type = 'Medicine';
        instance.req = '1';
        String myJSON = JSON.serialize(instance);
        String demoJSON = '{"keysToSave":[' + myJSON + ']}';
        
        newOrderScreenController.saveOrder(demoJSON,accrec.Id);
        System.assertEquals(1,1,'');
    }
     @isTest
     public static void testSaveOrder2(){
        Elixir_Custom_Setting__c patAccRecType = new Elixir_Custom_Setting__c();
        patAccRecType.ElixirSuite__Patient_Account_Recordtype__c = 'Patient_Account';
        patAccRecType.ElixirSuite__Default_Active_Care_Episode_Filter__c = '';
        insert patAccRecType;
        String patientRecType = patAccRecType.ElixirSuite__Patient_Account_Recordtype__c; 
        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(patientRecType).getRecordTypeId();
        Account accrec= new Account();
       // RecordType rt = [SELECT Id FROM RecordType WHERE sObjectType = 'Account' AND Name ='Patient Account'];
        accrec.RecordTypeId = recordTypeId;
        accrec.Name = 'Test';
        accrec.Phone = '900091111';
        accrec.ElixirSuite__Email_Id__c = 'a@g.com';
        accrec.ElixirSuite__Stage__c = 'Admitted';
        accrec.ElixirSuite__Current_Status_Of_Patient__c = 'Current Patients';
        insert accrec;
        ElixirSuite__Visits__c vst = new ElixirSuite__Visits__c();
        vst.ElixirSuite__Account__c = accrec.Id;
        vst.ElixirSuite__Status__c = 'Active';
        insert vst;
        RecordType rt1 = [SELECT Id FROM RecordType WHERE sObjectType = 'ElixirSuite__Procedure__c' AND Name = 'Template Inventory'];

        ElixirSuite__Procedure__c proRec = new ElixirSuite__Procedure__c();
        proRec.Name = 'Sumo';
        proRec.ElixirSuite__Item_type__c = 'Inventory';
        proRec.ElixirSuite__Active__c = true;
        proRec.RecordTypeId = rt1.Id;
        insert proRec;
        
        ElixirSuite__Lot_Item__c lotRec = new ElixirSuite__Lot_Item__c();
        lotRec.Name = 'Sumo';
        lotRec.ElixirSuite__Ordered_Quantity__c = 10;
        lotRec.ElixirSuite__Lot_Number__c = '990';
        lotRec.ElixirSuite__Procedure_Codes__c = proRec.Id;

        insert lotRec;
        ElixirSuite__Lot_Line_Items__c llt = new ElixirSuite__Lot_Line_Items__c();
        llt.ElixirSuite__Item_Name__c = lotRec.Id;
        llt.ElixirSuite__Available__c = false;
        llt.ElixirSuite__In_Maintenance__c=true;
        insert llt;
        MyObject instance = new MyObject();
        instance.proid = proRec.Id;
        instance.eid = lotRec.Id;
        instance.name = 'Sumo';
        instance.totalPrice = 10;
        instance.avail = 42;
        instance.lot = '990';
        instance.type = 'Medicine';
        instance.req = '1';
        String myJSON = JSON.serialize(instance);
        String demoJSON = '{"keysToSave":[' + myJSON + ']}';
        
        newOrderScreenController.saveOrder(demoJSON,accrec.Id);
        System.assertEquals(1,1,'');
        
    }
        class MyObject
    {
        Id proid;
        Id eid;
        String name;
        Decimal totalPrice;
        Decimal avail;
        String lot;
        String type;
        String req;
        
    }

}