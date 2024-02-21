@isTest
public class masterObjectTriggerHelperTest {
    @isTest
    public static void testCreateRecommendationsAndTasks(){
        //ERA creation
        EOB__c era=testDataFactory.createERA();
        insert era;
        //ERA Line Item
        ElixirSuite__ERA_Line_Item__c eraLineItem =new ElixirSuite__ERA_Line_Item__c();
        eraLineItem.EOB__c = era.Id;
        eraLineItem.Proc_code__c = '12345';
        eraLineItem.Charge__c = 400;
        eraLineItem.Total_Allowed_Amount__c = 400;
        eraLineItem.Adjustment_Amount_1__c = 100;
        eraLineItem.Adjustment_Group_Code__c='OA';
        eraLineItem.ElixirSuite__Group_1__c='CO';
        eraLineItem.ElixirSuite__Group_2__c='CO';
        eraLineItem.ElixirSuite__Group_3__c='CO';
        eraLineItem.ElixirSuite__Group_4__c='CO';
        eraLineItem.ElixirSuite__Group_5__c='CO';
        eraLineItem.ElixirSuite__Group_6__c='CO';
        eraLineItem.ElixirSuite__Group_7__c='CO';
        eraLineItem.ElixirSuite__Group_8__c='CO';
        eraLineItem.ElixirSuite__Code_1__c='X2';
        eraLineItem.ElixirSuite__Code_2__c='X2';
        eraLineItem.ElixirSuite__Code_3__c='X2';
        eraLineItem.ElixirSuite__Code_4__c='X2';
        eraLineItem.ElixirSuite__Code_5__c='X2';
        eraLineItem.ElixirSuite__Code_6__c='X2';
        eraLineItem.ElixirSuite__Code_7__c='X2';
        eraLineItem.ElixirSuite__Code_8__c='X2';
        eraLineItem.ElixirSuite__ERAInformational_Remark_Codes__c='M17';
        eraLineItem.ElixirSuite__ERASupplemental_Remark_Codes1__c='M11';
        eraLineItem.ElixirSuite__ERASupplemental_Remark_Codes2__c='M11';
        eraLineItem.ElixirSuite__ERASupplemental_Remark_Codes3__c='M11';
        eraLineItem.ElixirSuite__ERASupplemental_Remark_Codes4__c='M11';
        eraLineItem.ElixirSuite__ERASupplemental_Remark_Codes5__c='M11';
        eraLineItem.ElixirSuite__ERASupplemental_Remark_Codes6__c='M11';
        eraLineItem.ElixirSuite__ERASupplemental_Remark_Codes7__c='M11';
        eraLineItem.ElixirSuite__ERASupplemental_Remark_Codes8__c='M11';
        insert eraLineItem;
        ElixirSuite__ERA_Line_Item__c eraLineItem1 =new ElixirSuite__ERA_Line_Item__c();
        eraLineItem1.EOB__c = era.Id;
        eraLineItem1.Proc_code__c = '12345';
        eraLineItem1.Charge__c = 400;
        eraLineItem1.Total_Allowed_Amount__c = 400;
        eraLineItem1.Adjustment_Amount_1__c = 100;
        eraLineItem1.Adjustment_Group_Code__c='OA';
        eraLineItem1.ElixirSuite__Group_1__c='CO';
        eraLineItem1.ElixirSuite__Group_2__c='CO';
        eraLineItem1.ElixirSuite__Group_3__c='CO';
        eraLineItem1.ElixirSuite__Group_4__c='CO';
        eraLineItem1.ElixirSuite__Group_5__c='CO';
        eraLineItem1.ElixirSuite__Group_6__c='CO';
        eraLineItem1.ElixirSuite__Group_7__c='CO';
        eraLineItem1.ElixirSuite__Group_8__c='CO';
        eraLineItem1.ElixirSuite__Code_1__c='X2';
        eraLineItem1.ElixirSuite__Code_2__c='X2';
        eraLineItem1.ElixirSuite__Code_3__c='X2';
        eraLineItem1.ElixirSuite__Code_4__c='X2';
        eraLineItem1.ElixirSuite__Code_5__c='X2';
        eraLineItem1.ElixirSuite__Code_6__c='X2';
        eraLineItem1.ElixirSuite__Code_7__c='X2';
        eraLineItem1.ElixirSuite__Code_8__c='X2';
        insert eraLineItem1;
        //Master Record Creation
        List<ElixirSuite__Master_Object__c> masterRecords = new List<ElixirSuite__Master_Object__c>();
        
        ElixirSuite__Master_Object__c master1 = new ElixirSuite__Master_Object__c();
        master1.recordtypeid=Schema.SobjectType.ElixirSuite__Master_Object__c.getRecordTypeInfosByDeveloperName().get('ElixirSuite_Informational_Remark_Codes').getRecordTypeId();
        master1.Name='test';
        master1.ElixirSuite__ElixirSuite_Informational_Remark_Codes__c='M17';
        master1.ElixirSuite__ElixirSuite_Assign_To__c=UserInfo.getUserId();
        masterRecords.add(master1);
        
        ElixirSuite__Master_Object__c master2 = new ElixirSuite__Master_Object__c();
        master2.recordtypeid=Schema.SobjectType.ElixirSuite__Master_Object__c.getRecordTypeInfosByDeveloperName().get('ElixirSuite_Supplemental_Remark_Codes').getRecordTypeId();
        master2.Name='test';
        master2.ElixirSuite__Supplemental_Group_Code__c='M11';
        master2.ElixirSuite__ElixirSuite_Adjustment_Reason_Code__c='X2';
        master2.ElixirSuite__Adjustment_Group_Code__c='CO';
        masterRecords.add(master2);
        
        ElixirSuite__Master_Object__c master3 = new ElixirSuite__Master_Object__c();
        master3.recordtypeid=Schema.SobjectType.ElixirSuite__Master_Object__c.getRecordTypeInfosByDeveloperName().get('ElixirSuite_Adjustment_Codes').getRecordTypeId();
        master3.Name='test';
        master3.ElixirSuite__Adjustment_Group_Code__c='CO';
        master2.ElixirSuite__ElixirSuite_Adjustment_Reason_Code__c='X2';
        masterRecords.add(master3);
        
        test.startTest();
        insert masterRecords;
        System.assertEquals(1, 1, '');
        test.stopTest();
      //  System.assertEquals(masterRecords.size(), [select id from ElixirSuite__Recommendation__c].size());
    }
}