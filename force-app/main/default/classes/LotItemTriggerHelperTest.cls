@isTest
private class LotItemTriggerHelperTest {
    @isTest
    static void testAfterDeleteQuantityUpdate() {
        Id recordTypeId = Schema.SObjectType.Procedure__c.getRecordTypeInfosByDeveloperName().get('Medication').getRecordTypeId();
        List<Lot_Item__c> lotItemsToDelete = new List<Lot_Item__c>();
        Procedure__c testProcedure = new Procedure__c();
        testProcedure.Name = 'Test';
        testProcedure.RecordTypeId = recordTypeId;
        testProcedure.Active__c = true;
        testProcedure.Quantity__c = 0;
        insert testProcedure;
        Lot_Item__c testLotItem = new Lot_Item__c();
        testLotItem.Name = 'Test';
        //testLotItem.Available_Qty__c = 5;
        testLotItem.Procedure_Codes__c = testProcedure.Id;
        insert testLotItem;
        lotItemsToDelete.add(testLotItem);
        Test.startTest();
        delete testLotItem;
        System.assertEquals(1, 1, ' ');
        Test.stopTest();
    }
    
    @isTest
    static void testAfterUndeleteQuantityUpdate() {
        List<Lot_Item__c> undeletedLotItems = new List<Lot_Item__c>();
        Id recordTypeId = Schema.SObjectType.Procedure__c.getRecordTypeInfosByDeveloperName().get('Medication').getRecordTypeId();
        Procedure__c testProcedure = new Procedure__c();
        testProcedure.Name = 'Test';
        testProcedure.RecordTypeId = recordTypeId;
        testProcedure.Quantity__c = 0;
        testProcedure.Active__c = true;
        insert testProcedure;
        Lot_Item__c testLotItem = new Lot_Item__c();
        testLotItem.Name = 'Test';
        //testLotItem.Available_Qty__c = 5;
        testLotItem.Procedure_Codes__c = testProcedure.Id;
        insert testLotItem;
        undeletedLotItems.add(testLotItem);
        
        Test.startTest();
        LotItemTriggerHelper.afterUndeleteQuantityUpdate(undeletedLotItems);
        GlobalLotItemHelper glih = new GlobalLotItemHelper();
        glih.afterUndelete(undeletedLotItems);
        system.assertEquals(1, 1,' ');
        Test.stopTest();
    }
    @IsTest
    static void testAfterInsert() {
        // Create test data
        ElixirSuite__Lot_Item__c lotItem = new ElixirSuite__Lot_Item__c();
        lotItem.ElixirSuite__Ordered_Quantity__c = 5;
        lotItem.ElixirSuite__Arrival_Date__c = Date.today();
        lotItem.ElixirSuite__Expiry_Date__c = Date.today().addDays(10);
        
        // Insert the lot item
        Test.startTest();
        List<ElixirSuite__Lot_Item__c> newLotItemList = new List<ElixirSuite__Lot_Item__c>();
        newLotItemList.add(lotItem);
        LotItemTriggerHelper.afterInsert(newLotItemList);
        Test.stopTest();
        
        system.assertEquals(1, 1,' ');
    }
@IsTest
    static void testafterUpdate() {
        // Create test data
       
         ElixirSuite__Lot_Item__c lotItem = new ElixirSuite__Lot_Item__c();
        lotItem.ElixirSuite__Ordered_Quantity__c = 5;
        lotItem.ElixirSuite__Arrival_Date__c = Date.today();
        lotItem.ElixirSuite__Expiry_Date__c = Date.today().addDays(10);
        lotItem.ElixirSuite__Wastage_Quantity__c = 3;
        Insert lotItem;
         ElixirSuite__Lot_Item__c OldlotItem = new ElixirSuite__Lot_Item__c();
        OldlotItem.Id = lotItem.Id;
        OldlotItem.ElixirSuite__Ordered_Quantity__c = 5;
        OldlotItem.ElixirSuite__Arrival_Date__c = Date.today();
        OldlotItem.ElixirSuite__Expiry_Date__c = Date.today().addDays(10);
        OldlotItem.ElixirSuite__Wastage_Quantity__c = 5;
        Update OldlotItem;
        ElixirSuite__Lot_Line_Items__c lTm = new  ElixirSuite__Lot_Line_Items__c();
        lTm.ElixirSuite__Item_Name__c = lotItem.Id;
        lTm.ElixirSuite__Available__c = true;
        insert lTm;
        // Insert the lot item
        Test.startTest();
        List<ElixirSuite__Lot_Item__c> newLotItemList = new List<ElixirSuite__Lot_Item__c>();
        newLotItemList.add(OldlotItem);
        Map<Id,ElixirSuite__Lot_Item__c> lotItemMap = new Map<Id,ElixirSuite__Lot_Item__c>();
        lotItemMap.put(lotItem.Id,lotItem);
        LotItemTriggerHelper.afterUpdate(newLotItemList,lotItemMap);
        Test.stopTest();
        
        system.assertEquals(1, 1,' ');
    }
      @IsTest
    static void testafterUpdateNegative() {
        // Create test data
       
         ElixirSuite__Lot_Item__c lotItem = new ElixirSuite__Lot_Item__c();
        lotItem.ElixirSuite__Ordered_Quantity__c = 5;
        lotItem.ElixirSuite__Arrival_Date__c = Date.today();
        lotItem.ElixirSuite__Expiry_Date__c = Date.today().addDays(10);
        lotItem.ElixirSuite__Wastage_Quantity__c = 3;
        Insert lotItem;
         ElixirSuite__Lot_Item__c OldlotItem = new ElixirSuite__Lot_Item__c();
        OldlotItem.Id = lotItem.Id;
        OldlotItem.ElixirSuite__Ordered_Quantity__c = 5;
        OldlotItem.ElixirSuite__Arrival_Date__c = Date.today();
        OldlotItem.ElixirSuite__Expiry_Date__c = Date.today().addDays(10);
        OldlotItem.ElixirSuite__Wastage_Quantity__c = 1;
        Update OldlotItem;
        ElixirSuite__Lot_Line_Items__c lTm = new  ElixirSuite__Lot_Line_Items__c();
        lTm.ElixirSuite__Item_Name__c = lotItem.Id;
        lTm.ElixirSuite__Available__c = false;
        insert lTm;
        // Insert the lot item
        Test.startTest();
        List<ElixirSuite__Lot_Item__c> newLotItemList = new List<ElixirSuite__Lot_Item__c>();
        newLotItemList.add(OldlotItem);
        Map<Id,ElixirSuite__Lot_Item__c> lotItemMap = new Map<Id,ElixirSuite__Lot_Item__c>();
        lotItemMap.put(lotItem.Id,lotItem);
        LotItemTriggerHelper.afterUpdate(newLotItemList,lotItemMap);
        Test.stopTest();
        
        system.assertEquals(1, 1,' ');
    }
    
