public class TestDataFactoryOrderAPI {
    
    public static Account createAccount()
    {
        Account testAccount = new Account();
        testAccount.Last_name__c='Test';
        testAccount.First_Name__c='Account';
        testAccount.Name='Test Account';
        testAccount.BillingStreet='NewDelhi';
        testAccount.BillingCity = 'Ghaziabad';
        testAccount.BillingState='DE';
        testAccount.BillingPostalCode='23456'; 
        testAccount.BillingCountry='IN';
        testAccount.Gender__c='Male';
        testAccount.SSN__c='3465432';
        testAccount.Phone='3456222224';
        testAccount.Patient_s_Birth_Date__c=Date.newInstance(2017, 12, 9);
        testAccount.DOB__c=Date.newInstance(2016, 12, 9);
        return testAccount;
    }
    public static payor__c createPayor(){
        payor__c testpayor = new payor__c();
        testpayor.Name = 'ICICI Lambord';
        testpayor.Payer_Code__c='34344';
        testpayor.Address__c='ads';
        testpayor.City__c='Ghaziabad';
        testpayor.State__c='DE';
        testpayor.Zip_Code__c='56743';
        return testpayor;
        
    }
    public static vob__c createVob(){
        
        vob__c testvob = new vob__c(); 
        testvob.Patient_Relationship_With_Insured__c='18';
        return testvob;
    }
    public static Guarantor__c createGuarantor(){
        
        Guarantor__c testguarantor = new Guarantor__c();
        testguarantor.Relationship__c='18';
        return testguarantor;
    }
    public static Lab__c createLab(){
        
        Lab__c  testLab = new Lab__c ();
        testLab.Lab_Id__c='3003322268';
        testLab.Is_Active__c=true;
        testLab.Name='LabCorp San Diego';
        return testLab;
    }
    public static Facility__c createFacility(){
        
        
        Facility__c testFacility = new  Facility__c();
        testFacility.Facility_Id__c='80012670';
        testFacility.Name='Mirketa Inc Test Site - Mirketa North - 80012670';
        testFacility.Is_Active__c=true;
        
        return testFacility;
    }
    public static Physician__c createPhysician(){
        Physician__c testPhysician = new  Physician__c();
        testPhysician.First_Name__c='Anna';
        testPhysician.IsActive__c=true;
        testPhysician.Last_Name__c='Apple';
        testPhysician.IsPriority__c=true;
        return testPhysician;
    }
    
    public static Test__c createTest(){
        Test__c addTest = new Test__c();
        addTest.Test_Id__c='070322';
       
            addTest.Test_Description__c='Nicotine Metabolite, Serum';
        addTest.IsPreferred__c=true;
        return addTest;
            }
    public static ICD__c createICD(){
        ICD__c addICD  = new ICD__c();
         addICD.ICD_Id__c='Z00.8';
        addICD.Name='ENCOUNTER FOR OTHER GENERAL EXAMINATION';
        addICD.IsPreferred__c=true;
        return addICD;
    }
    
    public static Lab_Order__c createLabOrder(){
        Lab_Order__c testLabOrder   = new Lab_Order__c();
        testLabOrder.Status__c='E';
        
        return testLabOrder;
    }
    
    
    
}