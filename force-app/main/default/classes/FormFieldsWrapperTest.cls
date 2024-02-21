@isTest
private class FormFieldsWrapperTest {
    @isTest
    static void testCompareTo() {
        Form_Field__c oppy1 = new Form_Field__c(Sequence_Order__c=1);
        Form_Field__c oppy2 = new Form_Field__c(Sequence_Order__c=2);
        FormFieldsWrapper wrapper1 = new FormFieldsWrapper(oppy1);
        FormFieldsWrapper wrapper2 = new FormFieldsWrapper(oppy2);
        
         Integer expectedResult = -1;
        Integer actualResult = wrapper1.compareTo(wrapper2);
        System.assertEquals(expectedResult, actualResult, 'Test case 1 failed');
      
        expectedResult = 1;
        actualResult = wrapper2.compareTo(wrapper1);
        System.assertEquals(expectedResult, actualResult, 'Test case 2 failed');
        
        oppy1.Sequence_Order__c = 2;
        expectedResult = 0;
        actualResult = wrapper1.compareTo(wrapper2);
        System.assertEquals(expectedResult, actualResult, 'Test case 3 failed');
    }
}