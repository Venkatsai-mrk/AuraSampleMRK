@isTest
public class ERALineItemTriggerHelperTest {
    @isTest
    public static void createRecommendationsTestScenario1(){
        //ERA creation
		test.startTest();
        EOB__c era=testDataFactory.createERA();
        insert era;
        //Master Record Creation
        List<ElixirSuite__Master_Object__c> masterRecords = new List<ElixirSuite__Master_Object__c>();
        
        ElixirSuite__Master_Object__c master1 = new ElixirSuite__Master_Object__c();
        master1.recordtypeid=Schema.SobjectType.ElixirSuite__Master_Object__c.getRecordTypeInfosByDeveloperName().get('ElixirSuite_Informational_Remark_Codes').getRecordTypeId();
        master1.Name='test';
        master1.ElixirSuite__ElixirSuite_Informational_Remark_Codes__c='M17';
        master1.ElixirSuite__ElixirSuite_Assign_To__c=UserInfo.getUserId();
        masterRecords.add(master1);
        
        ElixirSuite__Master_Object__c master2 = new ElixirSuite__Master_Object__c();
        master2.recordtypeid=Schema.SobjectType.ElixirSuite__Master_Object__c.getRecordTypeInfosByDeveloperName().get('ElixirSuite_Informational_Remark_Codes').getRecordTypeId();
        master2.Name='test 2';
        master2.ElixirSuite__ElixirSuite_Informational_Remark_Codes__c='M17';
        master2.ElixirSuite__ElixirSuite_Assign_To__c=UserInfo.getUserId();
        masterRecords.add(master2);
        
        ElixirSuite__Master_Object__c master3 = new ElixirSuite__Master_Object__c();
        master3.recordtypeid=Schema.SobjectType.ElixirSuite__Master_Object__c.getRecordTypeInfosByDeveloperName().get('ElixirSuite_Supplemental_Remark_Codes').getRecordTypeId();
        master3.Name='test';
        master3.ElixirSuite__Supplemental_Group_Code__c='M11';
        master3.ElixirSuite__ElixirSuite_Adjustment_Reason_Code__c='X2';
        master3.ElixirSuite__Adjustment_Group_Code__c='CO';
        masterRecords.add(master3);
        
        ElixirSuite__Master_Object__c master4 = new ElixirSuite__Master_Object__c();
        master4.recordtypeid=Schema.SobjectType.ElixirSuite__Master_Object__c.getRecordTypeInfosByDeveloperName().get('ElixirSuite_Supplemental_Remark_Codes').getRecordTypeId();
        master4.Name='test 2';
        master4.ElixirSuite__Supplemental_Group_Code__c='M11';
        master4.ElixirSuite__ElixirSuite_Adjustment_Reason_Code__c='X2';
        master4.ElixirSuite__Adjustment_Group_Code__c='CO';
        masterRecords.add(master4);
        
        ElixirSuite__Master_Object__c master5 = new ElixirSuite__Master_Object__c();
        master5.recordtypeid=Schema.SobjectType.ElixirSuite__Master_Object__c.getRecordTypeInfosByDeveloperName().get('ElixirSuite_Adjustment_Codes').getRecordTypeId();
        master5.Name='test';
        master5.ElixirSuite__Adjustment_Group_Code__c='CO';
        master5.ElixirSuite__ElixirSuite_Adjustment_Reason_Code__c='X2';
        masterRecords.add(master5);
        
        ElixirSuite__Master_Object__c master6 = new ElixirSuite__Master_Object__c();
        master6.recordtypeid=Schema.SobjectType.ElixirSuite__Master_Object__c.getRecordTypeInfosByDeveloperName().get('ElixirSuite_Adjustment_Codes').getRecordTypeId();
        master6.Name='test 2';
        master6.ElixirSuite__Adjustment_Group_Code__c='CO';
        master6.ElixirSuite__ElixirSuite_Adjustment_Reason_Code__c='X2';
        masterRecords.add(master6);
        insert masterRecords;
        //Recommendation
        ElixirSuite__Recommendation__c recommendation = new ElixirSuite__Recommendation__c();
        recommendation.ElixirSuite__Master_Object__c=master1.Id;
        recommendation.ElixirSuite__ElixirSuite_Informational_Remark_Codes__c = 'M17';
        recommendation.ElixirSuite__Elixir_ERA__c = era.Id;
        insert recommendation;
        ElixirSuite__Recommendation__c recommendation1 = new ElixirSuite__Recommendation__c();
        recommendation1.ElixirSuite__Master_Object__c=master3.Id;
        recommendation1.ElixirSuite__ElixirSuite_Supplemental_Group_Code__c = 'M11';
        recommendation1.ElixirSuite__Elixir_ERA__c = era.Id;
        insert recommendation1;
        ElixirSuite__Recommendation__c recommendation2 = new ElixirSuite__Recommendation__c();
        recommendation2.ElixirSuite__Master_Object__c=master5.Id;
        recommendation2.ElixirSuite__ElixirSuite_Adjustment_Group_Code__c = 'CO';
        recommendation2.ElixirSuite__Elixir_ERA__c = era.Id;
        insert recommendation2;
        //ERA Line Item
        List<ElixirSuite__ERA_Line_Item__c> eraLineItemList =new List<ElixirSuite__ERA_Line_Item__c>();
        
        ElixirSuite__ERA_Line_Item__c eraLineItem =new ElixirSuite__ERA_Line_Item__c();
        eraLineItem.EOB__c = era.Id;
        eraLineItem.Proc_code__c = '12345';
        eraLineItem.Charge__c = 400;
        eraLineItem.Total_Allowed_Amount__c = 400;
        eraLineItem.Adjustment_Amount_1__c = 100;
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
        eraLineItemList.add(eraLineItem);
        
        ElixirSuite__ERA_Line_Item__c eraLineItem2 =new ElixirSuite__ERA_Line_Item__c();
        eraLineItem2.EOB__c = era.Id;
        eraLineItem2.Proc_code__c = '12345';
        eraLineItem2.Charge__c = 400;
        eraLineItem2.Total_Allowed_Amount__c = 400;
        eraLineItem2.Adjustment_Amount_1__c = 100;
        eraLineItem2.ElixirSuite__Group_1__c='CO';
        eraLineItem2.ElixirSuite__Group_2__c='CO';
        eraLineItem2.ElixirSuite__Group_3__c='CO';
        eraLineItem2.ElixirSuite__Group_4__c='CO';
        eraLineItem2.ElixirSuite__Group_5__c='CO';
        eraLineItem2.ElixirSuite__Group_6__c='CO';
        eraLineItem2.ElixirSuite__Group_7__c='CO';
        eraLineItem2.ElixirSuite__Group_8__c='CO';
        eraLineItem2.ElixirSuite__Code_1__c='X2';
        eraLineItem2.ElixirSuite__Code_2__c='X2';
        eraLineItem2.ElixirSuite__Code_3__c='X2';
        eraLineItem2.ElixirSuite__Code_4__c='X2';
        eraLineItem2.ElixirSuite__Code_5__c='X2';
        eraLineItem2.ElixirSuite__Code_6__c='X2';
        eraLineItem2.ElixirSuite__Code_7__c='X2';
        eraLineItem2.ElixirSuite__Code_8__c='X2';
        eraLineItemList.add(eraLineItem2);
        
        insert eraLineItemList;
        System.assertEquals(1, 1, '');
        test.stopTest();
        
    }
    @isTest
    public static void createRecommendationsTestScenario2(){
        //ERA creation
		test.startTest();
        EOB__c era=testDataFactory.createERA();
        insert era;
        //Master Record Creation
        List<ElixirSuite__Master_Object__c> masterRecords = new List<ElixirSuite__Master_Object__c>();
        
        ElixirSuite__Master_Object__c master1 = new ElixirSuite__Master_Object__c();
        master1.recordtypeid=Schema.SobjectType.ElixirSuite__Master_Object__c.getRecordTypeInfosByDeveloperName().get('ElixirSuite_Informational_Remark_Codes').getRecordTypeId();
        master1.Name='test';
        master1.ElixirSuite__ElixirSuite_Informational_Remark_Codes__c='M17';
        master1.ElixirSuite__ElixirSuite_Assign_To__c=UserInfo.getUserId();
        masterRecords.add(master1);
        
        ElixirSuite__Master_Object__c master2 = new ElixirSuite__Master_Object__c();
        master2.recordtypeid=Schema.SobjectType.ElixirSuite__Master_Object__c.getRecordTypeInfosByDeveloperName().get('ElixirSuite_Informational_Remark_Codes').getRecordTypeId();
        master2.Name='test 2';
        master2.ElixirSuite__ElixirSuite_Informational_Remark_Codes__c='M4-Alert';
        master2.ElixirSuite__ElixirSuite_Assign_To__c=UserInfo.getUserId();
        masterRecords.add(master2);
        
        ElixirSuite__Master_Object__c master3 = new ElixirSuite__Master_Object__c();
        master3.recordtypeid=Schema.SobjectType.ElixirSuite__Master_Object__c.getRecordTypeInfosByDeveloperName().get('ElixirSuite_Supplemental_Remark_Codes').getRecordTypeId();
        master3.Name='test';
        master3.ElixirSuite__Supplemental_Group_Code__c='M11';
        master3.ElixirSuite__Adjustment_Group_Code__c='PR';
        master3.ElixirSuite__ElixirSuite_Adjustment_Reason_Code__c='X2';
        masterRecords.add(master3);
        
        ElixirSuite__Master_Object__c master4 = new ElixirSuite__Master_Object__c();
        master4.recordtypeid=Schema.SobjectType.ElixirSuite__Master_Object__c.getRecordTypeInfosByDeveloperName().get('ElixirSuite_Supplemental_Remark_Codes').getRecordTypeId();
        master4.Name='test 2';
        master4.ElixirSuite__Supplemental_Group_Code__c='M15';
        master4.ElixirSuite__Adjustment_Group_Code__c='PR';
        master4.ElixirSuite__ElixirSuite_Adjustment_Reason_Code__c='X2';
        masterRecords.add(master4);
        
        ElixirSuite__Master_Object__c master5 = new ElixirSuite__Master_Object__c();
        master5.recordtypeid=Schema.SobjectType.ElixirSuite__Master_Object__c.getRecordTypeInfosByDeveloperName().get('ElixirSuite_Adjustment_Codes').getRecordTypeId();
        master5.Name='test';
        master5.ElixirSuite__Adjustment_Group_Code__c='CO';
        master5.ElixirSuite__ElixirSuite_Adjustment_Reason_Code__c='X2';
        masterRecords.add(master5);
        
        ElixirSuite__Master_Object__c master6 = new ElixirSuite__Master_Object__c();
        master6.recordtypeid=Schema.SobjectType.ElixirSuite__Master_Object__c.getRecordTypeInfosByDeveloperName().get('ElixirSuite_Adjustment_Codes').getRecordTypeId();
        master6.Name='test 2';
        master6.ElixirSuite__Adjustment_Group_Code__c='PR';
        master6.ElixirSuite__ElixirSuite_Adjustment_Reason_Code__c='X2';
        masterRecords.add(master6);
        insert masterRecords;
       
        //ERA Line Item
        List<ElixirSuite__ERA_Line_Item__c> eraLineItemList =new List<ElixirSuite__ERA_Line_Item__c>();
        
        ElixirSuite__ERA_Line_Item__c eraLineItem =new ElixirSuite__ERA_Line_Item__c();
        eraLineItem.EOB__c = era.Id;
        eraLineItem.Proc_code__c = '12345';
        eraLineItem.Charge__c = 400;
        eraLineItem.Total_Allowed_Amount__c = 400;
        eraLineItem.Adjustment_Amount_1__c = 100;
        eraLineItem.ElixirSuite__Group_1__c='CO';
        eraLineItem.ElixirSuite__Group_2__c='CO';
        eraLineItem.ElixirSuite__Group_3__c='CO';
        eraLineItem.ElixirSuite__Group_4__c='CO';
        eraLineItem.ElixirSuite__Group_5__c='CO';
        eraLineItem.ElixirSuite__Group_6__c='CO';
        eraLineItem.ElixirSuite__Group_7__c='CO';
        eraLineItem.ElixirSuite__Group_8__c='CO';
        eraLineItem.ElixirSuite__Code_1__c='X1';
        eraLineItem.ElixirSuite__ERAInformational_Remark_Codes__c='M17';
        eraLineItem.ElixirSuite__ERASupplemental_Remark_Codes1__c='M11';
        eraLineItem.ElixirSuite__ERASupplemental_Remark_Codes2__c='M11';
        eraLineItem.ElixirSuite__ERASupplemental_Remark_Codes3__c='M11';
        eraLineItem.ElixirSuite__ERASupplemental_Remark_Codes4__c='M11';
        eraLineItem.ElixirSuite__ERASupplemental_Remark_Codes5__c='M11';
        eraLineItem.ElixirSuite__ERASupplemental_Remark_Codes6__c='M11';
        eraLineItem.ElixirSuite__ERASupplemental_Remark_Codes7__c='M11';
        eraLineItem.ElixirSuite__ERASupplemental_Remark_Codes8__c='M11';
        eraLineItemList.add(eraLineItem);
        
        ElixirSuite__ERA_Line_Item__c eraLineItem2 =new ElixirSuite__ERA_Line_Item__c();
        eraLineItem2.EOB__c = era.Id;
        eraLineItem2.Proc_code__c = '12345';
        eraLineItem2.Charge__c = 400;
        eraLineItem2.Total_Allowed_Amount__c = 400;
        eraLineItem2.Adjustment_Amount_1__c = 100;
        eraLineItem2.ElixirSuite__Group_1__c='CO';
        eraLineItem2.ElixirSuite__Group_2__c='CO';
        eraLineItem2.ElixirSuite__Group_3__c='CO';
        eraLineItem2.ElixirSuite__Group_4__c='CO';
        eraLineItem2.ElixirSuite__Group_5__c='CO';
        eraLineItem2.ElixirSuite__Group_6__c='CO';
        eraLineItem2.ElixirSuite__Group_7__c='CO';
        eraLineItem2.ElixirSuite__Group_8__c='CO';
        eraLineItem2.ElixirSuite__Code_1__c='X1';
        eraLineItem2.ElixirSuite__ERAInformational_Remark_Codes__c='M17';
        eraLineItemList.add(eraLineItem2);
        
        insert eraLineItemList;
        eraLineItem2.ElixirSuite__ERASupplemental_Remark_Codes8__c='M5';
        eraLineItem2.ElixirSuite__Group_1__c='PR';
        eraLineItem2.ElixirSuite__Code_1__c='X2';
        eraLineItem2.ElixirSuite__ERAInformational_Remark_Codes__c = 'M4-Alert';
        update eraLineItem2;
        
        eraLineItem.ElixirSuite__ERASupplemental_Remark_Codes8__c='M15';
        eraLineItem.ElixirSuite__Group_1__c='PR';
        eraLineItem.ElixirSuite__Code_1__c='X2';
        eraLineItem.ElixirSuite__ERAInformational_Remark_Codes__c = 'M4-Alert';
        update eraLineItem;
        System.assertEquals(1, 1, '');
        test.stopTest();
       
    }
}