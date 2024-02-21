/**@author: Srihari G K
 * Last modified on: 16-2-2023
 * Test class:LabResultsControllerTest
 */
public with sharing class LabResultsController {
    @AuraEnabled
    public static Wrapper fetchLabOrders(Id userId){
        //Integer dummytotalRecords=0;
        Integer chctotalRecords=0;
        Integer totalRecords=0;
        List<ElixirSuite__Lab_Order__c> chcList = new List<ElixirSuite__Lab_Order__c>();
        //List<ElixirSuite__UA_Sample_Details__c> loList = new List<ElixirSuite__UA_Sample_Details__c>();
        //List<ElixirSuite__TabPermissionBasedOnProfiles__c> tabCsList = new List<ElixirSuite__TabPermissionBasedOnProfiles__c>();
        List<SObject> sobjectList = new List<SObject>();
        //String lab = '';
        Id accId;
        String query = 'SELECT Id, AccountId FROM User WHERE Id =: userId WITH SECURITY_ENFORCED';
        list<user> u = Database.query(query);
        if(u != null && !u.isEmpty()){
            accId = (String) u[0].get('AccountId');
        }
        chcList = [select id,(SELECT Id FROM ElixirSuite__LabOrder_HL7_Results__r),ElixirSuite__Test_Name__c, 
                   ElixirSuite__Collection_Date_Time__c, toLabel(ElixirSuite__Status__c) FROM ElixirSuite__Lab_Order__c 
             where ElixirSuite__Account_Id__c =:accId WITH SECURITY_ENFORCED order by createdDate desc];
        /*loList = [select Id,ElixirSuite__Medical_Test__c,ElixirSuite__Start_Date__c,ElixirSuite__Is_File_Created__c,
                  ElixirSuite__Status__c from ElixirSuite__UA_Sample_Details__c where ElixirSuite__Account__c =:accId WITH SECURITY_ENFORCED ];
        tabCsList = [SELECT id,Name, ElixirSuite__LabOrder_Priority__c FROM ElixirSuite__TabPermissionBasedOnProfiles__c 
                     where Name = 'TabPermissionBasedOnProfiles (Profile)' WITH SECURITY_ENFORCED limit 1];
        dummytotalRecords = [SELECT count() FROM ElixirSuite__UA_Sample_Details__c WITH SECURITY_ENFORCED];*/
        
        /*if (tabCsList.size()>0 && tabCsList!=Null && tabCsList[0].ElixirSuite__LabOrder_Priority__c!=Null){
            lab = tabCsList[0].ElixirSuite__LabOrder_Priority__c;
            if (tabCsList[0].ElixirSuite__LabOrder_Priority__c=='CHC LabOrder') {
                sobjectList =  chcList;
                totalRecords=chctotalRecords;
            }
            else if (tabCsList[0].ElixirSuite__LabOrder_Priority__c=='Dummy LabOrder') {
                sobjectList =  loList;
                totalRecords=dummytotalRecords;
            }
        }*/
        chctotalRecords = [SELECT count() FROM ElixirSuite__Lab_Order__c WITH SECURITY_ENFORCED];
        sobjectList =  chcList;
        totalRecords=chctotalRecords;
        Wrapper wrpr = new Wrapper();
        wrpr.sobjectWrapper = sobjectList;
        //wrpr.labWrapper = lab;
        wrpr.totalRecordsWrapper=totalRecords;
        return wrpr;
    }
    public class Wrapper{
        //@AuraEnabled public String labWrapper;
        @AuraEnabled public List<SObject> sobjectWrapper;
        @AuraEnabled public Decimal totalRecordsWrapper ;
    }  
}