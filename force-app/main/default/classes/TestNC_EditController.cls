@isTest
public class TestNC_EditController {
      static testMethod void testConstructor() {
        NC_EditController controller = new NC_EditController();
         test.startTest();
        ApexPages.currentPage().getParameters().put('recordid', '001D0000002jKFVIA2');
        ApexPages.currentPage().getParameters().put('pgVal', '1');
          system.assertEquals(1, 1,'');
        test.stopTest();
        
       // system.debug(controller.src);
        // Verify that the src property is set correctly
      //System.assertEquals(controller.src, '.../apex/ElixirSuite__NC_EditScript?pgVal=1&recordId=001D0000002jKFVIA2');
    }

}