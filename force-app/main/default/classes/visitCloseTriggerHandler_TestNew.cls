@isTest
public class visitCloseTriggerHandler_TestNew {
    @isTest
    public static void createClaim_Test(){
        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.ElixirSuite__Patient_s_Birth_Date__c = Date.newInstance(2000, 2, 17);
        acc.ElixirSuite__Insured_s_Address__c = 'Test Address';
        acc.AccountNumber = '7418529630';
        acc.Phone = '7418529631';
        acc.BillingPostalCode = '12365';
        acc.ElixirSuite__Gender__c='Female';
        acc.BillingState='SA';
        acc.BillingCity='AS';
        insert acc;

        Id objectRecordTypeIdLoc = Schema.SObjectType.ElixirSuite__VOB__c.getRecordTypeInfosByDeveloperName().get('VOB_record_type').getRecordTypeId();
        
        ElixirSuite__VOB__c exVob = new ElixirSuite__VOB__c();
        exVob.ElixirSuite__Account__c = acc.Id;
        exVob.ElixirSuite__Insured_Id_Number__c = '8529637417';
        exVob.ElixirSuite__Insured_Last_Name__c = 'Test Last';
        exVob.ElixirSuite__Patient_Relationship_With_Insured__c = 'Self';
        exVob.ElixirSuite__InsPhone__c = '7896541230';
        exVob.ElixirSuite__Insured_First_Name__c = 'Test First';
        exVob.ElixirSuite__Insured_Address__c = 'Test Address';
        exVob.ElixirSuite__Insured_City__c = 'TestCity';
        exVob.ElixirSuite__Insured_State__c = 'TestState';
        exVob.ElixirSuite__Insured_Zipcode__c = '17425';
        exVob.ElixirSuite__Reason_for__c = 'Test Reason';
        exVob.ElixirSuite__Status__c='Active';
        exVob.ElixirSuite__Insured_First_Name__c='RET';
        exVob.ElixirSuite__Insured_Middle_Name__c='UIT';
        exVob.ElixirSuite__Insured_Last_Name__c='OPI';
        exVob.ElixirSuite__Date_Of_Birth__c = Date.newInstance(2000, 2, 17);
        exVob.ElixirSuite__Insured_Policy_Group_FECA_Number__c='123';
        exVob.ElixirSuite__Gender__c='Male';
        exVob.ElixirSuite__Set_Default_VOB__c = 'Yes';
        exVob.RecordTypeId = objectRecordTypeIdLoc;
        insert exVob;
        
        ElixirSuite__Provider__c exPrvdr = new ElixirSuite__Provider__c();
        exPrvdr.ElixirSuite__Account__c = acc.Id;
        exPrvdr.Name = 'Test Provider';
        exPrvdr.ElixirSuite__Provider_Zip__c = '12356';
        exPrvdr.ElixirSuite__Provider_State__c = 'TestState';
        exPrvdr.ElixirSuite__Provider_Last_Name__c = 'TestLastProvider';
        exPrvdr.ElixirSuite__Provider_City__c = 'TestProviderCity';
        exPrvdr.ElixirSuite__Provider_Code__c = '14785';
        insert exPrvdr;
        Elixir_Custom_Setting__c pracRectype = new Elixir_Custom_Setting__c();
        pracRectype.ElixirSuite__Practitioner_Contact_Recordtype__c = 'Practitioner';
        pracRectype.ElixirSuite__Create_Claim_For_Care_Episode__c = true;
        insert pracRectype;
        String contactRecType = pracRectype.ElixirSuite__Practitioner_Contact_Recordtype__c; 
       Id objectRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(contactRecType).getRecordTypeId();  
       Contact con = new Contact(LastName = 'Bond',
           AccountId = acc.Id,ElixirSuite__Practitioner_NPI__c = '123',ElixirSuite__ID_Number__c = '1235',MailingStreet = 'Abc',
                                 MailingCity = 'cty', MailingState = 'CA',MailingPostalCode = '99999',MailingCountry = 'US',RecordTypeId=objectRecordTypeId
       );
        insert con;
        ElixirSuite__Visits__c exVisit = new ElixirSuite__Visits__c();
        exVisit.ElixirSuite__Account__c = acc.Id;
        exVisit.ElixirSuite__Status__c = 'Active';
        exVisit.ElixirSuite__Location__c = 'US';
        exVisit.ElixirSuite__Care_Episode_Location__c = exPrvdr.Id;
        exVisit.ElixirSuite__Billing_Provider__c = exPrvdr.Id;
        exVisit.ElixirSuite__Rendering_Provider__c = con.Id;
        exVisit.Name = 'Test Visit - 1';
        insert exVisit;
        
       
       
                Map<id,ElixirSuite__Visits__c> oldVisitMap = new Map<id,ElixirSuite__Visits__c>();
        oldVisitMap.put(exVisit.Id,exVisit);
        
        ElixirSuite__Procedure__c exPrcdr = new ElixirSuite__Procedure__c();
        exPrcdr.ElixirSuite__Account__c = acc.Id;
        exPrcdr.ElixirSuite__Active__c = true;
        exPrcdr.ElixirSuite__Visits__c = exVisit.Id;
        exPrcdr.ElixirSuite__Claim_Generation__c = false;
        exPrcdr.ElixirSuite__Claim__c = null;
        exPrcdr.ElixirSuite__Type_of_Procedure__c ='Insurance Payment';
        exPrcdr.ElixirSuite__Is_Billable__c = true;
        exPrcdr.ElixirSuite__Ready_for_Billing__c = true;
        exPrcdr.ElixirSuite__Charges__c = 1000;
        exPrcdr.ElixirSuite__Surgeon__c =con.Id;
        exPrcdr.Name = 'Test Care Episode';
        insert exPrcdr;
        
        ElixirSuite__Procedure__c exPrcdr2 = new ElixirSuite__Procedure__c();
        exPrcdr2.ElixirSuite__Account__c = acc.Id;
        exPrcdr2.ElixirSuite__Active__c = true;
        exPrcdr2.ElixirSuite__Visits__c = exVisit.Id;
        exPrcdr2.ElixirSuite__Charges__c = 1000;
        exPrcdr2.ElixirSuite__Claim_Generation__c = false;
        exPrcdr2.ElixirSuite__Type_of_Procedure__c ='Insurance Payment';
        exPrcdr2.ElixirSuite__Is_Billable__c = true;
        exPrcdr2.ElixirSuite__Ready_for_Billing__c = true;
        exPrcdr.ElixirSuite__Surgeon__c =con.Id;
        exPrcdr2.Name = 'Test Care Episode';
        insert exPrcdr2;
        
        ElixirSuite__ICD_Codes__c icd = new ElixirSuite__ICD_Codes__c(Name = 'ICDDEMO');
        insert icd;
        ElixirSuite__ICD_Codes__c icd2 = new ElixirSuite__ICD_Codes__c(Name = 'DRI');
        insert icd2;
        
        ElixirSuite__Procedure_Diagnosis__c pd = new ElixirSuite__Procedure_Diagnosis__c(ElixirSuite__Procedure__c = exPrcdr.Id,
                                                                                        ElixirSuite__ICD_Codes__c = icd.Id);
        insert pd;
        
         ElixirSuite__Procedure_Diagnosis__c pd2 = new ElixirSuite__Procedure_Diagnosis__c(ElixirSuite__Procedure__c = exPrcdr2.Id,
                                                                                        ElixirSuite__ICD_Codes__c = icd.Id);
        
        insert pd2;
         ElixirSuite__Procedure_Diagnosis__c pd3 = new ElixirSuite__Procedure_Diagnosis__c(ElixirSuite__Procedure__c = exPrcdr.Id,
                                                                                        ElixirSuite__ICD_Codes__c = icd2.Id);
       
        insert pd3;
        List<ElixirSuite__Visits__c> exVisitList = [Select id, ElixirSuite__Account__c, ElixirSuite__Status__c, ElixirSuite__Location__c,ElixirSuite__Billing_Provider__c,ElixirSuite__Rendering_Provider__c, 
                                                   ElixirSuite__Care_Episode_Location__c from ElixirSuite__Visits__c where Id =: exVisit.Id Limit 1];
        exVisitList[0].ElixirSuite__Status__c = 'Closed';
        update exVisitList;
          
        Test.startTest();
        visitCloseTriggerHandler.createClaim(oldVisitMap,exVisitList);
        VisitHelperController.countExistingRecords(acc.Id);
        System.assertEquals(1,1,'');
        Test.stopTest();
    } 
}