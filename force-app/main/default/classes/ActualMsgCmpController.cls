public with sharing class ActualMsgCmpController {
    @AuraEnabled
    public static List<ListView> getListViews() {
        List<ListView> listviews =
            [SELECT Id, Name FROM ListView WHERE SobjectType = 'ElixirSuite__Message_Subject__c' and Name='Inbox'];
        
        // Perform isAccessible() check here
        return listviews;
    }
    @AuraEnabled
    public static ElixirSuite__Message_Subject__c fetchSubject(string msgSubId) {
        
        ElixirSuite__Message_Subject__c message = [Select Id, Account__c,Subject__c,Archived__c,Bookmarked__c,Deleted__c, 
                                                   Parent_Message__c, Grand_Parent_Message__c,CreatedBy.Id,
                                                   (Select Id,Message_Body__c FROM Message_Details_lookup__r) 
                                                   FROM Message_Subject__c  where Id= :msgSubId WITH SECURITY_ENFORCED];
                                                   System.debug(message.Archived__c);
                                                   System.debug(message.Bookmarked__c);
                                                   System.debug(message.Deleted__c);
        return message;
    }
    
    @AuraEnabled
    public static List<String> fetchFiles(string msgSubId) {
        System.debug('fetchFiles is caleld');
        System.debug(msgSubId+' msgSubId');
        List<String> fileLst = new List<String>();
        
        ElixirSuite__Message_Details__c message = [SELECT Id, ElixirSuite__lookup_Message_Subject__c, ElixirSuite__Message_Body__c 
                                                   FROM ElixirSuite__Message_Details__c 
                                                   where ElixirSuite__lookup_Message_Subject__c=:msgSubId WITH SECURITY_ENFORCED];
        System.debug(message+' message');
        
        List<ContentDocumentLink> cdl = [SELECT Id,ContentDocumentId,LinkedEntityId from ContentDocumentLink
                                         where LinkedEntityId=:message.Id];
        System.debug(cdl+' cdl');
        
        for(ContentDocumentLink conRec : cdl){
            
            fileLst.add(conRec.ContentDocumentId);
        }
        
        return fileLst;
    }    
    
    @AuraEnabled
    public static String delSubject(string msgSubId) {
        
        ElixirSuite__Message_Subject__c mesRec = [SELECT Id, ElixirSuite__Subject__c,ElixirSuite__Deleted__c FROM ElixirSuite__Message_Subject__c where id=:msgSubId WITH SECURITY_ENFORCED];
        
        ID uID =UserInfo.getUserId();
        
        //User currentUser = [SELECT Id,IsPortalEnabled, FirstName,Profile.Name,ProfileId FROM User where Id=:uID];
        List<User> users = Database.query('SELECT Id,IsPortalEnabled, FirstName,Profile.Name,ProfileId FROM User where Id=:uID');
        Boolean isPortalEnabled = (Boolean) users[0].get('IsPortalEnabled');
        if(mesRec.ElixirSuite__Deleted__c == null ){
            if(isPortalEnabled == true ){
                mesRec.ElixirSuite__Deleted__c = '1';
            }
            else{
                mesRec.ElixirSuite__Deleted__c = '2';
            }
        }
        else if(mesRec.ElixirSuite__Deleted__c == '2' && isPortalEnabled == true ){
            
            mesRec.ElixirSuite__Deleted__c = '0';
        }
        else if(mesRec.ElixirSuite__Deleted__c == '2' && isPortalEnabled == false ){
            
            mesRec.ElixirSuite__Deleted__c = '2';
        }
        else if(mesRec.ElixirSuite__Deleted__c == '1' && isPortalEnabled == false ){
            
            mesRec.ElixirSuite__Deleted__c = '0';
        }
        else if(mesRec.ElixirSuite__Deleted__c == '1' && isPortalEnabled == true ){
            
            mesRec.ElixirSuite__Deleted__c = '1';
        }
        
        else if(mesRec.ElixirSuite__Deleted__c == '0' ){
            
            mesRec.ElixirSuite__Deleted__c = '0';
        }
        
        String msgDelRes = mesRec.ElixirSuite__Deleted__c;
        
        //DMLManager.updateAsUser(mesRec);
        update mesRec;
        
        // Perform isAccessible() check here
        return msgDelRes;
    }
    
    @AuraEnabled
    public static String arcSubject(string msgSubId) {
        
        ElixirSuite__Message_Subject__c mesRec = [SELECT Id, ElixirSuite__Subject__c,ElixirSuite__Archived__c FROM ElixirSuite__Message_Subject__c where id=:msgSubId WITH SECURITY_ENFORCED];
        
        ID uID =UserInfo.getUserId();
        
        //User currentUser = [SELECT Id,IsPortalEnabled, FirstName,Profile.Name,ProfileId FROM User where Id=:uID];
        List<User> users = Database.query('SELECT Id,IsPortalEnabled, FirstName,Profile.Name,ProfileId FROM User where Id=:uID');
        Boolean isPortalEnabled = (Boolean) users[0].get('IsPortalEnabled');
        if(mesRec.ElixirSuite__Archived__c == null ){
            if(isPortalEnabled == true ){
                mesRec.ElixirSuite__Archived__c = '1';
            }
            else{
                mesRec.ElixirSuite__Archived__c = '2';
            }
        }
        else if(mesRec.ElixirSuite__Archived__c == '2' && isPortalEnabled == true ){
            
            mesRec.ElixirSuite__Archived__c = '0';
        }
        else if(mesRec.ElixirSuite__Archived__c == '2' && isPortalEnabled == false ){
            
            mesRec.ElixirSuite__Archived__c = '2';
        }
        else if(mesRec.ElixirSuite__Archived__c == '1' && isPortalEnabled == false ){
            
            mesRec.ElixirSuite__Archived__c = '0';
        }
        else if(mesRec.ElixirSuite__Archived__c == '1' && isPortalEnabled == true ){
            
            mesRec.ElixirSuite__Archived__c = '1';
        }
        
        else if(mesRec.ElixirSuite__Archived__c == '0' ){
            
            mesRec.ElixirSuite__Archived__c = '0';
        }
        
        String msgDelRes = mesRec.ElixirSuite__Archived__c;
        
        //DMLManager.updateAsUser(mesRec);
        update mesRec;
        
        // Perform isAccessible() check here
        return msgDelRes;
    }
    @AuraEnabled
    public static String unArcSubject(string msgSubId) {
        ElixirSuite__Message_Subject__c mesRec = [SELECT Id, ElixirSuite__Subject__c,ElixirSuite__Archived__c FROM ElixirSuite__Message_Subject__c where id=:msgSubId WITH SECURITY_ENFORCED];
        
        ID uID =UserInfo.getUserId();
        
        //User currentUser = [SELECT Id,IsPortalEnabled, FirstName,Profile.Name,ProfileId FROM User where Id=:uID];
        List<User> users = Database.query('SELECT Id,IsPortalEnabled, FirstName,Profile.Name,ProfileId FROM User where Id=:uID');
        Boolean isPortalEnabled = (Boolean) users[0].get('IsPortalEnabled');
        if(mesRec.ElixirSuite__Archived__c != null){
            if(isPortalEnabled == true ){
                mesRec.ElixirSuite__Archived__c = '';
            }
            else{
                mesRec.ElixirSuite__Archived__c = '';
            }
        }
        else if(mesRec.ElixirSuite__Archived__c == '2' && isPortalEnabled == true ){
            
            mesRec.ElixirSuite__Archived__c = '';
        }
        else if(mesRec.ElixirSuite__Archived__c == '2' && isPortalEnabled == false ){
            
            mesRec.ElixirSuite__Archived__c = '';
        }
        else if(mesRec.ElixirSuite__Archived__c == '1' && isPortalEnabled == false ){
            
            mesRec.ElixirSuite__Archived__c = '';
        }
        else if(mesRec.ElixirSuite__Archived__c == '1' && isPortalEnabled == true ){
            
            mesRec.ElixirSuite__Archived__c = '';
        }
        
        else if(mesRec.ElixirSuite__Archived__c == '0' ){
            
            mesRec.ElixirSuite__Archived__c = '';
        }
        
        String msgDelRes = mesRec.ElixirSuite__Archived__c;
        
        //DMLManager.updateAsUser(mesRec);
        update mesRec;
        
        // Perform isAccessible() check here
        return msgDelRes;
    }
    
    @AuraEnabled
    public static String bookmrkSubject(string msgSubId) {
        
        ElixirSuite__Message_Subject__c mesRec = [SELECT Id, ElixirSuite__Subject__c,ElixirSuite__Bookmarked__c FROM ElixirSuite__Message_Subject__c where id=:msgSubId WITH SECURITY_ENFORCED];
        
        ID uID =UserInfo.getUserId();
        
        //User currentUser = [SELECT Id,IsPortalEnabled, FirstName,Profile.Name,ProfileId FROM User where Id=:uID];
        List<User> users = Database.query('SELECT Id,IsPortalEnabled, FirstName,Profile.Name,ProfileId FROM User where Id=:uID');
        Boolean isPortalEnabled = (Boolean) users[0].get('IsPortalEnabled');
        if(mesRec.ElixirSuite__Bookmarked__c == null ){
            if(isPortalEnabled == true ){
                mesRec.ElixirSuite__Bookmarked__c = '1';
            }
            else{
                mesRec.ElixirSuite__Bookmarked__c = '2';
            }
        }
        else if(mesRec.ElixirSuite__Bookmarked__c == '2' && isPortalEnabled == true ){
            
            mesRec.ElixirSuite__Bookmarked__c = '0';
        }
        else if(mesRec.ElixirSuite__Bookmarked__c == '2' && isPortalEnabled == false ){
            
            mesRec.ElixirSuite__Bookmarked__c = '2';
        }
        else if(mesRec.ElixirSuite__Bookmarked__c == '1' && isPortalEnabled == false ){
            
            mesRec.ElixirSuite__Bookmarked__c = '0';
        }
        else if(mesRec.ElixirSuite__Bookmarked__c == '1' && isPortalEnabled == true ){
            
            mesRec.ElixirSuite__Bookmarked__c = '1';
        }
        
        else if(mesRec.ElixirSuite__Bookmarked__c == '0' ){
            
            mesRec.ElixirSuite__Bookmarked__c = '0';
        }
        
        String msgDelRes = mesRec.ElixirSuite__Bookmarked__c;
        
        //DMLManager.updateAsUser(mesRec);
        update mesRec;
        
        // Perform isAccessible() check here
        return msgDelRes;
    }
    @AuraEnabled
    public static String removeBookmrkSubject(string msgSubId) {
        
        ElixirSuite__Message_Subject__c mesRec = [SELECT Id, ElixirSuite__Subject__c,ElixirSuite__Bookmarked__c FROM ElixirSuite__Message_Subject__c where id=:msgSubId WITH SECURITY_ENFORCED];
        
        ID uID =UserInfo.getUserId();
        
        //User currentUser = [SELECT Id,IsPortalEnabled, FirstName,Profile.Name,ProfileId FROM User where Id=:uID];
        List<User> users = Database.query('SELECT Id,IsPortalEnabled, FirstName,Profile.Name,ProfileId FROM User where Id=:uID');
        Boolean isPortalEnabled = (Boolean) users[0].get('IsPortalEnabled');
        if(mesRec.ElixirSuite__Bookmarked__c != null ){
            if(isPortalEnabled == true ){
                mesRec.ElixirSuite__Bookmarked__c = '';
            }
            else{
                mesRec.ElixirSuite__Bookmarked__c = '';
            }
        }
        else if(mesRec.ElixirSuite__Bookmarked__c == '2' && isPortalEnabled == true ){
            
            mesRec.ElixirSuite__Bookmarked__c = '';
        }
        else if(mesRec.ElixirSuite__Bookmarked__c == '2' && isPortalEnabled == false ){
            
            mesRec.ElixirSuite__Bookmarked__c = '';
        }
        else if(mesRec.ElixirSuite__Bookmarked__c == '1' && isPortalEnabled == false ){
            
            mesRec.ElixirSuite__Bookmarked__c = '';
        }
        else if(mesRec.ElixirSuite__Bookmarked__c == '1' && isPortalEnabled == true ){
            
            mesRec.ElixirSuite__Bookmarked__c = '';
        }
        
        else if(mesRec.ElixirSuite__Bookmarked__c == '0' ){
            
            mesRec.ElixirSuite__Bookmarked__c = '';
        }
        
        String msgDelRes = mesRec.ElixirSuite__Bookmarked__c;
        
        //DMLManager.updateAsUser(mesRec);
        update mesRec;
        
        // Perform isAccessible() check here
        return msgDelRes;
    }
    @AuraEnabled
    public static ElixirSuite__Elixir_Custom_Setting__c  getCustomSetting() {
        try{
            return ElixirSuite__Elixir_Custom_Setting__c.getOrgDefaults();
            
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}