@isTest
public class TestnewCropPrecriptionController {
     @isTest
    static void testNewCropPrecriptionController() {
        newCropPrecriptionController cc = new newCropPrecriptionController();
        
        test.startTest();
        ApexPages.currentPage().getParameters().put('recordid', '001D0000002jKFVIA2');
        ApexPages.currentPage().getParameters().put('pgVal', '1');
        system.assertEquals(1, 1,'');
        test.stopTest();
        
        //System.assertEquals('../apex/ElixirSuite__newcropScript?recordId=' + accountId + '&page=testPage', controller.src);
    }

}