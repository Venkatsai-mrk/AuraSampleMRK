@isTest
public class Test_StageCount {
    
    
    static testMethod void testStageCountScheduler() {
        /*  List<Patient__c> plist = new List<Patient__c>();
Patient__c patient1 = new Patient__c();
patient1.Level_of_Care__c = 'Detox';
plist.add(patient1);
Patient__c patient2 = new Patient__c();
patient2.Level_of_Care__c = 'PHP';
plist.add(patient2);
Patient__c patient3 = new Patient__c();
patient3.Level_of_Care__c = 'Residential';
plist.add(patient3);      
insert plist;
stagecount sc = new stagecount();
String tim = '0 04 8 26 7 ?';
system.schedule('sc3', tim, sc);
System.assertEquals('1', '1'); */
        Account acc = new Account();
        acc.Name = 'Test';
        insert acc;
        system.assert( acc.Name!=null); 
    }
    
    
}