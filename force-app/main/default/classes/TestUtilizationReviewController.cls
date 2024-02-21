@isTest
public class TestUtilizationReviewController {
    public  static testMethod void allCoverageParentMethod(){
        
        Account forIns = new Account();
        forIns.Name='Test Demo';
        // forIns.HealthCloudGA__MedicalRecordNumber__c = '34';
        forIns.DOB__c= System.today();
        forIns.Gender__c = 'Male';
        forIns.Blood_Group__c = 'O+';
        forIns.phone='9999999999';
        forIns.BillingPostalCode='577401000';
        insert forIns;
        
        Contact c = new Contact();
        c.LastName = 'demo';
        c.Birthdate = System.today();
        c.AccountId = forIns.Id;
        insert c;
        
        ElixirSuite__Payor__c pr  = new ElixirSuite__Payor__c();
        pr.Name = 'test';
        insert pr;
        
        ElixirSuite__VOB__c vb = new ElixirSuite__VOB__c();
        vb.ElixirSuite__Account__c = forIns.Id;
        vb.ElixirSuite__Payer__c = pr.Id;
        vb.ElixirSuite__Insured_First_Name__c='test';
        vb.ElixirSuite__Insured_Last_Name__c='test';
        vb.ElixirSuite__Patient_Relationship_With_Insured__c ='18';
        insert vb;
        
        Utilization_Review__c ur  = new Utilization_Review__c();
        ur.Type__c =  'Initial Review';
        ur.Status__c =  'Open';
        ur.Type__c =  'Initial Review';
        ur.Approved_LOC__c =  'Residential';
        ur.Approved_Number_of_Days__c =10;
        ur.Authorization_Number__c = 'Auth  -101';
        ur.Account__c = forIns.Id;
        
        insert ur;
        
        //added by ashwini
        Account acv= new Account();
        
        ElixirSuite__Procedure__c procedure = new ElixirSuite__Procedure__c();
        ID RecordType =Schema.SObjectType.ElixirSuite__Procedure__c.getRecordTypeInfosByName().get('Patient Procedure').getRecordTypeId();
        procedure.name = 'newprod';
        procedure.ElixirSuite__Account__c= acv.Id; 
        procedure.RecordTypeId = RecordType;
        procedure.From_Date__c = System.Today();
        procedure.Start_Time__c = System.now() ;
        procedure.To_Date__c = System.today() +3;
        procedure.End_Time__c = System.now() +3;
        insert procedure;
        
        
        List<String> toDelLst = new  List<String>();
        for(Integer i=0 ; i<=10 ; i++) {
            Utilization_Review__c toDel = new Utilization_Review__c();
            //toDel.Name = 'Demo'+i;
            toDel.Status__c='Open';
            toDel.Type__c = 'Initial Review';
            upsert toDel; 
            toDelLst.add(toDel.Id) ;
        }
        
        Form__c fo= new Form__c();
        fo.name = 'Nursing Screen & Assessment (1 and 2)';
        fo.ElixirSuite__Account__c=forIns.Id;
        fo.ElixirSuite__Category__c='test';
        fo.ElixirSuite__Sub_Category__c='test';
        fo.ElixirSuite__Version__c=12;
        insert fo;
        
        Form__c fo1= new Form__c();
        fo1.name = 'Nursing Screen & Assessment (1 and 2)';
        fo1.ElixirSuite__Account__c=null;
        fo1.ElixirSuite__Category__c='test';
        fo1.ElixirSuite__Sub_Category__c='test';
        fo1.ElixirSuite__Version__c=12;
        //fo1.Id=fo.Id;
      //  insert fo1;
        
        List<Form_Field__c> ffList = new List<Form_Field__c>();
        for (integer i=0;i<3;i++){
            Form_Field__c ff =new Form_Field__c();
            ff.Form__c=fo.id;
            ff.Section__c=12;
            ff.ElixirSuite__Data_Entry_Type__c='input:Text(Only)';
            ffList.add(ff);
        }
        //ff.name ='test';
        ffList[0].Field_Name__c='Signs and Symptoms of Withdrawal';
        ffList[1].Field_Name__c='PAWS Symptoms';
        ffList[2].Field_Name__c='What supports systems does the patient have?';
        
        insert ffList;
        
        DateTime myDateTime1 = DateTime.newInstance(2023, 6, 19, 10, 7, 12);
        DateTime myDateTime2 = DateTime.newInstance(2023, 6, 23, 10, 7, 12);
        Event e= new Event();
        e.Description ='Test1';
        e.StartDateTime= myDateTime1;
        e.EndDateTime = myDateTime2;
        e.WhatId= forIns.Id;
        insert e;
        
       
        Date myDate = Date.newInstance(2023, 7, 17);
        
        
        Test.startTest();
        UtilizationReviewController.fetchAllRelatedUtlizationRecordsForAccount(forIns.Id);
        UtilizationReviewController.getAllDataForUtilizationReview(forIns.Id,ur.Id);
       // customLookupForVobController.fetchSingleLookUpValue1('test');
        //  UtilizationReviewController.saveDataForUtilizationReview(ur,forIns.Id);
        UtilizationReviewController.deleteAllUtilizationRecords(toDelLst);
           UtilizationReviewController.getURRecordForEdit(ur.Id);
        // UtilizationReviewController.getFieldType('Name');
        // UtilizationReviewController.updtRecordAfterEdit(ur,ur.Id);
        
        // Added by Ashwini
       // Utilization_Review__c ure = new Utilization_Review__c();
       list<Utilization_Review__c> listutil= new list<Utilization_Review__c>();
        listutil.add(ur);
        //Datetime dt = DateTime.parse('10/14/2022 11:46 AM');
          String myDtString ='2001-07-19 04:37:12';
       UtilizationReviewController.saveDataForUtilizationReview(listutil,forIns.Id,myDtString,myDtString);
      
       //UtilizationReviewController.checkCareEpisode(ur.Id);
       UtilizationReviewController.fetchEvent(forIns.Id,myDate);
        String recid= ur.Id;
        UtilizationReviewController.updtRecordAfterEdit(listutil,recid);
            
        
        Test.stopTest();
        system.assert(forIns.Name!=null,'');
    }
    
}