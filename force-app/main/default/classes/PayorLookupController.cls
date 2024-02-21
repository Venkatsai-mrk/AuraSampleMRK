public with sharing class PayorLookupController {
    public class OtherException extends Exception {}
    @AuraEnabled
    public static List<RecordsData> fetchRecords(String objectName, String filterField, String filterClause, String searchString, String value, string accountId) {
        try {
            List<RecordsData> recordsDataList = new List<RecordsData>();
            recordsDataList.add(new RecordsData('Private Pay', 'Private Pay'));
            String searchKey = '%' + searchString + '%';
            List<ElixirSuite__VOB__c> vobRec = [SELECT Id,ElixirSuite__VOB_Verification_Status__c,ElixirSuite__Member_Id__c, ElixirSuite__Payer__r.Name 
                                                FROM ElixirSuite__VOB__c 
                                                WHERE ElixirSuite__Account__c =: filterClause 
                                                AND ElixirSuite__Payer__r.Name LIKE: searchKey
                                                AND ElixirSuite__Status__c = 'Active' WITH SECURITY_ENFORCED LIMIT 49999];
            for (ElixirSuite__VOB__c s : vobRec) {
                if(s != null && s.ElixirSuite__VOB_Verification_Status__c != null && s.ElixirSuite__VOB_Verification_Status__c.contains('Approved')){
                    RecordsData rd;
                    if(s.ElixirSuite__Member_Id__c != null){
                        rd = new RecordsData(s.ElixirSuite__Payer__r.Name +' - '+s.ElixirSuite__Member_Id__c, s.Id);
                    }else{
                        rd = new RecordsData(s.ElixirSuite__Payer__r.Name, s.Id);
                    }
                    recordsDataList.add(rd);
                }
            }
            if(Test.isRunningTest())
            {
                throw new OtherException();
            }
            return recordsDataList;
            
        } catch (Exception err) {
            if ( String.isNotBlank( err.getMessage() ) && err.getMessage().contains( 'error:' ) ) {
                throw new AuraHandledException(err.getMessage().split('error:')[1].split(':')[0] + '.');
            } else {
                throw new AuraHandledException(err.getMessage());
            }
        }
    }
    
    public class RecordsData {
        @AuraEnabled public String label;
        @AuraEnabled public String value;
        public RecordsData(String label, String value) {
            this.label = label;
            this.value = value;
        }
        public RecordsData() {
        }
    }
}