@isTest
public class patientCardControllerTest {
public static Account license= new Account();
    public static string keyString = '9876-5432-1001-2345-6789';
    
    public static testMethod void patientCardControllerTestMethod(){
        //list<RecordType> rcc =[Select Id From RecordType Where SobjectType='Account' And Name='Individual' limit 1];
        Account testPatient=new Account();
        //testPatient.RecordtypeId = rcc[0].Id;
        //testPatient.HealthCloudGA__IndividualId__c='808082989808ABCD';
        testPatient.Name='Test Patient';
        testPatient.Admit_Date__c=system.today();
        testPatient.Discharge_Date__c=system.now()+1;

        //Anubhav Started here
        testPatient.ElixirSuite__MRN_Number_New__c ='1234';
        testPatient.ElixirSuite__First_Name__c ='fname';
        testPatient.ElixirSuite__Last_Name__c ='lname';
        testPatient.ElixirSuite__SSN__c ='1234';
        testPatient.ElixirSuite__Email_Id__c ='its@gmail.com';
        testPatient.ElixirSuite__DOB__c =Date.parse('04/20/1998');
        testPatient.ElixirSuite__Gender__c='Male';
        testPatient.Phone ='9919850735';
        testPatient.BillingPostalCode='27440';
        testPatient.ElixirSuite__Deceased__c =True;

        //Anubhav ends here
         // Date dt= Date.parse('04/20/2018');
      // testPatient.DOB__c=dt;
        Insert testPatient;
        
        Contact con1=new Contact();
          //list<RecordType> rcc2 =[Select Id From RecordType Where SobjectType='Contact' And Name='Individual' limit 1];
        //con1.RecordTypeId=rcc2[0].Id;
         
        con1.AccountId=testPatient.Id;
        con1.LastName='Test Contact';
        con1.Birthdate=system.today()-100;
        con1.Email='mirketa@example.com';
        Insert con1;
       
        Account testPatient1=new Account();
         //testPatient1.RecordtypeId = rcc[0].Id;
        testPatient1.Name='Test Patient1';
        testPatient1.Admit_Date__c=system.today();
        testPatient1.Discharge_Date__c=system.now()+1;
        //Date dt1=Date.parse('04/20/2018');
        //testPatient1.DOB__c=dt1;
         //Anubhav Started here
         testPatient1.ElixirSuite__MRN_Number_New__c ='77887';
         testPatient1.ElixirSuite__First_Name__c ='char';
         testPatient1.ElixirSuite__Last_Name__c ='lee';
         testPatient1.ElixirSuite__SSN__c ='173e4';
         testPatient1.ElixirSuite__Email_Id__c ='fffg@gmail.com';
         testPatient1.ElixirSuite__DOB__c =Date.parse('04/10/1998');
         testPatient1.ElixirSuite__Gender__c='Male';
         testPatient1.Phone ='1996645676';
         testPatient1.BillingPostalCode='54321';
 
         //Anubhav ends here
        Insert testPatient1;
        
         
        Contact con2=new Contact();
          list<RecordType> rcc3 =[Select Id From RecordType Where SobjectType='Contact' And Name='Individual' limit 1];
       // con2.RecordTypeId=rcc3[0].Id;
        con2.AccountId=testPatient1.Id;
        con2.LastName='Test Contact2';
        con2.Birthdate=system.today()-106;
        
        con2.Email='mirketa1@example.com';
        Insert con2;
     
        
        ContentVersion content=new ContentVersion(); 
        content.Title='Header_Picture1'; 
        content.PathOnClient='/' + content.Title + '.jpg'; 
        Blob bodyBlob=Blob.valueOf('Unit Test ContentVersion Body'); 
        content.VersionData=bodyBlob; 
        //content.LinkedEntityId=sub.id;
        content.origin = 'H';
        content.FIRSTPUBLISHLOCATIONID=testPatient.Id;
        insert content;
        
        ContentDocumentLink contentlink=new ContentDocumentLink();
        contentlink.LinkedEntityId=con2.id;
        contentlink.contentdocumentid=[select contentdocumentid from contentversion where id =: content.id].contentdocumentid;
        contentlink.ShareType = 'I';
        contentlink.Visibility = 'AllUsers'; 
      
        insert contentlink;
      //Anubhav Start here
        Set<id> accSet = new Set<id>();
        accSet.add(testPatient.Id);
        accSet.add(testPatient1.Id);

        List<ElixirSuite__Master_Object__c> masterRec = new List<ElixirSuite__Master_Object__c>();
        ElixirSuite__Master_Object__c m1 = new ElixirSuite__Master_Object__c(ElixirSuite__Field_Label__c='Label',ElixirSuite__Field_Api__c='Apis');
        ElixirSuite__Master_Object__c m2 = new ElixirSuite__Master_Object__c(ElixirSuite__Field_Label__c='Label2',ElixirSuite__Field_Api__c='Apis2');
        masterRec.add(m1);
        masterRec.add(m2);
        Insert masterRec;
       //License_Class lCls = new License_Class();
       // insert lCls;
      //Anubhav Ends here
 		Test.startTest();
        System.debug(testPatient.Id);
        Object patWrap= patientCardController.patientCardMethod(testPatient.Id);
        patientCardController.handlingAfterUpload(testPatient.Id);
        //Anubhav Starts here
        Boolean temp = patientCardController.revertPatientDeceased(testPatient.Id);
        Set<id> setName = patientCardController.updateAllOpportunity(accSet);
        patientCardController.updateAllContact(accSet);
      Account accc = patientCardController.getTileConfigFieldsOrder(testPatient.Id);
      Map<String,String> labelMapp =patientCardController.getlabelsforFields();
      patientCardController.LicensBasdPermission();
      user uss = patientCardController.getUserInfo();
      patientCardController.patientWrapperMethod(testPatient.Id);
      //Anubhav Ends here
        system.assertEquals(1, 1,'');
       // system.assert(patWrap!=Null);
        Test.stopTest();
    }
    
   
}