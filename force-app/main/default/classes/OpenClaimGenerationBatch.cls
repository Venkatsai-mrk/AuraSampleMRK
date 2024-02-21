/*Author name           :  Abhishek Singh
* Purpose 	            :  To automatically create claim records for open procedures
* Schedule              :  Scheduling on the basis of days and hour 
* Test Class            :  OpenClaimGenerationBatch_Test
* Schedular class       :  OpenClaimGenerationBatch_schedule
* Created Date          :  15-Oct-2020
* Last Modified Date    :  15-Oct-2020
*/

public with sharing class OpenClaimGenerationBatch implements Database.Batchable<sObject> {
	
    public Database.QueryLocator start(Database.BatchableContext bc){
        
        Integer days;
        Integer hours;
        List<CMS_1500_Claim_Generation__c> CMSlist = [SELECT ID, days__c, After_every_hours__c, Active__c,No_of_Days_Open_Procedure__c,No_of_Hours_Open_Procedure__c 
        FROM CMS_1500_Claim_Generation__c 
        WHERE Active__c = true WITH SECURITY_ENFORCED];
        for(CMS_1500_Claim_Generation__c paStGIn : CMSlist)
        {
            if(paStGIn.No_of_Days_Open_Procedure__c != Null)
            {
                days = (Integer)paStGIn.No_of_Days_Open_Procedure__c;
            }
            if(paStGIn.No_of_Hours_Open_Procedure__c != Null)
            {
                hours = (Integer)paStGIn.No_of_Hours_Open_Procedure__c;
            }
        }
        DateTime dateInterval;
        if(days != Null)
        {
            dateInterval = System.now().addDays(-days);
        }
        if(hours != Null)
        {
            dateInterval = System.now().addHours(-hours);
        }
		
		//String WhereClause = 'Claim__c = null';
        //Id accId = 'a082x0000006HzsAAE';
        String WhereClause = '';
        if(!Test.isRunningTest()){
        WhereClause = ' Where ElixirSuite__Claim__c = null AND ElixirSuite__Generate_Claim__c = true AND ElixirSuite__Is_Billable__c = true AND ElixirSuite__Account__c != null AND CreatedDate  >= :dateInterval';
}
        //Date tod = System.today();//For testing
        //String WhereClause = 'Claim__c = null AND Account__c != null AND CreatedDate  >= :tod'; //For testing
		String query = 'SELECT Id, Name, ElixirSuite__Claim__c, ElixirSuite__CPT_HCPCS_Code__c, ElixirSuite__From_Date__c,ElixirSuite__Is_Billable__c,ElixirSuite__Generate_Claim__c, CreatedDate,ElixirSuite__Account__c, ElixirSuite__To_Date__c FROM ElixirSuite__Procedure__c  ' + WhereClause;
        
        return Database.getQueryLocator(query);
	} 
	
	public void execute(Database.BatchableContext BC, list<Procedure__c> scope){
		/*
		set<Id> accId = new set<Id>();
		set<Id> proId = new set<Id>();
		list<Claim_Line_Items__c> claimlineitemlist = new list<Claim_Line_Items__c>();
		Map<Id, Claim__c> ClaimMap = new Map<Id, Claim__c>();
		Map<Id, Procedure__c> procMap = new Map<Id, Procedure__c>();
		Map<Id, Claim_Line_Items__c> ClaimlineMap = new Map<Id, Claim_Line_Items__c>();
		Map<String, Actual_Price__c> ActualPriceMap = new Map<String, Actual_Price__c>();
		Map<String, Contracted_Price__c> ContractedPriceMap = new Map<String, Contracted_Price__c>();
		list<Procedure__c> AccProlist = new list<Procedure__c>();
		list<Procedure__c> Proclist = new list<Procedure__c>();
		Map<Id, list<Procedure__c>> AccountProcMap = new Map<Id, list<Procedure__c>>();
        
        Map<Id, List<Claim__c>> AccountClaimMap = new Map<Id, List<Claim__c>>();
        Map<Id, Integer> accountClaimsCountMap = new Map<Id, Integer>();
        
        //Getting list of Procedures for each patient account
		for(Procedure__c pro : scope){
			proId.add(pro.Id);
			accId.add(pro.Account__c);
			if(AccountProcMap.containsKey(pro.Account__c) && AccountProcMap.get(pro.Account__c) != null) {
				List<Procedure__c> prolist = AccountProcMap.get(pro.Account__c);
				//AccProlist.add(pro);
				proList.add(pro);
				//AccountProcMap.put(pro.Account__c,AccProlist); 
				AccountProcMap.put(pro.Account__c,proList); 
			}   
			else{
				AccountProcMap.put(pro.Account__c, new List<Procedure__c> {pro});
				ClaimMap.put(pro.Account__c, new Claim__c());
                AccountClaimMap.put(pro.Account__c, new List<Claim__c>());
			}
		}
        
            // List<Transactional_Data__c> lst_transData = new List<Transactional_Data__c>();
          Map<String,VOB__c> map_vobData = new Map<String,VOB__c>();
            //lst_transData = [SELECT Id, Insurance_Type__c, Insured_First_Name__c, Insured_Id_Number__c, Insured_Last_Name__c, Patient_Relationship_With_Insured__c,
                           //               Account__c, Active__c, CreatedDate, Name ,Auto_Accident__c,Employment__c,Is_there_another_Health_Benefit_Plan__c,Other_Accident__c,
                           //               Insured_Address__c,Insured_City__c,Insured_Policy_Group_FECA_Number__c,Insured_State__c,Insured_Telephone__c,Insured_Zipcode__c,OtherInsurancePlanName__c,
                           //               Other_Insured_Policy_Group_FECA_Number__c,Other_Insured_s_Name__c
                           //               FROM Transactional_Data__c where Account__c IN: accId AND Active__c = TRUE];
        //new modification
        for(VOB__c objVob : [Select Id,Payer__c,Account__c from VOB__c where Account__c IN:accId WITH SECURITY_ENFORCED])
        {
            map_vobData.put(objVob.Payer__c,objVob);
        }
        
                //patient payer from his details
           //List<Payor__c> relatedPayer = [SELECT Address__c, Id, Name, CreatedDate,Payer_Code__c, PayerType__c, State__c, City__c, Zipcode__c, Phone_Number__c, Transactional_Data__c, Procedure__c 
                                           // FROM Payor__c  WHERE Transactional_Data__c IN:lst_transData];
            
            //patient payer from his details- new modification
           List<Payor__c> relatedPayer = [SELECT Address__c, Id, Name, CreatedDate,Payer_Code__c, PayerType__c, State__c, City__c, Zip_Code__c, PhoneNumber__c, Procedure__c 
                                           FROM Payor__c  WHERE Id IN: map_vobData.keySet() WITH SECURITY_ENFORCED];
         
        	Set<String> providerCode = new Set<String>();
        	Set<String> payerCode = new Set<String>();

            for(Payor__c pay : relatedPayer){
                payerCode.add(pay.Payer_Code__c);
            }
                         
                        //get patient's provider info
            List<Provider__c> relatedProvider = [SELECT Id, Name, CreatedDate, 	Account__c,	Provider_Code__c FROM Provider__c 
                                                 where 	Account__c IN: accId WITH SECURITY_ENFORCED];
                       
            for(Provider__c pro : relatedProvider){
                providerCode.add(pro.Provider_Code__c);
            }
                
		//Getting actual price of the procedure to map it to claim line item Actual price field
		for(Actual_Price__c ActPrice : [Select Id, Procedure__c, Provider__r.Provider_Code__c,Procedure__r.CPT_HCPCS_Code__c,List_Price__c from Actual_Price__c where Provider__r.Provider_Code__c IN : providerCode]){
			ActualPriceMap.put(ActPrice.Procedure__r.CPT_HCPCS_Code__c, ActPrice);
		}
		
		//Getting actual price of the procedure to map it to claim line item Contracted price field
		for(Contracted_Price__c ConPrice : [Select Id, Procedure__c,Procedure__r.CPT_HCPCS_Code__c,payer__r.Payer_Code__c, Contracted_Amount__c from Contracted_Price__c where payer__r.Payer_Code__c IN : payerCode]){
			ContractedPriceMap.put(ConPrice.Procedure__r.CPT_HCPCS_Code__c, ConPrice);
		}
        
		for(Account acc : [SELECT id, 	
                   Name,	
                   Age__c, 
                   AccountNumber,	
                   First_Name__c,	
                   Gender__c,	
                   Last_Name__c,	
                   MRN_Number__c,	
                   Outstanding_Amount__c,
                   Patient_s_Birth_Date__c,	
                   Phone,	
                   Unallocated_Amount__c,
                   Profile_Picture__c,
                   Total_Patient_Responsibility__c, CreatedDate, ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode,ShippingCountry,
                   birthdate__c,BillingStreet, BillingCity, BillingState, BillingPostalCode,BillingCountry
                   from Account where Id IN:accId WITH SECURITY_ENFORCED]){
			
			//Inserting claim for specific patient account
			List<Procedure__c> lst_procedures = AccountProcMap.get(acc.Id);
            Integer noOfClaims = 0;
            if(lst_procedures.size() > 0  && lst_procedures.size() <= 6)
            {
                noOfClaims = 1;
            }
            else if(lst_procedures.size() > 6)
            {
                noOfClaims = lst_procedures.size()/6;
                Integer rem = math.mod(lst_procedures.size(),6);
                if(rem>0)
                {
                    noOfClaims = noOfClaims +1;
                }
            }
            accountClaimsCountMap.put(acc.Id,noOfClaims); //To store number of claims to be generated per Account
                        
            List<Claim__c> accClaimList = new List<Claim__c>();
            for(Integer i=1; i<=noOfClaims; i++)
            {
                Claim__c claim = new Claim__c();
                claim.Claim_Status__c = 'Saved';
                
                claim.Account__c = acc.Id;
                if(acc.Phone!= null){
                    claim.Patient_s_Phone__c = acc.Phone;
                }
                if(acc.Patient_s_Birth_Date__c!= null){
                    claim.Patient_DOB__c =acc.Patient_s_Birth_Date__c;
                }
                if(acc.Gender__c!= null && acc.Gender__c == 'Male'){
                    claim.Patient_Sex__c = 'M';
                }else{
                    claim.Patient_Sex__c = 'F';
                }
                if(acc.Name!= null){
                    claim.Patient_Name__c = acc.Name;
                }
                if(acc.BillingStreet!= null){
                    claim.Patient_s_Address__c = acc.BillingStreet;
                }
                if(acc.BillingState!= null){
                    claim.Patient_s_State__c = acc.BillingState;
                }
                if(acc.BillingCity!= null){
                    claim.Patient_s_City__c = acc.BillingCity;
                }
                if(acc.BillingPostalCode!= null){
                    claim.Patient_s_Zipcode__c =  decimal.valueOf(acc.BillingPostalCode) ;
                }
                accClaimList.add(claim);
            }
            AccountClaimMap.put(acc.Id,accClaimList);
        }

        List<Claim__c> claimsInsertList = new List<Claim__c>();
        if(AccountClaimMap.size()>0)
        {
            List<List<Claim__c>> clList = AccountClaimMap.values();
            claimsInsertList = clList[0];
            Database.insert(claimsInsertList,false);
            system.debug('AccountClaimMap.values()--'+claimsInsertList);
        }
		
        //Update Procedure records with inserted claim Id
	
        
        for(Claim__c clm : claimsInsertList){
			ClaimlineMap.put(clm.Id, new Claim_Line_Items__c());
		}
        
    
		//Inserting claim line Item
		List<Procedure__c> proceduresToUpdate = new List<Procedure__c>();
        List<Claim_Line_Items__c> clitemsToInsert = new List<Claim_Line_Items__c>();
		for(Id aId : AccountClaimMap.keySet())
        {
            List<Claim__c> clList = AccountClaimMap.get(aId);
            List<Procedure__c> lst_procedures = AccountProcMap.get(aId);
            Integer start=0, jump=0;
            Boolean count = true;
            for(Claim__c cl : clList){
               
                for(Integer i=start; i<lst_procedures.size(); i++)
                {
                    if(count==true && math.mod(i,6) == 0 && i!=0)
                    {
                        start = i;
                        count = false;
                        break;
                    }
                    else {
                        count = true;
                    }
                    Claim_Line_Items__c claimline = new Claim_Line_Items__c();
                    claimline.Claim__c = cl.Id;
                    if(ActualPriceMap.get(lst_procedures[i].CPT_HCPCS_Code__c)!= null && ActualPriceMap.get(lst_procedures[i].CPT_HCPCS_Code__c).List_Price__c!= null){
                        claimline.Procedure_Charge__c = ActualPriceMap.get(lst_procedures[i].CPT_HCPCS_Code__c).List_Price__c;
                    }
                    if(ContractedPriceMap.get(lst_procedures[i].CPT_HCPCS_Code__c)!= null && ContractedPriceMap.get(lst_procedures[i].CPT_HCPCS_Code__c).Contracted_Amount__c!= null){
                        claimline.Contracted_Amount__c = ContractedPriceMap.get(lst_procedures[i].CPT_HCPCS_Code__c).Contracted_Amount__c;
                    }
                    claimline.Total_Adjustment__c = 0;
                    claimline.Procedure__c = lst_procedures[i].Id;
                    claimline.CPT_HCPCS_Code__c = lst_procedures[i].CPT_HCPCS_Code__c;
                    claimline.To_Date__c = lst_procedures[i].To_Date__c;
                    claimline.From_Date__c = lst_procedures[i].From_Date__c;
                    clitemsToInsert.add(claimline);
                    
                    lst_procedures[i].Claim__c = cl.id;
                    proceduresToUpdate.add(lst_procedures[i]);
                }
			}
        }
		if(proceduresToUpdate.size()>0)
        {
            Database.update(proceduresToUpdate,false);
                    }
		if(clitemsToInsert.size()>0){
			Database.insert(clitemsToInsert, false);
					}
		*/
	}    
	public void finish(Database.BatchableContext BC){ 
		/*
		String schdays;
		String schhours;
		List<CMS_1500_Claim_Generation__c> CMSlist = [SELECT ID, days__c, After_every_hours__c, Active__c 
        FROM CMS_1500_Claim_Generation__c WHERE Active__c = true
        WITH SECURITY_ENFORCED];
		for(CMS_1500_Claim_Generation__c cms : CMSlist){ 
			Integer day = Integer.valueOf(cms.days__c);
            
            //Check for days value only in custom setting
			if(cms.days__c!= null && cms.After_every_hours__c== null){
				schdays = '0 0 1 '+day+' * ? *';
			}
            
            //Check for hours value only in custom setting
			if(cms.days__c== null && cms.After_every_hours__c!= null){
				Integer hour = Integer.valueOf(cms.After_every_hours__c);
                schhours = '0 0 '+hour+'* ? * *';
			}
		}
        
		OpenClaimGenerationBatch_schedule schd = new OpenClaimGenerationBatch_schedule();
        
        //Scheduling on the basis of days
		if(schdays!= null){
			system.schedule('OpenClaimGenerationBatch', schdays, schd);
		}
        
        //Scheduling on the basis of hours
		if(schhours!= null){
			system.schedule('OpenClaimGenerationBatch', schhours, schd);
		}
		*/
	}
}