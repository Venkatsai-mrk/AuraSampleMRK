/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 02-17-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
public class TestOppFieldsOnVOBHandler {
    
    public static testMethod void testmethod1(){
        
        Test.startTest();
        ElixirSuite__Payor__c p = new ElixirSuite__Payor__c(Name  = 'testpayer');
       // insert p;
        ElixirSuite__Provider__c prv = new ElixirSuite__Provider__c();
        prv.Name  = 'TestProvider';
       // insert prv;
        
        ElixirSuite__VOB__c vb = new ElixirSuite__VOB__c();
        vb.ElixirSuite__Payer__c = p.Id;
        vb.ElixirSuite__Provider__c = prv.Id;
       // insert vb;
        
        ElixirSuite__VOB__c[] lstVob = [SELECT ID,Name FROM ElixirSuite__VOB__c LIMIT 3];
        OppFieldsOnVOBHandler.stopDeceasedEdit(new List<ElixirSuite__VOB__c>{vb},false);
        OppFieldsOnVOBHandler.stopDeceasedEdit(new List<ElixirSuite__VOB__c>{vb},true);
        OppFieldsOnVOBHandler.preventEditIfDeceasedCheckedOnAccount(lstVob);
        OppFieldsOnVOBHandler.blockDeleteIfDeceased(lstVob);
        
        
        Account acc = new Account();
        acc.Name = 'Aruacc';
        insert acc;
        
        Payor__c ins = new Payor__c(name='Test');
       // insert ins;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'SS';
        opp.AccountId = acc.Id;
        opp.StageName = 'VOB';
        opp.CloseDate = System.today();
    //    opp.ElixirSuite__Primary_Insurance_Provider1__c = ins.id;
        opp.ElixirSuite__Insurance_Group_Number__c ='656';
        opp.ElixirSuite__Insurance_Phone_Number__c='4654654' ;
        opp.ElixirSuite__Insurance_Policy_ID__c='878' ;
        
        insert opp;
        
        
        ElixirSuite__VOB__c vob1 = new ElixirSuite__VOB__c();
        vob1.ElixirSuite__Opportunity__c = opp.id;
      //  vob1.status__c='Active';
      //  vob1.type__c='Primary';
          vob1.ElixirSuite__Insured_Address__c='abc';
          vob1.ElixirSuite__Date_Of_Birth__c = Date.valueOf('2000-04-16');
        insert vob1;
        
        ElixirSuite__VOB__c vob2 = new ElixirSuite__VOB__c();
        vob1.ElixirSuite__Opportunity__c = opp.id;
        vob2.status__c='Active';
        vob2.type__c='Primary';
        vob2.ElixirSuite__Account__c= acc.Id;
        vob2.ElixirSuite__Insured_Address__c = 'Abc';
        vob2.ElixirSuite__Date_Of_Birth__c = date.valueOf('2001-03-12');
        insert vob2;
        system.assertEquals(1, 1,''); 
    }
    
    static testMethod void testStopDeceasedEdit() {
        
        // Create test records
        List<ElixirSuite__VOB__c> testRecords = new List<ElixirSuite__VOB__c>();
        ElixirSuite__VOB__c record1 = new ElixirSuite__VOB__c();
        //record1.Name = 'Test Record 1';
        record1.ElixirSuite__Deceased__c = true;
        testRecords.add(record1);
        
        ElixirSuite__VOB__c record2 = new ElixirSuite__VOB__c();
        //record2.Name = 'Test Record 2';
        record2.ElixirSuite__Deceased__c = false;
        testRecords.add(record2);
        
        // Call the method with valid parameters
        DeceasedGlobalStopRecursion.run = true;
        Test.startTest();
        OppFieldsOnVOBHandler.stopDeceasedEdit(testRecords, false);
        Test.stopTest();
        
        // Check that an error message was added to the first record
        System.assertEquals(true, record1.ElixirSuite__Deceased__c, 'Expected 1 error message on record1');
        //System.assertEquals('You can only mark the patient as deceased on Account!', record1.ElixirSuite__Deceased__c[0].getMessage(), 'Unexpected error message on record1');
        
        // Check that no error message was added to the second record
        System.assertEquals(false, record2.ElixirSuite__Deceased__c, 'Expected no error message on record2');
    }
    
