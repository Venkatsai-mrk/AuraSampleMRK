public with sharing class visitCloseTriggerHandler {
    public static void createClaim(Map<id,ElixirSuite__Visits__c> oldVisitMap,List<ElixirSuite__Visits__c> newVisitList){
        
        set<id> accountIds = new set<id>();
        Set<String> providerIds = new Set<String>();
List<String> renderingIds = new List<String>();
        for(ElixirSuite__Visits__c eachVisit : newVisitList){
            accountIds.add(eachVisit.ElixirSuite__Account__c);
            providerIds.add(eachVisit.ElixirSuite__Care_Episode_Location__c);
            providerIds.add(eachVisit.ElixirSuite__Billing_Provider__c);
renderingIds.add(eachVisit.ElixirSuite__Rendering_Provider__c);
        }
        
        try{
            List<ElixirSuite__Procedure__c> procedureList = [select id,
                                                             ElixirSuite__Charges__c,
                                                             Name,
                                                             ElixirSuite__Type_of_Procedure__c,
                                                             ElixirSuite__From_Date_of_Service__c,
                                                             ElixirSuite__To_Date_Of_Service__c,
                                                             ElixirSuite__Place_Of_Service_Picklist__c,
                                                             ElixirSuite__Diagnosis_Pointer__c,
                                                             ElixirSuite__Days_Units__c,
                                                             ElixirSuite__Visits__c,
                                                             ElixirSuite__Modifier1__r.Name,
                                                             ElixirSuite__Modifier2__r.Name,
                                                             ElixirSuite__Modifier3__r.Name,
                                                             ElixirSuite__Modifier4__r.Name,
                                                             ElixirSuite__Surgeon__c,ElixirSuite__Surgeon__r.Name,ElixirSuite__Surgeon__r.FirstName,ElixirSuite__Surgeon__r.LastName,ElixirSuite__Surgeon__r.ElixirSuite__Taxonomy__c,ElixirSuite__Surgeon__r.ElixirSuite__Practitioner_NPI__c,
                                                             ElixirSuite__Surgeon__r.ElixirSuite__ID_Number__c,ElixirSuite__Surgeon__r.ElixirSuite__Tax_Id__c,ElixirSuite__Surgeon__r.MailingStreet,ElixirSuite__Surgeon__r.MailingCity,ElixirSuite__Surgeon__r.MailingState,
                                                             ElixirSuite__Surgeon__r.MailingPostalCode ,ElixirSuite__Surgeon__r.MailingCountry
                                                             FROM ElixirSuite__Procedure__c where ElixirSuite__Visits__c in :oldVisitMap.keySet()
                                                             AND ElixirSuite__Is_Billable__c = true AND ElixirSuite__Claim_Generation__c = false AND ElixirSuite__Claim__c = null AND ElixirSuite__Type_of_Procedure__c ='Insurance Payment'
                                                             AND ElixirSuite__Ready_for_Billing__c = true WITH SECURITY_ENFORCED];
            //Anusha - start - To check if no procedures present, auto claim won't generate
            Map<String,List<ElixirSuite__Procedure__c>> visitAndItsProc = new Map<String,List<ElixirSuite__Procedure__c>>();
            for(ElixirSuite__Procedure__c eachProc : procedureList){
                if(visitAndItsProc.containsKey(eachProc.ElixirSuite__Visits__c)){
                    visitAndItsProc.get(eachProc.ElixirSuite__Visits__c).add(eachProc);
                }else{
                    visitAndItsProc.put(eachProc.ElixirSuite__Visits__c,new List<ElixirSuite__Procedure__c>{eachProc});
                }
            }
            //Anusha - end
            Integer procCount = 0;
            Integer claimcount = 0;
            Integer cc = 0;
            Map<String,Integer> VisitVsClaimCount = new Map<String,Integer>();
            string claimProcessedVia;
            if(visitAndItsProc.size() > 0){
            for(String visitId:visitAndItsProc.keyset()){
                List<ElixirSuite__Procedure__c> procList = visitAndItsProc.get(visitId);
                if(!procList.isEmpty()){
                procCount = procList.size();
            }
            claimcount = (procCount/6)+1 ;
            cc =Math.mod(procCount,6);
            if(cc==0 && procCount!=0 && procCount!=1 && procCount!=2 && procCount!=3 && procCount!=4 && procCount!=5){
                claimcount--;
            }
            VisitVsClaimCount.put(visitId,claimcount);
            }
            }
            Schema.DescribeSObjectResult res2 = ElixirSuite__Provider__c.sObjectType.getDescribe();
            List<String> apiNames2 =  new List<String>(res2.fields.getMap().keySet());
            String query2 = 'SELECT ' +String.escapeSingleQuotes(String.join(apiNames2,',')) + ' FROM ElixirSuite__Provider__c ';
            query2+= 'WHERE Id IN :providerIds ';
            Map<Id,ElixirSuite__Provider__c> providerMap = new Map<Id,ElixirSuite__Provider__c>((List<ElixirSuite__Provider__c>)Database.query(query2));
            
            Schema.DescribeSObjectResult res1 = Account.sObjectType.getDescribe();
            List<String> apiNames1 =  new List<String>(res1.fields.getMap().keySet());
            String query1 = 'SELECT ' +String.escapeSingleQuotes(String.join(apiNames1,',')) + ',(select id,ElixirSuite__Insured_Id_Number__c,ElixirSuite__Insured_Last_Name__c, ElixirSuite__Payer__c,ElixirSuite__OtherInsurancePlanName__c,ElixirSuite__Insurance_Plan_Name__c,ElixirSuite__Insured_Country__c,ElixirSuite__Payer__r.ElixirSuite__Claim_Processing_via__c,ElixirSuite__Patient_Relationship_With_Insured__c,ElixirSuite__Insured_Address__c,ElixirSuite__Insured_City__c,ElixirSuite__Date_Of_Birth__c,ElixirSuite__Insured_Policy_Group_FECA_Number__c,ElixirSuite__Insured_Zipcode__c,ElixirSuite__Insured_State__c,ElixirSuite__Member_Id__c,ElixirSuite__Gender__c,ElixirSuite__Insured_First_Name__c,ElixirSuite__InsPhone__c,ElixirSuite__Insured_Middle_Name__c,ElixirSuite__Other_Insured_s_Name__c,ElixirSuite__Insurance_Type__c,ElixirSuite__Other_Insured_Policy_Group_FECA_Number__c,ElixirSuite__Medicare_Type_Code__c from ElixirSuite__VOB__r where ElixirSuite__Status__c= '+'\''+ 'Active' + '\' AND ElixirSuite__Status__c!='+'\''+''+ '\' and RecordType.DeveloperName=' +'\''+ 'VOB_record_type' + '\' AND ElixirSuite__Set_Default_VOB__c='+'\''+ 'Yes'+ '\''+' ORDER BY Createddate DESC LIMIT 1)' +' FROM Account ';
            query1+= 'WHERE Id IN :accountIds ';
            Map<id,Account> relatedAccounts = new Map<id,Account>((List<Account>)Database.query(query1));    
            
            /* Map<id,Account> relatedAccounts = new Map<id,Account>([select 
              id, Name,RecordType.DeveloperName,Patient_s_Birth_Date__c,ElixirSuite__Insured_s_Address__c,
              AccountNumber,ElixirSuite__Gender__c,ElixirSuite__DOB__c,BillingCity,BillingState,BillingPostalCode,Phone,BillingAddress,BillingStreet,BillingCountry,
              (select id,ElixirSuite__Insured_Id_Number__c,ElixirSuite__Insured_Last_Name__c, ElixirSuite__Payer__c,ElixirSuite__Insured_Country__c,ElixirSuite__Payer__r.ElixirSuite__Claim_Processing_via__c,
              ElixirSuite__Patient_Relationship_With_Insured__c,ElixirSuite__Insured_Address__c,ElixirSuite__Insured_City__c,ElixirSuite__Date_Of_Birth__c,ElixirSuite__Insured_Policy_Group_FECA_Number__c,
              ElixirSuite__Insured_Zipcode__c,ElixirSuite__Insured_State__c,ElixirSuite__Member_Id__c,
              ElixirSuite__Gender__c,ElixirSuite__Insured_First_Name__c,ElixirSuite__InsPhone__c,ElixirSuite__Insured_Middle_Name__c,ElixirSuite__Other_Insured_s_Name__c
              from ElixirSuite__VOB__r where ElixirSuite__Status__c='Active' and ElixirSuite__Status__c!='' and RecordType.DeveloperName='VOB_record_type' and ElixirSuite__Set_Default_VOB__c='Yes')
              from Account where id in :accountIds WITH SECURITY_ENFORCED]);*/
            /*Map<id,Account> visitAndAccount = new Map<id,Account>();
            for(ElixirSuite__Visits__c eachVisit : newVisitList){
                if(relatedAccounts.containsKey(eachVisit.ElixirSuite__Account__c)){
                    visitAndAccount.put(eachVisit.id,relatedAccounts.get(eachVisit.ElixirSuite__Account__c));
                }  
            }*/
            // map to get practitioner contact details
            Elixir_Custom_Setting__c val = Elixir_Custom_Setting__c.getOrgDefaults();
        String contactRecType = val.ElixirSuite__Practitioner_Contact_Recordtype__c;
            Id objectRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(contactRecType).getRecordTypeId();
            Map<id,Contact> visitAndRendPractiotioner = new Map<id,Contact>([SELECT id,Name,FirstName, LastName,ElixirSuite__Tax_Id__c, ElixirSuite__Taxonomy__c,MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry, ElixirSuite__Practitioner_NPI__c, ElixirSuite__ID_Number__c, MailingAddress 
                                                                             FROM Contact WHERE Id IN: renderingIds AND RecordTypeId =: objectRecordTypeId  WITH SECURITY_ENFORCED]);
            
            List<claim__c> claimList = new List<claim__c>();
            Map<String, String> patientSex = new Map<String, String> {
                'female' => 'F',
                    'male' => 'M',
                    'f' => 'F',
                    'm' => 'M'};
                        Boolean territory = Account.getSobjectType().getDescribe().fields.getMap().keySet().contains('billingcountrycode');
            Map<id,claim__c> visitAndItsClaim = new Map<id,claim__c>();
            /* List<ElixirSuite__CMS_1500_Claim_Generation__c> cmsMDT = [Select ElixirSuite__Federal_Tax_Id_Number__c,ElixirSuite__Service_Facility_Location_Information__c,ElixirSuite__Accept_Assignment__c,ElixirSuite__Billing_Provider_NPI__c,
                                                                      ElixirSuite__Billing_Provider_Address__c,ElixirSuite__Billing_Provider_City__c,ElixirSuite__Billing_Provider_Name__c,ElixirSuite__Billing_Provider_State__c,ElixirSuite__Bill_Provider_Phone__c,
                                                                      ElixirSuite__Billing_Provider_Zipcode__c,ElixirSuite__Other_Accident__c,ElixirSuite__Employment__c,ElixirSuite__Auto_Accident__c,ElixirSuite__Billing_Provider_Tax_ID__c
                                                                      from ElixirSuite__CMS_1500_Claim_Generation__c WITH SECURITY_ENFORCED];*/
Map<String, String> stateMap = new Map<String, String> {
                            'Alabama' => 'AL', 'AL' => 'AL',
                                'Alaska' => 'AK','AK' => 'AK',
                                'Arizona' => 'AZ', 'AZ' => 'AZ',
                                'Arkansas' => 'AR', 'AR' => 'AR',
                                'California' => 'CA', 'CA' => 'CA',
                                'Colorado' => 'CO', 'CO' => 'CO',
                                'Connecticut' => 'CT', 'CT' => 'CT',
                                'District Of Columbia' => 'DC', 'DC' => 'DC',
                                'Florida' => 'FL', 'FL' => 'FL',
                                'Georgia' => 'GA', 'GA' => 'GA',
                                'Hawaii' => 'HI', 'HI' => 'HI',
                                'Idaho' => 'ID', 'ID' => 'ID',
                                'Illinois' => 'IL', 'IL' => 'IL',
                                'Indiana' => 'IN', 'IN' => 'IN',
                                'Iowa' => 'IA', 'IA' => 'IA',
                                'Kansas' => 'KS', 'KS' => 'KS',
                                'Maine' => 'ME', 'ME' => 'ME',
                                'Maryland' => 'MD','MD' => 'MD',
                                'Massachusetts' => 'MA', 'MA' => 'MA',
                                'Michigan' => 'MA', 'MA' => 'MA',
                                'Minnesota' => 'MN', 'MN' => 'MN',
                                'Mississippi' => 'MS', 'MS' => 'MS',
                                'Missouri' => 'MA', 'MA' => 'MA',
                                'Montana' => 'MO', 'MO' => 'MO',
                                'Nebraska' => 'NE', 'NE' => 'NE',
                                'Nevada' => 'MN','MN' => 'MN',
                                'New Jersey' => 'NJ','NJ' => 'NJ',
                                'New Hampshire' => 'NH', 'NH' => 'NH',
                                'New Mexico' => 'MA', 'MA' => 'MA',
                                'New York' => 'NM', 'NM' => 'NM',
                                'North Carolina' => 'NC', 'NC' => 'NC',
                                'Dakota' => 'ND', 'ND' => 'ND',
                                'Ohio' => 'OH', 'OH' => 'OH',
                                'Oklahoma' => 'OK','OK' => 'OK',
                                'Oregon' => 'OR','OR' => 'OR',
                                'Pennsylvania' => 'PA', 'PA' => 'PA',
                                'Rhode Island' => 'RI', 'RI' => 'RI',
                                'South Carolina' => 'SC', 'SC' => 'SC',
                                'South Dakota' => 'SD', 'SD' => 'SD',
                                'Tennessee' => 'TN', 'TN' => 'TN',
                                'Texas' => 'TX','TX' => 'TX',
                                'Utah' => 'UT', 'UT' => 'UT',
                                'Vermont' => 'VT', 'VT' => 'VT',
                                'Virginia' => 'VA','VA' => 'VA',
                                'Washington' => 'WA','WA' => 'WA',
                                'West Virginia' => 'WV','WV' => 'WV',
                                'Wisconsin' => 'WI','WI' => 'WI',
                                'Wyoming' => 'WY','WY' => 'WY'
                                };
            
            for(ElixirSuite__Visits__c eachVisit : newVisitList){
                if(eachVisit.ElixirSuite__Status__c =='Closed' && oldVisitMap!=null && eachVisit.ElixirSuite__Status__c!=oldVisitMap.get(eachVisit.id).ElixirSuite__Status__c && relatedAccounts.get(eachVisit.ElixirSuite__Account__c).ElixirSuite__VOB__r.size()==1 && visitAndItsProc.containsKey(eachVisit.id) &&!visitAndItsProc.get(eachVisit.id).isEmpty()){
                    for(integer i=0;i<VisitVsClaimCount.get(eachVisit.Id);i++){  
                        Claim__c claim = new Claim__c();  
                        claim.ElixirSuite__Patient_Name__c = relatedAccounts.get(eachVisit.ElixirSuite__Account__c).Name;
                        claim.ElixirSuite__Patient_DOB__c = relatedAccounts.get(eachVisit.ElixirSuite__Account__c).ElixirSuite__DOB__c;//Added by Ashwini before Patient_s_Birth_Date__c now ElixirSuite__DOB__c 07/02/2023
                        claim.ElixirSuite__Patient_Account_Number__c = relatedAccounts.get(eachVisit.ElixirSuite__Account__c).AccountNumber;
                        claim.ElixirSuite__Account__c = relatedAccounts.get(eachVisit.ElixirSuite__Account__c).id;
                        claim.ElixirSuite__Visits__c = eachVisit.id;
                        
                        // added by jami for 11362
                        if(eachVisit.ElixirSuite__Rendering_Provider__c != null){
                            Id renderingProviderId = eachVisit.ElixirSuite__Rendering_Provider__c;
                            if (visitAndRendPractiotioner.containsKey(renderingProviderId)) {
                                Contact renderingProvider = visitAndRendPractiotioner.get(renderingProviderId);
                                if (renderingProvider != null) {
                                    claim.ElixirSuite__Rendering_Provider_First_Name__c = renderingProvider.FirstName;
                                    claim.ElixirSuite__Rendering_Provider_Last_Name__c = renderingProvider.LastName;
                                    claim.ElixirSuite__Rendering_Provider_Taxonomy__c = renderingProvider.ElixirSuite__Taxonomy__c;
                                    claim.ElixirSuite__Rendering_Provider_NPI__c = renderingProvider.ElixirSuite__Practitioner_NPI__c;
                                    claim.ElixirSuite__Rendering_Provider_Tax_Id__c = renderingProvider.ElixirSuite__Tax_Id__c;
                                    String street = '';
                                    String city = '';
                                    String state = '';
                                    String postalCode = '';
                                    String country = '';
                                    if(renderingProvider.MailingStreet != null){
                                        street = renderingProvider.MailingStreet;
                                    }
                                    if(renderingProvider.MailingCity != null){
                                        city = renderingProvider.MailingCity;
                                    }
                                    if(renderingProvider.MailingState != null){
                                        state = renderingProvider.MailingState;
                                    }
                                    if(renderingProvider.MailingPostalCode != null){
                                        postalCode = renderingProvider.MailingPostalCode;
                                    }
                                    if(renderingProvider.MailingCountry != null){
                                        country = renderingProvider.MailingCountry;
                                    }
                                    String mailingAddress = street + '\n' +
                                        city + ', ' + 
                                        state + ' ' +
                                        postalCode + '\n' +
                                        country;
                                    claim.ElixirSuite__Rendering_Provider_Address__c =  mailingAddress;
                                }
                            }
                        }
                        if(eachVisit.ElixirSuite__Care_Episode_Location__c != null && !providerMap.isEmpty() && providerMap.containsKey(eachVisit.ElixirSuite__Care_Episode_Location__c)){
                            claim.ElixirSuite__Service_Facility_Location_NPI__c = (providerMap.get((eachVisit.ElixirSuite__Care_Episode_Location__c))).ElixirSuite__Provider_Code__c;
                            claim.ElixirSuite__Service_Facility_Location_Information__c = (providerMap.get((eachVisit.ElixirSuite__Care_Episode_Location__c))).Name;
                            claim.ElixirSuite__Servic_Fcility_Loc_Informaton_OtherID__c = (providerMap.get((eachVisit.ElixirSuite__Care_Episode_Location__c))).ElixirSuite__Provider_Tax_Id__c;
                            claim.ElixirSuite__Service_Facility_Loc_Address__c = (providerMap.get((eachVisit.ElixirSuite__Care_Episode_Location__c))).ElixirSuite__Address__c; 
                            claim.ElixirSuite__Service_Facility_Address_2__c = (providerMap.get((eachVisit.ElixirSuite__Care_Episode_Location__c))).ElixirSuite__Address_2__c; 
                            claim.ElixirSuite__Service_Facility_Loc_City__c = (providerMap.get((eachVisit.ElixirSuite__Care_Episode_Location__c))).ElixirSuite__Provider_City__c;
                            claim.ElixirSuite__Service_Facility_Loc_State__c = (providerMap.get((eachVisit.ElixirSuite__Care_Episode_Location__c))).ElixirSuite__Provider_State__c;
                            claim.ElixirSuite__Service_Facility_Loc_Zip__c = (providerMap.get((eachVisit.ElixirSuite__Care_Episode_Location__c))).ElixirSuite__Provider_Zip__c;
                        }
                        
                        if(eachVisit.ElixirSuite__Billing_Provider__c != null && !providerMap.isEmpty() && providerMap.containsKey(eachVisit.ElixirSuite__Billing_Provider__c)){
                            claim.ElixirSuite__Billing_Provider_Info__c = (providerMap.get((eachVisit.ElixirSuite__Billing_Provider__c))).ElixirSuite__Provider_Code__c;//Added by Ashwini before ElixirSuite__BILLING_PROVIDER_INFO__c
                            claim.ElixirSuite__Billing_Provider_Address_1__c = (providerMap.get((eachVisit.ElixirSuite__Billing_Provider__c))).ElixirSuite__Address__c; 
                            claim.ElixirSuite__Billing_Provider_Address_2__c = (providerMap.get((eachVisit.ElixirSuite__Billing_Provider__c))).ElixirSuite__Address_2__c; 
                            claim.ElixirSuite__Billing_Provider_City__c =  (providerMap.get((eachVisit.ElixirSuite__Billing_Provider__c))).ElixirSuite__Provider_City__c;
                            claim.ElixirSuite__Billing_Provider_Name__c =  (providerMap.get((eachVisit.ElixirSuite__Billing_Provider__c))).Name;
                            claim.ElixirSuite__Billing_Provider_State__c = (providerMap.get((eachVisit.ElixirSuite__Billing_Provider__c))).ElixirSuite__Provider_State__c;
                            claim.ElixirSuite__Billing_Provider_Zip__c =   (providerMap.get((eachVisit.ElixirSuite__Billing_Provider__c))).ElixirSuite__Provider_Zip__c;
                            claim.ElixirSuite__Billing_Provider_Tax_ID__c = (providerMap.get((eachVisit.ElixirSuite__Billing_Provider__c))).ElixirSuite__Provider_Tax_Id__c;
                            claim.ElixirSuite__Billing_Provider_Info_NPI__c = (providerMap.get((eachVisit.ElixirSuite__Billing_Provider__c))).ElixirSuite__Provider_Code__c; 
                            claim.ElixirSuite__Billing_Provider_Taxonomy__c = (providerMap.get((eachVisit.ElixirSuite__Billing_Provider__c))).ElixirSuite__Provider_Taxonomy__c;
                            claim.ElixirSuite__Bill_Phone__c = (providerMap.get((eachVisit.ElixirSuite__Billing_Provider__c))).ElixirSuite__Provider_Phone__c;
                            claim.ElixirSuite__Federal_Tax_Id_Number__c = (providerMap.get((eachVisit.ElixirSuite__Billing_Provider__c))).ElixirSuite__Provider_Tax_Id__c;
                            claim.Billing_Provider_Tax_ID_Type__c = (providerMap.get((eachVisit.ElixirSuite__Billing_Provider__c))).ElixirSuite__Tax_Id_Type__c;
                        }
                        //Added by Ashwini//
                        if(patientSex.containsKey((relatedAccounts.get(eachVisit.ElixirSuite__Account__c).ElixirSuite__Gender__c).toLowerCase())){
                            claim.ElixirSuite__Patient_Sex__c = patientSex.get((relatedAccounts.get(eachVisit.ElixirSuite__Account__c).ElixirSuite__Gender__c).toLowerCase());   
                        }else{
                            claim.ElixirSuite__Patient_Sex__c = 'U';  
                        }
                        claim.ElixirSuite__Patient_s_City__c =relatedAccounts.get(eachVisit.ElixirSuite__Account__c).BillingCity;
                        claim.ElixirSuite__Prior_Authorization_Number__c = eachVisit.ElixirSuite__Pre_Authorization_Number__c;
                        claim.ElixirSuite__Hospitalization_From_Date__c = eachVisit.ElixirSuite__Hospitalization_Start_Date__c;
                        claim.ElixirSuite__Hospitalization_To_Date__c = eachVisit.ElixirSuite__Hospitalization_End_Date__c;
                        String patientState = relatedAccounts.get(eachVisit.ElixirSuite__Account__c).BillingState;
                        if(patientState != null && !String.isBlank(patientState) ){
                        patientState = patientState.toUppercase();
                        }
                        if(stateMap.containsKey(patientState)){
                        claim.ElixirSuite__Patient_s_State__c = stateMap.get(patientState);
                        }else{
                        claim.ElixirSuite__Patient_s_State__c = relatedAccounts.get(eachVisit.ElixirSuite__Account__c).BillingState;    
                        }    
                        claim.ElixirSuite__Patient_Zip_Code__c =relatedAccounts.get(eachVisit.ElixirSuite__Account__c).BillingPostalCode;
                        claim.ElixirSuite__Patient_s_Phone__c = relatedAccounts.get(eachVisit.ElixirSuite__Account__c).Phone;
                        claim.ElixirSuite__Patient_s_Address__c = relatedAccounts.get(eachVisit.ElixirSuite__Account__c).BillingStreet;
                        Account ac = relatedAccounts.get(eachVisit.ElixirSuite__Account__c);
                        if(territory){
                            claim.ElixirSuite__Patient_Country_Code__c = String.valueOf(ac.get('BillingCountryCode'));  
                        }else{
                            claim.ElixirSuite__Patient_Country_Code__c = relatedAccounts.get(eachVisit.ElixirSuite__Account__c).BillingCountry;
                        }
                        //End
                        claim.ElixirSuite__Claim_Status__c = 'Ready to Submit';
                        //if(cmsMDT!=null && cmsMDT.size()>0){
                            //claim.ElixirSuite__Service_Facility_Location_Information__c = cmsMDT[0].ElixirSuite__Service_Facility_Location_Information__c;
                            //claim.ElixirSuite__Accept_Assignment__c = cmsMDT[0].ElixirSuite__Accept_Assignment__c;
                            //claim.ElixirSuite__Other_Accident__c = cmsMDT[0].ElixirSuite__Other_Accident__c;
                            //claim.ElixirSuite__Employment_Related__c = cmsMDT[0].ElixirSuite__Employment__c;
                            //claim.ElixirSuite__Auto_Accident_Related__c = cmsMDT[0].ElixirSuite__Auto_Accident__c;
                            
                        //}
                        //claim.ElixirSuite__Billing_Provider_Info__c='Community Wellness venture, 1930 Martin Luther King Jr. Ave, SE Washington, DC 20020, 202-450-5822 ';
                        //claim.ElixirSuite__Service_Facility_Location_Information__c='Community Wellness venture, 1930 Martin Luther King Jr. Ave, SE Washington, DC 20020 ';
                        //claim.ElixirSuite__Accept_Assignment__c='Yes';
                        claim.ElixirSuite__Any_Other_Health_Benefit_Plan__c=true;
                                                //Added by Ashwini//
                        String insuredName;
                        if(relatedAccounts.get(eachVisit.ElixirSuite__Account__c).ElixirSuite__VOB__r[0].ElixirSuite__Insured_First_Name__c != null && relatedAccounts.get(eachVisit.ElixirSuite__Account__c).ElixirSuite__VOB__r[0].ElixirSuite__Insured_First_Name__c != ''){
                            insuredName = relatedAccounts.get(eachVisit.ElixirSuite__Account__c).ElixirSuite__VOB__r[0].ElixirSuite__Insured_First_Name__c;
                        }
                        if(relatedAccounts.get(eachVisit.ElixirSuite__Account__c).ElixirSuite__VOB__r[0].ElixirSuite__Insured_Middle_Name__c != null && relatedAccounts.get(eachVisit.ElixirSuite__Account__c).ElixirSuite__VOB__r[0].ElixirSuite__Insured_Middle_Name__c != ''){
                            insuredName = insuredName + ' ' + relatedAccounts.get(eachVisit.ElixirSuite__Account__c).ElixirSuite__VOB__r[0].ElixirSuite__Insured_Middle_Name__c;
                        }
                        if(relatedAccounts.get(eachVisit.ElixirSuite__Account__c).ElixirSuite__VOB__r[0].ElixirSuite__Insured_Last_Name__c != null && relatedAccounts.get(eachVisit.ElixirSuite__Account__c).ElixirSuite__VOB__r[0].ElixirSuite__Insured_Last_Name__c != ''){
                            insuredName = insuredName + ' ' + relatedAccounts.get(eachVisit.ElixirSuite__Account__c).ElixirSuite__VOB__r[0].ElixirSuite__Insured_Last_Name__c;
                        }
                        claim.ElixirSuite__Insured_s_Name__c= insuredName;
                        claim.ElixirSuite__Other_Insured_s_Name__c = relatedAccounts.get(eachVisit.ElixirSuite__Account__c).ElixirSuite__VOB__r[0].ElixirSuite__Other_Insured_s_Name__c;
                        claim.Insurance_Type__c = relatedAccounts.get(eachVisit.ElixirSuite__Account__c).ElixirSuite__VOB__r[0].ElixirSuite__Insurance_Type__c;
//added by jami for LX3-12673
                        if(relatedAccounts.get(eachVisit.ElixirSuite__Account__c).ElixirSuite__VOB__r[0].ElixirSuite__Insurance_Type__c == 'MA' || relatedAccounts.get(eachVisit.ElixirSuite__Account__c).ElixirSuite__VOB__r[0].ElixirSuite__Insurance_Type__c == 'MB' ){
                        claim.ElixirSuite__Medicare_Type_Code__c = relatedAccounts.get(eachVisit.ElixirSuite__Account__c).ElixirSuite__VOB__r[0].ElixirSuite__Medicare_Type_Code__c;
}else{
                          claim.ElixirSuite__Medicare_Type_Code__c = '';  
                        }
                        claim.Other_Insurance_Plan_Name__c = relatedAccounts.get(eachVisit.ElixirSuite__Account__c).ElixirSuite__VOB__r[0].ElixirSuite__Other_Insured_Policy_Group_FECA_Number__c;
                        claim.Other_Insured_s_Policy_Group_Number__c = relatedAccounts.get(eachVisit.ElixirSuite__Account__c).ElixirSuite__VOB__r[0].ElixirSuite__OtherInsurancePlanName__c;
                        claim.Insurance_Plan_Name__c = relatedAccounts.get(eachVisit.ElixirSuite__Account__c).ElixirSuite__VOB__r[0].ElixirSuite__Insurance_Plan_Name__c;
                        claim.ElixirSuite__Insured_First_name__c=relatedAccounts.get(eachVisit.ElixirSuite__Account__c).ElixirSuite__VOB__r[0].ElixirSuite__Insured_First_Name__c;
                        if(patientSex.containsKey((relatedAccounts.get(eachVisit.ElixirSuite__Account__c).ElixirSuite__VOB__r[0].ElixirSuite__Gender__c).toLowerCase())){
                            claim.ElixirSuite__Insured_Sex__c=patientSex.get((relatedAccounts.get(eachVisit.ElixirSuite__Account__c).ElixirSuite__VOB__r[0].ElixirSuite__Gender__c).toLowerCase());
                        }else{
                            claim.ElixirSuite__Insured_Sex__c = 'U';  
                        }
                        claim.ElixirSuite__Insured_DOB__c=relatedAccounts.get(eachVisit.ElixirSuite__Account__c).ElixirSuite__VOB__r[0].ElixirSuite__Date_Of_Birth__c;
                        claim.ElixirSuite__Insured_Address__c=relatedAccounts.get(eachVisit.ElixirSuite__Account__c).ElixirSuite__VOB__r[0].ElixirSuite__Insured_Address__c;
                        claim.ElixirSuite__Insured_City__c=relatedAccounts.get(eachVisit.ElixirSuite__Account__c).ElixirSuite__VOB__r[0].ElixirSuite__Insured_City__c;
                        claim.ElixirSuite__Patient_Relationship_to_Insured__c=relatedAccounts.get(eachVisit.ElixirSuite__Account__c).ElixirSuite__VOB__r[0].ElixirSuite__Patient_Relationship_With_Insured__c;//Added by Ashwini 07/02/2023
                        claim.ElixirSuite__Payer_Order__c = 'Primary';
                                                            
                        String insuredState =relatedAccounts.get(eachVisit.ElixirSuite__Account__c).ElixirSuite__VOB__r[0].ElixirSuite__Insured_State__c;
                        if(insuredState != null && !String.isBlank(insuredState) ){
                        insuredState = insuredState.toUppercase();
                        }
                        if(stateMap.containsKey(insuredState)){
                        claim.ElixirSuite__Insured_State__c = stateMap.get(insuredState);
                        }else{
                        claim.ElixirSuite__Insured_State__c =  relatedAccounts.get(eachVisit.ElixirSuite__Account__c).ElixirSuite__VOB__r[0].ElixirSuite__Insured_State__c;   
                        }
                        claim.ElixirSuite__Insured_Zip_Code__c=relatedAccounts.get(eachVisit.ElixirSuite__Account__c).ElixirSuite__VOB__r[0].ElixirSuite__Insured_Zipcode__c;
                        claim.ElixirSuite__Insured_Policy__c=relatedAccounts.get(eachVisit.ElixirSuite__Account__c).ElixirSuite__VOB__r[0].ElixirSuite__Insured_Policy_Group_FECA_Number__c;
                        claim.ElixirSuite__VOB_lookup__c=relatedAccounts.get(eachVisit.ElixirSuite__Account__c).ElixirSuite__VOB__r[0].id;
                        claim.ElixirSuite__Payor__c=relatedAccounts.get(eachVisit.ElixirSuite__Account__c).ElixirSuite__VOB__r[0].ElixirSuite__Payer__c;
                        claim.ElixirSuite__Insured_Telephone__c=relatedAccounts.get(eachVisit.ElixirSuite__Account__c).ElixirSuite__VOB__r[0].ElixirSuite__InsPhone__c;
                        claim.ElixirSuite__Insured_s_ID_Number__c=relatedAccounts.get(eachVisit.ElixirSuite__Account__c).ElixirSuite__VOB__r[0].ElixirSuite__Member_Id__c;
                        
                        claim.ElixirSuite__Insured_Country_Code__c=relatedAccounts.get(eachVisit.ElixirSuite__Account__c).ElixirSuite__VOB__r[0].ElixirSuite__Insured_Country__c;
                        claimProcessedVia = relatedAccounts.get(eachVisit.ElixirSuite__Account__c).ElixirSuite__VOB__r[0].ElixirSuite__Payer__r.ElixirSuite__Claim_Processing_via__c;
                        //End
                                                claimList.add(claim);
                    }
                }
            }
            if(!claimList.isEmpty() && claimList.size()>0 && claimList!=null){
                
                DMLManager.insertAsUser(claimList);
                List<claim__c> ClaimRecList = [Select id,Name,ElixirSuite__Visits__c,ElixirSuite__Payor__c,ElixirSuite__Payor__r.ElixirSuite__Claim_Processing_via__c From claim__c where Id IN: claimList WITH SECURITY_ENFORCED];
                Map<id,List<claim__c>> visitAndItsClaimList = new Map<id,List<claim__c>>();
                List<String> cIdList = new List<String>();
                Boolean sendClaimToClaimMD = false;
                for(claim__c cl: ClaimRecList){

                    if(visitAndItsClaimList.containsKey(cl.ElixirSuite__Visits__c)){
                        visitAndItsClaimList.get(cl.ElixirSuite__Visits__c).add(cl);
                    }else{
                        visitAndItsClaimList.put(cl.ElixirSuite__Visits__c,new List<claim__c>{cl});
                    }
                    if(cl.ElixirSuite__Payor__c != null && cl.ElixirSuite__Payor__r.ElixirSuite__Claim_Processing_via__c != null && cl.ElixirSuite__Payor__r.ElixirSuite__Claim_Processing_via__c =='Clearing House'){
                     sendClaimToClaimMD = true;
                    cIdList.add(cl.Id);
                }
                }
                visitCloseTriggerHandler.createClaimLineItem(oldVisitMap,visitAndItsClaimList,procedureList,newVisitList,visitAndItsProc);
                Set<String> sset = new Set<String>(cIdList);
                sset.remove(null);
                String claimLst = String.join(new List<String>(sset), ',');
                if(sendClaimToClaimMD){
                    try{
                        
                        List<Elixir_Pluggable_Classes__mdt> pluggableClass = new List<Elixir_Pluggable_Classes__mdt>();
                        String virtualClassName;
                        pluggableClass = [SELECT DeveloperName,Virtual_Class__c FROM Elixir_Pluggable_Classes__mdt WHERE DeveloperName='NewClaimMDIntegration' WITH SECURITY_ENFORCED];
                        if(pluggableClass != null && !pluggableClass.isEmpty()){
                            
                            virtualClassName = pluggableClass[0].Virtual_Class__c;
                            
                        }
                        Elixir_Custom_Setting__c elixirCustom = Elixir_Custom_Setting__c.getOrgDefaults();
                        if(elixirCustom != null && elixirCustom.ElixirSuite__Send_Claim_To_ClaimMd__c && virtualClassName != '' && virtualClassName !=null){
                            Callable calloutclaimMd = (Callable) Type.forName(virtualClassName).newInstance();
                            calloutclaimMd.call('RefreshClaimMDCallout', new Map<String, Object> {
                                'claimLst' => claimLst
                                    });
                            
                                                }
                    }
                    catch(exception e){
                        ExceptionLog.logError(e);
                    }
                }
            }
        }catch(exception e){
            ExceptionLog.logError(e);
        }
    }
    
    //create claim line items
    public static void createClaimLineItem(Map<id,ElixirSuite__Visits__c> oldVisitMap, Map<id,List<claim__c>> visitAndItsClaimList, List<ElixirSuite__Procedure__c> procList, list<ElixirSuite__Visits__c> newVisitRecords,Map<String,List<ElixirSuite__Procedure__c>> visitAndItsProc){
        try{
            Map<id,Set<String>> procDiagnosisCode = new Map<id,Set<String>>();//
            // Map<String,List<ElixirSuite__Procedure__c>> visitAndItsProc = new Map<id,List<ElixirSuite__Procedure__c>>(); //Anusha LX3-6566
            
            //List<String> procId = new List<String>();//
            Map<Id,Id> proclaimMap = new Map<Id,Id>();
            //System.debug('procList '+procList);
            //Anusha - start LX3-6566
            /* for(ElixirSuite__Procedure__c eachProc : procList){
                procId.add(eachProc.Id);
                if(visitAndItsProc.containsKey(eachProc.ElixirSuite__Visits__c)){
                    visitAndItsProc.get(eachProc.ElixirSuite__Visits__c).add(eachProc);
                }else{
                    visitAndItsProc.put(eachProc.ElixirSuite__Visits__c,new List<ElixirSuite__Procedure__c>{eachProc});
                }
            }*/
            for(ElixirSuite__Visits__c eachVisit : newVisitRecords){
                if(!visitAndItsProc.containsKey(eachVisit.Id)){
                    return;
                }
                for(ElixirSuite__Procedure__c eachProc: visitAndItsProc.get(eachVisit.Id)){
                    if( eachProc.ElixirSuite__Charges__c==null){
                        eachProc.ElixirSuite__Charges__c =0;
                    }
                    if(eachProc.ElixirSuite__Charges__c==0){
                        // System.debug(' eachProc.ElixirSuite__Charges__c '+ eachProc.ElixirSuite__Charges__c);
                        eachVisit.addError('Charges not configured on associated Procedure(s), please contact System Admin before closing this care episode.');
                    }
                }
            }
            //Anusha - end LX3-6566
            
                        Map<Id,ElixirSuite__Claim__c> updateClaimData = new Map<Id,ElixirSuite__Claim__c>();
            List<ElixirSuite__Procedure_Diagnosis__c> diagList =[Select id,ElixirSuite__ICD_Codes__r.name,ElixirSuite__Procedure__c from ElixirSuite__Procedure_Diagnosis__c 
                                                                 where ElixirSuite__Procedure__c in :procList WITH SECURITY_ENFORCED];
            
            for(ElixirSuite__Procedure_Diagnosis__c diag:diagList){
                if(procDiagnosisCode.containsKey(diag.ElixirSuite__Procedure__c)) {
                    procDiagnosisCode.get(diag.ElixirSuite__Procedure__c).add(diag.ElixirSuite__ICD_Codes__r.name);
                }else{
                    procDiagnosisCode.put(diag.ElixirSuite__Procedure__c,new Set<String>{diag.ElixirSuite__ICD_Codes__r.name});
                }  
            }
            Map<id,Decimal> claimAndProcedureCharges = new Map<id,Decimal>();
            Map<Id,List<string>> claimDiagCode = new Map<Id,List<string>>();
            Map<String,Integer> claimFieldCodeMap = new  Map<String,Integer>();
            List<ElixirSuite__Claim_Line_Items__c> lineItemsToUpdate = new List<ElixirSuite__Claim_Line_Items__c>();
            for(id visitId : visitAndItsClaimList.keySet()){
integer i = 0;
                integer j = 0;
                Decimal claimCharge = 0;
                Boolean rendInfoCheck = false;
                List<claim__c> visitClaimList =  visitAndItsClaimList.get(visitId); 
                for(ElixirSuite__Procedure__c eachProc : visitAndItsProc.get(visitId)){
                    if(visitAndItsClaimList.containsKey(eachProc.ElixirSuite__Visits__c)){
                        ElixirSuite__Claim_Line_Items__c lineItem = new ElixirSuite__Claim_Line_Items__c();
                        lineItem.ElixirSuite__Claim__c= visitClaimList[i].Id;
                                                ElixirSuite__Claim__c claimData;
                        
                        
                        
                        if(updateClaimData.get(visitClaimList[i].Id) !=null)
                        {
                            claimData = updateClaimData.get(visitClaimList[i].Id);
                        }else{
                            claimData = new ElixirSuite__Claim__c();
                            claimData.Id=visitClaimList[i].Id;
                        }
                                                proclaimMap.put(eachProc.id,claimData.id);
                        
                        List<String> existingCode = claimDiagCode.get(claimData.id);
                        if(procDiagnosisCode.get(eachProc.Id) != null) { 
                            for(String diag: procDiagnosisCode.get(eachProc.Id)){
                                Integer fieldCode = 64;
                                if(claimFieldCodeMap.containsKey(claimData.id)){
                                    fieldCode = claimFieldCodeMap.get(claimData.id);   
                                }
                                //  system.debug('Diag '+diag);
                                
                                if(((existingCode != null && !(existingCode.contains(diag))) || existingCode == null) && fieldCode < 76){
                                    
                                    String fieldName = 'ElixirSuite__Diagnosis_'+string.fromCharArray(new List<Integer> {fieldCode+1})+'__c';
                                    // system.debug('fieldName '+fieldName);
                                    claimData.put(fieldName,diag);
                                    updateClaimData.put(claimData.Id,claimData);
                                    // System.debug('updateClaimData '+updateClaimData);
                                    // System.debug('claimData '+claimData);
                                    if(lineItem.ElixirSuite__Diagnosis_Pointer__c != null){
                                        lineItem.ElixirSuite__Diagnosis_Pointer__c = lineItem.ElixirSuite__Diagnosis_Pointer__c + ','+string.fromCharArray(new List<Integer> {fieldCode+1}); 
                                    }else{
                                        lineItem.ElixirSuite__Diagnosis_Pointer__c = string.fromCharArray(new List<Integer> {fieldCode+1});
                                    }
                                    claimFieldCodeMap.put(claimData.id,fieldCode+1);
                                    if(claimDiagCode.get(claimData.Id) != null && (claimDiagCode.get(claimData.Id)).size() >0){
                                        claimDiagCode.get(claimData.Id).add(diag);
                                    }else{
                                        List<String> diagnosisCode = new List<String>();
                                        diagnosisCode.add(diag);
                                        claimDiagCode.put(claimData.Id,diagnosisCode);
                                    }
                                    
                                    
                                }else{
                                    for(integer k=65;k<=76;k++){
                                        String fieldName = 'ElixirSuite__Diagnosis_'+string.fromCharArray(new List<Integer> {k})+'__c';
                                        if(diag == claimData.get(fieldName)){
                                            
                                            if(lineItem.ElixirSuite__Diagnosis_Pointer__c != null){
                                                lineItem.ElixirSuite__Diagnosis_Pointer__c = lineItem.ElixirSuite__Diagnosis_Pointer__c + ','+string.fromCharArray(new List<Integer> {k}); 
                                            }else{
                                                lineItem.ElixirSuite__Diagnosis_Pointer__c = string.fromCharArray(new List<Integer> {k});
                                            }  
                                            break;
                                        }  
                                    }
                                    
                                }
                            }
                            
                            
                        }
                        //
                        
                        j++;
                        lineItem.ElixirSuite__Procedure__c =eachProc.id;
                        lineItem.ElixirSuite__Procedure_Charge__c = eachProc.ElixirSuite__Charges__c;
                        lineItem.ElixirSuite__CPT_HCPCS_Code__c = eachProc.Name;
                        lineItem.ElixirSuite__From_Date_Of_Service__c = Date.valueOf(eachProc.ElixirSuite__From_Date_of_Service__c);
                        lineItem.ElixirSuite__To_Date_Of_Service__c = Date.valueOf(eachProc.ElixirSuite__To_Date_Of_Service__c);
                        lineItem.ElixirSuite__Place_of_Service__c = eachProc.ElixirSuite__Place_Of_Service_Picklist__c!=null ? eachProc.ElixirSuite__Place_Of_Service_Picklist__c : '';
                        lineItem.ElixirSuite__Days_Units__c = eachProc.ElixirSuite__Days_Units__c;
                        lineItem.ElixirSuite__Place_of_Service_Code_s__c = eachProc.ElixirSuite__Place_Of_Service_Picklist__c!=null ? eachProc.ElixirSuite__Place_Of_Service_Picklist__c.substring(0,2) : ''; //Anusha
                        lineItem.ElixirSuite__Modifier_1__c= eachProc.ElixirSuite__Modifier1__r.Name;
                        lineItem.ElixirSuite__Modifier_2__c= eachProc.ElixirSuite__Modifier2__r.Name;
                        lineItem.ElixirSuite__Modifier_3__c= eachProc.ElixirSuite__Modifier3__r.Name;
                        lineItem.ElixirSuite__Modifier_4__c= eachProc.ElixirSuite__Modifier4__r.Name;
                        // adding rendering practitioner by jami for 11363
                        if(eachProc.ElixirSuite__Surgeon__c != null){
                            lineItem.ElixirSuite__Rendering_Provider_First_Name__c = eachProc.ElixirSuite__Surgeon__r.FirstName;
                            lineItem.ElixirSuite__Rendering_Provider_Last_Name__c = eachProc.ElixirSuite__Surgeon__r.LastName;
                            lineItem.ElixirSuite__Rendering_Provider_Taxonomy__c = eachProc.ElixirSuite__Surgeon__r.ElixirSuite__Taxonomy__c;
                            lineItem.ElixirSuite__Rendering_Provider_NPI__c = eachProc.ElixirSuite__Surgeon__r.ElixirSuite__Practitioner_NPI__c;
                            lineItem.ElixirSuite__Rendering_Provider_Non_NPI__c = eachProc.ElixirSuite__Surgeon__r.ElixirSuite__Tax_Id__c;
                            String street = '';
                            String city = '';
                            String state = '';
                            String postalCode = '';
                            String country = '';
                            if(eachProc.ElixirSuite__Surgeon__r.MailingStreet != null){
                                street = eachProc.ElixirSuite__Surgeon__r.MailingStreet;
                            }
                            if(eachProc.ElixirSuite__Surgeon__r.MailingCity != null){
                                city = eachProc.ElixirSuite__Surgeon__r.MailingCity;
                            }
                            if(eachProc.ElixirSuite__Surgeon__r.MailingState != null){
                                state = eachProc.ElixirSuite__Surgeon__r.MailingState;
                            }
                            if(eachProc.ElixirSuite__Surgeon__r.MailingPostalCode != null){
                                postalCode = eachProc.ElixirSuite__Surgeon__r.MailingPostalCode;
                            }
                            if(eachProc.ElixirSuite__Surgeon__r.MailingCountry != null){
                                country = eachProc.ElixirSuite__Surgeon__r.MailingCountry;
                            }
                            String mailingAddress = street + '\n' +
                                city + ', ' + 
                                state + ' ' +
                                postalCode + '\n' +
                                country;
                            lineItem.ElixirSuite__Rendering_Provider_Address__c =  mailingAddress;
                            
                            if(!rendInfoCheck){
                                rendInfoCheck = true; 
                                claimData.ElixirSuite__Rendering_Provider_First_Name__c = eachProc.ElixirSuite__Surgeon__r.FirstName;
                                claimData.ElixirSuite__Rendering_Provider_Last_Name__c = eachProc.ElixirSuite__Surgeon__r.LastName;
                                claimData.ElixirSuite__Rendering_Provider_Taxonomy__c = eachProc.ElixirSuite__Surgeon__r.ElixirSuite__Taxonomy__c;
                                claimData.ElixirSuite__Rendering_Provider_NPI__c =  eachProc.ElixirSuite__Surgeon__r.ElixirSuite__Practitioner_NPI__c;
                                claimData.ElixirSuite__Rendering_Provider_Tax_Id__c = eachProc.ElixirSuite__Surgeon__r.ElixirSuite__Tax_Id__c;
                                claimData.ElixirSuite__Rendering_Provider_Address__c =  mailingAddress;
                            }
                            
                        }
                        lineItemsToUpdate.add(lineItem);
                        
                        
                        if(eachProc.ElixirSuite__Days_Units__c != null && eachProc.ElixirSuite__Days_Units__c  !=0 && eachProc.ElixirSuite__Charges__c != null){
                            claimCharge += (eachProc.ElixirSuite__Days_Units__c * eachProc.ElixirSuite__Charges__c);  
                        }else if(eachProc.ElixirSuite__Charges__c != null){
                            claimCharge += eachProc.ElixirSuite__Charges__c ;    
                        }
                                                claimData.ElixirSuite__Total_Charge__c = claimCharge;
                        updateClaimData.put(claimData.Id,claimData);
                    }
                    
                    if(j==6){
                        i++;
                        j=0;
                        claimCharge =0;
                        rendInfoCheck = false;
                    }
                }
            }
                     
            if(!lineItemsToUpdate.isEmpty() && lineItemsToUpdate.size()  > 0){
                
                
                DMLManager.insertAsUser(lineItemsToUpdate);   
            }
            
            
            if(!updateClaimData.isEmpty() && updateClaimData.size() > 0){
                DMLManager.updateAsUser(updateClaimData.values());
            }
                        
            for(Procedure__c proc : procList){
                
                if(proclaimMap!=null && proclaimMap.get(proc.Id)!=null){
                    proc.Claim__c = proclaimMap.get(proc.Id) ; 
                    proc.ElixirSuite__Claim_Generation__c = true;
                }
            }
            if(procList != null && procList.size() > 0){
                DMLManager.updateAsUser(procList);
            }
      }catch(exception e){
        ExceptionLog.logError(e);
    }  
    }
}