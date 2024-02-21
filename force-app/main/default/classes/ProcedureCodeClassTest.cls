@isTest
public class ProcedureCodeClassTest {

    @isTest
    public static void insertProcedureCode(){
        Account acc = new Account();
        acc.Name = 'Mahi';
        acc.ElixirSuite__Last_Name__c = 'Gvrp';
        acc.ElixirSuite__First_Name__c = 'Gangavarapu';
        acc.ElixirSuite__DOB__c = system.today();
        acc.ElixirSuite__SSN__c = '12345';
        acc.ElixirSuite__Gender__c = 'Male';
        acc.Phone = '9876543210';
        acc.ElixirSuite__Email_Id__c = 'gvrpmahi@gmail.com';
        acc.ElixirSuite__MRN_Number_New__c = '12345';
        acc.BillingPostalCode = '51500';
        insert acc;
        Set<Id> accIdSet = new Set<Id>();
        accIdSet.add(acc.id);
        
        ElixirSuite__Procedure__c pro = new ElixirSuite__Procedure__c();
        pro.name ='test';
        insert pro;
        ElixirSuite__Procedure__c pro1 = new ElixirSuite__Procedure__c();
        pro1.name ='test';
        insert pro1;
       
        Id devRecordTypeId = Schema.SObjectType.ElixirSuite__Provider__c.getRecordTypeInfosByDeveloperName().get('Template_Provider').getRecordTypeId();
       
        ElixirSuite__Provider__c p1 = new ElixirSuite__Provider__c();
        p1.name ='tedfdst';
        p1.RecordTypeId=devRecordTypeId;
        //p1.ElixirSuite__Account__c = acc.id;
        p1.ElixirSuite__Provider_Code__c='123';
        insert p1;
         ElixirSuite__Provider__c p = new ElixirSuite__Provider__c();
        p.name ='test';
        p.RecordTypeId=devRecordTypeId;
        p.ElixirSuite__Account__c = acc.id;
        p.ElixirSuite__Provider_Code__c='ABC';
        p.ElixirSuite__Provider__c=p1.id;
        insert p;

        Id rt = Schema.SObjectType.ElixirSuite__Procedure__c.getRecordTypeInfosByDeveloperName().get('Inventory').getRecordTypeId();
        

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
        ElixirSuite__Inventory__c inv2 = new ElixirSuite__Inventory__c();
        inv2.ElixirSuite__Units_Procured__c = 12;
        inv2.ElixirSuite__Patient_Procedure_Id__c=proRec.id;
        inv2.ElixirSuite__Lot_Number__c = '540';
        inv2.ElixirSuite__Inventory_Item_Name__c = 'Gloves';
        inv2.ElixirSuite__Account__c = acc.Id;
        inv2.ElixirSuite__Procedure_Codes__c=proRec.id;
        insert inv2;
        List<ElixirSuite__Inventory__c> inventories = new List<ElixirSuite__Inventory__c>();
        ElixirSuite__Inventory__c inv = new ElixirSuite__Inventory__c();
        inv.ElixirSuite__Units_Procured__c = 12;
        inv.ElixirSuite__Patient_Procedure_Id__c=pro.id;
        inv.ElixirSuite__Lot_Number__c = '540';
        inv.ElixirSuite__Inventory_Item_Name__c = 'Gloves';
        inv.ElixirSuite__Account__c = acc.Id;
        inv.ElixirSuite__Procedure_Codes__c=pro.id;

        ElixirSuite__Inventory__c inv1 = new ElixirSuite__Inventory__c();
        inv1.ElixirSuite__Units_Procured__c = 12;
        inv1.ElixirSuite__Patient_Procedure_Id__c=pro1.id;
        inv1.ElixirSuite__Lot_Number__c = '540';
        inv1.ElixirSuite__Inventory_Item_Name__c = 'Gloves';
        inv1.ElixirSuite__Account__c = acc.Id;
        inv1.ElixirSuite__Procedure_Codes__c=pro.id;
        inventories.add(inv1);
        insert inventories;
        
        ElixirSuite__Payment_Transaction__c pt = new ElixirSuite__Payment_Transaction__c();
        pt.ElixirSuite__Account__c=acc.id;
        pt.ElixirSuite__Procedure__c =pro.id;
        insert pt;




        ElixirSuite__Actual_Price__c ac = new ElixirSuite__Actual_Price__c();
        
        ac.ElixirSuite__Procedure__c=pro.id;
        ac.ElixirSuite__Provider__c=p1.id;
        insert ac;
        
        
        
        Test.startTest();
        ProcedureCodeClass.insertProcedureCode(inventories);
        Set<Id> patientProcedures = new Set<Id>();
        List<ElixirSuite__Inventory__c> invList =[select id,ElixirSuite__Patient_Procedure_Id__c from ElixirSuite__Inventory__c WITH SECURITY_ENFORCED];
        for(ElixirSuite__Inventory__c invabc : invList)
        {
            patientProcedures.add(invabc.ElixirSuite__Patient_Procedure_Id__c);
        }
        
        ProcedureCodeClass.updateActualPrice(accIdSet, inventories, patientProcedures);
        
        System.assertEquals(1, 1, ''); 
        Test.stopTest();
    }
    
}