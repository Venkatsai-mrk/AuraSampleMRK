public class newCropPrecriptionController {
 
    public string src{get;set;}
    public newCropPrecriptionController(){
        Id accId=ApexPages.currentPage().getParameters().get('recordid').escapeHtml4();
        string page=ApexPages.currentPage().getParameters().get('page').escapeHtml4();
        
        
        //ElixirSuite__CHCCredentials__mdt creds=[select ElixirSuite__Password__c,ElixirSuite__UserName__c From  ElixirSuite__CHCCredentials__mdt];
        //system.debug(creds);
        src='../apex/ElixirSuite__newcropScript?recordId=' + accId + '&page=' + page;
    }
}