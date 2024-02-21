@isTest
public class TestLabOrderController { 
    @isTest
    public static  void  method1(){
        Account a  = new Account();
        a.name='testAccount';
        a.Verification_Code__c = '101';
        a.Phone='0123456789';
        a.BillingPostalCode='85212';
        insert a;
        Account acc  = new Account();
        acc.name='testAccount1';
        acc.Verification_Code__c = '1101';
        acc.Phone='01234567819';
        acc.BillingPostalCode='185212';
        insert acc;
        UA_Sample_Details__c testDelete  = new UA_Sample_Details__c();
        testDelete.Account__c = a.id;
        insert testDelete;
        LabOrderController.getLabOrder(testDelete.id);
        LabOrderController.deleteLabOrderRecord(testDelete.id);
        List<UA_Sample_Details__c> lstDemo = new  List<UA_Sample_Details__c>();
        for (Integer i=0;i<10;i++) {
            UA_Sample_Details__c p = new UA_Sample_Details__c();
            p.Account__c=a.id;       
            lstDemo.add(p);
        }
        insert lstDemo;
        List<String> recToDelete  = new List<String>();
        for (UA_Sample_Details__c temp :  lstDemo){
            recToDelete.add(temp.id);         
        }
        LabOrderController.deleteRecords(recToDelete);
        LabOrderController.getCode(a.Id);
        LabOrderController.getRelatedLabOrder(a.id);
        UA_Sample_Details__c forSave  = new UA_Sample_Details__c();
        forsave.Start_Date__c=system.today();
        forSave.On_Admission__c=true;
        forSave.Frequency__c='Every 3 Days';
        forSave.Fax__c='011INDIA';
        forSave.Medical_Test__c='';
        forSave.Ordered_Via__c='Verbal, read back and verified';
        forSave.Ordered_By__c=UserInfo.getUserId();
        forSave.Account__c = a.id;

        insert forSave;
        List<String> newLit= new List<String>();
        newLit.add(forSave.id);

        //String procValue  = '{"sobjectType":"UA_Sample_Details__c","Start_Date__c":"2020-02-19","On_Admission__c":true,"Frequency__c":"Every 3 Days","Fax__c":"011","Medical_Test__c":"","Ordered_Via__c":"Verbal, read back and verified"}';
        //string necessityDetails = 'demo deails';
        //String acct  = a.id;
        //String medVal = 'Demo medicine';
        // HealthCloudGA__EHRProcedureRequest__c procReq,
        // String acct ,String starttimeProcedure , String endtimeProcedure,String attachId,String commentSign,string LabOrderID
        String stTime = String.valueOf(system.now());
        String edTime = String.valueOf(system.now() + 2);


        Attachment attach=new Attachment(); 
        attach.Name='Unit Test Attachment'; 
        Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body'); 
        attach.body=bodyBlob; attach.parentId=a.id;
        insert attach;
        ElixirSuite__UA_Sample_Details__c labOrder = new ElixirSuite__UA_Sample_Details__c();
        labOrder.ElixirSuite__Account__c=acc.id;
        labOrder.Status__c='In Progress';
        insert labOrder;
        
       



        // LabOrderController.saveRecord(forSave,necessityDetails,acct,medVal ,stTime , edTime );
        LabOrderController.saveRecordAfterEdit(forSave,userinfo.getUserId(),forSave.Id,stTime,edTime,attach.Id,'Demo comment','30/6/2020',forSave.Id);
        LabOrderController.saveSign(attach.Id , 'Demo comment','30/6/2020',forSave.Id);
        LabOrderController.getAllUser();
        LabOrderController.UpdateRecords(newLit);
        LabOrderController.fetchCusomMetadataRecord();
        LabOrderController.getAllPicklistValues();
        LabOrderController.checkCareEpisode(a.id);
        LabOrderController.saveRecord(lstDemo, 'necessityDetails', a.id, 'medVal','30/6/2020', '30/8/2020');
        LabOrderController.fetchAccountName(a.id);
        LabOrderController.saveColumnsApex('Text');
        //LabOrderController.attachApprovalDataToLabOrder(labOrder.id,'Completed');
        LabOrderController.getLabNames();
        LabOrderController.getAvailableTestName();
       
        system.assert(a.Name!=null); 
        
        //added by Shivank
         

       
        
        // Create test data for JSON input
        List<OrderSignatureSave.SignAndAprroveData> approvalData = new List<OrderSignatureSave.SignAndAprroveData>();
        OrderSignatureSave.SignAndAprroveData approval1 = new OrderSignatureSave.SignAndAprroveData();
        approval1.approvalLevel = 1;
        approval1.dateOfApproval = Date.today();
        approval1.comments = 'Approval 1 Comment';
        approval1.userId = UserInfo.getUserId();
        approvalData.add(approval1);
        
        OrderSignatureSave.SignAndAprroveData approval2 = new OrderSignatureSave.SignAndAprroveData();
        approval2.approvalLevel = 2;
        approval2.dateOfApproval = Date.today();
        approval2.comments = 'Approval 2 Comment';
        approval2.userId = UserInfo.getUserId();
        approvalData.add(approval2);
        
        OrderSignatureSave.SignAndAprroveData approval3 = new OrderSignatureSave.SignAndAprroveData();
        approval3.approvalLevel = 3;
        approval3.dateOfApproval = Date.today();
        approval3.comments = 'Approval 3 Comment';
        approval3.userId = UserInfo.getUserId();
        approvalData.add(approval3);
        
        // Convert approvalData to JSON string
        String approvalDataJson = JSON.serialize(approvalData);
        
        // Call the method being tested
        Test.startTest();
        String labOrderId = LabOrderController.attachApprovalDataToLabOrder(labOrder.Id, approvalDataJson);
        Test.stopTest();
        
        // Retrieve the lab order after the method call
        ElixirSuite__UA_Sample_Details__c updatedLabOrder = [SELECT Id, Status__c FROM ElixirSuite__UA_Sample_Details__c WHERE Id = :labOrderId];
        
        // Assert that the lab order was updated
        System.assertEquals('In Progress', updatedLabOrder.Status__c, 'Lab Order status should be "In Progress" after approval.');
        
    }

}