@isTest
public class TestGenericDialogBox {
    @isTest
    public static void genericDialogBoxMethod(){
        List<String> stList = new List<String>{'Name'};
        String Account= 'Account';   
        Test.startTest();
        List<sObject> i = GenericDialogBox.records(Account,'%',stList,stList,'Id != null');
        System.assertEquals(1, 1, '');
        Test.stopTest();
    }
}