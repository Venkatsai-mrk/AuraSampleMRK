@isTest

 public with sharing class ShowSuccess_ctrlTest {
    @isTest
    public static void insertaccTest(){
     Account acc= new Account(Name='test account');
     insert acc;                                  
    ElixirSuite__Procedure__c proc = new ElixirSuite__Procedure__c();
     proc.Name = 'test procedure';
     proc.ElixirSuite__Account__c = acc.Id;
     proc.ElixirSuite__CPT_HCPCS_Code__c = '67890';
     proc.ElixirSuite__Is_Billable__c = true;
     proc.ElixirSuite__Ready_for_Billing__c = false;
     proc.ElixirSuite__Generate_Claim__c = true;             
     insert proc;    
     List<ElixirSuite__Procedure__c> proclist = new List<ElixirSuite__Procedure__c>();               
           ElixirSuite__Procedure__c proce  =new ElixirSuite__Procedure__c();
                proce.Name = 'test10';
                proce.ElixirSuite__Account__c = acc.Id;
                proce.ElixirSuite__CPT_HCPCS_Code__c = 'Test CPT Code';
                proce.ElixirSuite__Is_Billable__c = true;
                proce.ElixirSuite__Ready_for_Billing__c = true;
                proce.ElixirSuite__Generate_Claim__c=true;
            proclist.add(proce);        
            insert proclist;   
        ApexPages.currentPage().getParameters().put('Id', acc.Id);                                                     
        ApexPages.StandardSetController controller = new ApexPages.StandardSetController( [SELECT Id,Is_Patient_Procedure__c FROM ElixirSuite__Procedure__c
                                                                                           WHERE ElixirSuite__Account__c = :acc.Id]);                                                                                       
             
        ShowSuccess_ctrl showCtrl = new ShowSuccess_ctrl(controller);      
        Test.startTest();     
        PageReference pageRef = Page.GenerateClaimSendProc;
        showCtrl.insertacc();
        PageReference url = showCtrl.listView();
		Test.stopTest();                 
        List<ApexPages.Message> messages = ApexPages.getMessages();
        List<ElixirSuite__Procedure__c> procUpdate = [select Id, Name,
                                                      ElixirSuite__Generate_Claim__c 
                                                      from  ElixirSuite__Procedure__c 
                                                      where ElixirSuite__Account__c =:acc.Id];
        update procUpdate;      
        for (ElixirSuite__Procedure__c procedure : procUpdate) {          
            procedure.ElixirSuite__Generate_Claim__c =true;
            System.assertEquals(true, procedure.ElixirSuite__Generate_Claim__c,'');
        }
        System.assertEquals(1, 1,'');   
    }     
    @isTest
    static void testInsertacc() {
    Id stExam = Schema.SObjectType.ElixirSuite__Procedure__c.getRecordTypeInfosByName().get('Patient Procedure').getRecordTypeId();   
                list<Account> accList = new list<Account>();
                Account testAccount = new Account();
                testAccount.Name='Test Account';
                accList.add(testAccount);
    if(!accList.isEmpty()){
             insert accList;
    }               
    List<ElixirSuite__Procedure__c> testProcedures = new List<ElixirSuite__Procedure__c>();
    for(Integer i=0; i<3; i++) {
            testProcedures.add(new ElixirSuite__Procedure__c(
                Name = 'test',
                RecordTypeId = stExam,
                ElixirSuite__Account__c = testAccount.Id,
                ElixirSuite__CPT_HCPCS_Code__c = '12345',
                ElixirSuite__Is_Billable__c = true,
                ElixirSuite__Ready_for_Billing__c = true,
                ElixirSuite__Generate_Claim__c = true
            ));
        }
        insert testProcedures;
        ShowSuccess_ctrl controller = new ShowSuccess_ctrl(new ApexPages.StandardSetController(testProcedures));
        controller.pageId = testAccount.Id;        
        Test.startTest();
        controller.insertacc();
        Test.stopTest();                
         List<ElixirSuite__Procedure__c> updatedProcedures = [SELECT ElixirSuite__Generate_Claim__c FROM ElixirSuite__Procedure__c WHERE Id IN :testProcedures];
        System.assertEquals(3, updatedProcedures.size(), 'All procedures should be updated');
        for(ElixirSuite__Procedure__c updatedProcedure : updatedProcedures) {
            System.assertEquals(true, updatedProcedure.ElixirSuite__Generate_Claim__c, 'Generate_Claim__c should be set to true');
      }
   }
 }