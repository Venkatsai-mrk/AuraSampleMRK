public with sharing class ToastController 
{
    public List<Claim__c> selClaimLst {get;set;}
    public String claimIds {get;set;}
      // Constructor
      public ToastController(ApexPages.StandardSetController cntlr){
          selClaimLst = (List<Claim__c>) cntlr.getSelected();
           system.debug('### selClaimLst : ' +selClaimLst);
           claimIds = '';  
           for(Claim__c cl : selClaimLst){
               claimIds += cl.Id + ','; //build list of ids string concatenated with comma  
            }
           claimIds = claimIds.removeEnd(',');
      } 
      //comminted
      public PageReference redirectToLC(){
      String returnUrl='';
      returnUrl = '/lightning/cmp/ElixirSuite__ParentGetERACmp';
          PageReference pgReturnPage = new PageReference(returnUrl);
          pgReturnPage.setRedirect(true);
          return pgReturnPage;
      }
    public PageReference redirectToLCForClaim(){
      String returnUrl='';
      returnUrl = '/lightning/cmp/ElixirSuite__ParentSendClaimSubmission';
          PageReference pgReturnPage = new PageReference(returnUrl);
          pgReturnPage.setRedirect(true);
        system.debug('test' + claimIds);
          pgReturnPage.getParameters().put('c__strInput',claimIds);
          return pgReturnPage;
      }
}