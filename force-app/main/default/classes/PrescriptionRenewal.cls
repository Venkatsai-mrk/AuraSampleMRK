public class PrescriptionRenewal {
    Public Account acc;
    public string src{get;set;}
    public PrescriptionRenewal(){
        Id accId=ApexPages.currentPage().getParameters().get('id');
        system.debug(accId);
        
        acc = [Select id, ElixirSuite__First_Name__c, ElixirSuite__Last_Name__c, ElixirSuite__DOB__c  from Account where Id =: accId];
        system.debug(acc.ElixirSuite__DOB__c);
        DateTime dt = acc.ElixirSuite__DOB__c;
        String dateStr = dt.format('MM/dd/yyyy');
        
        String strJson = CHCCredentials__mdt.getInstance('newCHCData').value__c;
        Map<String,String> credMap = (Map<String,String>)JSON.deserialize(strJson, Map<String,String>.class);
        system.debug(credMap);
        system.debug(credMap.get('userid'));
        system.debug(credMap.get('password'));
        system.debug(credMap.get('organization'));
        
        //src = 'https://cli-cert.emdeon.com/servlet/DxLogin?userid='+credMap.get('userid')+'&PW='+credMap.get('password')+'&hdnBusiness='+credMap.get('organization')+'&apiLogin=true&target=jsp/rx/rx/NewRxAuth.jsp&actionCommand=loadRx&lastRow=0';
        src = 'https://cli-cert.emdeon.com/servlet/DxLogin?userid='+credMap.get('userid')+'&PW='+credMap.get('password')+'&hdnBusiness='+credMap.get('organization')+'&apiLogin=true&target=jsp/lab/person/PersonRxHistory.jsp&actionCommand=apiRxHistory&P_ACT='+accId+'&P_LNM='+acc.ElixirSuite__Last_Name__c+'&P_FNM='+acc.ElixirSuite__First_Name__c+'&P_DOB='+dateStr;
    }
}