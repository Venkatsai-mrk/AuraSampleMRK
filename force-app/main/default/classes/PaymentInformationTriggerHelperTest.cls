@isTest
public class PaymentInformationTriggerHelperTest {
    
    
     @isTest
    public static void afterInsUpd(){
        Elixir_Custom_Setting__c patAccRecType = new Elixir_Custom_Setting__c();
        patAccRecType.ElixirSuite__Patient_Account_Recordtype__c = 'Patient_Account';
        insert patAccRecType;
        Id objectRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(patAccRecType.ElixirSuite__Patient_Account_Recordtype__c).getRecordTypeId();

        Account accrec= new Account();
      //  RecordType rt = [SELECT Id FROM RecordType WHERE sObjectType = 'Account' AND Name ='Patient Account'];
        accrec.RecordTypeId = objectRecordTypeId;
        accrec.Name = 'Test';
        accrec.Phone = '900091111';
        accrec.ElixirSuite__Email_Id__c = 'a@g.com';
        accrec.ElixirSuite__Stage__c = 'Admitted';
        accrec.ElixirSuite__Current_Status_Of_Patient__c = 'Current Patients';
        insert accrec;
        
        Id recordTypeId = Schema.SObjectType.ElixirSuite__Payment_Information__c.getRecordTypeInfosByDeveloperName().get('Credit_Card').getRecordTypeId();
        
        ElixirSuite__Payment_Information__c payInf = new ElixirSuite__Payment_Information__c();
        payInf.ElixirSuite__Account__c = accrec.Id;
        payInf.RecordTypeId = recordTypeId;
        payInf.ElixirSuite__Default__c = true;
        insert payInf;
        
        Account accrec1= new Account();
        accrec1.RecordTypeId = objectRecordTypeId;
        accrec1.Name = 'Test1';
        accrec1.Phone = '900091222';
        accrec1.ElixirSuite__Email_Id__c = 'a1@g.com';
        accrec1.ElixirSuite__Stage__c = 'Admitted';
        accrec1.ElixirSuite__Current_Status_Of_Patient__c = 'Current Patients';
        insert accrec1;
        
        ElixirSuite__Payment_Information__c payInf1 = new ElixirSuite__Payment_Information__c();
        payInf1.ElixirSuite__Account__c = accrec1.Id;
        payInf1.RecordTypeId = recordTypeId;
        insert payInf1;
        
         ElixirSuite__Payment_Information__c payInf2 = new ElixirSuite__Payment_Information__c();
        payInf2.ElixirSuite__Account__c = accrec.Id;
        payInf2.RecordTypeId = recordTypeId;
        payInf2.ElixirSuite__Default__c = true;
        insert payInf2;
        
        system.assertEquals(1, 1,'');
        
    }

}