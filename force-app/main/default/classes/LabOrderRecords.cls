public with sharing class LabOrderRecords {
    @AuraEnabled(cacheable=true)
    //Fetches records of Lab Test
    public static List<Lab_Order__c> getLabOrderList(String searchKey,String accountid,string filterField, string filterOperator, string filterText){
       try{ 
            String queryfirst = 'SELECT Id, Name,(SELECT Id FROM LabOrder_HL7_Results__r),(SELECT Id ,Name FROM Attachments),ElixirSuite__Result_Status__c, LastModifiedDate,Physician_Name__c,LabName__c,Facility_Name__c,Test_Name__c, Lab_Order_Req__c, Lab_Order_Number__c,Order__c,ElixirSuite__Order__r.Name,Account_Id__c,toLabel(Status__c), CreatedDate,ElixirSuite__Lab_Type__c FROM Lab_Order__c where (Account_Id__c=:accountid) ';
            String querylast = ' WITH SECURITY_ENFORCED order by LastModifiedDate desc';
            // string newDateValueFormat;
            //for for List View Filter
            if(filterOperator=='='){
                filterText='\''+String.escapeSingleQuotes(filterText)+'\'';
            }
            //Changes in query for Search Box
            if( searchKey != null && searchKey != '' ){
                String key = '%' + String.escapeSingleQuotes(searchKey) + '%';
                queryfirst += ' AND ((Name LIKE :key) OR (Lab_Order_Req__c LIKE :key) OR (Test_Name__c LIKE:key) OR (toLabel(Status__c) LIKE:key))';
            }
            //For List View Filter
            else if(filterField!='' && filterOperator!='' && filterText!='' && filterField!=null && filterOperator!=null && filterText!=null){
                queryfirst+= 'AND '+String.escapeSingleQuotes(filterField)+' '+String.escapeSingleQuotes(filterOperator)+' '+filterText;
            }
            //Complete Query
            queryfirst += querylast ;
            return Database.query(queryfirst);
        }catch(Exception e){
            //throw new AuraHandledException(e.getMessage());
            ExceptionLog.logError(e);
            return null;
        }
    }
    //For counting Records Fetched
    @AuraEnabled(cacheable=true)
    public static void countLabOrders() {
        try{
            Integer countRecord=[SELECT count() FROM Lab_Order__c WITH SECURITY_ENFORCED];
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
}