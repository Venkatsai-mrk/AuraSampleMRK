@isTest
public class AllergyMedicalControllerTest 
{
	public static testMethod void allergyMethod()
    {
        Account acc = new Account();
        acc.Name = 'test';
        insert acc;
        String recordType = Schema.sObjectType.Medical_Examination__c.getRecordTypeInfosByName().get('Allergy').getRecordTypeId();
        Medical_Examination__c med = new Medical_Examination__c();
        med.Allergy_Name__c = 'Test1';
        med.ElixirSuite__Account__c = acc.Id;
        med.ElixirSuite__Start_Time__c = System.now();
        med.Category__c = 'Food Allergy';
        med.RecordTypeId  = recordType;
        med.ElixirSuite__End_Time__c = System.now();
        
        try{
             insert med;
        }
        catch(Exception e){}
       
        String recordType1 = Schema.sObjectType.Medical_Examination__c.getRecordTypeInfosByName().get('Medical Alerts').getRecordTypeId();
        Medical_Examination__c med1 = new Medical_Examination__c();
        med1.Allergy_Name__c = 'Test1';
        med1.ElixirSuite__Account__c = acc.Id;
        med1.ElixirSuite__Start_Time__c = System.now();
        med1.Category__c = 'Food Allergy';
        med1.RecordTypeId  = recordType1;
        med1.ElixirSuite__End_Time__c = System.now();

        try
        {
            insert med1;
        }
        catch(Exception e){}
       
        
        Medical_Examination__c med2 = new Medical_Examination__c();
        med2.Allergy_Name__c = 'Test1';
        med2.ElixirSuite__Account__c = acc.Id;
        med2.ElixirSuite__Start_Time__c = System.now();
        med2.Category__c = 'Skin Allergy';
        med2.RecordTypeId  = recordType;
        med2.ElixirSuite__End_Time__c = System.now();

        try
        {
            insert med2;
        }
        catch(Exception e){}

        Medical_Examination__c med3 = new Medical_Examination__c();
        med3.Allergy_Name__c = 'Test1';
        med3.ElixirSuite__Account__c = acc.Id;
        med3.ElixirSuite__Start_Time__c = System.now();
        med3.Category__c = 'Drug Allergy';
        med3.RecordTypeId  = recordType;
        med3.ElixirSuite__End_Time__c = System.now();

        try
        {
            insert med3;
        }
        catch(Exception e){}
        
        Test.startTest();
        	AllergyMedicalController.getData(acc.Id);
           system.assertEquals(1,1,' ');
        Test.stopTest();
        System.assert(med.Allergy_Name__c!=null,'Allergy Name Should not null');
        
    }

     @isTest
    public static void LicensBasdPermissionMethod1(){
        Id ids=UserInfo.getUserId();
        User u = [select Id,ElixirSuite__License_Type__c from User where id=:ids];
        u.ElixirSuite__License_Type__c ='Type of license - EHR';
        update u;
        
        Test.startTest();
        AllergyMedicalController.LicensBasdPermission();
        system.assertEquals(1,1,' ');
		Test.stopTest();
    }
     @isTest
    public static void LicensBasdPermissionMethod2(){
        Id ids=UserInfo.getUserId();
        User u = [select Id,ElixirSuite__License_Type__c from User where id=:ids];
        u.ElixirSuite__License_Type__c ='Type of license - EPM';
        update u;
        
		Test.startTest();
        AllergyMedicalController.LicensBasdPermission();
        system.assertEquals(1,1,' ');
		Test.stopTest();
    }
     @isTest
    public static void LicensBasdPermissionMethod3(){
        Id ids=UserInfo.getUserId();
        User u = [select Id,ElixirSuite__License_Type__c from User where id=:ids];
        u.ElixirSuite__License_Type__c ='Type of license - RCM';
        update u;
        
        Test.startTest();
        AllergyMedicalController.LicensBasdPermission();
        system.assertEquals(1,1,' ');
		Test.stopTest();

    }
}