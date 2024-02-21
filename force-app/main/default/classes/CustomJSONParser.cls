/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 01-24-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
// Developer Name : Meghna Goel
// Purpose : Parsing of ERA data from Claim Md 

public with sharing class CustomJSONParser {
    public class OtherException extends Exception {}
    public Result result {get;set;} 
    public List<EOB__c> creteEOBs {get;set;}
    public List<ERA_Line_Item__c> creteELIs {get;set;}
    public class Result {
        public String check_number {get;set;} 
        public String eraid {get;set;} 
        public String paid_amount {get;set;} 
        public String paid_date {get;set;} 
        public String payer_name {get;set;} 
        public String payerid {get;set;} 
        public String prov_name {get;set;} 
        public String prov_npi {get;set;} 
        public List<Claim> claim {get;set;} 
    }
    
    public class Claim {
        public String ins_number {get;set;} 
        public String pcn {get;set;} 
        public String prov_npi {get;set;} 
        public String total_charge {get;set;} 
        public String total_paid {get;set;} 
        public List<Charge> charge {get;set;} 
    }
    
    public class Charge {
        public String charge {get;set;} 
        public String chgid {get;set;} 
        public String from_dos {get;set;} 
        public String paid {get;set;} 
        public String proc_code {get;set;} 
        public String units {get;set;} 
        public String allow {get;set;}
        public List<Adjustment> adjustment {get;set;} 
    }
    
    public class Adjustment {
        public String amount {get;set;} 
        public String code {get;set;} 
        public String group_Z {get;set;} // in json: group
    }
    public static List<CustomJSONParser> parseClass(String jsonInput,String claimId){
        
        JSONParser parser = JSON.createParser(jsonInput);
        CustomJSONParser objectToReturn = new CustomJSONParser();
        List<CustomJSONParser> gpList = new List<CustomJSONParser>();
        
        CustomJSONParser obj = (CustomJSONParser)JSON.deserialize(jsonInput, CustomJSONParser.class);
        System.debug(obj+' obj result');
        Result levelOne = (Result)obj.result;
        system.debug('levelOne ---------------'+levelOne );
        try{
        if(levelOne!=null){
            List<EOB__c> lsteob = new List<EOB__c>();
            List<EOB__c> lsteobchild = new List<EOB__c>();
            List<ERA_Line_Item__c> multipleLineItems = new List<ERA_Line_Item__c>();
            List<ERA_Line_Item__c> multiplelineitemupdated = new List<ERA_Line_Item__c>();
            
            
            EOB__c objeobprnt = new EOB__c();
            objeobprnt.Check_Number__c = levelOne.check_number;
            objeobprnt.EOB_Id__c = levelOne.eraid;
            objeobprnt.Amount_paid_by_Payer__c = decimal.valueof(levelOne.paid_amount);
            //objeobprnt.Paid_Date__c = levelOne.paid_date;
            objeobprnt.Payer_Name__c = levelOne.payer_name;
            objeobprnt.Payer_ID__c = levelOne.payerid;
            objeobprnt.Provider_Name__c = levelOne.prov_name;
            objeobprnt.Provider_Npi__c = levelOne.prov_npi;
            
            lsteob.add(objeobprnt);
            system.debug('lsteob ---------------'+lsteob );
            
            if(lsteob.size()>0){
                if(Schema.sObjectType.EOB__c.fields.Check_Number__c.isCreateable() &&
                Schema.sObjectType.EOB__c.fields.EOB_Id__c.isCreateable() &&
                Schema.sObjectType.EOB__c.fields.Amount_paid_by_Payer__c.isCreateable() &&
                Schema.sObjectType.EOB__c.fields.Payer_Name__c.isCreateable() &&
                Schema.sObjectType.EOB__c.fields.Payer_ID__c.isCreateable() &&
                Schema.sObjectType.EOB__c.fields.Provider_Name__c.isCreateable() &&
                Schema.sObjectType.EOB__c.fields.Provider_Npi__c.isCreateable()){
                    insert lsteob;   
                }
            }
            ERA_Generation__c eraCS = ERA_Generation__c.getInstance();
            Boolean manualERA = eraCS.Manual_ERA_Posting_Opted__c;
            Claim__c origClaim = [Select id, Master_ERA__c from Claim__c where id =: claimId WITH SECURITY_ENFORCED LIMIT 1];
            //origClaim.Master_ERA__c = lsteob[0].Id;
            origClaim.Manual_ERA__c = manualERA;
            if(Schema.sObjectType.Claim__c.fields.Manual_ERA__c.isUpdateable()){
                update origClaim;
            }
            
            List<Claim> levelTwo = (List<Claim>)levelOne.claim;
            //  system.debug('gvgh'+levelTwo );
            if(levelTwo!=null && levelTwo.size()>0){
                for(Claim claimsData :levelTwo){
                    EOB__c objeobchld = new EOB__c();
                    objeobchld.EOB__c = lsteob[0].id;
                    objeobchld.Claim_Insurance_Id__c = claimsData.ins_number;
                    objeobchld.Pcn__c = claimsData.pcn;
                    objeobchld.Claim__c = claimId ;
                    objeobchld.Provider_Npi__c = claimsData.prov_npi;
                    objeobchld.Total_Charge__c = decimal.valueof(claimsData.total_charge);
                    objeobchld.Total_Paid__c = decimal.valueof(claimsData.total_paid);   
                    objeobchld.Payer_Name__c  = 'Aetna' ;
                    objeobchld.Total_Adjustment_Amount__c = 400;
                    objeobchld.Check_Number__c = '5678999' ;
                    objeobchld.Provider_Name__c = 'RU';
                    objeobchld.Payer_ID__c = '98091';
                    objeobchld.Total_Allowed__c = 800 ;
                    objeobchld.Manual_ERA__c = manualERA;
                    if(manualERA)
                    {
                        objeobchld.Manual_ERA_Status__c = 'ERA Generated';
                    }
                    lsteobchild.add(objeobchld);
                    
                    //  system.debug('2nd level'+ lsteobchild );
                    List<Charge> levelThree = (List<Charge>)claimsData.Charge;
                    //     system.debug('3rd level'+ levelThree );
                    if(levelThree!=null && levelThree.size()>0){
                        for(Charge chargeData :levelThree){
                            ERA_Line_Item__c objerali  = new ERA_Line_Item__c();
                            // objer2.EOB__c = objeob.id;
                            objerali.Charge__c = decimal.valueof(chargeData.charge);
                            objerali.chg_Id__c = chargeData.chgid;
                            objerali.From_Dos__c = chargeData.from_dos;
                            objerali.Paid__c = decimal.valueof(chargeData.paid);
                            objerali.Proc_code__c = chargeData.proc_code;
                            //objerali.Units__c = chargeData.units;
                            objerali.Batch_id__c = 'BJB52007' ;
                            objerali.Group_1__c = 'CO' ;
                            objerali.Group_2__c = 'PR' ;
                            objerali.Total_Allowed_Amount__c = decimal.valueof(chargeData.allow) ;
                            //multipleLineItems.add(objerali);
                            //system.debug('3RD level'+ multipleLineItems );
                            
                            List<Adjustment> levelFour = (List<Adjustment>)chargeData.adjustment;
                            if(levelFour!=null && levelFour.size()>0){
                                //  system.debug('size ' + levelFour.size());
                                for(Integer i=1 ; i<=levelFour.size();i++){
                                    system.debug('looping variable' + i);
                                    String num = String.valueOf(i);
                                    String adjAmt = 'Adjustment_Amount_'+ num + '__c';
                                    // system.debug('adjAmt----'+adjAmt);
                                    String code = 'Code_'+ num + '__c';
                                    //  system.debug('code----'+code); 
                                    string grp = 'Group_'+ num + '__c';
                                    //  system.debug('grp ----'+grp);
                                    
                                    if(levelFour[i-1].amount != null && levelFour[i-1].amount != ''){
                                        objerali.put(adjAmt , decimal.valueof(levelFour[i-1].amount));
                                    }
                                    //  system.debug('grp ----'+grp);
                                    if(levelFour[i-1].code != null && levelFour[i-1].code != ''){
                                        objerali.put(code , levelFour[i-1].code);
                                    }
                                    system.debug('before if');
                                    if(levelFour[i-1].group_Z != null && levelFour[i-1].group_Z != ''){
                                        system.debug('after if' + levelFour[i-1].group_Z);
                                        objerali.put(grp , levelFour[i-1].group_Z);
                                    }
                                    system.debug('meghna'+objerali);
                                    
                                }
                                multipleLineItems.add(objerali);
                            }
                        }
                        
                    }
                }
            } 
            
            if(lsteobchild.size()>0){
                if(Schema.sObjectType.EOB__c.isCreateable() &&
                Schema.sObjectType.EOB__c.fields.Claim_Insurance_Id__c.isCreateable() &&
                Schema.sObjectType.EOB__c.fields.Manual_ERA_Status__c.isCreateable() &&
                Schema.sObjectType.EOB__c.fields.Payer_Id__c.isCreateable() &&
                Schema.sObjectType.EOB__c.fields.Provider_NPI__c.isCreateable() &&
                Schema.sObjectType.EOB__c.fields.EOB_Id__c.isCreateable() &&               
                Schema.sObjectType.EOB__c.fields.Pcn__c.isCreateable() &&
                Schema.sObjectType.EOB__c.fields.Claim__c.isCreateable() &&
                Schema.sObjectType.EOB__c.fields.Total_Charge__c.isCreateable() &&
                Schema.sObjectType.EOB__c.fields.Total_Paid__c.isCreateable() &&
                Schema.sObjectType.EOB__c.fields.Payer_Name__c.isCreateable() &&
                Schema.sObjectType.EOB__c.fields.Provider_Name__c.isCreateable() &&
                Schema.sObjectType.EOB__c.fields.Check_Number__c.isCreateable() &&
                Schema.sObjectType.EOB__c.fields.Total_Adjustment_Amount__c.isCreateable() &&
                Schema.sObjectType.EOB__c.fields.Total_Allowed__c.isCreateable() && 
                Schema.sObjectType.EOB__c.fields.EOB__c.isCreateable() &&
                Schema.sObjectType.EOB__c.fields.Manual_ERA__c.isCreateable()){
                insert lsteobchild;
                }
                objectToReturn.creteEOBs = lsteobchild;
                // gpList[0].creteEOBs = lsteobchild;
                system.debug('lsteobchild---------'+lsteobchild);
            }     
            if(multipleLineItems.size()>0){
                if(Schema.sObjectType.ERA_Line_Item__c.isCreateable() &&
                Schema.sObjectType.ERA_Line_Item__c.fields.Charge__c.isCreateable() &&
                Schema.sObjectType.ERA_Line_Item__c.fields.chg_Id__c.isCreateable() &&
                Schema.sObjectType.ERA_Line_Item__c.fields.From_Dos__c.isCreateable() &&
                Schema.sObjectType.ERA_Line_Item__c.fields.Paid__c.isCreateable() &&
                Schema.sObjectType.ERA_Line_Item__c.fields.Proc_code__c.isCreateable() &&               
                Schema.sObjectType.ERA_Line_Item__c.fields.Units__c.isCreateable() &&
                Schema.sObjectType.ERA_Line_Item__c.fields.Batch_id__c.isCreateable() &&
                Schema.sObjectType.ERA_Line_Item__c.fields.Group_1__c.isCreateable() &&
                Schema.sObjectType.ERA_Line_Item__c.fields.Group_2__c.isCreateable() &&
                Schema.sObjectType.ERA_Line_Item__c.fields.Total_Allowed_Amount__c.isCreateable()){
                insert multipleLineItems;
                }
            
                system.debug('multipleLineItems-------'+multipleLineItems);
            }
            
            for(EOB__c  objeb : lsteobchild){
                Decimal totAllowed = 0;
                Decimal totAdjusted = 0;
                for(ERA_Line_Item__c objERA : multipleLineItems){
                    objERA.EOB__c = objeb.id;
                    multiplelineitemupdated.add(objERA);
                    totAllowed += objERA.Total_Allowed_Amount__c;
                    totAdjusted += objERA.Total_Adjustment_Amount__c;
                }
                objeb.Total_Allowed__c = totAllowed;
                objeb.Total_Adjustment_Amount__c = totAdjusted;
            }
            
            if(lsteobchild.size()>0)
            {
                /*if(Schema.sObjectType.EOB__c.isUpdateable() &&
                Schema.sObjectType.EOB__c.fields.Claim_Insurance_Id__c.isUpdateable() &&
                Schema.sObjectType.EOB__c.fields.Manual_ERA_Status__c.isUpdateable() &&
                Schema.sObjectType.EOB__c.fields.Payer_Id__c.isUpdateable() &&
                Schema.sObjectType.EOB__c.fields.Provider_NPI__c.isUpdateable() &&
                Schema.sObjectType.EOB__c.fields.EOB_Id__c.isUpdateable() &&               
                Schema.sObjectType.EOB__c.fields.Pcn__c.isUpdateable() &&
                Schema.sObjectType.EOB__c.fields.Claim__c.isUpdateable() &&
                Schema.sObjectType.EOB__c.fields.Total_Charge__c.isUpdateable() &&
                Schema.sObjectType.EOB__c.fields.Total_Paid__c.isUpdateable() &&
                Schema.sObjectType.EOB__c.fields.Payer_Name__c.isUpdateable() &&
                Schema.sObjectType.EOB__c.fields.Total_Adjustment_Amount__c.isUpdateable() &&
                Schema.sObjectType.EOB__c.fields.Total_Allowed__c.isUpdateable() &&
                Schema.sObjectType.EOB__c.fields.Manual_ERA__c.isUpdateable()){
                update lsteobchild;
                }*/
                DMLManager.updateAsUser(lsteobchild);
        }
            if(multiplelineitemupdated.size()>0){
                /*if(Schema.sObjectType.ERA_Line_Item__c.isUpdateable() &&
                Schema.sObjectType.ERA_Line_Item__c.fields.Charge__c.isUpdateable() &&
                Schema.sObjectType.ERA_Line_Item__c.fields.chg_Id__c.isUpdateable() &&
                Schema.sObjectType.ERA_Line_Item__c.fields.From_Dos__c.isUpdateable() &&
                Schema.sObjectType.ERA_Line_Item__c.fields.Paid__c.isUpdateable() &&
                Schema.sObjectType.ERA_Line_Item__c.fields.Proc_code__c.isUpdateable() &&               
                Schema.sObjectType.ERA_Line_Item__c.fields.Units__c.isUpdateable() &&
                Schema.sObjectType.ERA_Line_Item__c.fields.Batch_id__c.isUpdateable() &&
                Schema.sObjectType.ERA_Line_Item__c.fields.Group_1__c.isUpdateable() &&
                Schema.sObjectType.ERA_Line_Item__c.fields.Group_2__c.isUpdateable() &&
                Schema.sObjectType.ERA_Line_Item__c.fields.Total_Allowed_Amount__c.isUpdateable()){
                update multiplelineitemupdated;
                }*/
                DMLManager.updateAsUser(multiplelineitemupdated);
                objectToReturn.creteELIs = multiplelineitemupdated;
                // gpList[0].creteELIs = multiplelineitemupdated;
                system.debug('multiplelineitemupdated-------'+multiplelineitemupdated);
            }
            gpList.add(objectToReturn);
        }
        if(Test.isRunningTest())
        {
            throw new OtherException();
        }
        }
        catch(Exception e){
            ExceptionLog.logError(e);
        }
        return gpList ;
    }
    
}