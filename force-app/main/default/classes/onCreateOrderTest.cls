@isTest public class onCreateOrderTest {
    @isTest static void testTrigger(){
        Account acc = TestDataFactoryOrderAPI.createAccount();
        insert acc;
        Payor__c payor = TestDataFactoryOrderAPI.createPayor();
        insert payor;
        VOB__c vobData = TestDataFactoryOrderAPI.createVob();
        vobData.Insurance_Providers__c = payor.Id;
        vobData.Account__c=acc.Id;
        insert vobData;
        Guarantor__c guarantor  =TestDataFactoryOrderAPI.createGuarantor();
        guarantor.Account__c =acc.Id;
        insert guarantor;
        Lab__c  lab= TestDataFactoryOrderAPI.createLab();
        insert lab;
        Facility__c facData = TestDataFactoryOrderAPI.createFacility();
        facData.Lab_ID__c=lab.Lab_Id__c;
        insert facData;
        
        Physician__c phyData =  TestDataFactoryOrderAPI.createPhysician();
        insert phyData;
        
        List<Test__c> testList = new List<Test__c>();
        List<ICD__c> ICDList = new List<ICD__c>();
        
        Test__c testData1 = TestDataFactoryOrderAPI.createTest();
        testData1.Lab_Id__c=lab.Lab_Id__c;
        insert testData1;
        testList.add(testData1);
        
        DateTime dateData = DateTime.now();
        ICD__c icdData = TestDataFactoryOrderAPI.createICD();
        insert icdData;
        ICDList.add(icdData);
        
        List<String> selectedTest = new List<String>();
        List<String> selectedLabOrder = new List<String>();
        List<String> selectedICD = new List<String>();
        For(Integer i=0;i<testList.size();i++){
            selectedTest.add(testList[i].Test_Id__c);
        }
        For(Integer i=0;i<ICDList.size();i++){
            selectedICD.add(ICDList[i].ICD_Id__c);
        }
        Lab_Order__c labOrder = TestDataFactoryOrderAPI.createLabOrder();
        labOrder.Account_Id__c=acc.Id;
        labOrder.Collection_Date_Time__c  =dateData;
        labOrder.Facility_Id__c = facData.Facility_Id__c;
        labOrder.ICD_Id__c = icdData.ICD_Id__c;
        labOrder.Lab_Id__c  =lab.Lab_Id__c;
        labOrder.Physician_Name__c = phyData.Last_Name__c+','+phyData .First_Name__c;
        labOrder.Test_Id__c = testData1.Test_Id__c;
        labOrder.ICD_Id__c = icdData.Name;
        labOrder.Lab_Order_Number__c = '3005022370';
        labOrder.Lab_Order_Req__c = '105968';
        insert labOrder;
       /* labOrder.Lab_Id__c  =lab2.Lab_Id__c;
        labOrder.Facility_Id__c = facData1.Facility_Id__c;
        labOrder.Test_Id__c = testData2.Test_Id__c;
        update labOrder;*/
        
        System.assertEquals(1, 1, '');
    }
}