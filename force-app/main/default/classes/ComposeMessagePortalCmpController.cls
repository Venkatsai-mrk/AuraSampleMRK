public without sharing class ComposeMessagePortalCmpController {
    @AuraEnabled
    public static string insertSubjectAndMessage(String mySubject,String myMessage,String patientId,String selectedTeamMemberId, List<String> base64Data, String fileName){
        Message_Subject__c messageSubject = new Message_Subject__c();
        messageSubject.Subject__c = mySubject;
        messageSubject.Account__c = patientId;
          List<ContentDocumentLink> conDocLinkLst= new  List<ContentDocumentLink>();
        Id contactId;
        Id teamMemberId = selectedTeamMemberId;
        Id recordId;
        
        
        SObjectType objectType = teamMemberId.getSObjectType();
        String objTypeStr = String.valueOf(objectType);
        if(objTypeStr == 'Contact'){
            contactId = selectedTeamMemberId;
            Contact con=[SELECT Id,Practitioner_User__c FROM Contact WHERE Id =:contactId WITH SECURITY_ENFORCED LIMIT 1];
        if(con.Practitioner_User__c!=null){
           recordId = con.Practitioner_User__c; 
        }
        //messageSubject.User__c = selectedTeamMemberId;
        messageSubject.ElixirSuite__Contact__c=selectedTeamMemberId;
        messageSubject.User__c = recordId;
        }
        else if(objTypeStr == 'ElixirSuite__Provider__c'){
            messageSubject.Provider__c = selectedTeamMemberId;
        }       
        messageSubject.IsPortal__c = true;
       //insert messageSubject;
        DMLManager.insertAsUser(messageSubject);
        

        Message_Details__c messageDetails = new Message_Details__c();
        messageDetails.Message_Body__c = myMessage;
        messageDetails.lookup_Message_Subject__c = messageSubject.Id;
        //insert messageDetails;
        DMLManager.insertAsUser(messageDetails);
        
        List<ImageWrapper> files = (List<ImageWrapper>)JSON.deserialize(fileName , List<ImageWrapper>.class);
        for(ImageWrapper img :files){
            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.ContentDocumentId = img.value;
            cdl.LinkedEntityId = messageDetails.id;
            cdl.Visibility = 'AllUsers';
            conDocLinkLst.add(cdl);
    
            ContentDocumentLink cdlAccount = new ContentDocumentLink();
            cdlAccount.ContentDocumentId = img.value;
            cdlAccount.LinkedEntityId = patientId;
            cdlAccount.Visibility = 'AllUsers';
            conDocLinkLst.add(cdlAccount);
        }
   
    upsert conDocLinkLst;

        
        return 'success';
    }
    public static String getPatient(){
        String userId = UserInfo.getUserId();
        String patientId = '';
        List<User> users = Database.query('Select Id,AccountId from User where Id=:userId AND AccountId!= null');
        if(users!=null && users.size()>0){
            patientId = (String) users[0].get('AccountId');
        }
        return patientId;
    }
    public class SelectOption {
        @AuraEnabled public String label;
        @AuraEnabled public String value;
    
        public SelectOption(String value, String label) {
            this.label = label;
            this.value = value;
        }
    }
    public static List<SelectOption> getAccountTeamMembers(String accId){
        List<SelectOption> options = new List<SelectOption>();
        //List<sObject> teamMembers = Database.query('SELECT Id,AccountId, UserId,User.Name FROM AccountTeamMember WHERE AccountId =:accId');
        //It queries the AccountContactRelation object to retrieve the care team members associated with the account ID.
        List<SObject> teamMembers=Database.query('SELECT Id, AccountId, ContactId,Contact.Name,Contact.FirstName,Contact.LastName, IsDirect, ElixirSuite__Care_Team_Role__c, ElixirSuite__Contact_Type__c FROM AccountContactRelation where AccountId =:accId AND IsDirect=false AND ElixirSuite__Contact_Type__c =\'Care team\' ');
        List<sObject> providers = Database.query('Select Id, Name FROM Provider__c WHERE Account__c =:accId');
        for (sObject teamMember : teamMembers) {
            options.add(new SelectOption(String.valueOf(teamMember.get('ContactId')), String.valueOf(teamMember.getSObject('Contact').get('Name'))));
        }
        for(sObject provider : providers){
             options.add(new SelectOption(String.valueOf(provider.get('Id')), String.valueOf(provider.get('Name'))));
        }
        return options;
    }
    public static List<SelectOption> defaultValue(String accId){
         List<SelectOption> options = new List<SelectOption>();
        Account acc = [Select id, Active_Care_Episode_Location__c, Active_Care_Episode_Location__r.Name from Account where id =:accId WITH SECURITY_ENFORCED LIMIT 1];
        List<Provider__c> provider = [Select id, Name from Provider__c where Provider__c =:acc.Active_Care_Episode_Location__c AND Account__c=:accId WITH SECURITY_ENFORCED ORDER BY createdDate DESC LIMIT 1];
        if(provider!=null && provider.size()>0){
        options.add(new SelectOption(String.valueOf(provider[0].Id), String.valueOf(provider[0].Name)));
        }
        return options;
    }
    @AuraEnabled
    public static ElixirSuite__Elixir_Custom_Setting__c  getCustomSetting() {
        try{
            return ElixirSuite__Elixir_Custom_Setting__c.getOrgDefaults();
            
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    public class Wrapper{
        @AuraEnabled public String accId;
        @AuraEnabled public List<SelectOption> options;
        @AuraEnabled public List<SelectOption> defaultValueSelected;
      }
    @AuraEnabled 
    public static Wrapper wrappedData(){
        Wrapper wrp = new Wrapper();
        wrp.accId = getPatient();
        wrp.options = getAccountTeamMembers(wrp.accId);
        wrp.defaultValueSelected = defaultValue(wrp.accId);
        return wrp;
    }
    public class ImageWrapper{
        public String name;
        public String value;
    }
}