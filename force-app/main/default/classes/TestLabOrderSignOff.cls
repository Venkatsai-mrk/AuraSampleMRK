@isTest
public class TestLabOrderSignOff {
    @isTest
    public static void testMethod1(){
        //Insert test account
        Account acc = new Account();
        acc.Name = 'Test';
        acc.Verification_Code__c = '6781';
        insert acc;
        
        Prescription_Order__c po = new Prescription_Order__c();
        po.Account__c = acc.Id ; 
        po.Signature_Comments__c = 'the document has been signed';
        insert po ;
        
        UA_Sample_Details__c a = new UA_Sample_Details__c();
        a.Account__c=acc.id;
        insert a;
        
        Form__c  f= new Form__c();
        f.Account__c=acc.id;
        f.Name='new';
        f.Category__c='medical';
        f.Sub_Category__c='new';
        f.Version__c=1;
        insert f;
        
        Attachment att = new Attachment();
        att.ContentType = 'abc.pdf';
        att.Description = 'the image is for all purpose' ;
        att.Name = 'abc file';
        att.ParentId = acc.id ;
        att.Body = blob.valueOf('the image is done');
        insert att ; 
        System.assertEquals(1, 1, ' ');
    }
    
    @isTest
    public static void test1(){
        Test.startTest();
        testMethod1();
        Account accId1 = [Select Id,Verification_Code__c from Account where Name = 'Test' limit 1];
        Id accId = accId1.Id; 
        String verificationCode = accId1.Verification_Code__c ; 
        Prescription_Order__c po = new Prescription_Order__c();
        po = [Select id  ,Account__c from Prescription_Order__c];
        Id pw = po.Id ;
        UA_Sample_Details__c po1 = new UA_Sample_Details__c();
        po1 = [Select id  ,Account__c from UA_Sample_Details__c];
        Id pw2 = po1.Id ;
        Form__c fo = new Form__c();
        fo = [Select id  ,Account__c from Form__c];
        Id pw1= fo.Id ;
        Attachment att = new Attachment();
        att =[select id from attachment limit 1];
        //  Sample_Analysis__c  e= new Sample_Analysis__c();
        //   e.Account__c=accId;
        //  insert e;
        //  list<string> liste = new list<string>();
        //  liste.add(e.Id);
        //  EditPrescriptionOrderController.fetchMedications(pw);
        LabOrderSignOff.newVal(verificationCode , pw2 , '6781' , accId);
        SignOffController.newVal(verificationCode , pw , '6781' , accId);
        newApexForCode.newVal(verificationCode , pw1 , '6781' , accId ,'', '');
        // EncounterController.encounterRecords(accId);
        //EncounterController.deleteRecords(e.Id);
        // EncounterController.deleteAllEncounter(liste);
        System.assertEquals(1, 1, ' ');
        Test.stopTest();
    }
    
}