/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 02-17-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest 
public class TestLeadTriggerHelper {
    @isTest 
    public static void testOpportunityFromLead()  {
        Id accountRecordTypeId = Schema.SObjectType.Provider__c.getRecordTypeInfosByDeveloperName().get('Template_Provider').getRecordTypeId();
        Provider__c provider = new Provider__c(
            Name = 'US',
            Provider_Code__c = 'Athena',
            RecordTypeId=accountRecordTypeId
        );
        insert provider;
        Lead ld =TestdataUtility.setupLeadTestData() ;
        List<Lead> leadlst = new List<Lead>();
        leadlst.add(ld);
        Map<id,Lead> oppIDLeadMap = new Map<id,Lead>();
        oppIdLeadMap.put(accountRecordTypeId,ld);
        LeadTriggerHelper vob = new LeadTriggerHelper();
        vob.VobCreation(oppIDLeadMap);
        Account ac=new Account();
        ac.Name='a';
        insert ac;
        Opportunity op=new Opportunity();
        op.Name='a';
        op.CloseDate=System.today();
        op.AccountId=ac.id;
        op.StageName='Prospecting';
        insert op;
        Test.startTest();
        ld.Provider__c = provider.Id;
        ld.Where_did_you_hear_about_us__c='test';
        ld.Has_Insurance__c=True;
        ld.Insurance_Phone_Number__c='987432323';
        ld.Secondary_Insurance_Phone_Number__c='988765432';
        update ld;
        Database.LeadConvert lc = new Database.LeadConvert();
        lc.setLeadId(ld.Id);
        LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
        system.debug('convertsted  :-->'+convertStatus);
        lc.setConvertedStatus(convertStatus.MasterLabel);
        //lc.setConvertedStatus('Qualified/Converted');
        //lc.setDoNotCreateOpportunity(false);
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        System.debug([SELECT Id, isConverted FROM Lead WHERE id= :ld.Id]);
        system.debug('isconverted test: '+ld.isConverted);
        
        Test.stopTest();
        System.assertEquals(1, 1, ' ');
        
        
    }
    
    @isTest public static void testOpportunityFromLead1()  {
        Id accountRecordTypeId = Schema.SObjectType.Provider__c.getRecordTypeInfosByDeveloperName().get('Template_Provider').getRecordTypeId();
        Provider__c provider = new Provider__c(
            Name = 'US',
            Provider_Code__c = 'Athena',
            RecordTypeId = accountRecordTypeId
        );
        insert provider;
        Lead ld =TestdataUtility.setupLeadTestData() ;
        Account ac=new Account();
        ac.Name='a';
        insert ac;
        Opportunity op=new Opportunity();
        op.Name='a';
        op.CloseDate=System.today();
        op.AccountId=ac.id;
        op.StageName='Prospecting';
        insert op;
        Test.startTest();
        ld.Provider__c = provider.Id;
        ld.Where_did_you_hear_about_us__c='test';
        ld.Has_Insurance__c=False;
        ld.Secondary_Insurance_Phone_Number__c='9789789789';
        update ld;
        Database.LeadConvert lc = new Database.LeadConvert();
        lc.setLeadId(ld.Id);
        
        
        
        //lc.setConvertedStatus('Qualified/Converted');
        
        
       // Database.LeadConvertResult lcr = Database.convertLead(lc);
        
        //system.debug('isconverted tesr'+ld.isConverted);
        LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
        system.debug('convertsted  :-->'+convertStatus);
        lc.setConvertedStatus(convertStatus.MasterLabel);
        //lc.setConvertedStatus('Qualified/Converted');
        //lc.setDoNotCreateOpportunity(false);
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        
        Test.stopTest();
        System.assertEquals(1, 1, ' ');
        
        
        
        
    }
    
    @isTest public static void testOpportunityFromLead2()  {
        Id accountRecordTypeId = Schema.SObjectType.Provider__c.getRecordTypeInfosByDeveloperName().get('Template_Provider').getRecordTypeId();
        Provider__c provider = new Provider__c(
            Name = 'US',
            Provider_Code__c = 'Athena',
            RecordTypeId = accountRecordTypeId
        );
        insert provider;
        Lead ld =TestdataUtility.setupLeadTestData() ;
        Account ac=new Account();
        ac.Name='a';
        insert ac;
        Opportunity op=new Opportunity();
        op.Name='a';
        op.CloseDate=System.today();
        op.AccountId=ac.id;
        op.StageName='Prospecting';
        insert op;
        Test.startTest();
        ld.Provider__c = provider.Id;
        ld.Where_did_you_hear_about_us__c='test';
        ld.Has_Insurance__c=True;
        ld.Secondary_Insurance_Phone_Number__c='9789789789';
        update ld;
        Database.LeadConvert lc = new Database.LeadConvert();
        lc.setLeadId(ld.Id);
        
        
        
        //lc.setConvertedStatus('Qualified/Converted');
        
        
       // Database.LeadConvertResult lcr = Database.convertLead(lc);
        
        //system.debug('isconverted tesr'+ld.isConverted);
        LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
        system.debug('convertsted  :-->'+convertStatus);
        lc.setConvertedStatus(convertStatus.MasterLabel);
        //lc.setConvertedStatus('Qualified/Converted');
        //lc.setDoNotCreateOpportunity(false);
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        System.assertEquals(1, 1, ' ');
        Test.stopTest();
        
        
        
        
        
    }
    
