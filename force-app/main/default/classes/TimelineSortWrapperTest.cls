/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 02-17-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
public class TimelineSortWrapperTest {
    @isTest
    static void testCompareTo() {
        // Create two Master_Object__c records with different Sort_Order__c values
        Master_Object__c oppy1 = new Master_Object__c(Sort_Order__c = 2);
        insert oppy1;
        Master_Object__c oppy2 = new Master_Object__c(Sort_Order__c = 1);
        insert oppy2;
        
        // Create two TimelineSortWrapper objects
        TimelineSortWrapper wrapper1 = new TimelineSortWrapper(oppy1);
        TimelineSortWrapper wrapper2 = new TimelineSortWrapper(oppy2);
        
        // Verify that the compareTo method returns 1 for wrapper1 and wrapper2
        System.assertEquals(wrapper1.compareTo(wrapper2), 1, 'Expecting 1');
        
        // Verify that the compareTo method returns -1 for wrapper2 and wrapper1
        System.assertEquals(wrapper2.compareTo(wrapper1), -1, 'Expecting -1');
        
        // Create a third TimelineSortWrapper object with the same Master_Object__c as wrapper2
        TimelineSortWrapper wrapper3 = new TimelineSortWrapper(oppy2);
        
        // Verify that the compareTo method returns 0 for wrapper2 and wrapper3
        System.assertEquals(wrapper2.compareTo(wrapper3), 0, 'Expecting 0');
    }
}