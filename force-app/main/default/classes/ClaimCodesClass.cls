public class ClaimCodesClass {
    @AuraEnabled
    public static ElixirOEM_FormApprovalHelper.FormApprovalHelperWrapper getselectOptions(String setupKeySelected) {
        return ElixirOEM_FormApprovalHelper.fetchOptions_SetupKey(setupKeySelected);   
    }
    /*@AuraEnabled 
    public static account saveAccount(Account acc){
        system.debug('acc--->' + acc);
        List<Account> acctLst = new List<Account>();
        acctLst.add(acc);
        if(acctLst!=null && acctLst.size()>0){
            insert acctLst;
        }
        
        return acc;
    }*/
}