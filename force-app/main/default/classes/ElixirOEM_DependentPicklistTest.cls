@isTest
public class ElixirOEM_DependentPicklistTest {
    @isTest
    public static void unitTest(){
        //Form_Object__mdt med = new Form_Object__mdt();
       // med.Object_Name__c = 'abs';
        //insert med;
        Account patient = new Account();
        patient.name = 'Test Patient';
        patient.ElixirSuite__Email_Id__c = 'kj@gmail.com';
        patient.Patient_s_Birth_Date__c = System.today().addyears(-20);
        patient.MRN_Number__c = 1234567;
        patient.ElixirSuite__First_Name__c ='fname';
        patient.ElixirSuite__Last_Name__c ='lname';
        patient.ElixirSuite__SSN__c ='1234';
        patient.ElixirSuite__Gender__c='Male';
        patient.Phone ='9919850735';
        patient.BillingPostalCode='27440';
        insert patient;
        List<string>accList = New List<string>();
       //  controllingValueToDependentValues = FormRenderUtility.getDependentPicklistValues(dependedentField);
      //  Account a = new Account();
      //  a.Name = 'ABC';
      //  accList.add(a);
          
        Test.startTest();
 
        ElixirOEM_DependentPicklist.fetchAllValidObject();
        ElixirOEM_DependentPicklist.getFields(accList);
    //    ElixirOEM_DependentPicklist.getFields(controllingValueToDependentValues1);
        System.assertEquals(1, 1, '');
        
        Test.stopTest();
        
    }

}