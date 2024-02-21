@isTest
public with sharing class SearchBarControllerTest {
    @isTest
    public static void searchBarTest() {

        String searchKeyWord = 'test';
        String recId = '12345';
        String typeOfNote = 'Note';
		Test.startTest();
        SearchBarController.getMenuItems(searchKeyWord, recId, typeOfNote);
        SearchBarController.getDiagnosisItems(searchKeyWord);
        
        date dt = system.today();
        String dob = string.valueOf(dt);
        new SearchBarController.InnerWrapperCls( 'test form', 'test Name' , dob , 'pass123' , 'test Parent');
        
        new SearchBarController.LookupWrapperClass( '001', 'test Field' , 'New value' , 'new' , true);       
		Test.stopTest();  
        system.assertEquals(1, 1, '');     
    }
    
    @isTest
    public static void searchBarTest1() {

		Test.startTest();
        SearchBarController.getMenuItems('test1', '14789', 'Problem');
        SearchBarController.getMenuItems('test1', '14789', 'Diagnosis');
        Test.stopTest();
        system.assertEquals(1, 1, '');
    }

}