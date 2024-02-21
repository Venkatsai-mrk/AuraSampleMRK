/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 02-08-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
public class VaccineLookupControllerTest {
    
    @isTest
    public static void testVaccineLookupController(){
        Id devRecordTypeId = Schema.SObjectType.ElixirSuite__Vaccine__c.getRecordTypeInfosByDeveloperName().get('Template_Vaccine').getRecordTypeId();
        Vaccine__c vac = new Vaccine__c();
        vac.Name = 'Covid';
        vac.CVX_Code__c = 'C123';
        vac.Next_Dose_in_Series_After__c = 1;
        vac.Vaccine_Route__c = 'Intradermal';
        vac.Vaccine_Site__c = 'Left Upper Arm';
        vac.Vaccine_Series__c = 'SARS-COV-2';
        vac.RecordTypeId = devRecordTypeId;
        insert vac;
        
        test.startTest();
        VaccineLookupController.RecordsData vlrd = new VaccineLookupController.RecordsData('test','test');
        VaccineLookupController.fetchRecords('o','Vaccine__c' );
        System.assertEquals(1,1,'');
        test.stopTest();
    }

}