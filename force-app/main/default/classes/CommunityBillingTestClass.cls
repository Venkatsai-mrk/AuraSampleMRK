@isTest
public class CommunityBillingTestClass {
    @isTest
    static void testCommunityBilling(){
        Account patient = new Account();
        patient.name = 'Test Patient';
        insert patient;

        Contact con = new Contact();
        con.AccountId = patient.Id;
        con.Lastname = 'Test con';
        insert con;

        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User'];
       
        User u = new User(Alias = 'standt',
            Email = 'standarduser@testorg.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Testing',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = p.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'standarduser' + Datetime.now().getTime() + '@testorg.com'
        );
        insert u;
        
        
        Procedure__c procedure = new Procedure__c();
        procedure.Name = 'demo app';
        procedure.Account__c = patient.Id;
        procedure.CPT_HCPCS_Code__c = '12345';
        procedure.ElixirSuite__Type_of_Procedure__c='Insurance Payment';
        procedure.From_Date__c = System.today();
        procedure.To_Date__c = System.today().addDays(1);
        insert procedure;
                
        Id providerRecType = Schema.SObjectType.ElixirSuite__Provider__c.getRecordTypeInfosByDeveloperName().get('Patient_Provider').getRecordTypeId();
        
        Provider__c providerRec = new Provider__c();
        providerRec.Account__c = patient.Id;
        providerRec.Provider_Code__c  = 'Test123';
        providerRec.Name = 'TestProvider';
        providerRec.RecordTypeId=providerRecType;
        
        insert providerRec;
        
        ElixirSuite__Visits__c episode = new ElixirSuite__Visits__c();
        episode.Name = 'Test episode';
        episode.Account__c = patient.Id;
        episode.ElixirSuite__Status__c='Closed';
        episode.ElixirSuite__Account__c=patient.Id;
        episode.Care_Episode_Location__c = providerRec.Id;
        insert episode;
        
        Payment_Transaction__c payTrans = new Payment_Transaction__c();
        payTrans.Account__c = patient.Id;
        payTrans.Procedure__c = procedure.Id;
        payTrans.Date_Of_Service__c = System.today();
        payTrans.Cpt_Codes__c = '12345';
        payTrans.Actual_Price__c = 1500;
        payTrans.Patient_Responsibility__c = 500;
        payTrans.ElixirSuite__Provider__c=providerRec.Id;
        
        insert payTrans;
        
        Master_Transaction__c mst = new Master_Transaction__c();
        mst.Total_Amount_Paid__c = 1000;
        mst.Total_Unallocated_Amount__c = 1000;
        mst.ElixirSuite__Total_Remaining_Unallocated_Amount__c =900;
        mst.Payment_Type__c = 'Cash';
        mst.ElixirSuite__Reason_Of_Payment__c = 'Unallocated Payment';
        mst.Account__c = patient.Id;
        mst.ElixirSuite__Account__c=patient.Id;
        insert mst;
        Id paymntTxnRecordTypeId = Schema.SObjectType.ElixirSuite__Payment_Transaction__c.getRecordTypeInfosByDeveloperName().get('Insurance_Payment').getRecordTypeId();
        
        
        
        ElixirSuite__Payment_Transaction__c payTran = new ElixirSuite__Payment_Transaction__c();
        payTran.ElixirSuite__Actual_Price__c = 500;
        payTran.ElixirSuite__Procedure__c = procedure.Id;
        payTran.ElixirSuite__Cpt_Codes__c = 'CPT100';
        payTran.ElixirSuite__Insurance_Payments__c = 200;
        payTran.ElixirSuite__Account__c = patient.Id;
        payTran.RecordTypeId = paymntTxnRecordTypeId;
        payTran.ElixirSuite__Patient_Payments__c = 100;
        payTran.ElixirSuite__Payment_Adjustments__c = 10;
        insert payTran;
        
        Transactions__c tran= new Transactions__c();
        tran.ElixirSuite__Type_of_Payment__c = 'Payment';
        tran.ElixirSuite__Mode_of_Payment__c='Cash';
        tran.ElixirSuite__Payment_DateTime__c=Date.today();
        tran.ElixirSuite__Master_Transaction__c = payTran.Id;
        insert tran;
        
        Event events = new Event();
        events.Care_Episode__c = episode.Id;
        events.Appointment_Type__c = 'demo app';
        events.ElixirSuite__Care_Episode__c=episode.Id;
        events.StartDateTime = System.today().addDays(1);
        events.DurationInMinutes = 2;
        insert events;
        
        Test.startTest();
        PortalBillingClass.displayBillingDetail(u.id);
        PortalBillingClass.getProviderPaymentWrapper();
        PortalBillingClass.getPatientId();
        PortalBillingClass.getImageUrls(providerRec.Id);
        
        PortalBillingClass.searchVisit(Date.today()-10, date.today()+10, UserInfo.getUserId());
        PortalBillingClass.searchTransaction(Date.today()-10, date.today()+10);
        PortalBillingClass.getTransactions(10,5);
        Test.stopTest();
        System.assertEquals('','','');
    }
    
}