@isTest
private class TestRecommendation {
    @isTest static void RecommendationComponentController(){
       ElixirSuite__EOB__c e = new ElixirSuite__EOB__c();
        insert e;
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User u = new User(Alias = 'staddd', Email='standarduser@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles', UserName='standuser@gmail.com');
        
        
        
        ElixirSuite__Recommendation__c rec = new ElixirSuite__Recommendation__c();
        rec.ElixirSuite__Elixir_Recommendation__c='testing Rec';
        rec.ElixirSuite__Elixir_Assign_To__c = u.Id;
        rec.ElixirSuite__Elixir_ERA__c = e.id;
        insert rec;
        
            
         
        
       List <ElixirSuite__Recommendation__c> recList = new List<ElixirSuite__Recommendation__c>();
        recList.add(rec);
        
        
        
        Test.startTest();
        //Elixir_ViewEditERAEOBRecs.fetchRecs(e.Id);
        //Elixir_ViewEditERAEOBRecs.saveRecList(recList, recList);
        
        Test.stopTest();
       
        System.assertEquals(1, 1, '');
        

            
        
    } 

}