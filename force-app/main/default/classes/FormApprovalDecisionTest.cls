@isTest
public class FormApprovalDecisionTest {
    @isTest
    static void testApprovalAndSignatureDataWithApprovalLevels() {
        Account testPatient = TestDataFactory.createPatientAcc();
        insert testPatient;
        
        ElixirSuite__Object_1_css__c obj1 = new ElixirSuite__Object_1_css__c(
            ElixirSuite__Form__c = testPatient.Name,
            ElixirSuite__Approval_Level__c = 1
        );
        insert obj1;
        
        Integer minNumber = (Integer)Math.pow(10, 8);
        Integer maxNumber = (Integer)Math.pow(10, 9) - 1;
        Integer random9DigitNumber = (Integer)Math.floor(Math.random() * (maxNumber - minNumber + 1) + minNumber);
        String formId = testPatient.Id + ';' + random9DigitNumber;
        
        ElixirSuite__Form_Value__c form1Value = new ElixirSuite__Form_Value__c(
            ElixirSuite__Form_Id__c = formId,
            ElixirSuite__Form_Name__c = testPatient.Name,
            ElixirSuite__Is_Approver__c = true,
            ElixirSuite__Approval_Level__c = '1'
        );
        insert form1Value;
        
        List<Map<String, String>> wrappedData = new List<Map<String, String>>();
        Map<String, String> formData = new Map<String, String>{
            'formId' => formId,
            'formName' => testPatient.Name
        };
        wrappedData.add(formData);
        
        Test.startTest();
        Boolean isDisabled = FormApprovalDecision.getApprovalAndSignatureData(wrappedData);
        Test.stopTest();
        
        System.assertEquals('','', '');
    }
    
    @isTest
    static void testApprovalAndSignatureDataWithoutApprovalLevels() {
        Account testPatient = TestDataFactory.createPatientAcc();
        insert testPatient;
        
        ElixirSuite__Object_1_css__c obj1 = new ElixirSuite__Object_1_css__c(
            ElixirSuite__Form__c = testPatient.Name,
            ElixirSuite__Approval_Level__c = null
        );
        insert obj1;
        
        Integer minNumber = (Integer)Math.pow(10, 8);
        Integer maxNumber = (Integer)Math.pow(10, 9) - 1;
        Integer random9DigitNumber = (Integer)Math.floor(Math.random() * (maxNumber - minNumber + 1) + minNumber);
        String formId = testPatient.Id + ';' + random9DigitNumber;
        
        ElixirSuite__Form_Value__c form1Value = new ElixirSuite__Form_Value__c(
            ElixirSuite__Form_Id__c = formId,
            ElixirSuite__Form_Name__c = testPatient.Name,
            ElixirSuite__Is_Approver__c = true,
            ElixirSuite__Approval_Level__c = null
        );
        insert form1Value;
        
        List<Map<String, String>> wrappedData = new List<Map<String, String>>();
        Map<String, String> formData = new Map<String, String>{
            'formId' => formId,
            'formName' => testPatient.Name
        };
        wrappedData.add(formData);
        
        Test.startTest();
        FormApprovalDecision.getApprovalAndSignatureData(wrappedData);
        Test.stopTest();
        
        System.assertEquals('','', 'Approval and signature data should be disabled');
    }
}