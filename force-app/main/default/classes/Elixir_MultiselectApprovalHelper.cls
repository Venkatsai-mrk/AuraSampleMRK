public with sharing class Elixir_MultiselectApprovalHelper {
     @AuraEnabled
    public static Elixir_PrescriptionsApprovalHelper.FormApprovalHelperWrapper getselectOptions(String setupKeySelected) {
       return Elixir_PrescriptionsApprovalHelper.fetchOptions_SetupKey(setupKeySelected);
    
    }

}