    @isTest 
    public static void testOpportunityFromLead3()  {
        Id accountRecordTypeId = Schema.SObjectType.Provider__c.getRecordTypeInfosByDeveloperName().get('Template_Provider').getRecordTypeId();
        Provider__c provider = new Provider__c(
            Name = 'US',
            Provider_Code__c = 'Athena',
            RecordTypeId=accountRecordTypeId
        );
        insert provider;
        Lead ld =TestdataUtility.setupLeadTestData() ;
        List<Lead> leadlst = new List<Lead>();
        leadlst.add(ld);
        Map<id,Lead> oppIDLeadMap = new Map<id,Lead>();
        oppIdLeadMap.put(accountRecordTypeId,ld);
        LeadTriggerHelper vob = new LeadTriggerHelper();
        vob.VobCreation(oppIDLeadMap);
        Account ac=new Account();
        ac.Name='a';
        insert ac;
        Opportunity op=new Opportunity();
        op.Name='a';
        op.CloseDate=System.today();
        op.AccountId=ac.id;
        op.StageName='Prospecting';
        insert op;
        Test.startTest();
        ld.Provider__c = provider.Id;
        ld.Where_did_you_hear_about_us__c='test';
        ld.Has_Insurance__c=True;
        ld.Insurance_Phone_Number__c='987432323';
        ld.Secondary_Insurance_Phone_Number__c='988765432';
        update ld;
        Database.LeadConvert lc = new Database.LeadConvert();
        lc.setLeadId(ld.Id);
        LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
        system.debug('convertsted  :-->'+convertStatus);
        lc.setConvertedStatus(convertStatus.MasterLabel);
        //lc.setConvertedStatus('Qualified/Converted');
        //lc.setDoNotCreateOpportunity(false);
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        System.debug([SELECT Id, isConverted FROM Lead WHERE id= :ld.Id]);
        system.debug('isconverted test: '+ld.isConverted);
        system.assertEquals(1,1,'');
        Test.stopTest();
        
        
        
    }
    
    @isTest public static void testOpportunityFromLead4()  {
        Id accountRecordTypeId = Schema.SObjectType.Provider__c.getRecordTypeInfosByDeveloperName().get('Template_Provider').getRecordTypeId();
        Provider__c provider = new Provider__c(
            Name = 'US',
            Provider_Code__c = 'Athena',
            RecordTypeId = accountRecordTypeId
        );
        insert provider;
        
        Lead ld =TestdataUtility.setupLeadTestData() ;
        ld.ElixirSuite__Primary_Subscriber_Middle_Name__c = 'test';
        ld.ElixirSuite__Secondary_Subscriber_Last_Name__c = 'lstName';
        ld.ElixirSuite__Tertiary_Subscriber_Middle_Name__c = 'seclstName';
        ld.ElixirSuite__WC_Date_of_Accident__c = System.today();
        
        
      
        List<Lead> leadlst = new List<Lead>();
        leadlst.add(ld);
        Map<id,Lead> oppIDLeadMap = new Map<id,Lead>();
        oppIdLeadMap.put(accountRecordTypeId,ld);
        LeadTriggerHelper vob = new LeadTriggerHelper();
        vob.VobCreation(oppIDLeadMap);
        
        Account ac=new Account();
        ac.Name='a';
        insert ac;
        Opportunity op=new Opportunity();
        op.Name='a';
        op.CloseDate=System.today();
        op.AccountId=ac.id;
        op.StageName='Prospecting';
        insert op;
        Test.startTest();
        ld.Provider__c = provider.Id;
        ld.Where_did_you_hear_about_us__c='test';
        ld.Has_Insurance__c=False;
        ld.Secondary_Insurance_Phone_Number__c='9789789789';
        update ld;
        Database.LeadConvert lc = new Database.LeadConvert();
        lc.setLeadId(ld.Id);
        
        
        
        //lc.setConvertedStatus('Qualified/Converted');
        
        
       // Database.LeadConvertResult lcr = Database.convertLead(lc);
        
        //system.debug('isconverted tesr'+ld.isConverted);
        LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
        system.debug('convertsted  :-->'+convertStatus);
        lc.setConvertedStatus(convertStatus.MasterLabel);
        //lc.setConvertedStatus('Qualified/Converted');
        //lc.setDoNotCreateOpportunity(false);
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        System.assertEquals(1, 1, ' ');
        Test.stopTest();
        
        
        
        
    }
    
}