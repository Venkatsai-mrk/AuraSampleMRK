public with sharing class InsuranceController {
    public VOB__c PatientData{get;set;}
    public string Vobids{get;set;}
    public boolean displayPopup {get; set;}     
    
    public ApexPages.StandardSetController stdCntrlr {get; set;}
    public InsuranceController(ApexPages.StandardController controller){
        String Vobid = '';															  
        Vobid = Apexpages.currentpage().getparameters().get('Id').escapeHtml4();
        Vobids=Vobid;
        /*PatientData = [select id,	PatientFirstName__c,PatientLastName__c,Patient_Birth_Date__c,Member_Id__c,Group_Number__c,
                       Payer_Name__c, Subscriber_Member_ID__c from VOB__c where id=:Vobid ];*/
        PatientData = [select id,	PatientFirstName__c,PatientLastName__c,Patient_Birth_Date__c,Member_Id__c,Group_Number__c,
                       Payer_Name__c from VOB__c where id=:Vobid WITH SECURITY_ENFORCED];
    }
    
    public void closePopup() {        
        displayPopup = false;    
    }     
    public void showPopup() {        
        displayPopup = true;    
    }
    
    public void accept(){
        /*PatientData = [select id,	
                       PatientFirstName__c,
                       PatientLastName__c,
                       Patient_Birth_Date__c,
                       Member_Id__c,
                       Group_Number__c,
                       Payer_Name__c,
                       Last_Verified_Date__c,Type__c,
                       Subscriber_Member_ID__c  
                       from VOB__c 
                       where id=:Vobids ];*/
         PatientData = [select id,	
                       PatientFirstName__c,
                       PatientLastName__c,
                       Patient_Birth_Date__c,
                       Member_Id__c,
                       Group_Number__c,
                       Payer_Name__c,
                       Last_Verified_Date__c,Type__c  
                       from VOB__c 
                       where id=:Vobids WITH SECURITY_ENFORCED];
        System.debug('PatientData '+PatientData);
        
        Result__c vobResult = new Result__c();
        try{
        vobResult.Deduc_inNtwk_Clientperc__c=20;
        vobResult.Co_Insurance_Provider_Percent__c= 80;
        vobResult.in_network_total__c=0;
        vobResult.In_Net_Co_Payment__c = 50;
        vobResult.out_of_network_outOfPocket_total__c = 0;
        vobResult.Insurance_Type__c =  PatientData.Type__c;
        vobResult.VOB__c = PatientData.id;
        vobResult.Payer_Name__c = PatientData.Payer_Name__c;
        
        System.debug('vobResult '+vobResult);
        
        if(Schema.sObjectType.Result__c.fields.Deduc_inNtwk_Clientperc__c.isCreateable() &&
        Schema.sObjectType.Result__c.fields.Co_Insurance_Provider_Percent__c.isCreateable() &&
        Schema.sObjectType.Result__c.fields.in_network_total__c.isCreateable() &&
        Schema.sObjectType.Result__c.fields.In_Net_Co_Payment__c.isCreateable() &&
        Schema.sObjectType.Result__c.fields.out_of_network_outOfPocket_total__c.isCreateable() &&
        Schema.sObjectType.Result__c.fields.Insurance_Type__c.isCreateable() &&
        Schema.sObjectType.Result__c.fields.VOB__c.isCreateable() &&
        Schema.sObjectType.Result__c.fields.Payer_Name__c.isCreateable()){
            insert vobResult;
        }
        }
         catch(Exception e){
         ExceptionLog.logError(e);
        }
         
        PatientData.VOB_Verification_Status__c = 'Approved' ;
        PatientData.Last_Verified_Date__c = Date.today();
        if(Schema.sObjectType.VOB__c.fields.VOB_Verification_Status__c.isUpdateable() &&
        Schema.sObjectType.VOB__c.fields.Last_Verified_Date__c.isUpdateable()){
            update PatientData ; 
        }
    }
    
}