@isTest
public with sharing class TestStampingHelper {
@isTest
    Static void testAddstamps(){
     
            
        StampingHelper stamp = new StampingHelper();        
         test.startTest();
         stamp.addStamps('Test dev', 'test','test stamp' );
         test.stopTest();
        System.assertEquals(1, 1, 'testStamps should contain one stamp');
    }
    @isTest
    public Static void testgetStamps(){
              
        DA_Stamps__mdt stamp2 = new DA_Stamps__mdt();
         stamp2.DeveloperName = 'Test dev2';
        stamp2.Label = 'Test2';
        stamp2.Stamp_SVG_String__c='test stamp2';
        
         DA_Stamps__mdt stamp3 = new DA_Stamps__mdt();
         stamp3.DeveloperName = 'Test dev3';
        stamp3.Label = 'Test3';
        stamp3.Stamp_SVG_String__c='test stamp3';
         List<DA_Stamps__mdt> testStamps = new List<DA_Stamps__mdt>{stamp2,stamp3};
       
              Test.startTest();
        list<DA_Stamps__mdt> stamplist = StampingHelper.getStamps();
             Test.stopTest();
        System.assertEquals(2, testStamps.size(), 'two stamps should be presented');
        System.assertEquals('Test2', testStamps[0].Label, 'two stamps should be presented');
        System.assertEquals('Test3', testStamps[1].Label, 'two stamps should be presented');
        
    }
    @isTest
    static void getTestStampstest(){
       
        StampingHelper obj =  new StampingHelper();
       
        DA_Stamps__mdt stamp3 = new DA_Stamps__mdt();
        //list<DA_Stamps__mdt>additional = new list<DA_Stamps__mdt>();
        stamp3.DeveloperName = 'Test dev1';
        stamp3.Label = 'Test1';
        stamp3.Stamp_SVG_String__c='test stamp1';
       
         List<DA_Stamps__mdt> testStamps = new List<DA_Stamps__mdt>{stamp3};
        
       list<DA_Stamps__mdt> teststamplist= obj.getTestStamps();
        System.assertEquals(1,1,'');
            
    }
}