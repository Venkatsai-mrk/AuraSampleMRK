
/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 11-08-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class XMLParserClass{

public static void dummyMethod(){}
    
    /*
    public Map<String, String> xmlDataMap = new Map<String,String>(); 

    public String generateXML(){
		system.debug('doc');
        Dom.Document doc = new Dom.Document();
		system.debug('doc1');
        Dom.Xmlnode rootNode = doc.createRootElement('Claims', null, null);
        system.debug('doc2');
        Dom.Xmlnode headerNode = rootNode.addChildElement('claim', null, null);
		system.debug('doc3');
        //assign header attributes
        
        list<Claim__c> ClaimToPost = new list<Claim__c>();
        ClaimToPost=[select id,Accept_Assignment__c,Additional_Claim_Information__c,Amount_Paid__c,Any_Other_Health_Benefit_Plan__c,Billing_Provider_Info__c
                    ,Claim_Codes__c,Name,Claim_Status__c,Date_Of_Current_Illness__c,Dates_Patient_Unable_To_Work__c,Federal_Tax_Id_Number__c
                     ,Hospitalization_Dates__c,Insurance_Plan_Name__c,Other_Insurance_Plan_Name__c,Insurance_Type__c,Insured_Authorized_Person_Signature__c
                     ,Insured_Address__c,Insured_City__c,Insured_DOB__c,Insured_Policy__c,Insured_Sex__c,Insured_State__c,Insured_Telephone__c,Insured_Zipcode__c
                     ,Insured_s_Name__c,Insured_s_ID_Number__c,Name_of_referring_provider_Other_sourc__c,NPI__c,Other_Claim_Id__c,Other_Date__c,Other_Insured_s_Name__c
                     ,Other_Insured_s_Policy_Group_Number__c,Outside_Lab__c,Account__c,Patient_Condition_Related_To_Accident__c,Patient_Condition_Related_To_Employment__c
                     ,Patient_Condition_to_Other_Accident__c,Patient_DOB__c,Patient_Name__c,Patient_Relationship_to_Insured__c,Patient_Sex__c,Patient_Signature__c,Patient_s_Phone__c,
                     Patient_s_City__c,Patient_s_State__c,Patient_s_Zipcode__c,Total_Charge__c,Referring_Physician_Signature__c,Reserved_For_NUCC_Use1__c,Reserved_For_NUCC_Use2__c,
                     Reserved_For_NUCC_Use3__c,Service_Facility_Location_Information__c,Billing_Provider_Name__c,Billing_Provider_City__c,Billing_Provider_Address_1__c,Billing_Provider_State__c
                     ,Billing_Provider_Zip__c,Bill_Phone__c,First_Diagnosis__c,Billing_Provider_Tax_ID__c,Billing_Provider_Tax_ID_Type__c,Other_Payer_Name__c,Payer_ID__c,Diagnosis_Reference__c,
                     Charge_Amount__c,From_Date__c,Thru_Date__c,Units__c,Procedure_Code__c,Auto_Accident_Related__c,Employment_Related__c,Insured_Country_Code__c,Patient_Country_Code__c
                     ,Place_of_Service__c,Patient_s_Address__c
                     from Claim__c WITH SECURITY_ENFORCED LIMIT 49999];

        headerNode.setAttribute('pcn', ClaimToPost[0].Account__c);
        headerNode.setAttribute('pat_name_l', 'ClaimToPost[0]');
        headerNode.setAttribute('pat_name_f', 'ClaimToPost[0]');
        headerNode.setAttribute('bill_npi', ClaimToPost[0].NPI__c);
        headerNode.setAttribute('payerid', ClaimToPost[0].Payer_ID__c);
        headerNode.setAttribute('payer_name', ClaimToPost[0].Other_Payer_Name__c);
        headerNode.setAttribute('ins_number', 'ClaimToPost[0]');
        headerNode.setAttribute('pat_dob', String.Valueof(ClaimToPost[0].Patient_DOB__c));
        headerNode.setAttribute('pat_sex', ClaimToPost[0].Patient_Sex__c);
        headerNode.setAttribute('ins_name_f', 'ClaimToPost[0]');
        headerNode.setAttribute('ins_name_l', 'ClaimToPost[0]');
        headerNode.setAttribute('payer_order', 'ClaimToPost[0]');
        headerNode.setAttribute('pat_addr_1', ClaimToPost[0].Patient_s_Address__c);
        headerNode.setAttribute('pat_city', ClaimToPost[0].Patient_s_City__c);
        headerNode.setAttribute('pat_country', ClaimToPost[0].Patient_Country_Code__c);
        headerNode.setAttribute('pat_state', ClaimToPost[0].Patient_s_State__c);
        headerNode.setAttribute('pat_zip', String.ValueOf(ClaimToPost[0].Patient_s_Zipcode__c));
        headerNode.setAttribute('pat_rel', ClaimToPost[0].Patient_Relationship_to_Insured__c);
        headerNode.setAttribute('ins_addr_1', ClaimToPost[0].Insured_Address__c);
        headerNode.setAttribute('ins_city', ClaimToPost[0].Insured_City__c);
        headerNode.setAttribute('ins_country', ClaimToPost[0].Insured_Country_Code__c);
        headerNode.setAttribute('ins_state', ClaimToPost[0].Insured_State__c);
        headerNode.setAttribute('ins_zip', String.ValueOf(ClaimToPost[0].Insured_Zipcode__c));
        headerNode.setAttribute('employment_related', ClaimToPost[0].Employment_Related__c);
        headerNode.setAttribute('auto_accident', ClaimToPost[0].Auto_Accident_Related__c);
        headerNode.setAttribute('ins_dob', String.ValueOf(ClaimToPost[0].Insured_DOB__c));
        headerNode.setAttribute('ins_sex', ClaimToPost[0].Insured_Sex__c);
        headerNode.setAttribute('place_of_service_1', ClaimToPost[0].Place_of_Service__c);
        headerNode.setAttribute('bill_taxid', ClaimToPost[0].Billing_Provider_Tax_ID__c);
        headerNode.setAttribute('bill_taxid_type', ClaimToPost[0].Billing_Provider_Tax_ID_Type__c);
        headerNode.setAttribute('accept_assign', ClaimToPost[0].Accept_Assignment__c);
        headerNode.setAttribute('total_charge', String.ValueOf(ClaimToPost[0].Total_Charge__c));
        headerNode.setAttribute('amount_paid',  String.ValueOf(ClaimToPost[0].Amount_Paid__c));
        headerNode.setAttribute('bill_name', ClaimToPost[0].Billing_Provider_Name__c);
        headerNode.setAttribute('bill_addr_1', ClaimToPost[0].Billing_Provider_Address_1__c);
        headerNode.setAttribute('bill_city', ClaimToPost[0].Billing_Provider_City__c);
        headerNode.setAttribute('bill_state', ClaimToPost[0].Billing_Provider_State__c);
        headerNode.setAttribute('bill_zip', ClaimToPost[0].Billing_Provider_Zip__c);
        headerNode.setAttribute('bill_phone', ClaimToPost[0].Bill_Phone__c);
        headerNode.setAttribute('diag_1', ClaimToPost[0].First_Diagnosis__c);
        
        Dom.Xmlnode childNode = headerNode.addChildElement('Charge', null, null);

        childNode.setAttribute('proc_code',ClaimToPost[0].Procedure_Code__c);
        childNode.setAttribute('units',ClaimToPost[0].Units__c);
        childNode.setAttribute('from_date',String.ValueOf(ClaimToPost[0].From_Date__c));
        childNode.setAttribute('thru_date',String.ValueOf(ClaimToPost[0].Thru_Date__c));
        childNode.setAttribute('charge',ClaimToPost[0].Charge_Amount__c);
        childNode.setAttribute('diag_ref',ClaimToPost[0].Diagnosis_Reference__c);
        
		SYSTEM.debug('KK'+doc.toXmlString());
        return doc.toXmlString();
    }

    private void iterateThroughXML(DOM.XMLNode node){

      system.debug('lll'+node.getChildElements());
        
       
                  if (node.getAttributeCount() > 0) {
                  xmlDataMap.put(node.getAttributeValue(node.getAttributeKeyAt(0), node.getAttributeKeyNsAt(0)), node.getAttributeValue(node.getAttributeKeyAt(1), node.getAttributeKeyNsAt(1)));
                }
            

            for (Dom.XMLNode child: node.getChildElements())
              System.debug(child.getText());
           }

    public void parserXML(String toParse){

        xmlDataMap = new Map<String,String>();
        DOM.Document doc = new DOM.Document();
        
        try{
        
            doc.load(toParse);
            DOM.XMLNode root = doc.getRootElement();
            system.debug(root.getChildElement('claim', null));
           
            iterateThroughXML(root);
        }catch(Exception ex){

            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.Error, ex.getMessage());
            ApexPages.addMessage(msg);
       } 
    }
*/
}