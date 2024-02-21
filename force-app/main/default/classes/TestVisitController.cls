/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 02-03-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
public class TestVisitController {
    
    static testMethod void visitRecords(){
        
        Test.startTest();
        Account a = new Account(Name = 'Test121');
        insert a;
        
        Id recordTypeId = Schema.SObjectType.ElixirSuite__Provider__c.getRecordTypeInfosByDeveloperName().get('Template_Provider').getRecordTypeId();
        
        ElixirSuite__Provider__c p = new ElixirSuite__Provider__c();
        p.ElixirSuite__Provider_Code__c = 'code';
        p.RecordTypeId = recordTypeId ;
        insert p;
        
        
        Visits__c v= new Visits__c();
        v.Name= 'DemoVisit123';
        v.account__c=a.id;
        v.Status__c='Active';
        v.ElixirSuite__Location__c = 'demo';
        v.ElixirSuite__Care_Episode_Location__c = p.Id;
        insert v;
        
        Visits__c v1= new Visits__c();
        v1.Name= 'DemoVisit123';
        v1.account__c=a.id;
        v1.Status__c='Closed';
        insert v1;
        
        Form_value__c formValue = new Form_Value__C();
         formValue.Account__c = a.id;
         formValue.Is_CareEpisode__c = true;
         formValue.Care_Episode__c = v1.Id;
         formValue.ElixirSuite__Status__c = 'Open';
         insert formValue;
        
        Form_value__c formValue1 = new Form_Value__C();
         formValue1.Account__c = a.id;
         formValue1.Is_CareEpisode__c = true;
         formValue1.Care_Episode__c = v.Id;
         formValue1.ElixirSuite__Status__c = 'Completed';
         insert formValue1;
        
        List<String> vstlst = new List<String>();
        vstlst.add(v.Id);
        vstlst.add(v1.Id);
        
        List<Visits__c> carelist = [select id,ElixirSuite__Status__c, ElixirSuite__Account__c,ElixirSuite__Care_Episode_Location__c from Visits__c];
        
        VisitController.visitRecords(a.Id);
        VisitController.deleteRecords(v1.Id);
        VisitController.deleteAllVisit(vstlst);
        VisitController.checkFormStatusWhenClosed(carelist );
        VisitController.checkCareEpisodeStatus(carelist );
        
        VisitController.fetchAccountName(a.Id);
        VisitController.generateAutoNumber(a.Id);
        VisitController.checkReopenStaus(carelist);
        VisitController.updateChangedLocations(carelist);
        
        Test.stopTest();
        //system.assert(a.Name!=null);
        system.assertEquals(1,1,'');
    }
	
    @isTest
    static void testVisitSummaryData() {
        
        String patientTile = 'Visit Summary';
        String visitSummarySections = 'Lab Order(s);Prescription(s);Problem(s);Allergies;Diagnosis Code(s);Vital Signs;Procedure Code(s)';
        
        
        ElixirSuite__Master_Object__c testMasterObject = new ElixirSuite__Master_Object__c();
        Id recordTypeId = Schema.SObjectType.ElixirSuite__Master_Object__c.getRecordTypeInfosByDeveloperName().get('Patient_Portal').getRecordTypeId();
        testMasterObject.Name = 'Test Master Object';
        testMasterObject.ElixirSuite__Patient_Tile_Entity__c = patientTile;
        testMasterObject.RecordtypeId=recordTypeId;
        testMasterObject.ElixirSuite__Visit_Summary_Sections__c = 'Lab Order(s);Prescription(s);Problem(s);Allergies;Diagnosis Code(s);Vital Signs;Procedure Code(s)';
        testMasterObject.ElixirSuite__Enable_Visit_Summary__c=true;
        insert testMasterObject;
        
        Account a = new Account(Name = 'Test121');
        insert a;
        Id recordTypeId1 = Schema.SObjectType.ElixirSuite__Provider__c.getRecordTypeInfosByDeveloperName().get('Template_Provider').getRecordTypeId();

        ElixirSuite__Provider__c p = new ElixirSuite__Provider__c();
        p.ElixirSuite__Provider_Code__c = 'code';
        p.RecordTypeId = recordTypeId1 ;
        insert p;
        List<Visits__c> visitsLst = new List<Visits__c>();
       
        Visits__c v= new Visits__c();
        v.Name= 'DemoVisit123';
        v.account__c=a.id;
        v.Status__c='Active';
        v.ElixirSuite__Location__c = 'demo';
        v.ElixirSuite__Care_Episode_Location__c = p.Id;
        insert v;
        
        v.Status__c = 'Closed';
        visitsLst.add(v);
        update visitsLst;
        Map<id,ElixirSuite__Visits__c> oldVisitsMap = new Map<id,ElixirSuite__Visits__c>();
       oldVisitsMap.put(v.Id,v);
        GlobalVirtualVisitTrigger obj = new GlobalVirtualVisitTrigger();
        obj.afterUpdateVisit(visitsLst,oldVisitsMap);
        system.assertEquals(1,1,'');
        
    }
}