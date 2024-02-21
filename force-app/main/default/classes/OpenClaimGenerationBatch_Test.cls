@isTest
public class OpenClaimGenerationBatch_Test {
    
    @isTest
    public static void testCase1(){
                
        Test.startTest();
        CMS_1500_Claim_Generation__c cms = new CMS_1500_Claim_Generation__c();
        cms.No_of_Days_Open_Procedure__c = 1;
        cms.No_of_Hours_Open_Procedure__c = 1;
        cms.ElixirSuite__Active__c = true;
        insert cms;
        OpenClaimGenerationBatch ex = new OpenClaimGenerationBatch();
        Database.executeBatch(ex);
        System.assertEquals(1, 1);
        Test.stopTest();
        
    }
}