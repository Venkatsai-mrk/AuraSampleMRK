public with sharing class ManualReconciliationVFController {
 private ApexPages.StandardController standardController;

    public ManualReconciliationVFController(ApexPages.StandardController controller) {
        standardController = controller;
    }

    public String getRecordId() {
        return standardController.getId();
    }
    
    public PageReference redirectToLCForClaim() {
    String returnUrl = '/lightning/cmp/ElixirSuite__ManualEraReconciliation';
    PageReference pgReturnPage = new PageReference(returnUrl);
    pgReturnPage.setRedirect(true);

    String claimId = ApexPages.currentPage().getParameters().get('id').escapeHtml4();
    pgReturnPage.getParameters().put('c__strInput', claimId);
    return pgReturnPage;
}
}