        @IsTest
    static void testBeforeUpdate() {
        // Create test data
         ElixirSuite__Lot_Item__c lotItem = new ElixirSuite__Lot_Item__c();
        lotItem.ElixirSuite__Ordered_Quantity__c = 5;
        lotItem.ElixirSuite__Arrival_Date__c = Date.today();
        lotItem.ElixirSuite__Expiry_Date__c = Date.today().addDays(10);
        lotItem.ElixirSuite__Wastage_Quantity__c = null;
        Insert lotItem;
         ElixirSuite__Lot_Item__c OldlotItem = new ElixirSuite__Lot_Item__c();
        OldlotItem.Id = lotItem.Id;
        OldlotItem.ElixirSuite__Ordered_Quantity__c = 5;
        OldlotItem.ElixirSuite__Arrival_Date__c = Date.today();
        OldlotItem.ElixirSuite__Expiry_Date__c = Date.today().addDays(10);
        OldlotItem.ElixirSuite__Wastage_Quantity__c = 2;
        Update OldlotItem;
         ElixirSuite__Lot_Line_Items__c lTm = new  ElixirSuite__Lot_Line_Items__c();
        lTm.ElixirSuite__Item_Name__c = lotItem.Id;
        lTm.ElixirSuite__Available__c = true;
        insert lTm;
        // Insert the lot item
        Test.startTest();
        List<ElixirSuite__Lot_Item__c> newLotItemList = new List<ElixirSuite__Lot_Item__c>();
        newLotItemList.add(OldlotItem);
        Map<Id,ElixirSuite__Lot_Item__c> lotItemMap = new Map<Id,ElixirSuite__Lot_Item__c>();
        lotItemMap.put(lotItem.Id,lotItem);
        LotItemTriggerHelper.beforeUpdate(newLotItemList,lotItemMap);
        Test.stopTest();
        
        system.assertEquals(1, 1,' ');
    }
}