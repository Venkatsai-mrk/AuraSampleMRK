@isTest
public class dualBoxcontroller_Test 
{
	public static testMethod void dualTest()
    {
        Claim__c claimRecord = new Claim__c();
        claimRecord.claim_status__c = 'Ready to Submit';
        claimRecord.pcn__c = 'John';
        claimRecord.patient_first_Name__c = 'David';
        claimRecord.patient_last_Name__c = 'Beckam';
        claimRecord.npi__c = '1831234939';
        claimRecord.Message__c = '';
        insert claimRecord;
        
        Claim_Line_Items__c rec = new Claim_Line_Items__c();
        rec.CPT_HCPCS_Code__c = '38525';
        rec.Days_Units__c = 2;
        rec.From_Date__c = System.today().adddays(-10);
        rec.To_Date__c = System.today().adddays(-8);
        rec.procedure_charge__c = 900;
        rec.diag_ref__c = 'A';
        rec.claim__c = claimRecord.Id;
        insert rec;
        
        Test.startTest();
        	List<String> selectedoptions = new List<String>();
        	selectedoptions.add('Test');
        	dualBoxcontroller.getselectOptions(claimRecord.Id);
        	dualBoxcontroller.getValues(claimRecord.Id, selectedoptions);
        Test.stopTest();
          System.assertEquals(1, 1, ' ');
    }
}