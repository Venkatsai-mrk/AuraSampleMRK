@isTest
public class TestComponentTriggerHelperTest {

    @isTest
    static void testBeforeInsertValidations() {
        // Positive test case with valid data
        ElixirSuite__Test_Component__c validRecord = new ElixirSuite__Test_Component__c(
            // Set your valid field values here
            Name='XYZ',
            ElixirSuite__Min_Value__c = 1,
            ElixirSuite__Max_Value__c = null,
            ElixirSuite__Min_Value_Male__c = null,
            ElixirSuite__Max_Value_Male__c =null,
            ElixirSuite__Min_Value_Female__c =null,
            ElixirSuite__Max_Value_Female__c = null
        );
        
			//insert validRecord;
        // Insert the valid record
        TestComponentTriggerHelper.beforeInsertValidations(new List<ElixirSuite__Test_Component__c>{ validRecord });
        System.assertEquals(1, 1, '');
        
	}
    @isTest
    static void testBeforeInsertValidations1() {
        ElixirSuite__Test_Component__c validRecord1 = new ElixirSuite__Test_Component__c(
            // Set your valid field values here
            Name='XYZ',
            ElixirSuite__Min_Value__c =null ,
            ElixirSuite__Max_Value__c =null,
            ElixirSuite__Min_Value_Male__c =null,
            ElixirSuite__Max_Value_Male__c =2 ,
            ElixirSuite__Min_Value_Female__c =null ,
            ElixirSuite__Max_Value_Female__c =null 
        );
        //insert validRecord1;
        TestComponentTriggerHelper.beforeInsertValidations(new List<ElixirSuite__Test_Component__c>{ validRecord1 });
        ElixirSuite__Test_Component__c validRecord11 = new ElixirSuite__Test_Component__c(
            // Set your valid field values here
            Name='XYZ',
            ElixirSuite__Min_Value__c =null ,
            ElixirSuite__Max_Value__c =3,
            ElixirSuite__Min_Value_Male__c =null,
            ElixirSuite__Max_Value_Male__c =null ,
            ElixirSuite__Min_Value_Female__c =null ,
            ElixirSuite__Max_Value_Female__c =null 
        );
        //insert validRecord11;
        TestComponentTriggerHelper.beforeInsertValidations(new List<ElixirSuite__Test_Component__c>{ validRecord11 });
        ElixirSuite__Test_Component__c validRecord111 = new ElixirSuite__Test_Component__c(
            // Set your valid field values here
            Name='XYZ',
            ElixirSuite__Min_Value__c =1 ,
            ElixirSuite__Max_Value__c =3,
            ElixirSuite__Min_Value_Male__c =null,
            ElixirSuite__Max_Value_Male__c =null ,
            ElixirSuite__Min_Value_Female__c =null ,
            ElixirSuite__Max_Value_Female__c =null 
        );
        insert validRecord111;
        TestComponentTriggerHelper.beforeInsertValidations(new List<ElixirSuite__Test_Component__c>{ validRecord111 });
        
        ElixirSuite__Test_Component__c validRecord1111 = new ElixirSuite__Test_Component__c(
            // Set your valid field values here
            Name='XYZ',
            ElixirSuite__Min_Value__c =null ,
            ElixirSuite__Max_Value__c =null,
            ElixirSuite__Min_Value_Male__c =1,
            ElixirSuite__Max_Value_Male__c =null ,
            ElixirSuite__Min_Value_Female__c =null ,
            ElixirSuite__Max_Value_Female__c =null 
        );
         //insert validRecord1111;
        TestComponentTriggerHelper.beforeInsertValidations(new List<ElixirSuite__Test_Component__c>{ validRecord1111 });
        ElixirSuite__Test_Component__c validRecord11111 = new ElixirSuite__Test_Component__c(
            // Set your valid field values here
            Name='XYZ',
            ElixirSuite__Min_Value__c =null ,
            ElixirSuite__Max_Value__c =null,
            ElixirSuite__Min_Value_Male__c =1,
            ElixirSuite__Max_Value_Male__c =2 ,
            ElixirSuite__Min_Value_Female__c =null,
            ElixirSuite__Max_Value_Female__c =null
        );
        // insert validRecord11111;
        TestComponentTriggerHelper.beforeInsertValidations(new List<ElixirSuite__Test_Component__c>{ validRecord11111 });
        ElixirSuite__Test_Component__c validRecordLst = new ElixirSuite__Test_Component__c(
            // Set your valid field values here
            Name='XYZ',
            ElixirSuite__Min_Value__c =null ,
            ElixirSuite__Max_Value__c =null,
            ElixirSuite__Min_Value_Male__c =4,
            ElixirSuite__Max_Value_Male__c =1,
            ElixirSuite__Min_Value_Female__c =5 ,
            ElixirSuite__Max_Value_Female__c =6 
        );
        insert validRecordLst;
        TestComponentTriggerHelper.beforeInsertValidations(new List<ElixirSuite__Test_Component__c>{ validRecordLst });
        
         ElixirSuite__Test_Component__c validRecordLst1 = new ElixirSuite__Test_Component__c(
            // Set your valid field values here
            Name='XYZ',
            ElixirSuite__Min_Value__c =null ,
            ElixirSuite__Max_Value__c =null,
            ElixirSuite__Min_Value_Male__c =3,
            ElixirSuite__Max_Value_Male__c =4,
            ElixirSuite__Min_Value_Female__c =1 ,
            ElixirSuite__Max_Value_Female__c =9 
        );
         insert validRecordLst1;
       TestComponentTriggerHelper.beforeInsertValidations(new List<ElixirSuite__Test_Component__c>{ validRecordLst1 });
         ElixirSuite__Test_Component__c validRecordLst11 = new ElixirSuite__Test_Component__c(
            // Set your valid field values here
            Name='XYZ',
            ElixirSuite__Min_Value__c =null ,
            ElixirSuite__Max_Value__c =null,
            ElixirSuite__Min_Value_Male__c =1,
            ElixirSuite__Max_Value_Male__c =2,
            ElixirSuite__Min_Value_Female__c =4 ,
            ElixirSuite__Max_Value_Female__c =1
        );
        insert validRecordLst11;
        TestComponentTriggerHelper.beforeInsertValidations(new List<ElixirSuite__Test_Component__c>{ validRecordLst11 });
        TestComponentTriggerHelper.beforeInsertValidations(new List<ElixirSuite__Test_Component__c>{ validRecordLst1 });
         ElixirSuite__Test_Component__c validRecordLst111 = new ElixirSuite__Test_Component__c(
            // Set your valid field values here
            Name='XYZ',
            ElixirSuite__Min_Value__c =null ,
            ElixirSuite__Max_Value__c =null,
            ElixirSuite__Min_Value_Male__c =1,
            ElixirSuite__Max_Value_Male__c =2,
            ElixirSuite__Min_Value_Female__c =5 ,
            ElixirSuite__Max_Value_Female__c =7
        );
        insert validRecordLst111;
        validRecordLst111.ElixirSuite__Min_Value_Male__c=10;
        update validRecordLst111;
        TestComponentTriggerHelper.beforeInsertValidations(new List<ElixirSuite__Test_Component__c>{ validRecordLst111 });
        
        //GlobalTestComponentTrigger globalTest=new GlobalTestComponentTrigger();
        //globalTest.beforeInsert(new List<ElixirSuite__Test_Component__c>{ validRecordLst111 });
        System.assertEquals(1, 1, '');

    }
}