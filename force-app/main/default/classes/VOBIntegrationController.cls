/*
Created Date : 2 March 2021
Created By : Sonal Agarwal
Description : Apex class to post the patient's data to Claim MD and get back the insurance verification details
*/
public with sharing class VOBIntegrationController {
    @AuraEnabled
    public static Object checkValidDetails(String vobId)
    {
        Map<String, Object> args = new Map<String, Object>{
            'vobId'=>vobId
                };
                    VOBResponse wrap = new VOBResponse();
        Object Obj;
        List<Elixir_Pluggable_Classes__mdt> pluggableClass = new List<Elixir_Pluggable_Classes__mdt>();
        String virtualClassName;
        pluggableClass = [SELECT DeveloperName,Virtual_Class__c 
                          FROM Elixir_Pluggable_Classes__mdt 
                          WHERE DeveloperName='NewClaimMDIntegration'
                          WITH SECURITY_ENFORCED];
        if(pluggableClass != null && !pluggableClass.isEmpty()){
            
            virtualClassName = pluggableClass[0].Virtual_Class__c;
            
        }
        if(virtualClassName != '' && virtualClassName!=null){
            Callable cls = (Callable) Type.forName(virtualClassName).newInstance();
            Obj = cls.call('checkValidations',args);
            system.debug('obj' + obj);
              return Obj;
            
        }else{
            String mockRes = '{"result":{"elig":{"elig_result_date": "20230425","elig_result_time": "0008","eligid": "28277016","group_number": "202GROUP","ins_addr_1": "21 JUMP ST","ins_city": "MEMPHIS","ins_dob": "19750821","ins_name_f": "CHIQUITA","ins_name_l": "BROWN","ins_number": "12345678","ins_sex": "M","ins_state": "TN","ins_zip": "871012155","plan_begin_date": "20230326-20230525","plan_number": "PLAN101","benefit":[{"benefit_code": "30","benefit_coverage_code": "1","benefit_coverage_description": "Active Coverage","benefit_description": "Health Benefit Plan Coverage","benefit_notes": "FUNDING TYPE = FULLY INSURED","date_of_last_update": "20160702","insurance_plan": "AETNA CHOICE PLUS","insurance_type_code": "C1","insurance_type_description": "Commercial","entity_addr_1":"P.O. BOX 30555","entity_city":"SALT LAKE CITY","entity_code":"PR","entity_description":"Payer","entity_name":"AETNA","entity_state":"UT","entity_zip":"841300555"},{"benefit_amount": "0","benefit_code": "30","benefit_coverage_code": "C","benefit_coverage_description": "Deductible","benefit_description": "Health Benefit Plan Coverage","benefit_level_code": "FAM","benefit_level_description": "Family","benefit_period_code": "24","benefit_period_description": "Year to Date","inplan_network": "W"},{"benefit_amount": "0","benefit_code": "30","benefit_coverage_code": "C","benefit_coverage_description": "Deductible","benefit_description": "Health Benefit Plan Coverage","benefit_level_code": "IND","benefit_level_description": "Individual","benefit_period_code": "24","benefit_period_description": "Year to Date","inplan_network": "W"},{"benefit_amount": "0","benefit_code": "30","benefit_coverage_code": "G","benefit_coverage_description": "Out of Pocket (Stop Loss)","benefit_description": "Health Benefit Plan Coverage","benefit_level_code": "FAM","benefit_level_description": "Family","benefit_period_code": "24","benefit_period_description": "Year to Date","inplan_network": "W","insurance_type_code": "C1","insurance_type_description": "Commercial"},{"benefit_amount": "0","benefit_code": "30","benefit_coverage_code": "G","benefit_coverage_description": "Out of Pocket (Stop Loss)","benefit_description": "Health Benefit Plan Coverage","benefit_level_code": "IND","benefit_level_description": "Individual","benefit_period_code": "24","benefit_period_description": "Year to Date","inplan_network": "W","insurance_type_code": "C1","insurance_type_description": "Commercial"},{"benefit_amount": "3000","benefit_code": "30","benefit_coverage_code": "C","benefit_coverage_description": "Deductible","benefit_description": "Health Benefit Plan Coverage","benefit_level_code": "FAM","benefit_level_description": "Family","benefit_period_code": "23","benefit_period_description": "Calendar Year","inplan_network": "N"},{"benefit_amount": "0","benefit_code": "30","benefit_coverage_code": "C","benefit_coverage_description": "Deductible","benefit_description": "Health Benefit Plan Coverage","benefit_level_code": "IND","benefit_level_description": "Individual","benefit_period_code": "29","benefit_period_description": "Remaining","inplan_network": "Y"},{"benefit_amount": "9000","benefit_code": "30","benefit_coverage_code": "G","benefit_coverage_description": "Out of Pocket (Stop Loss)","benefit_description": "Health Benefit Plan Coverage","benefit_level_code": "FAM","benefit_level_description": "Family","benefit_period_code": "23","benefit_period_description": "Calendar Year","inplan_network": "N","insurance_type_code": "C1","insurance_type_description": "Commercial"},{"benefit_amount": "1500","benefit_code": "30","benefit_coverage_code": "C","benefit_coverage_description": "Deductible","benefit_description": "Health Benefit Plan Coverage","benefit_level_code": "IND","benefit_level_description": "Individual","benefit_period_code": "29","benefit_period_description": "Remaining","inplan_network": "N"},{"benefit_amount": "99999","benefit_code": "30","benefit_coverage_code": "G","benefit_coverage_description": "Out of Pocket (Stop Loss)","benefit_description": "Health Benefit Plan Coverage","benefit_level_code": "FAM","benefit_level_description": "Family","benefit_period_code": "29","benefit_period_description": "Remaining","inplan_network": "Y","insurance_type_code": "C1","insurance_type_description": "Commercial"},{"benefit_amount": "99999","benefit_code": "30","benefit_coverage_code": "G","benefit_coverage_description": "Out of Pocket (Stop Loss)","benefit_description": "Health Benefit Plan Coverage","benefit_level_code": "IND","benefit_level_description": "Individual","benefit_period_code": "29","benefit_period_description": "Remaining","inplan_network": "Y","insurance_type_code": "C1","insurance_type_description": "Commercial"},{"benefit_amount": "4500","benefit_code": "30","benefit_coverage_code": "G","benefit_coverage_description": "Out of Pocket (Stop Loss)","benefit_description": "Health Benefit Plan Coverage","benefit_level_code": "IND","benefit_level_description": "Individual","benefit_period_code": "23","benefit_period_description": "Calendar Year","inplan_network": "N","insurance_type_code": "C1","insurance_type_description": "Commercial"},{"benefit_amount": "99999","benefit_code": "30","benefit_coverage_code": "G","benefit_coverage_description": "Out of Pocket (Stop Loss)","benefit_description": "Health Benefit Plan Coverage","benefit_level_code": "IND","benefit_level_description": "Individual","benefit_period_code": "23","benefit_period_description": "Calendar Year","inplan_network": "Y","insurance_type_code": "C1","insurance_type_description": "Commercial"},{"benefit_amount": "1500","benefit_code": "30","benefit_coverage_code": "C","benefit_coverage_description": "Deductible","benefit_description": "Health Benefit Plan Coverage","benefit_level_code": "IND","benefit_level_description": "Individual","benefit_period_code": "23","benefit_period_description": "Calendar Year","inplan_network": "N"},{"benefit_amount": "3000","benefit_code": "30","benefit_coverage_code": "C","benefit_coverage_description": "Deductible","benefit_description": "Health Benefit Plan Coverage","benefit_level_code": "FAM","benefit_level_description": "Family","benefit_period_code": "29","benefit_period_description": "Remaining","inplan_network": "N"},{"benefit_amount": "0","benefit_code": "30","benefit_coverage_code": "C","benefit_coverage_description": "Deductible","benefit_description": "Health Benefit Plan Coverage","benefit_level_code": "FAM","benefit_level_description": "Family","benefit_period_code": "29","benefit_period_description": "Remaining","inplan_network": "Y"},{"benefit_amount": "9000","benefit_code": "30","benefit_coverage_code": "G","benefit_coverage_description": "Out of Pocket (Stop Loss)","benefit_description": "Health Benefit Plan Coverage","benefit_level_code": "FAM","benefit_level_description": "Family","benefit_period_code": "29","benefit_period_description": "Remaining","inplan_network": "N","insurance_type_code": "C1","insurance_type_description": "Commercial"},{"benefit_amount": "99999","benefit_code": "30","benefit_coverage_code": "G","benefit_coverage_description": "Out of Pocket (Stop Loss)","benefit_description": "Health Benefit Plan Coverage","benefit_level_code": "FAM","benefit_level_description": "Family","benefit_period_code": "23","benefit_period_description": "Calendar Year","inplan_network": "Y","insurance_type_code": "C1","insurance_type_description": "Commercial"},{"benefit_amount": "0","benefit_code": "30","benefit_coverage_code": "C","benefit_coverage_description": "Deductible","benefit_description": "Health Benefit Plan Coverage","benefit_level_code": "FAM","benefit_level_description": "Family","benefit_period_code": "23","benefit_period_description": "Calendar Year","inplan_network": "Y"},{"benefit_amount": "0","benefit_code": "30","benefit_coverage_code": "C","benefit_coverage_description": "Deductible","benefit_description": "Health Benefit Plan Coverage","benefit_level_code": "IND","benefit_level_description": "Individual","benefit_period_code": "23","benefit_period_description": "Calendar Year","inplan_network": "Y"},{"benefit_amount": "4500","benefit_code": "30","benefit_coverage_code": "G","benefit_coverage_description": "Out of Pocket (Stop Loss)","benefit_description": "Health Benefit Plan Coverage","benefit_level_code": "IND","benefit_level_description": "Individual","benefit_period_code": "29","benefit_period_description": "Remaining","inplan_network": "N","insurance_type_code": "C1","insurance_type_description": "Commercial"},{"benefit_code": "1","benefit_coverage_code": "1","benefit_coverage_description": "Active Coverage","benefit_description": "Medical Care","inplan_network": "W"},{"benefit_code": "33","benefit_coverage_code": "1","benefit_coverage_description": "Active Coverage","benefit_description": "Chiropractic","inplan_network": "W"},{"benefit_code": "47","benefit_coverage_code": "1","benefit_coverage_description": "Active Coverage","benefit_description": "Hospital","inplan_network": "W"},{"benefit_code": "48","benefit_coverage_code": "1","benefit_coverage_description": "Active Coverage","benefit_description": "Hospital - Inpatient","inplan_network": "W"},{"benefit_code": "50","benefit_coverage_code": "1","benefit_coverage_description": "Active Coverage","benefit_description": "Hospital - Outpatient","inplan_network": "W"},{"benefit_code": "86","benefit_coverage_code": "1","benefit_coverage_description": "Active Coverage","benefit_description": "Emergency Services","inplan_network": "W"},{"benefit_code": "98","benefit_coverage_code": "1","benefit_coverage_description": "Active Coverage","benefit_description": "Professional (Physician) Visit - Office","inplan_network": "W"},{"benefit_code": "AL","benefit_coverage_code": "1","benefit_coverage_description": "Active Coverage","benefit_description": "Vision (Optometry)","inplan_network": "W"},{"benefit_code": "MH","benefit_coverage_code": "1","benefit_coverage_description": "Active Coverage","benefit_description": "Mental Health","inplan_network": "W"},{"benefit_code": "PT","benefit_coverage_code": "1","benefit_coverage_description": "Active Coverage","benefit_description": "Physical Therapy","inplan_network": "W"},{"benefit_code": "UC","benefit_coverage_code": "1","benefit_coverage_description": "Active Coverage","benefit_description": "Urgent Care","inplan_network": "W"},{"benefit_code": "96","benefit_coverage_code": "1","benefit_coverage_description": "Active Coverage","benefit_description": "Professional (Physician)","benefit_notes": "SPECIALIST","inplan_network": "W"},{"benefit_code": "96","benefit_coverage_code": "A","benefit_coverage_description": "Co-Insurance","benefit_description": "Professional (Physician)","benefit_level_code": "IND","benefit_level_description": "Individual","benefit_notes": "SPECIALIST","benefit_percent": "0","benefit_period_code": "27","benefit_period_description": "Visit","inplan_network": "Y"},{"benefit_code": "33","benefit_coverage_code": "A","benefit_coverage_description": "Co-Insurance","benefit_description": "Chiropractic","benefit_level_code": "IND","benefit_level_description": "Individual","benefit_percent": "0","benefit_period_code": "27","benefit_period_description": "Visit","inplan_network": "Y"},{"benefit_code": "98","benefit_coverage_code": "A","benefit_coverage_description": "Co-Insurance","benefit_description": "Professional (Physician) Visit - Office","benefit_level_code": "IND","benefit_level_description": "Individual","benefit_percent": "0","benefit_period_code": "27","benefit_period_description": "Visit","inplan_network": "Y"},{"benefit_code": "PT","benefit_coverage_code": "A","benefit_coverage_description": "Co-Insurance","benefit_description": "Physical Therapy","benefit_level_code": "IND","benefit_level_description": "Individual","benefit_percent": "0","benefit_period_code": "27","benefit_period_description": "Visit","inplan_network": "Y"},{"benefit_code": "UC","benefit_coverage_code": "A","benefit_coverage_description": "Co-Insurance","benefit_description": "Urgent Care","benefit_level_code": "IND","benefit_level_description": "Individual","benefit_percent": "0","benefit_period_code": "27","benefit_period_description": "Visit","inplan_network": "Y"},{"benefit_code": "48","benefit_coverage_code": "A","benefit_coverage_description": "Co-Insurance","benefit_description": "Hospital - Inpatient","benefit_level_code": "IND","benefit_level_description": "Individual","benefit_percent": "0","benefit_period_code": "27","benefit_period_description": "Visit","inplan_network": "Y"},{"benefit_code": "50","benefit_coverage_code": "A","benefit_coverage_description": "Co-Insurance","benefit_description": "Hospital - Outpatient","benefit_level_code": "IND","benefit_level_description": "Individual","benefit_percent": "0","benefit_period_code": "27","benefit_period_description": "Visit","inplan_network": "Y"},{"benefit_code": "86","benefit_coverage_code": "A","benefit_coverage_description": "Co-Insurance","benefit_description": "Emergency Services","benefit_level_code": "IND","benefit_level_description": "Individual","benefit_percent": "0","benefit_period_code": "27","benefit_period_description": "Visit","inplan_network": "Y"},{"benefit_code": "33","benefit_coverage_code": "A","benefit_coverage_description": "Co-Insurance","benefit_description": "Chiropractic","benefit_level_code": "IND","benefit_level_description": "Individual","benefit_percent": "50","benefit_period_code": "27","benefit_period_description": "Visit","inplan_network": "N"},{"benefit_code": "50","benefit_coverage_code": "A","benefit_coverage_description": "Co-Insurance","benefit_description": "Hospital - Outpatient","benefit_level_code": "IND","benefit_level_description": "Individual","benefit_percent": "50","benefit_period_code": "27","benefit_period_description": "Visit","inplan_network": "N"},{"benefit_code": "86","benefit_coverage_code": "A","benefit_coverage_description": "Co-Insurance","benefit_description": "Emergency Services","benefit_level_code": "IND","benefit_level_description": "Individual","benefit_percent": "50","benefit_period_code": "27","benefit_period_description": "Visit","inplan_network": "N"},{"benefit_code": "98","benefit_coverage_code": "A","benefit_coverage_description": "Co-Insurance","benefit_description": "Professional (Physician) Visit - Office","benefit_level_code": "IND","benefit_level_description": "Individual","benefit_percent": "50","benefit_period_code": "27","benefit_period_description": "Visit","inplan_network": "N"},{"benefit_code": "UC","benefit_coverage_code": "A","benefit_coverage_description": "Co-Insurance","benefit_description": "Urgent Care","benefit_level_code": "IND","benefit_level_description": "Individual","benefit_percent": "50","benefit_period_code": "27","benefit_period_description": "Visit","inplan_network": "N"},{"benefit_code": "PT","benefit_coverage_code": "A","benefit_coverage_description": "Co-Insurance","benefit_description": "Physical Therapy","benefit_level_code": "IND","benefit_level_description": "Individual","benefit_percent": "50","benefit_period_code": "27","benefit_period_description": "Visit","inplan_network": "N"},{"benefit_code": "48","benefit_coverage_code": "A","benefit_coverage_description": "Co-Insurance","benefit_description": "Hospital - Inpatient","benefit_level_code": "IND","benefit_level_description": "Individual","benefit_percent": "50","benefit_period_code": "27","benefit_period_description": "Visit","inplan_network": "N"},{"benefit_code": "96","benefit_coverage_code": "A","benefit_coverage_description": "Co-Insurance","benefit_description": "Professional (Physician)","benefit_level_code": "IND","benefit_level_description": "Individual","benefit_notes": "SPECIALIST","benefit_percent": "50","benefit_period_code": "27","benefit_period_description": "Visit","inplan_network": "N"},{"benefit_amount": "0","benefit_code": "96","benefit_coverage_code": "B","benefit_coverage_description": "Co-Payment","benefit_description": "Professional (Physician)","benefit_level_code": "IND","benefit_level_description": "Individual","benefit_notes": "SPECIALIST","benefit_period_code": "27","benefit_period_description": "Visit","inplan_network": "N"},{"benefit_amount": "35","benefit_code": "UC","benefit_coverage_code": "B","benefit_coverage_description": "Co-Payment","benefit_description": "Urgent Care","benefit_level_code": "IND","benefit_level_description": "Individual","benefit_period_code": "27","benefit_period_description": "Visit","inplan_network": "Y"},{"benefit_amount": "0","benefit_code": "UC","benefit_coverage_code": "B","benefit_coverage_description": "Co-Payment","benefit_description": "Urgent Care","benefit_level_code": "IND","benefit_level_description": "Individual","benefit_period_code": "27","benefit_period_description": "Visit","inplan_network": "N"},{"benefit_amount": "0","benefit_code": "48","benefit_coverage_code": "B","benefit_coverage_description": "Co-Payment","benefit_description": "Hospital - Inpatient","benefit_level_code": "IND","benefit_level_description": "Individual","benefit_period_code": "27","benefit_period_description": "Visit","inplan_network": "N"},{"benefit_amount": "0","benefit_code": "PT","benefit_coverage_code": "B","benefit_coverage_description": "Co-Payment","benefit_description": "Physical Therapy","benefit_level_code": "IND","benefit_level_description": "Individual","benefit_period_code": "27","benefit_period_description": "Visit","inplan_network": "N"},{"benefit_amount": "0","benefit_code": "98","benefit_coverage_code": "B","benefit_coverage_description": "Co-Payment","benefit_description": "Professional (Physician) Visit - Office","benefit_level_code": "IND","benefit_level_description": "Individual","benefit_period_code": "27","benefit_period_description": "Visit","inplan_network": "N"},{"benefit_amount": "0","benefit_code": "33","benefit_coverage_code": "B","benefit_coverage_description": "Co-Payment","benefit_description": "Chiropractic","benefit_level_code": "IND","benefit_level_description": "Individual","benefit_period_code": "27","benefit_period_description": "Visit","inplan_network": "N"},{"benefit_amount": "0","benefit_code": "86","benefit_coverage_code": "B","benefit_coverage_description": "Co-Payment","benefit_description": "Emergency Services","benefit_level_code": "IND","benefit_level_description": "Individual","benefit_period_code": "27","benefit_period_description": "Visit","inplan_network": "N"},{"benefit_amount": "0","benefit_code": "50","benefit_coverage_code": "B","benefit_coverage_description": "Co-Payment","benefit_description": "Hospital - Outpatient","benefit_level_code": "IND","benefit_level_description": "Individual","benefit_period_code": "27","benefit_period_description": "Visit","inplan_network": "N"},{"benefit_amount": "125","benefit_code": "50","benefit_coverage_code": "B","benefit_coverage_description": "Co-Payment","benefit_description": "Hospital - Outpatient","benefit_level_code": "IND","benefit_level_description": "Individual","benefit_period_code": "27","benefit_period_description": "Visit","inplan_network": "Y"},{"benefit_amount": "15","benefit_code": "96","benefit_coverage_code": "B","benefit_coverage_description": "Co-Payment","benefit_description": "Professional (Physician)","benefit_level_code": "IND","benefit_level_description": "Individual","benefit_notes": "SPECIALIST","benefit_period_code": "27","benefit_period_description": "Visit","inplan_network": "Y"},{"benefit_amount": "15","benefit_code": "98","benefit_coverage_code": "B","benefit_coverage_description": "Co-Payment","benefit_description": "Professional (Physician) Visit - Office","benefit_level_code": "IND","benefit_level_description": "Individual","benefit_period_code": "27","benefit_period_description": "Visit","inplan_network": "Y"},{"benefit_amount": "15","benefit_code": "33","benefit_coverage_code": "B","benefit_coverage_description": "Co-Payment","benefit_description": "Chiropractic","benefit_level_code": "IND","benefit_level_description": "Individual","benefit_period_code": "27","benefit_period_description": "Visit","inplan_network": "Y"},{"benefit_amount": "15","benefit_code": "PT","benefit_coverage_code": "B","benefit_coverage_description": "Co-Payment","benefit_description": "Physical Therapy","benefit_level_code": "IND","benefit_level_description": "Individual","benefit_period_code": "27","benefit_period_description": "Visit","inplan_network": "Y"},{"benefit_amount": "250","benefit_code": "48","benefit_coverage_code": "B","benefit_coverage_description": "Co-Payment","benefit_description": "Hospital - Inpatient","benefit_level_code": "IND","benefit_level_description": "Individual","benefit_period_code": "27","benefit_period_description": "Visit","inplan_network": "Y"},{"benefit_amount": "75","benefit_code": "86","benefit_coverage_code": "B","benefit_coverage_description": "Co-Payment","benefit_description": "Emergency Services","benefit_level_code": "IND","benefit_level_description": "Individual","benefit_period_code": "27","benefit_period_description": "Visit","inplan_network": "Y"},{"benefit_amount": "999999.99","benefit_code": "33","benefit_coverage_code": "F","benefit_coverage_description": "Limitations","benefit_description": "Chiropractic","benefit_level_code": "IND","benefit_level_description": "Individual","benefit_notes": "ADDITIONAL VISITS AVAILABLE BASED ON MEDICAL NECESSITY REVIEW REHABILITATIVE","benefit_period_code": "23","benefit_period_description": "Calendar Year","benefit_qnty": "30","inplan_network": "W"},{"benefit_amount": "999999.99","benefit_code": "33","benefit_coverage_code": "F","benefit_coverage_description": "Limitations","benefit_description": "Chiropractic","benefit_level_code": "IND","benefit_level_description": "Individual","benefit_notes": "ADDITIONAL VISITS AVAILABLE BASED ON MEDICAL NECESSITY REVIEW REHABILITATIVE","benefit_period_code": "29","benefit_period_description": "Remaining","benefit_qnty": "30","inplan_network": "W"},{"benefit_code": "PT","benefit_coverage_code": "F","benefit_coverage_description": "Limitations","benefit_description": "Physical Therapy","benefit_level_code": "IND","benefit_level_description": "Individual","benefit_notes": "REHABILITATIVE ADDITIONAL BENEFIT FOR MUSCULOSKELETAL PAIN MANAGEMENT PROGRAM","benefit_period_code": "29","benefit_period_description": "Remaining","benefit_qnty": "3","inplan_network": "Y"},{"benefit_code": "33","benefit_coverage_code": "F","benefit_coverage_description": "Limitations","benefit_description": "Chiropractic","benefit_level_code": "IND","benefit_level_description": "Individual","benefit_notes": "REHABILITATIVE ADDITIONAL BENEFIT FOR MUSCULOSKELETAL PAIN MANAGEMENT PROGRAM","benefit_period_code": "29","benefit_period_description": "Remaining","benefit_qnty": "3","inplan_network": "Y"},{"benefit_amount": "999999.99","benefit_code": "PT","benefit_coverage_code": "F","benefit_coverage_description": "Limitations","benefit_description": "Physical Therapy","benefit_level_code": "IND","benefit_level_description": "Individual","benefit_notes": "REHABILITATIVE","benefit_period_code": "23","benefit_period_description": "Calendar Year","benefit_qnty": "20","inplan_network": "W"},{"benefit_amount": "999999.99","benefit_code": "PT","benefit_coverage_code": "F","benefit_coverage_description": "Limitations","benefit_description": "Physical Therapy","benefit_level_code": "IND","benefit_level_description": "Individual","benefit_notes": "REHABILITATIVE","benefit_period_code": "29","benefit_period_description": "Remaining","benefit_qnty": "20","inplan_network": "W"},{"benefit_code": "88","benefit_coverage_code": "U","benefit_coverage_description": "Contact Following Entity for Eligibility or Benefit Information","benefit_description": "Pharmacy","entity_code":"VN","entity_description":"Vendor","entity_name":"OPTUMRX","entity_website":"PROFESSIONALS.OPTUMRX.COM"}]}}}';
                ElixirSuite__VOB__c vobRec = [SELECT Id, ElixirSuite__Account__c,ElixirSuite__Type__c,ElixirSuite__Policy_Holder_DOB__c, ElixirSuite__Provider__r.Name,ElixirSuite__Payer_Name__c,ElixirSuite__Insured_First_Name__c,  
                         ElixirSuite__Insured_Middle_Name__c, ElixirSuite__Insured_Last_Name__c, ElixirSuite__Payer__c,ElixirSuite__Payer__r.name, ElixirSuite__Payer__r.ElixirSuite__Payer_Code__c, ElixirSuite__Patient_Relationship_With_Insured__c,
                         ElixirSuite__Provider__c, ElixirSuite__Provider__r.ElixirSuite__Provider_Code__c,ElixirSuite__Procedure_Code__c
                         ,ElixirSuite__Provider__r.ElixirSuite__Provider_First_Name__c,RecordtypeId,ElixirSuite__Member_Id__c,
                         ElixirSuite__Provider__r.ElixirSuite__Provider_Last_Name__c,ElixirSuite__Provider__r.ElixirSuite__Provider_Taxonomy__c,ElixirSuite__Provider__r.ElixirSuite__Provider_Tax_Id__c,
                         ElixirSuite__Provider__r.ElixirSuite__Provider_TaxId_Type__c,ElixirSuite__Provider__r.ElixirSuite__Provider_City__c,ElixirSuite__Provider__r.ElixirSuite__Provider_State__c,
                         ElixirSuite__Provider__r.ElixirSuite__Provider_Zip__c,ElixirSuite__Patient_Birth_Date__c,ElixirSuite__Date_Of_Birth__c,ElixirSuite__Service_Date__c,ElixirSuite__Benefit__c
                         FROM ElixirSuite__VOB__c 
                         WHERE id=:vobId and ElixirSuite__Status__c = 'Active' WITH SECURITY_ENFORCED order by CreatedDate desc];
            
            List<VOB_Codes_and_Fields__mdt> vobFieldList = new List<VOB_Codes_and_Fields__mdt>([Select id, DeveloperName, In_Plan_Network__c, Benefit_Coverage__c, Benefit_Level__c, Benefit_Period__c, VOB_Field__c from VOB_Codes_and_Fields__mdt LIMIT 5000]);
            Map<String,String> vobCodeFieldMap = new Map<String,String>();
            for(VOB_Codes_and_Fields__mdt vcf : vobFieldList)
            {
                String key = '';
                key += vcf.Benefit_Coverage__c.toLowerCase()+'#';
                key += vcf.Benefit_Level__c.toLowerCase()+'#';
                key += vcf.In_Plan_Network__c;
                
                vobCodeFieldMap.put(key,vcf.VOB_Field__c);
            }   
            ElixirSuite__VOB__c vobRec2;
            vobRec2 = vobRec;
            vobRec2.ElixirSuite__JSON_Dump__c = mockRes;
            //update vobRec2;
            if(vobRec2!=null ){
                DMLManager.updateAsUser(vobRec2);
            }
            // obj = mockRes;
            wrap.vobFieldsMap = vobCodeFieldMap;
            wrap.jsonResp = mockRes;
            wrap.vob = vobRec;
             system.debug('wrap : '+ wrap);
        return wrap;
        }
       
    }   
    @AuraEnabled
    public static void saveResults(List<Result__c> result1, String vobId1)
    {   
        
        ElixirSuite__VOB__c vobRec = [SELECT Id,Name, ElixirSuite__Account__c,ElixirSuite__Type__c, ElixirSuite__Status__c,
                                      ElixirSuite__Service_Date__c,ElixirSuite__Benefit__c,recordtypeid,ElixirSuite__Payer__r.name
                                      FROM ElixirSuite__VOB__c 
                                      WHERE id=:vobId1 WITH SECURITY_ENFORCED order by CreatedDate desc limit 1];
        string recordtypename ='';
        if(vobRec!=null){
            recordtypename = Schema.getGlobalDescribe().get('Elixirsuite__VOB__c').getDescribe().getRecordTypeInfosById().get(vobRec.recordtypeid).getName();
        }
        if(result1 != null){
            for(Result__c res :result1){
                res.VOB__c = vobId1;
                res.Insurance_Type__c = recordtypename;
                if(vobRec!=null){
                    res.Payer_Name__c = vobRec.ElixirSuite__Payer__r.name;
                }
            }
            if(Schema.sObjectType.Result__c.fields.VOB__c.isCreateable() &&
               Schema.sObjectType.Result__c.fields.Insurance_Type__c.isCreateable() &&
               Schema.sObjectType.Result__c.fields.Payer_Name__c.isCreateable() ){
                   // insert result1;
                   DMLManager.insertAsUser(result1);
               }
            if(vobRec!=null){
                vobRec.VOB_Verification_Status__c = 'Approved';
                //if(Schema.sObjectType.VOB__c.fields.VOB_Verification_Status__c.isUpdateable()){
                DMLManager.updateAsUser(vobRec);
            }
            //update vobRec1;
            // }
        }
        
    }
    
    @AuraEnabled
    public static License_Class LicensBasdPermission()
    {
        Id currentUid = UserInfo.getUserId();
        String AvailLicense = [Select Id,ElixirSuite__License_Type__c,Username,Name 
                               FROM User where Id =:currentUid WITH SECURITY_ENFORCED].ElixirSuite__License_Type__c;
        List<String> lst_availLicense = new List<String>();
        lst_availLicense = AvailLicense.split(';');
        License_Class lCls = new License_Class();
        try{
            for(String str : lst_availLicense)
            {
                if(str == 'Elixir EHR')
                {
                    lCls.isEhr = True;
                    continue;
                }
                
                else if(str == 'Elixir Contact Center')
                {
                    lCls.isContactCenter = True;
                    continue;
                }
                
                else if(str == 'Elixir RCM')
                {
                    lCls.isRcm = True;
                    continue;
                }
            }
        }
        catch(Exception e){
            ExceptionLog.logError(e);
        }
        return lCls;
    }
    public class License_Class
    {
        @AuraEnabled public Boolean isEhr;
        @AuraEnabled public Boolean isRcm;
        @AuraEnabled public Boolean isContactCenter;
    }
    public class MessageWrapper
    {
        @AuraEnabled
        public String msgState;
        @AuraEnabled
        public String msgStr;
        @AuraEnabled
        public VOB__c vob;
        @AuraEnabled
        public String patRelationCode;
        @AuraEnabled
        public List<VOB__c> volList;
    }
    public class VOBResponse
    {
        @AuraEnabled
        public String jsonResp;
        @AuraEnabled
        public Map<String,String> vobFieldsMap;
        @AuraEnabled
        public VOB__c vob;
    }
    
    
}