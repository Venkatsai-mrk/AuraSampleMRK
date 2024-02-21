public class NC_EditController {
 public string src{get;set;}
    public NC_EditController(){
        Id accId=ApexPages.currentPage().getParameters().get('recordid').escapeHtml4();
        string pgVal=ApexPages.currentPage().getParameters().get('pgVal').escapeHtml4();
        system.debug(accId);
        system.debug(pgVal);
        
        //ElixirSuite__CHCCredentials__mdt creds=[select ElixirSuite__Password__c,ElixirSuite__UserName__c From  ElixirSuite__CHCCredentials__mdt];
        //system.debug(creds);
        src='../apex/ElixirSuite__NC_EditScript?pgVal=' + pgVal + '&recordId=' + accId;
    }
}