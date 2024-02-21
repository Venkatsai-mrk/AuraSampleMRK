public without sharing class MyCareTeamDetailsForPortal {
    public class WrapperOption {
        @AuraEnabled public String label;
        @AuraEnabled public String value;
        @AuraEnabled public String teamMemberRole;
        @AuraEnabled public String specialtity;
        
        public WrapperOption(String value, String label, String teamMemberRole,String specialtity) {
            this.value = value;
            this.label = label;
            this.teamMemberRole = teamMemberRole;
            this.specialtity = specialtity;
        }
    }

    @AuraEnabled
    public static Boolean isEnableAppointment() {
        Id patientPortalId =Schema.SObjectType.ElixirSuite__Master_Object__c.getRecordTypeInfosByDeveloperName().get('Patient_Portal').getRecordTypeId();
            
        List<ElixirSuite__Master_Object__c> masterRecord = new List<ElixirSuite__Master_Object__c>();
        masterRecord = [select name,ElixirSuite__Patient_Tile_Entity__c, ElixirSuite__Enable_Appointment_Booking__c, recordtype.name from ElixirSuite__Master_Object__c where RecordTypeId=:patientPortalId and ElixirSuite__Patient_Tile_Entity__c='Portal Definition' WITH SECURITY_ENFORCED limit 1];
        if(masterRecord.size()>0)
        {
            return masterRecord[0].ElixirSuite__Enable_Appointment_Booking__c;
        }
        else{
            return true;
        }
    }
    @AuraEnabled
    public static List<WrapperOption> getAccountTeamMembers(){
        try{
         
        String patientId='';
        String conId='';
        //It retrieves the current user's ID using "UserInfo.getUserId()"
        String uId = UserInfo.getUserId();
         
        //It queries the User object to find the contact ID associated with the user.
        List<User> userRecs = Database.query('SELECT id,ContactId FROM User WHERE Id =:uId');
        if(userRecs!=null && userRecs.size()>0){
            conId = (String)userRecs[0].get('ContactId');
        }
        //It queries the Contact object to find the account ID associated with the contact.
        List<Contact> contacts = Database.query('SELECT Id,AccountId FROM Contact WHERE Id= :conId');
        if(contacts!=null && contacts.size()>0){
            patientId = (String)contacts[0].get('AccountId');
        }
        List<WrapperOption> options = new List<WrapperOption>();
        //It queries the AccountTeamMember object to retrieve the team members associated with the account ID.
        //List<SObject> teamMembers = Database.query('SELECT Id,AccountId,TeamMemberRole, UserId,User.FirstName, User.LastName FROM AccountTeamMember WHERE AccountId =:patientId');
        
        //It queries the AccountContactRelation object to retrieve the care team members associated with the account ID.
        List<SObject> teamMembers=Database.query('SELECT Id, AccountId, ContactId,Contact.FirstName,Contact.MiddleName,Contact.LastName, IsDirect, ElixirSuite__Care_Team_Role__c, ElixirSuite__Contact_Type__c FROM AccountContactRelation where AccountId =:patientId AND IsDirect=false AND ElixirSuite__Contact_Type__c =\'Care team\' ');         
        // "userlst" to store the user IDs of the team members.
        List<String> userlst = new List<String>();
        for(SObject collectUserId : teamMembers) {
            userlst.add(String.valueOf(collectUserId.get('ContactId')));
        }
        // retrieve the contact information for the user IDs in "userlst"
        List<Contact> contLst = fetchContactOfUser(userlst);
        // "usercontactMap" to map user IDs to contact IDs
        Map<String,String> usercontactMap = new  Map<String,String>();
        // "contactIdSet" to store the contact IDs
        Set<Id> contactIdSet = new Set<Id>();
        for(Contact con : contLst){
            usercontactMap.put(con.Id,con.Id);
            contactIdSet.add(con.Id);
        }
        // retrieve the specialties associated with the contact IDs in "contactIdSet".
        List<UserLocation__c> specialitiesLst = fetchSpecialities(contactIdSet);
         // "contactSpecialitymap" to map contact IDs to a list of specialties
        Map<String,List<String>> contactSpecialitymap = new Map<String,List<String>>();
        for(ElixirSuite__UserLocation__c ul : specialitiesLst) {
            if(!contactSpecialitymap.containsKey(ul.ElixirSuite__Practitioner__c)) {
                contactSpecialitymap.put(ul.ElixirSuite__Practitioner__c, new List<String>());
            }
            contactSpecialitymap.get(ul.ElixirSuite__Practitioner__c).add(ul.ElixirSuite__Specialty__r.Specialty_Name__c);
        }
        
        for(SObject teamMember : teamMembers) {
            String firstName = '';
            String lastName = '';
            String fullName = '';
            String middleName = '';
            String specialtity = '';
            String contactId = String.valueOf(teamMember.get('contactId'));
            if(contactSpecialitymap.containsKey(usercontactMap.get(contactId))){           
                List<String> specialties = contactSpecialitymap.get(usercontactMap.get(contactId));
                
                specialtity = getSpecialiity(specialties,specialtity);
                
            }
            firstName = String.valueOf(teamMember.getSObject('Contact').get('FirstName'));
            lastName = String.valueOf(teamMember.getSObject('Contact').get('LastName'));
            middleName = String.valueOf(teamMember.getSObject('Contact').get('MiddleName'));
            if(String.isNotBlank(firstName) && String.isNotBlank(middleName)){
                fullName = firstName+' '+middleName +' '+lastName;
            }
            else if(String.isNotBlank(firstName)){
                fullName = firstName+' '+lastName;
            }
            else if(String.isNotBlank(middleName)){
                fullName = middleName+' '+lastName;
            }
            else{
                fullName = lastName;
            }
            
            options.add(new WrapperOption(String.valueOf(teamMember.get('contactId')), fullName, String.valueOf(teamMember.get('ElixirSuite__Care_Team_Role__c')),specialtity));
        }
        
        
        return options;
        }catch(Exception e){
            ExceptionLog.logError(e);
            return NULL;
        }
        
    }
    public static String getSpecialiity(List<String> specialties,String specialtity){
                    if (specialties.size() > 1) {
                    specialtity = String.join(specialties, ', ');
                } else {
                    specialtity = specialties[0];
                }
                    return specialtity;
                }
    //takes a list of user IDs as input and queries the Contact object to retrieve the contacts associated with those user IDs. It filters the contacts based on a specific record type called "Practitioner" 
    public static List<Contact> fetchContactOfUser(List<String> allUserId){
        Elixir_Custom_Setting__c val = Elixir_Custom_Setting__c.getOrgDefaults();
        String contactRecType = val.ElixirSuite__Practitioner_Contact_Recordtype__c;
        Id recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(contactRecType).getRecordTypeId();
        return [SELECT Id,Practitioner_User__c FROM Contact WHERE Id IN : allUserId AND RecordTypeId=:recordTypeId WITH SECURITY_ENFORCED];
    }
    //takes a set of contact IDs as input and queries a custom object called "UserLocation__c" to retrieve the specialties associated with those contact IDs. 
    public static List<ElixirSuite__UserLocation__c> fetchSpecialities(Set<Id> contactIdSet){
        return [SELECT Id,Practitioner__c,Specialty__c,Specialty__r.Specialty_Name__c FROM UserLocation__c where Practitioner__c IN : contactIdSet WITH SECURITY_ENFORCED];
    }
    @AuraEnabled
    public static ElixirSuite__Elixir_Custom_Setting__c  getCustomSetting() {
        try{
            return ElixirSuite__Elixir_Custom_Setting__c.getOrgDefaults();
            
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static String getPractitionerUser(String contactId) {
        String practitionerUserId = '';
        try {
            List<Contact> contactRecord = [SELECT Id, ElixirSuite__Practitioner_User__c FROM Contact WHERE Id = :contactId WITH SECURITY_ENFORCED LIMIT 1];
            if (contactRecord != null && contactRecord.size() > 0) {
                practitionerUserId = contactRecord[0].ElixirSuite__Practitioner_User__c;
                
            }
            return practitionerUserId;
        } catch (Exception ex) {
            return NULL;
        }
        
    }
}