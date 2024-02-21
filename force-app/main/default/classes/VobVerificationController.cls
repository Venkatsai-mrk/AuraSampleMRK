public with sharing class VobVerificationController {
  private ApexPages.StandardController standardController;

    public VobVerificationController(ApexPages.StandardController controller) {
        standardController = controller;
    }

    public String getRecordId() {
        return standardController.getId();
    }
    
    public PageReference redirectToLCForVob() {
    String returnUrl = '/lightning/cmp/ElixirSuite__ParentVobVerification';
    PageReference pgReturnPage = new PageReference(returnUrl);
    pgReturnPage.setRedirect(true);

    String vobId = ApexPages.currentPage().getParameters().get('id').escapeHtml4();
    pgReturnPage.getParameters().put('ElixirSuite__recordId', vobId);
         Boolean detailBtn = true;
    pgReturnPage.getParameters().put('ElixirSuite__isDetailButton', String.valueOf(detailBtn));
    return pgReturnPage;
}
}