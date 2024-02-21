public with sharing class ElixirOEM_MultiselectForApprovalHelper {
    @AuraEnabled
    public static ElixirOEM_FormApprovalHelper.FormApprovalHelperWrapper getselectOptions(String setupKeySelected) {
       return ElixirOEM_FormApprovalHelper.fetchOptions_SetupKey(setupKeySelected);
    
    }

}