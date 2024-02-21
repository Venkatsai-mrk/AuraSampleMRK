public with sharing class ShowSuccess_ctrl {
    
    public string accName{set;get;}
    public string pageId{set;get;}
    //ApexPages.StandardController sc;
    public ShowSuccess_ctrl(ApexPages.StandardSetController controller)
    { 
        pageId = ApexPages.currentPage().getParameters().get('Id');
        
    }
    public void insertacc(){
        try{
        List<ElixirSuite__Procedure__c> lst_procs = new List<ElixirSuite__Procedure__c>();
        for(ElixirSuite__Procedure__c objPro : [Select Id,ElixirSuite__Account__c,
        ElixirSuite__CPT_HCPCS_Code__c,ElixirSuite__Is_Billable__c,
        ElixirSuite__Ready_for_Billing__c,ElixirSuite__Is_Patient_Procedure__c,
        ElixirSuite__Generate_Claim__c FROM ElixirSuite__Procedure__c 
        WHERE ElixirSuite__Is_Patient_Procedure__c = true AND 
        ElixirSuite__Ready_for_Billing__c = true AND ElixirSuite__Account__c=:pageId
        WITH SECURITY_ENFORCED]){
            objPro.ElixirSuite__Generate_Claim__c = true;
            lst_procs.add(objPro);
        }
        if(Procedure__c.sObjectType.getDescribe().isUpdateable() &&
            Schema.sObjectType.Procedure__c.fields.Generate_Claim__c.isUpdateable() &&
            Schema.sObjectType.Procedure__c.fields.CPT_HCPCS_Code__c.isUpdateable() &&
            Schema.sObjectType.Procedure__c.fields.Ready_for_Billing__c.isUpdateable() &&
            Schema.sObjectType.Procedure__c.fields.Is_Patient_Procedure__c.isUpdateable() &&
            Schema.sObjectType.Procedure__c.fields.Ready_for_Billing__c.isUpdateable()){
                if(Schema.sObjectType.ElixirSuite__Procedure__c.isUpdateable()){
            update lst_procs;
        }
    }
        if (lst_procs.size()>0){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Procedures submitted for claim generation successfully'));
        }
        else if(lst_procs.size()<=0)
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'No procedures are ready for claim generation'));
        }
        
    }
         catch(Exception e){
         ExceptionLog.logError(e);
        }

    }
    
    public PageReference listView() {
        PageReference url = new PageReference('/lightning/r/'+pageId+'/related/ElixirSuite__Procedures__r/view?ws=%2Flightning%2Fr%2FAccount%2F'+pageId+'%2Fview');
        url.setredirect(true);
        return url;
    }
}