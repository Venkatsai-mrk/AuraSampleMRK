@isTest
public with sharing class TestSendStatementAsEmail {
    @isTest
    static void sendEmailNotifTest() {
        
        Patient_Statement__c patStmt = new Patient_Statement__c();
        patStmt.ElixirSuite__Patient_Name__c ='test patient ';
        insert patStmt;
        list<Patient_Statement__c> patStmtlist = new list<Patient_Statement__c>();
        patStmtlist.add(patStmt);
        SendStatementAsEmail.sendEmailNotif(patStmtlist);
        System.assertEquals(1, Limits.getEmailInvocations(),'');    
        
    }
}