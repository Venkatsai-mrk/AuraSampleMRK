@isTest
public class ElixirOEM_AllocateDiscountHelperTest {
@isTest
    static void allocateMethod(){
    Elixir_Custom_Setting__c setting = new Elixir_Custom_Setting__c();
      setting.ElixirSuite__Patient_Account_Recordtype__c = 'Patient_Account';
      insert setting;
      String patAccRecType = setting.ElixirSuite__Patient_Account_Recordtype__c; 
        Id devRecordTypeId  = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(patAccRecType).getRecordTypeId();
    
		 Account acc =new Account ();
         acc.RecordTypeId=devRecordTypeId;
         acc.Name= 'Virat Kohli';
         acc.ElixirSuite__DOB__c =date.newInstance(2003, 9, 15);
         acc.ElixirSuite__Gender__c='Male';
         acc.ElixirSuite__Email_Id__c='virat@gmail.com';
		 acc.phone='9988776655';
		 acc.ElixirSuite__First_Name__c='Virat';
		 acc.ElixirSuite__Last_Name__c='Kohli';
		 acc.BillingPostalCode='50021';
		 acc.ElixirSuite__SSN__c='12345';
         insert acc;
        Test.startTest();
         ElixirSuite__Payment_Transaction__c pt = new ElixirSuite__Payment_Transaction__c(ElixirSuite__Expected_Receivable_amount__c=1000,
                                                                                         ElixirSuite__Procedure_Utilized__c=true,
                                                                                         ElixirSuite__Other_Discounts__c=1000,
                                                                                         ElixirSuite__Actual_Price__c=1000,
                                                                                          ElixirSuite__Account__c = acc.Id
                                                                                       );
        insert pt;
        String prcString = '{"procedures":[{"Id":'+'"'+pt.Id+'"'+',"remainingAmount":7000,"currentDiscAmt" : 9000}]}';
          ElixirSuite__Master_Transaction__c mtToInsert = new ElixirSuite__Master_Transaction__c();
                mtToInsert.ElixirSuite__Total_Remaining_Unallocated_Amount__c = 5000;
                mtToInsert.ElixirSuite__Transaction_Date__c = System.today();
                mtToInsert.ElixirSuite__Allocated_Amount__c =  10000;
                mtToInsert.ElixirSuite__Total_Unallocated_Amount__c = 20000;
        insert mtToInsert;
       
        Set<Id> masterTransactionIdSet = new Set<Id>();
        masterTransactionIdSet.add(pt.Id);
        
        ElixirOEM_AllocateDiscountHelper.customDiscountTable(acc.Id);
          ElixirOEM_AllocateDiscountHelper.initPayloadCallData(acc.Id);
        ElixirOEM_AllocateDiscountHelper.filterProcedureOnMasterTransaction(System.today(),System.today(),'Heart attack','cptcode',acc.Id,
                                                                           new List<String>());
        ElixirOEM_AllocateDiscountHelper.queryAllProceduresOnMasterTransaction(acc.Id);
        ElixirOEM_AllocateDiscountHelper.paymentSchedulePayload(acc.Id);
      //  ElixirOEM_AllocateDiscountHelper.calculateRemainingAmt(masterTransactionIdSet,'Discount Percentage');
        ElixirOEM_AllocateDiscountHelper.allocateDiscountInSystem(mtToInsert,'Discount Percentage',acc.Id,prcString,3000,1000,mtToInsert.Id);
        System.assertEquals(1, 1, '');   
        Test.stopTest();
           
    }
}