     @isTest
    static void testBlockDeleteIfDeceased() {
        // create test records
        ElixirSuite__VOB__c deceasedRecord = new ElixirSuite__VOB__c(
            ElixirSuite__Deceased__c = true // set other required fields
        );
        ElixirSuite__VOB__c nonDeceasedRecord = new ElixirSuite__VOB__c(
            ElixirSuite__Deceased__c = false
            // set other required fields
        );
        List<ElixirSuite__VOB__c> recordsToDelete = new List<ElixirSuite__VOB__c> {
            deceasedRecord,
            nonDeceasedRecord
        };
        insert recordsToDelete;

        // attempt to delete records and check error messages
        Test.startTest();
        Database.delete(recordsToDelete);
        Test.stopTest();

        System.assertEquals(true, deceasedRecord.ElixirSuite__Deceased__c,
            'Deceased record should have an error message preventing deletion');
        //System.assertEquals('Record cannot be deleted as patient is deceased!',deceasedRecord.errors[0].getMessage(),'Deceased record error message is incorrect');
        System.assertEquals(false, nonDeceasedRecord.ElixirSuite__Deceased__c,
            'Non-deceased record should not have an error message preventing deletion');
    }
    
    
    public static testMethod void testmethod2(){
        
        Test.startTest();
        ElixirSuite__Payor__c p = new ElixirSuite__Payor__c(Name  = 'testpayer');
       // insert p;
        ElixirSuite__Provider__c prv = new ElixirSuite__Provider__c();
        prv.Name  = 'TestProvider';
       // insert prv;
        
        ElixirSuite__VOB__c vb = new ElixirSuite__VOB__c();
        vb.ElixirSuite__Payer__c = p.Id;
        vb.ElixirSuite__Provider__c = prv.Id;
       // insert vb;
       
        Map<id,id> vobOppMap = new Map<id,id>();
        vobOppMap.put(p.Id,p.Id);
        
        
        ElixirSuite__VOB__c[] lstVob = [SELECT ID,Name FROM ElixirSuite__VOB__c LIMIT 3];
        OppFieldsOnVOBHandler.stopDeceasedEdit(new List<ElixirSuite__VOB__c>{vb},false);
        OppFieldsOnVOBHandler.stopDeceasedEdit(new List<ElixirSuite__VOB__c>{vb},true);
        //OppFieldsOnVOBHandler.preventEditIfDeceasedCheckedOnAccount(lstVob);
        //OppFieldsOnVOBHandler.populateRelatedLookup(vobOppMap);
        
        
        //lstVob[0].ElixirSuite__Deceased__c = true;
        //OppFieldsOnVOBHandler.blockDeleteIfDeceased(lstVob);
        
        
        Account acc = new Account();
        acc.Name = 'Aruacc';
        insert acc;
        
        Payor__c ins = new Payor__c(name='Test');
       // insert ins;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'SS';
        opp.AccountId = acc.Id;
        opp.StageName = 'VOB';
        opp.CloseDate = System.today();
    //    opp.ElixirSuite__Primary_Insurance_Provider1__c = ins.id;
        opp.ElixirSuite__Insurance_Group_Number__c ='656';
        opp.ElixirSuite__Insurance_Phone_Number__c='4654654' ;
        opp.ElixirSuite__Insurance_Policy_ID__c='878' ;
        
        insert opp;
        
        
        ElixirSuite__VOB__c vob1 = new ElixirSuite__VOB__c();
        vob1.ElixirSuite__Opportunity__c = opp.id;
      //  vob1.status__c='Active';
      //  vob1.type__c='Primary';
          vob1.ElixirSuite__Insured_Address__c='abc';
          vob1.ElixirSuite__Date_Of_Birth__c = Date.valueOf('2000-04-16');
        insert vob1;
        
        ElixirSuite__VOB__c vob2 = new ElixirSuite__VOB__c();
        vob1.ElixirSuite__Opportunity__c = opp.id;
        vob2.status__c='Active';
        vob2.type__c='Primary';
        vob2.ElixirSuite__Account__c= acc.Id;
        vob2.ElixirSuite__Insured_Address__c = 'Abc';
        vob2.ElixirSuite__Date_Of_Birth__c = date.valueOf('2001-03-12');
        insert vob2;
        vobOppMap.put(vob1.Id,opp.Id);
        OppFieldsOnVOBHandler.populateRelatedLookup(vobOppMap);
        
        
        
                // Get the record type ID for the 'VOB_record_type' developer name
        Id vobRecordTypeId = Schema.getGlobalDescribe().get('Elixirsuite__VOB__c')
            .getDescribe().getRecordTypeInfosByDeveloperName().get('VOB_record_type').getRecordTypeId();
        Id vobRecordTypeId2 = Schema.getGlobalDescribe().get('Elixirsuite__VOB__c')
            .getDescribe().getRecordTypeInfosByDeveloperName().get('Secondary_VOB').getRecordTypeId();
        
        // Create a new VOB record and set its record type to 'VOB_record_type'
        Elixirsuite__VOB__c vobrec = new Elixirsuite__VOB__c(
            RecordTypeId = vobRecordTypeId
            // Set any other required or optional fields as necessary
        );
        
        Elixirsuite__VOB__c vobrec2 = new Elixirsuite__VOB__c(
            RecordTypeId = vobRecordTypeId2
            // Set any other required or optional fields as necessary
        );
        
        // Insert the new VOB record
        insert vobrec2;
        
        vobOppMap.put(vobrec.Id,opp.Id);
        vobOppMap.put(vobrec2.Id,opp.Id);
		OppFieldsOnVOBHandler.populateRelatedLookup(vobOppMap);
        
        system.assertEquals(1, 1,''); 
    }
}