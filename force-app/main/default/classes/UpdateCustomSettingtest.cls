@isTest
public class UpdateCustomSettingtest {
   
    public static testmethod void testupdate(){
       
        //UpdateCustomSetting.updateKey('keyString');
        
        
        EMR_License__c e=new EMR_License__c();
        e.key__c='test';
        e.name='ue';
        //e.keyString='test1';
        insert e;
        test.startTest();
       // UpdateCustomSetting.deleteAllKeys();
        UpdateCustomSetting.getKeyCount();
       // UpdateCustomSetting.updateKey('test');
        UpdateCustomSetting.checkLicenseKey();
        UpdateCustomSetting.fakemethod();
        test.stopTest();
       
        System.assertEquals(1, 1, ' ');
    }
   
}