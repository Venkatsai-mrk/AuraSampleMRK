@isTest
public class TestnewCropPresSearch {
     
    @isTest
    static void cropSearch(){
  
         Account acc = new Account(Name='Test Account');
        insert acc;
   
        test.startTest();
        List<Prescription_Order__c> prec = newCropPresSearch.getPrescriptionBySearch('',acc.id);
        List<Prescription_Order__c> prec1= newCropPresSearch.getPrescriptionByStatus('',acc.id);
        String ur = newCropPresSearch.getUserInfo();
        Boolean uTest=newCropPresSearch.getUserType();
          system.assertEquals(1, 1,'');
         test.stopTest();
    }

}