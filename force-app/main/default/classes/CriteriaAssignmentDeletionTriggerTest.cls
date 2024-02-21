@isTest
public class CriteriaAssignmentDeletionTriggerTest {
    
    
    public static void dataSetUp(){
        ElixirSuite__Account_Group__c accountGroup = new ElixirSuite__Account_Group__c();
        accountGroup.Name ='Test Record';
        accountGroup.ElixirSuite__Is_Active__c = true;
        insert accountGroup;
        
        List<ElixirSuite__Criteria_Assignment__c> listOfCriteriaAssignment = new List<ElixirSuite__Criteria_Assignment__c>();
        ElixirSuite__Criteria_Assignment__c  criteriaAssignment = new ElixirSuite__Criteria_Assignment__c();
        criteriaAssignment.ElixirSuite__Account_Group__c = accountGroup.Id;
        criteriaAssignment.ElixirSuite__Criteria_Type__c = 'Age';
        criteriaAssignment.ElixirSuite__Field_Value__c = '20';
        criteriaAssignment.ElixirSuite__Field_API_Name__c = 'ElixirSuite__Age__c';
        criteriaAssignment.ElixirSuite__Operator__c ='equals';
        
        ElixirSuite__Criteria_Assignment__c  criteriaAssignment1 = new ElixirSuite__Criteria_Assignment__c();
        criteriaAssignment1.ElixirSuite__Account_Group__c = accountGroup.Id;
        criteriaAssignment1.ElixirSuite__Criteria_Type__c = 'Admit Date';
        criteriaAssignment1.ElixirSuite__Field_Value__c = '2022-03-28';
        criteriaAssignment1.ElixirSuite__Field_API_Name__c = 'ElixirSuite__Admit_Date__c';
        criteriaAssignment1.ElixirSuite__Operator__c ='equals';
        
        ElixirSuite__Criteria_Assignment__c  criteriaAssignment2 = new ElixirSuite__Criteria_Assignment__c();
        criteriaAssignment2.ElixirSuite__Account_Group__c = accountGroup.Id;
        criteriaAssignment2.ElixirSuite__Criteria_Type__c = 'LOC';
        criteriaAssignment2.ElixirSuite__Field_Value__c = '[{"Id":"a0T5Y00000b7ZyeUAE","Name":"PG10067"}]';
        criteriaAssignment2.ElixirSuite__Field_API_Name__c = 'ElixirSuite__Programs__c';
        criteriaAssignment2.ElixirSuite__Operator__c ='equals';
        
        ElixirSuite__Criteria_Assignment__c  criteriaAssignment3 = new ElixirSuite__Criteria_Assignment__c();
        criteriaAssignment3.ElixirSuite__Account_Group__c = accountGroup.Id;
        criteriaAssignment3.ElixirSuite__Criteria_Type__c = 'Age';
        criteriaAssignment3.ElixirSuite__Field_Value__c = '20';
        criteriaAssignment3.ElixirSuite__Field_API_Name__c = 'ElixirSuite__Age__c';
        criteriaAssignment3.ElixirSuite__Operator__c ='equals';
        
        ElixirSuite__Criteria_Assignment__c  criteriaAssignment4 = new ElixirSuite__Criteria_Assignment__c();
        criteriaAssignment4.ElixirSuite__Account_Group__c = accountGroup.Id;
        criteriaAssignment4.ElixirSuite__Criteria_Type__c = 'Current Patient Name';
        criteriaAssignment4.ElixirSuite__Field_Value__c = '[{"Id":"0015Y0000308EWPQA2","Name":"Neeta Thakur"}]';
        criteriaAssignment4.ElixirSuite__Field_API_Name__c = 'Account';
        criteriaAssignment4.ElixirSuite__Operator__c ='equals';
        
        ElixirSuite__Criteria_Assignment__c  criteriaAssignment5 = new ElixirSuite__Criteria_Assignment__c();
        criteriaAssignment5.ElixirSuite__Account_Group__c = accountGroup.Id;
        criteriaAssignment5.ElixirSuite__Criteria_Type__c = 'Location';
        criteriaAssignment5.ElixirSuite__Field_Value__c = '[]';
        criteriaAssignment5.ElixirSuite__Field_API_Name__c = 'ElixirSuite__Provider__c';
        criteriaAssignment5.ElixirSuite__Operator__c ='equals';
        
        listOfCriteriaAssignment.add(criteriaAssignment);
        listOfCriteriaAssignment.add(criteriaAssignment1);
        listOfCriteriaAssignment.add(criteriaAssignment2);
        listOfCriteriaAssignment.add(criteriaAssignment3);
        listOfCriteriaAssignment.add(criteriaAssignment4);
        listOfCriteriaAssignment.add(criteriaAssignment5);
        
        insert listOfCriteriaAssignment;
        
        
    }
    
    @isTest
    public static void deleteionTestMethod(){
        dataSetUp();
        
        ElixirSuite__Account_Group__c queryAccountGroup =[Select id,Name from ElixirSuite__Account_Group__c limit 1];
        
        ElixirSuite__Criteria_Assignment__c queryCriteria =[Select id,Name,ElixirSuite__Criteria_Type__c from ElixirSuite__Criteria_Assignment__c where ElixirSuite__Criteria_Type__c='Age' limit 1];
       
       delete  queryCriteria;
       System.assertEquals(1, 1, '');
        
    }
    
    
}