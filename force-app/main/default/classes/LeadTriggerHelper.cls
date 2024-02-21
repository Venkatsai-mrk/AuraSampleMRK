/*
 Trigger is updating some fields on opportunities and creating vob records on lead conversion if primary and secondary sections on lead are filled.
 */
public with sharing class LeadTriggerHelper{ 
    public void OpportunityFromLead(List<Lead> leads)
    {
        Map<id,Lead> oppIDLeadMap = new Map<id,Lead>();
        List<VOB__c> vobToInsert = new List<VOB__c>();
        List<Account> acctoInsert = new List<Account>();
        List<Opportunity> OpptoInsert = new List<Opportunity>();
        try{
        for(Lead ld : leads){
            if(ld.ConvertedOpportunityId != null){
            if(ld.isConverted==true){
                oppIDLeadMap.put(ld.ConvertedOpportunityId, ld); 
                
                String firstname=ld.FirstName==null ? '':ld.FirstName;
                String middlename=ld.MiddleName==null ? '':ld.MiddleName;
                OpptoInsert.add(new Opportunity(id = ld.ConvertedOpportunityId,Phone__c=ld.Phone,Caller_Name__c=ld.Caller_Name__c,Email__c=ld.Email,ElixirSuite__SSN__c=ld.ElixirSuite__SSN__c,
                                                Subscriber_Address_State__c=ld.State, Address_Street__c= ld.Street, Address_City__c= ld.City,
                                                Address_State__c= ld.State, Address_Zip__c= ld.PostalCode, Address_Country__c= ld.Country,
                                                Name=firstname +' '+ middlename + ' ' + ld.LastName,Patient_First_Name__c=ld.FirstName,Patient_Last_Name__c=ld.LastName,ElixirSuite__Patient_Middle_Name__c =ld.MiddleName));      
            }
            }
        }
        if(Schema.sObjectType.Opportunity.fields.Phone__c.isUpdateable() &&
        Schema.sObjectType.Opportunity.fields.Caller_Name__c.isUpdateable() &&
        Schema.sObjectType.Opportunity.fields.Email__c.isUpdateable() &&
        Schema.sObjectType.Opportunity.fields.ElixirSuite__SSN__c.isUpdateable() &&  
        Schema.sObjectType.Opportunity.fields.Subscriber_Address_State__c.isUpdateable() &&
        Schema.sObjectType.Opportunity.fields.Address_Street__c.isUpdateable() &&
        Schema.sObjectType.Opportunity.fields.Address_City__c.isUpdateable() &&  
        Schema.sObjectType.Opportunity.fields.Address_State__c.isUpdateable() &&
        Schema.sObjectType.Opportunity.fields.Address_Zip__c.isUpdateable() &&
        Schema.sObjectType.Opportunity.fields.Address_Country__c.isUpdateable() &&  
        Schema.sObjectType.Opportunity.fields.Name.isUpdateable() &&
        Schema.sObjectType.Opportunity.fields.Patient_First_Name__c.isUpdateable() &&
        Schema.sObjectType.Opportunity.fields.Patient_Last_Name__c.isUpdateable() &&
        Schema.sObjectType.Opportunity.fields.ElixirSuite__Patient_Middle_Name__c.isUpdateable()){
            update OpptoInsert;
        }
        }
        catch(Exception e){
        ExceptionLog.logError(e);
        }
        
        if(oppIDLeadMap!= null && oppIDLeadMap.size() >0){
            Boolean checkVal = Elixir_Utility.getLeadTriggerExecution();
            if(checkVal==true){
            VobCreation(oppIDLeadMap);
            }
            booleanFlag.flag= true;
        }
    }
    
    public void VobCreation(Map<id,Lead> oppIDLeadMap) 
    {
        List<VOB__c> vobToInsert = new List<VOB__c>();
        try{
        Id PrimVobRecordTypeId = Schema.SObjectType.ElixirSuite__VOB__c.getRecordTypeInfosByDeveloperName().get('VOB_record_type').getRecordTypeId();
        Id SecVobRecordTypeId = Schema.SObjectType.ElixirSuite__VOB__c.getRecordTypeInfosByDeveloperName().get('Secondary_VOB').getRecordTypeId();
        Id tertiaryVobRecordTypeId = Schema.SObjectType.ElixirSuite__VOB__c.getRecordTypeInfosByDeveloperName().get('Tertiary_VOB').getRecordTypeId();
        Id workerVobRecordTypeId = Schema.SObjectType.ElixirSuite__VOB__c.getRecordTypeInfosByDeveloperName().get('Worker_s_Comp').getRecordTypeId();
        Id AutoVobRecordTypeId = Schema.SObjectType.ElixirSuite__VOB__c.getRecordTypeInfosByDeveloperName().get('Auto_accident').getRecordTypeId();
            
            
        for(ID oppId: oppIDLeadMap.keySet()){
            Lead ld = oppIDLeadMap.get(oppId);
            
            //if(ld.Has_Insurance__c== true){
            if(ld.Primary_Insurance_Provider__c!=null || ld.ElixirSuite__Primary_Subscriber_Middle_Name__c!=null || ld.ElixirSuite__Primary_Subscriber_Last_Name__c!=null || ld.Insurance_Phone_Number__c!=null || ld.Insurance_Policy_ID__c!=null || ld.Subscriber_Name__c!=null || ld.Insurance_Group_Number__c!=null || ld.Subscriber_DOB__c!=null){
                VOB__c vob = new VOB__c();
                vob.ElixirSuite__Stage__c = 'VOB In Queue';
                vob.ElixirSuite__Status__c = 'Active';
                vob.ElixirSuite__Type__c='Primary';  // changing this from vobtype__c to type__c
                vob.RecordTypeId= PrimVobRecordTypeId;
                vob.ElixirSuite__Patient_s_Gender__c = ld.ElixirSuite__Gender__c;
                vob.Opportunity__c=oppId;//client name
                Vob.ElixirSuite__Account__c=ld.ConvertedAccountId; //link with respective account when lead converted
                vob.ElixirSuite__Patient_Birth_Date__c=ld.Client_DOB__c;//client dob
                //vob.ElixirSuite__Patient_Relationship_With_Insured__c=ld.Relationship_to_Client__c; //changing reference from Subscriber_Relationship__c to ElixirSuite__Patient_Relationship_With_Insured__c
                vob.ElixirSuite__VOB_Verification_Status__c = 'Not Approved';
                vob.ElixirSuite__Service_Date__c = system.today();
                vob.ElixirSuite__Patient_SSN__c = ld.ElixirSuite__SSN__c;

                //primary subscriber details
                vob.ElixirSuite__Payer__c=ld.ElixirSuite__Primary_Insurance_Provider__c; //Anusha - replaced Insurance_Providers__c with Payer__c
                vob.ElixirSuite__Insured_First_Name__c=ld.ElixirSuite__Subscriber_Name__c; //this is first name //changing reference from Subscriber_Name__c to 	ElixirSuite__Insured_First_Name__c
                vob.ElixirSuite__Insured_Middle_Name__c=ld.ElixirSuite__Primary_Subscriber_Middle_Name__c; //middle name
                vob.ElixirSuite__Insured_Last_Name__c=ld.ElixirSuite__Primary_Subscriber_Last_Name__c; //last name
                vob.ElixirSuite__Date_Of_Birth__c=ld.ElixirSuite__Subscriber_DOB__c;  
                vob.ElixirSuite__Insurance_Policy_ID__c=ld.Insurance_Policy_ID__c;  
                vob.ElixirSuite__Member_Id__c=ld.ElixirSuite__Insurance_Policy_ID__c; //Anusha
                vob.ElixirSuite__Insurance_Group_Number__c=ld.ElixirSuite__Insurance_Group_Number__c;
                vob.ElixirSuite__Insurance_Company_Phone__c=ld.ElixirSuite__Insurance_Phone_Number__c;
                vob.ElixirSuite__Patient_Relationship_With_Insured__c=ld.ElixirSuite__Patient_Relationship_to_Primary_Insured__c; //Anusha
              
                List<String> address = new List<String>{'Street', 'City','State', 'PostalCode','Country'};
                List<String> primaryName = new List<String>{'ElixirSuite__Subscriber_Name__c', 'ElixirSuite__Primary_Subscriber_Middle_Name__c','ElixirSuite__Primary_Subscriber_Last_Name__c'};
                
                String FullName = '';
                
                String Fulladdress = '';
                for(String field :address){
                    if(String.isNotBlank(((String)ld.get(field)))){
                        Fulladdress+=(String)ld.get(field) + ' ';
                    }
                    vob.Patient_Address__c= Fulladdress;
                }
                if(vob.ElixirSuite__Subscriber_Name__c == null){
                    for(String field :primaryName){
                        if(String.isNotBlank(((String)ld.get(field)))){
                            FullName+=(String)ld.get(field) + ' ';
                        }
                        
                        vob.ElixirSuite__Subscriber_Name__c= FullName;
                    }
                }
                
                vobToInsert.add(vob);
            }
            if(ld.Secondary_Insurance_Provider_payor__c!=null|| ld.ElixirSuite__Secondary_Subscriber_Last_Name__c!=null || ld.ElixirSuite__Secondary_Subscriber_Middle_Name__c!=null || ld.Secondary_Insurance_Phone_Number__c!=null || ld.Secondary_Insurance_Policy_ID__c!=null || ld.Secondary_Subscriber_Name__c!=null || ld.Secondary_Insurance_Group_Number__c!=null || ld.Secondary_Subscriber_DOB__c!=null){
                //Secondary Insurance creation
                List<String> secondaryName = new List<String>{'ElixirSuite__Secondary_Subscriber_Name__c', 'ElixirSuite__Secondary_Subscriber_Middle_Name__c','ElixirSuite__Secondary_Subscriber_Last_Name__c'};
                String secondaryFullName = '';   
                
                vob__c vobsec = new vob__c();                         
                vobsec.ElixirSuite__Stage__c = 'VOB In Queue';
                vobsec.ElixirSuite__Status__c = 'Active';
                vobsec.ElixirSuite__Type__c='Secondary';   // changing this from vobtype__c to type__c
                vobsec.RecordTypeId= SecVobRecordTypeId;
                vobsec.ElixirSuite__Patient_s_Gender__c = ld.ElixirSuite__Gender__c;
                vobsec.Opportunity__c=oppId;//client name
                vobsec.Account__c=ld.ConvertedAccountId;    //link with respective account when lead converted 
                vobsec.ElixirSuite__Patient_Birth_Date__c=ld.Client_DOB__c;//client dob
               // vobsec.ElixirSuite__Patient_Relationship_With_Insured__c=ld.Relationship_to_Client__c; //changing reference from Subscriber_Relationship__c to ElixirSuite__Patient_Relationship_With_Insured__c
                vobsec.ElixirSuite__VOB_Verification_Status__c = 'Not Approved';
                vobsec.ElixirSuite__Service_Date__c = system.today();
                vobsec.ElixirSuite__Patient_SSN__c = ld.ElixirSuite__SSN__c;
                
                vobsec.ElixirSuite__Payer__c=ld.ElixirSuite__Secondary_Insurance_Provider_payor__c; //Anusha - replaced Secondary_Insurance_Provider__c with Payer__c
                vobsec.ElixirSuite__Insured_First_Name__c=ld.ElixirSuite__Secondary_Subscriber_Name__c;
                vobsec.ElixirSuite__Insured_Middle_Name__c=ld.ElixirSuite__Secondary_Subscriber_Middle_Name__c;
                vobsec.ElixirSuite__Insured_Last_Name__c=ld.ElixirSuite__Secondary_Subscriber_Last_Name__c;
                vobsec.ElixirSuite__Date_Of_Birth__c=ld.ElixirSuite__Secondary_Subscriber_DOB__c; //Anusha - replaced Secondary_Subscriber_DOB__c with Date_Of_Birth__c
                vobsec.ElixirSuite__Member_Id__c=ld.ElixirSuite__Secondary_Insurance_Policy_ID__c; //Anusha - replaced Secondary_Insurance_Policy_ID__c with Member_Id__c
                vobsec.ElixirSuite__Insurance_Group_Number_Sec__c=ld.ElixirSuite__Secondary_Insurance_Group_Number__c;
                vobsec.ElixirSuite__Secondary_Insurance_Phone_Number__c=ld.ElixirSuite__Secondary_Insurance_Phone_Number__c;
                vobsec.ElixirSuite__Patient_Relationship_With_Insured__c=ld.ElixirSuite__Patient_Relationship_to_Secondary_Insure__c; //Anusha
                
                List<String> PatAddress = new List<String>{'Street', 'City','State', 'PostalCode','Country'};
                    
                String FullPatAddress = '';
                for(String field :PatAddress){
                    if(String.isNotBlank(((String)ld.get(field)))){
                        FullPatAddress+=(String)ld.get(field) + ' ';
                        system.debug('FullPatAddress'+FullPatAddress);
                    }
                    vobsec.Patient_Address__c= FullPatAddress;
                }
                
                if(vobsec.ElixirSuite__Secondary_Subscriber_Name__c == null){
                    for(String field :secondaryName){
                        if(String.isNotBlank(((String)ld.get(field)))){
                            secondaryFullName+=(String)ld.get(field) + ' ';
                        }
                        
                        vobsec.ElixirSuite__Secondary_Subscriber_Name__c= secondaryFullName;
                    }
                } 
                
                vobToInsert.add(vobsec);  
                
            }
            if(ld.Tertiary_Insurance_Provider__c!=null || ld.ElixirSuite__Tertiary_Subscriber_Middle_Name__c!=null || ld.ElixirSuite__Tertiary_Subscriber_Last_Name__c!=null  || ld.ElixirSuite__Tertiary_Insurance_Policy_ID__c!=null || ld.ElixirSuite__Tertiary_Subscriber_First_Name__c!=null  || ld.ElixirSuite__Tertiary_Subscriber_DOB__c!=null){
                VOB__c vob = new VOB__c();
                vob.ElixirSuite__Stage__c = 'VOB In Queue';
                vob.ElixirSuite__Status__c = 'Active';
                vob.ElixirSuite__Type__c='Primary';  // changing this from vobtype__c to type__c
                vob.RecordTypeId= tertiaryVobRecordTypeId;
                vob.ElixirSuite__Patient_s_Gender__c = ld.ElixirSuite__Gender__c;
                vob.Opportunity__c=oppId;//client name
                Vob.ElixirSuite__Account__c=ld.ConvertedAccountId; //link with respective account when lead converted
                vob.ElixirSuite__Patient_Birth_Date__c=ld.Client_DOB__c;//client dob
             //   vob.ElixirSuite__Patient_Relationship_With_Insured__c=ld.Relationship_to_Client__c; //changing reference from Subscriber_Relationship__c to ElixirSuite__Patient_Relationship_With_Insured__c
                vob.ElixirSuite__VOB_Verification_Status__c = 'Not Approved';
                vob.ElixirSuite__Service_Date__c = system.today();
                vob.ElixirSuite__Patient_SSN__c = ld.ElixirSuite__SSN__c;

                //Tertiary subscriber details
                vob.ElixirSuite__Payer__c=ld.ElixirSuite__Tertiary_Insurance_Provider__c;
                vob.ElixirSuite__Insured_First_Name__c=ld.ElixirSuite__Tertiary_Subscriber_First_Name__c;
                vob.ElixirSuite__Insured_Middle_Name__c=ld.ElixirSuite__Tertiary_Subscriber_Middle_Name__c;
                vob.ElixirSuite__Insured_Last_Name__c=ld.ElixirSuite__Tertiary_Subscriber_Last_Name__c;
                vob.ElixirSuite__Date_Of_Birth__c=ld.ElixirSuite__Tertiary_Subscriber_DOB__c;  
                vob.ElixirSuite__Member_Id__c=ld.ElixirSuite__Tertiary_Insurance_Policy_ID__c;				
                vob.ElixirSuite__Patient_Relationship_With_Insured__c=ld.ElixirSuite__Patient_Relationship_to_Tertiary_Insured__c;
              
                List<String> address = new List<String>{'Street', 'City','State', 'PostalCode','Country'};
              //  List<String> primaryName = new List<String>{'ElixirSuite__Tertiary_Subscriber_First_Name__c', 'ElixirSuite__Tertiary_Subscriber_Middle_Name__c','ElixirSuite__Tertiary_Subscriber_Last_Name__c'};
                
               // String FullName = '';
                
                String Fulladdress = '';
                for(String field :address){
                    if(String.isNotBlank(((String)ld.get(field)))){
                        Fulladdress+=(String)ld.get(field) + ' ';
                    }
                    vob.Patient_Address__c= Fulladdress;
                }
               /* if(vob.ElixirSuite__Subscriber_Name__c == null){
                    for(String field :primaryName){
                        if(String.isNotBlank(((String)ld.get(field)))){
                            FullName+=(String)ld.get(field) + ' ';
                        }
                        
                        vob.ElixirSuite__Subscriber_Name__c= FullName;
                    }
                } */
                
                vobToInsert.add(vob);
            }
             if(ld.ElixirSuite__WC_Insurance_Provider__c!=null || ld.ElixirSuite__WC_Insurance_Policy_ID__c!=null || ld.ElixirSuite__WC_State_of_Occurrence__c!=null  || ld.ElixirSuite__WC_Date_of_Accident__c!=null ){
                VOB__c vob = new VOB__c();
                vob.ElixirSuite__Stage__c = 'VOB In Queue';
                vob.ElixirSuite__Status__c = 'Active';
                vob.ElixirSuite__Type__c='Primary';  // changing this from vobtype__c to type__c
                vob.RecordTypeId= workerVobRecordTypeId;
                vob.ElixirSuite__Patient_s_Gender__c = ld.ElixirSuite__Gender__c;
                vob.Opportunity__c=oppId;//client name
                Vob.ElixirSuite__Account__c=ld.ConvertedAccountId; //link with respective account when lead converted
                vob.ElixirSuite__Patient_Birth_Date__c=ld.Client_DOB__c;//client dob
             //   vob.ElixirSuite__Patient_Relationship_With_Insured__c=ld.Relationship_to_Client__c; //changing reference from Subscriber_Relationship__c to ElixirSuite__Patient_Relationship_With_Insured__c
                vob.ElixirSuite__VOB_Verification_Status__c = 'Not Approved';
                vob.ElixirSuite__Service_Date__c = system.today();
                vob.ElixirSuite__Patient_SSN__c = ld.ElixirSuite__SSN__c;

                //Worker's Comp subscriber details
                vob.ElixirSuite__Payer__c=ld.ElixirSuite__WC_Insurance_Provider__c;
                vob.ElixirSuite__State_of_Occurrence__c=ld.ElixirSuite__WC_State_of_Occurrence__c;
                vob.ElixirSuite__Date_of_Accident__c=ld.ElixirSuite__WC_Date_of_Accident__c;
                vob.ElixirSuite__Member_Id__c=ld.ElixirSuite__WC_Insurance_Policy_ID__c;
           
              
                List<String> address = new List<String>{'Street', 'City','State', 'PostalCode','Country'};
              //  List<String> primaryName = new List<String>{'ElixirSuite__Tertiary_Subscriber_First_Name__c', 'ElixirSuite__Tertiary_Subscriber_Middle_Name__c','ElixirSuite__Tertiary_Subscriber_Last_Name__c'};
                
               // String FullName = '';
                
                String Fulladdress = '';
                for(String field :address){
                    if(String.isNotBlank(((String)ld.get(field)))){
                        Fulladdress+=(String)ld.get(field) + ' ';
                    }
                    vob.Patient_Address__c= Fulladdress;
                }
              
                vobToInsert.add(vob);
            }
            
             if(ld.ElixirSuite__Auto_Accident_Provider_Company__c!=null || ld.ElixirSuite__AA_Policy_ID__c!=null || ld.ElixirSuite__AA_State_of_Occurrence__c!=null  || ld.ElixirSuite__AA_Subscriber_First_Name__c!=null || ld.ElixirSuite__AA_Subscriber_Middle_Name__c!=null || ld.ElixirSuite__AA_Subscriber_Last_Name__c!=null ){
                VOB__c vob = new VOB__c();
                vob.ElixirSuite__Stage__c = 'VOB In Queue';
                vob.ElixirSuite__Status__c = 'Active';
                vob.ElixirSuite__Type__c='Primary';  // changing this from vobtype__c to type__c
                vob.RecordTypeId= AutoVobRecordTypeId;
                vob.ElixirSuite__Patient_s_Gender__c = ld.ElixirSuite__Gender__c;
                vob.Opportunity__c=oppId;//client name
                Vob.ElixirSuite__Account__c=ld.ConvertedAccountId; //link with respective account when lead converted
                vob.ElixirSuite__Patient_Birth_Date__c=ld.Client_DOB__c;//client dob
             //   vob.ElixirSuite__Patient_Relationship_With_Insured__c=ld.Relationship_to_Client__c; //changing reference from Subscriber_Relationship__c to ElixirSuite__Patient_Relationship_With_Insured__c
                vob.ElixirSuite__VOB_Verification_Status__c = 'Not Approved';
                vob.ElixirSuite__Service_Date__c = system.today();
                vob.ElixirSuite__Patient_SSN__c = ld.ElixirSuite__SSN__c;
 				
                 
               //Auto Accident subscriber details
                vob.ElixirSuite__Payer__c=ld.ElixirSuite__Auto_Accident_Provider_Company__c;
                vob.ElixirSuite__Insured_First_Name__c=ld.ElixirSuite__AA_Subscriber_First_Name__c;
                vob.ElixirSuite__Insured_Middle_Name__c=ld.ElixirSuite__AA_Subscriber_Middle_Name__c;
                vob.ElixirSuite__Insured_Last_Name__c=ld.ElixirSuite__AA_Subscriber_Last_Name__c;
                vob.ElixirSuite__Date_Of_Birth__c=ld.ElixirSuite__AA_Subscriber_DOB__c;  
                vob.ElixirSuite__Member_Id__c=ld.ElixirSuite__AA_Policy_ID__c;
                vob.ElixirSuite__State_of_Occurrence__c=ld.ElixirSuite__AA_State_of_Occurrence__c;
                vob.ElixirSuite__Patient_Relationship_With_Insured__c=ld.ElixirSuite__Patient_Relationship_to_AA_Insured__c;
           
              
                List<String> address = new List<String>{'Street', 'City','State', 'PostalCode','Country'};
              //  List<String> primaryName = new List<String>{'ElixirSuite__Tertiary_Subscriber_First_Name__c', 'ElixirSuite__Tertiary_Subscriber_Middle_Name__c','ElixirSuite__Tertiary_Subscriber_Last_Name__c'};
                
               // String FullName = '';
                
                String Fulladdress = '';
                for(String field :address){
                    if(String.isNotBlank(((String)ld.get(field)))){
                        Fulladdress+=(String)ld.get(field) + ' ';
                    }
                    vob.Patient_Address__c= Fulladdress;
                }
              
                vobToInsert.add(vob);
            }
            
            
            
        }
        if(Schema.sObjectType.VOB__c.isCreateable() 
           && Schema.sObjectType.vob__c.fields.Stage__c.isCreateable() 
           && Schema.sObjectType.vob__c.fields.Opportunity__c.isCreateable()
           && Schema.sObjectType.vob__c.fields.PatientDOB__c.isCreateable()
           && Schema.sObjectType.vob__c.fields.Date_Of_Birth__c.isCreateable() 
           && Schema.sObjectType.vob__c.fields.Insurance_Providers__c.isCreateable()
           && Schema.sObjectType.vob__c.fields.Insurance_Policy_ID__c.isCreateable()
           && Schema.sObjectType.vob__c.fields.ElixirSuite__State_of_Occurrence__c.isCreateable()
           && Schema.sObjectType.vob__c.fields.ElixirSuite__Date_of_Accident__c.isCreateable()
           && Schema.sObjectType.vob__c.fields.Insurance_Company_Phone__c.isCreateable()
           && Schema.sObjectType.vob__c.fields.Type__c.isCreateable()
           && Schema.sObjectType.vob__c.fields.Secondary_Subscriber_DOB__c.isCreateable()
           &&  Schema.sObjectType.vob__c.fields.Secondary_Insurance_Policy_ID__c.isCreateable()
           &&  Schema.sObjectType.vob__c.fields.Secondary_Insurance_Phone_Number__c.isCreateable()  
           &&  Schema.sObjectType.vob__c.fields.Insurance_Group_Number_Sec__c.isCreateable() 
           &&  Schema.sObjectType.vob__c.fields.RecordTypeId.isCreateable() 
           &&  Schema.sObjectType.vob__c.fields.ElixirSuite__Patient_Birth_Date__c.isCreateable() 
           &&  Schema.sObjectType.vob__c.fields.Patient_Address__c.isCreateable() 
           &&  Schema.sObjectType.vob__c.fields.Insurance_Group_Number__c.isCreateable() 
           &&  Schema.sObjectType.vob__c.fields.Account__c.isCreateable() 
           && Schema.sObjectType.vob__c.fields.ElixirSuite__Patient_SSN__c.isCreateable() 
           && Schema.sObjectType.vob__c.fields.ElixirSuite__Insured_First_Name__c.isCreateable() 
           && Schema.sObjectType.vob__c.fields.ElixirSuite__Insured_Middle_Name__c.isCreateable() 
           && Schema.sObjectType.vob__c.fields.ElixirSuite__Insured_Last_Name__c.isCreateable()
           && Schema.sObjectType.vob__c.fields.Secondary_Insurance_Provider__c.isCreateable()
           && Schema.sObjectType.vob__c.fields.ElixirSuite__Secondary_Subscriber_Name__c.isCreateable()
           && Schema.sObjectType.vob__c.fields.ElixirSuite__Secondary_Insurance_Phone_Number__c.isCreateable()
           && Schema.sObjectType.vob__c.fields.ElixirSuite__Insurance_Group_Number_Sec__c.isCreateable()
           && Schema.sObjectType.vob__c.fields.ElixirSuite__Account__c.isCreateable()
           && Schema.sObjectType.vob__c.fields.ElixirSuite__Date_Of_Birth__c.isCreateable()
           && Schema.sObjectType.vob__c.fields.ElixirSuite__Type__c.isCreateable()
           && Schema.sObjectType.vob__c.fields.ElixirSuite__Status__c .isCreateable()
           && Schema.sObjectType.vob__c.fields.ElixirSuite__Stage__c .isCreateable()
           && Schema.sObjectType.vob__c.fields.ElixirSuite__Subscriber_Name__c.isCreateable()
           && Schema.sObjectType.vob__c.fields.ElixirSuite__Patient_s_Gender__c .isCreateable()
           && Schema.sObjectType.vob__c.fields.ElixirSuite__Patient_Relationship_With_Insured__c.isCreateable()
           && Schema.sObjectType.vob__c.fields.ElixirSuite__Insurance_Company_Phone__c.isCreateable()
           && Schema.sObjectType.vob__c.fields.ElixirSuite__Insurance_Group_Number__c.isCreateable()
           && Schema.sObjectType.vob__c.fields.ElixirSuite__Member_Id__c.isCreateable()
           && Schema.sObjectType.vob__c.fields.ElixirSuite__Insurance_Policy_ID__c.isCreateable()
           && Schema.sObjectType.vob__c.fields.ElixirSuite__Payer__c.isCreateable()
           && Schema.sObjectType.vob__c.fields.ElixirSuite__Service_Date__c .isCreateable()
           && Schema.sObjectType.vob__c.fields.ElixirSuite__VOB_Verification_Status__c .isCreateable()){
            Insert vobToInsert;
            }
        }
        catch(Exception e){
        ExceptionLog.logError(e);
        }
    }
    
}