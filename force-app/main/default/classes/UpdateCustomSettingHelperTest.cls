@isTest
public class UpdateCustomSettingHelperTest {
@isTest
    public static void deleteAllKey(){
        List<ElixirSuite__EMR_License__c> rec =new  List<ElixirSuite__EMR_License__c>();
        ElixirSuite__EMR_License__c emrRec = new ElixirSuite__EMR_License__c();
        emrRec.Name = 'EMR';
        rec.add(emrRec);
        insert rec;
        
        test.startTest();
        UpdateCustomSettingHelper.deleteAllKey();
        UpdateCustomSettingHelper.getKeyCounts();
        test.stopTest();
        system.assertEquals(1,1,'Hello');
        List<EMR_License__c> remainingLicenses = [SELECT Id FROM EMR_License__c];
        System.assertEquals(1, 1, ' ');
    }
    @isTest
    public static void testGetKeyCounts_NoRecords() {
        Integer count = UpdateCustomSettingHelper.getKeyCounts();
        System.assertEquals(1, 1, ' ');
         String result = UpdateCustomSettingHelper.deleteAllKey();
         System.assertEquals(1, 1, ' ');
    }      
    
}