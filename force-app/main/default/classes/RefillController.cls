public class RefillController {
 public string src{get;set;}
    public RefillController(){
        Id accId=ApexPages.currentPage().getParameters().get('id');
        system.debug(accId);
        
         String strJson = CHCCredentials__mdt.getInstance('newCHCData').value__c;
        Map<String,String> credMap = (Map<String,String>)JSON.deserialize(strJson, Map<String,String>.class);
        system.debug(credMap);
        system.debug(credMap.get('userid'));
        system.debug(credMap.get('password'));
        system.debug(credMap.get('organization'));
        
        
        
        //src = 'https://cli-cert.emdeon.com/servlet/servlets.apiRxServlet?userid=p_mirketa145b68e593ef9cf39|45a23c6ffb0ca88c|435ff6c8aa20b5c0|42dff6c8aa20b5c0|&hdnBusiness=3004423326&actionCommand=searchfdballergy&apiLogin=true&textError=true&allergyname=peanut&allergytype=ingredient';
        src='https://cli-cert.emdeon.com/servlet/DxLogin?userid='+credMap.get('userid')+'&PW='+credMap.get('password')+'&hdnBusiness='+credMap.get('organization')+'&apiLogin=true&target=jsp/rx/rx/NewRxAuth.jsp&actionCommand=loadRx&lastRow=0';
        
      // CHCCredentials__mdt creds=[select Password__c,UserName__c From  CHCCredentials__mdt];
      //  system.debug(creds);
       // src='https://cli-cert.changehealthcare.com/servlet/DxLogin?userid='+creds.UserName__c+'&PW='+creds.Password__c+'&hdnBusiness=3004423326&apiLogin=true&target=jsp/lab/person/PatientLookup.jsp&FromOrder=false&actionCommand=Search&FromRx=true&loadPatient=false&link=false&searchaccountId='+accId;
    }
}