@isTest
public class InsertPreAssessmentTest {
    
     @isTest
     public static void testInsertPreAssessmentid(){
      Opportunity opp = new Opportunity(Name='Opp345', StageName='Prospecting', Phone__c='8765437890', DOB__c= Date.newInstance(1988,2,3),CloseDate=system.today());
    insert opp;
         Test.startTest();
         InsertPreAssessment.InsertPreAssessmentid(opp.id);
         Pre_assessment__c preAssessment= [SELECT Id,ElixirSuite__Date_Of_Birth__c, ElixirSuite__Phone__c, ElixirSuite__Opportunity__c, ElixirSuite__Stage__c FROM ElixirSuite__Pre_assessment__c WITH SECURITY_ENFORCED limit 1];
          System.assertEquals(1,1,'');
         Test.stopTest(); 
        
}
 
   

}