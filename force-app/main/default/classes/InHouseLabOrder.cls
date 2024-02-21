public with sharing class InHouseLabOrder {
    @AuraEnabled
    public static List<string> addInHouseLabOrder(string ordertypevalue,string accountid,string billtype,string labId, 
                                           string facilityId, string physiciasnName,string selectedEnteredBy,string selectedVerifiedBy,
                                           String physicianId,String enteredById,string verifiedById, list<string> tests, 
                                           list<string> ICDs,string collectionDateTime,DateTime DateTimeCollection, 
                                           String expectedDateTime,DateTime dateTimeExpected,string code,string policy,string groupvalue,
                                           String parentInsuranceID, string guarantorRecordId,String orderId)
    {
try{
        List<ElixirSuite__Lab_Order__c> labOrderInsertion = new list<ElixirSuite__Lab_Order__c>();
        List<ID> labOrderIds = new list<ID>();
        List<string> orderIdList=new List<string>();
        String parentOrderRecId = '';
        List<ElixirSuite__Order__c> parentLabOrderInsertion = new list<ElixirSuite__Order__c>();
        ElixirSuite__Elixir_Custom_Setting__c customSetting = ElixirSuite__Elixir_Custom_Setting__c.getOrgDefaults();
        String careFilter = customSetting.ElixirSuite__Default_Active_Care_Episode_Filter__c;
        if(string.isBlank(careFilter)){
            careFilter = 'createddate desc';
        }
        String careStatus = 'Active';
        //
        Id recordTypeId1 = Schema.SObjectType.ElixirSuite__Procedure__c.getRecordTypeInfosByDeveloperName().get('Template_Lab_Test').getRecordTypeId();

List<ElixirSuite__Procedure__c> testRecords1 = [SELECT Id, Name, CreatedDate FROM ElixirSuite__Procedure__c WHERE RecordTypeId = :recordTypeId1 AND Name IN : tests WITH SECURITY_ENFORCED ORDER BY CreatedDate DESC LIMIT 1];

Map<String,Id> testIdToNameMap = new Map<String,Id>();

for (ElixirSuite__Procedure__c testRecord : testRecords1) {
    testIdToNameMap.put( testRecord.Name,testRecord.Id);
}
// Now you have a map with Id and Name of the records.

        string querystr = '';
        querystr += 'Select Id,ElixirSuite__Account__c,ElixirSuite__Status__c from ElixirSuite__Visits__c where ElixirSuite__Status__c=:careStatus AND ElixirSuite__Account__c =: accountid WITH SECURITY_ENFORCED order by ';
        querystr += careFilter ;
        List<ElixirSuite__Visits__c> lst_visits = database.query(querystr);
        if(String.isNotBlank(orderId)){ 
            parentOrderRecId = orderId;
        }
        else{
            ElixirSuite__Order__c parentLaborder = new ElixirSuite__Order__c();
            parentLabOrderInsertion.add(parentLaborder);           
            DMLManager.insertAsUser(parentLabOrderInsertion);
            parentOrderRecId = parentLabOrderInsertion[0].Id;
        }

        List<ElixirSuite__Test__c> testRecords=[select id, name, ElixirSuite__Test_Description__c, 
                                                ElixirSuite__Test_Id__c, 
                                                ElixirSuite__Test_Name__c, ElixirSuite__Coding_System__c,
                                                ElixirSuite__Coding_System_Name__c, RecordType.Name from ElixirSuite__Test__c
                                                WHERE ElixirSuite__Test_Id__c IN:tests
                                                WITH SECURITY_ENFORCED];
        Map<String, String> testIdToValueMap=new Map<String, String>();
        Map<String, String> testIdToPackageMap=new Map<String, String>();
        Set<Id> packageTestId = new Set<Id>();

        for(ElixirSuite__Test__c testvalues:testRecords){
            if(testvalues.RecordType.Name == 'Package'){
                packageTestId.add(testvalues.Id);
                tests.remove(tests.indexOf(testvalues.ElixirSuite__Test_Id__c));
            }
            else{
                testIdToValueMap.put(testvalues.ElixirSuite__Test_Id__c, testvalues.Id);
            }
        }
        List<ElixirSuite__Test__c> testRecordsFromPackage =[select id, name, ElixirSuite__Test_Description__c, 
                                                            ElixirSuite__Test_Id__c, 
                                                            ElixirSuite__Test_Name__c, ElixirSuite__Coding_System__c,
                                                            ElixirSuite__Coding_System_Name__c, RecordType.Name,ElixirSuite__Test__c from ElixirSuite__Test__c
                                                            WHERE ElixirSuite__Test__c IN:packageTestId
                                                            WITH SECURITY_ENFORCED];
        for(ElixirSuite__Test__c testvalues:testRecordsFromPackage){
            tests.add(testvalues.ElixirSuite__Test_Id__c);
            testIdToPackageMap.put(testvalues.ElixirSuite__Test_Id__c, testvalues.ElixirSuite__Test__c);
        }
        Id recordTypeId = Schema.SObjectType.ElixirSuite__Lab_Order__c.getRecordTypeInfosByDeveloperName().get('Manual').getRecordTypeId();
        for(String testsvalue:tests){
            if(ordertypevalue =='Standard' && testsvalue != null){
                ElixirSuite__Lab_Order__c labVal = new ElixirSuite__Lab_Order__c();
                labVal.ElixirSuite__Order_Type__c = ordertypevalue;
                labVal.ElixirSuite__Lab_Order_Req__c = 'Awaiting Lab Order #';
                labVal.ElixirSuite__Physician_Name__c = physiciasnName;
                labVal.ElixirSuite__Ordering_Provider__c = physicianId;
                labVal.ElixirSuite__Entered_By__c = enteredById;
                labVal.ElixirSuite__Verified_By__c = verifiedById;
                labVal.ElixirSuite__Lab_Id__c=labId;
                labVal.ElixirSuite__Status__c  ='E';
                labVal.ElixirSuite__Bill_Type__c = billtype;
                labVal.ElixirSuite__Facility_Id__c=facilityId;
                labVal.ElixirSuite__Account_Id__c=accountid;
                labVal.ElixirSuite__Order__c = parentOrderRecId;
                labVal.RecordTypeId = recordTypeId;
                labVal.ElixirSuite__Test_Id__c=testsvalue;
                //labVal.ElixirSuite__Test_Name__c=testsvalue;
                if(testIdToValueMap.containsKey(testsvalue)){
                    labVal.ElixirSuite__Test__c=testIdToValueMap.get(testsvalue);
                }
                if(testIdToPackageMap.containsKey(testsvalue)){
                    labVal.ElixirSuite__Test__c=testIdToPackageMap.get(testsvalue);
                }
                labVal.ElixirSuite__Collection_Date_Time__c =DateTimeCollection;
                labVal.ElixirSuite__ICD_Id__c=String.join(ICDs, ';');
                if(String.isNotBlank(guarantorRecordId)){
                    labVal.ElixirSuite__Contact__c = guarantorRecordId;
                }
                if(String.isNotBlank(parentInsuranceID)){
                    labVal.ElixirSuite__Insurance__c = parentInsuranceID;
                }
                if (lst_visits.size() > 0){
                    labVal.ElixirSuite__Care_Episode__c = lst_visits[0].Id;
                }                                       
                
                labOrderInsertion.add(labVal);
            }
            else if(ordertypevalue =='PSC' && testsvalue != null){
                ElixirSuite__Lab_Order__c labVal = new ElixirSuite__Lab_Order__c();
                //labVal.ElixirSuite__Lab_Order_Number__c = orderId;
                labVal.ElixirSuite__Order_Type__c = ordertypevalue;
                labVal.ElixirSuite__Lab_Order_Req__c = 'Awaiting Lab Order #';
                labVal.ElixirSuite__Physician_Name__c = physiciasnName;
                labVal.ElixirSuite__Ordering_Provider__c = physicianId;
                labVal.ElixirSuite__Entered_By__c = enteredById;
                labVal.ElixirSuite__Verified_By__c = verifiedById;
                labVal.ElixirSuite__Lab_Id__c=labId;
                labVal.ElixirSuite__Bill_Type__c = billtype;
                labVal.ElixirSuite__Status__c  ='E';
                labVal.ElixirSuite__Facility_Id__c=facilityId;
                labVal.ElixirSuite__Account_Id__c=accountid;
                labVal.RecordTypeId = recordTypeId;
                labVal.ElixirSuite__Test_Id__c=testsvalue;
                //labVal.ElixirSuite__Test_Name__c=testsvalue;
                if(testIdToValueMap.containsKey(testsvalue)){
                    labVal.ElixirSuite__Test__c=testIdToValueMap.get(testsvalue);
                }
                if(testIdToPackageMap.containsKey(testsvalue)){
                    labVal.ElixirSuite__Test__c=testIdToPackageMap.get(testsvalue);
                }
                labVal.ElixirSuite__Order__c = parentOrderRecId;
                labVal.ElixirSuite__Expected_Date_Time__c =dateTimeExpected;
                labVal.ElixirSuite__ICD_Id__c=String.join(ICDs, ';');
                if(String.isNotBlank(guarantorRecordId)){
                    labVal.ElixirSuite__Contact__c = guarantorRecordId;
                }
                if(String.isNotBlank(parentInsuranceID)){
                    labVal.ElixirSuite__Insurance__c = parentInsuranceID;
                }
                if (lst_visits.size() > 0){
                    labVal.ElixirSuite__Care_Episode__c = lst_visits[0].Id;
                }
                
                labOrderInsertion.add(labVal);
            }
        }

        if(Schema.sObjectType.ElixirSuite__Lab_Order__c.isCreateable()){
            Database.SaveResult[] srList = Database.insert(labOrderInsertion);
            for (Database.SaveResult sr : srList) {
                if (sr.isSuccess()) {
                    labOrderIds.add(sr.getId());
                }
            }
            orderIdList.addAll(labOrderIds);
            /*List<ElixirSuite__Lab_Order__c> labOrderInsertedIds = [SELECT Id,ElixirSuite__Lab_Order_Req__c FROM ElixirSuite__Lab_Order__c WHERE ID IN : labOrderIds];
            for(ElixirSuite__Lab_Order__c lo  : labOrderInsertedIds){
                lo.ElixirSuite__Lab_Order_Req__c = lo.ID;
            }
            if(labOrderInsertedIds != NULL && !labOrderInsertedIds.isEmpty()){
                database.update(labOrderInsertedIds);
            }*/
        }
       
        // Query ElixirSuite__Lab_Order__c records and create a map of test name to lab order ID
        List<ElixirSuite__Lab_Order__c> labOrderIdsLst = [SELECT Id, ElixirSuite__Test_Name__c ,ElixirSuite__Test__c
                                                          FROM ElixirSuite__Lab_Order__c 
                                                          WHERE Id IN :labOrderIds
                                                          WITH SECURITY_ENFORCED];
        Map<String, String> testNameToLabOrderIdMap = new Map<String, String>();
        for (ElixirSuite__Lab_Order__c labOrder : labOrderIdsLst) {
            testNameToLabOrderIdMap.put(labOrder.ElixirSuite__Test_Name__c, labOrder.Id);
        }
        
        Set<Id> testIds=new Set<Id>();
        for(Lab_Order__c manualLabOrder : labOrderIdsLst)
        {
           testIds.add(manualLabOrder.ElixirSuite__Test__c);
        }

        //Query the Test records

        List<ElixirSuite__Test__c> testLst = [Select Id, Name, ElixirSuite__Test_Name__c, ElixirSuite__Test_Id__c,
            (SELECT Id, Name, ElixirSuite__Min_Value__c, ElixirSuite__Max_Value__c,ElixirSuite__Min_Value_Male__c, ElixirSuite__Unit__c,
            ElixirSuite__Max_Value_Male__c, ElixirSuite__Min_Value_Female__c, ElixirSuite__Max_Value_Female__c
            FROM ElixirSuite__Lab_Test_Components__r) 
            FROM ElixirSuite__Test__c 
            WHERE Id IN :testIds WITH SECURITY_ENFORCED];

        Account acc=[select id, Name, ElixirSuite__Birth_Sex__c, ElixirSuite__Gender__c from account where id=:accountid WITH SECURITY_ENFORCED LIMIT 1];
        
        // Initialize a list to store ElixirSuite__Test_Result_Detail__c records
        List<ElixirSuite__Test_Result_Detail__c> labTestLst = new List<ElixirSuite__Test_Result_Detail__c>();

        // Loop through ElixirSuite__Test__c records and their ElixirSuite__Test_Component__c
         for (ElixirSuite__Test__c testRecordsLst : testLst) {
            for (ElixirSuite__Test_Component__c testComponent : testRecordsLst.ElixirSuite__Lab_Test_Components__r) {
                ElixirSuite__Test_Result_Detail__c labTestResult = new ElixirSuite__Test_Result_Detail__c();

                // Check if the test component name exists in the map
                if (testNameToLabOrderIdMap.containsKey(testRecordsLst.ElixirSuite__Test_Name__c)) {
                    labTestResult.ElixirSuite__Test_ResultId__c = testNameToLabOrderIdMap.get(testRecordsLst.ElixirSuite__Test_Name__c);
                }

                labTestResult.ElixirSuite__Component_Name__c = testComponent.Name;
                if(testComponent.ElixirSuite__Min_Value__c !=null && testComponent.ElixirSuite__Max_Value__c !=null){
                    labTestResult.ElixirSuite__Min_Value__c = testComponent.ElixirSuite__Min_Value__c;
                    labTestResult.ElixirSuite__Max_Value__c = testComponent.ElixirSuite__Max_Value__c;
                }
                else{
                    if(acc.ElixirSuite__Gender__c =='M'){
                        labTestResult.ElixirSuite__Min_Value__c = testComponent.ElixirSuite__Min_Value_Male__c;
                        labTestResult.ElixirSuite__Max_Value__c = testComponent.ElixirSuite__Max_Value_Male__c;

                    }
                    if(acc.ElixirSuite__Gender__c =='F'){
                        labTestResult.ElixirSuite__Min_Value__c = testComponent.ElixirSuite__Min_Value_Female__c;
                        labTestResult.ElixirSuite__Max_Value__c = testComponent.ElixirSuite__Max_Value_Female__c;
                    }
                }
                
                labTestResult.ElixirSuite__Units__c = testComponent.ElixirSuite__Unit__c;
                labTestLst.add(labTestResult);
            }
        }

        // Insert the ElixirSuite__Test_Result_Detail__c records
        if (!labTestLst.isEmpty() && Schema.sObjectType.ElixirSuite__Test_Result_Detail__c.isCreateable()) {
            Database.insert(labTestLst);
        }
       return orderIdList; 
    }
catch(Exception e){
            ExceptionLog.logError(e);
            throw new AuraHandledException(e.getMessage());
            
        }
         
        }
    @AuraEnabled
    public static Boolean updateOrderStatusInHouse(List<String> labOrderIds){
        Boolean result = false;
        List<ElixirSuite__Lab_Order__c> labOrderList = [SELECT Id,ElixirSuite__Status__c,ElixirSuite__Order__c FROM ElixirSuite__Lab_Order__c WHERE Id IN:labOrderIds WITH SECURITY_ENFORCED];
         try {
            Set<Id> orderIdSet = new Set<Id>();
            for(ElixirSuite__Lab_Order__c labOrder : labOrderList){
                if(labOrder.ElixirSuite__Order__c != NULL){
                    orderIdSet.add(labOrder.ElixirSuite__Order__c);
                }
            }
            List<ElixirSuite__Lab_Order__c> allOrderRelatedLabOrders = [SELECT Id,ElixirSuite__Status__c FROM ElixirSuite__Lab_Order__c WHERE ElixirSuite__Order__c IN:orderIdSet WITH SECURITY_ENFORCED];

            for(ElixirSuite__Lab_Order__c LabOrder : allOrderRelatedLabOrders){
                LabOrder.ElixirSuite__Status__c = 'R';
            }
            if(allOrderRelatedLabOrders != NULL && !allOrderRelatedLabOrders.isEmpty()){
                Database.SaveResult[] srList = database.update(allOrderRelatedLabOrders);
                for (Database.SaveResult sr : srList) {
                    if(sr.isSuccess()) {
                        result = true;
                    }
                    else {
                        result = false;
                        break;
                    }
                }
            }
        }
        catch(Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return result;
    }
    @AuraEnabled
    public static List<string> updateInHouseLabOrder(String ordertypevalue,String accountid,String billtype,String labId,String facilityId,String physicianId,String enteredById,String verifiedById,list<string> ICDs,String collectionDateTime,String expectedDateTime,String parentInsuranceID,String guarantorRecordId,String labOrderId,List<String> removedTests){
        List<ElixirSuite__Lab_Order__c> labOrderLst = new List<ElixirSuite__Lab_Order__c>();
        List<ElixirSuite__Lab_Order__c> labOrderList = [SELECT Id,ElixirSuite__Order__c,ElixirSuite__Status__c,ElixirSuite__Bill_Type__c,ElixirSuite__Facility_Id__c,ElixirSuite__Lab_Id__c,ElixirSuite__Order_Type__c,ElixirSuite__Entered_By__c,ElixirSuite__Verified_By__c,ElixirSuite__Ordering_Provider__c,ElixirSuite__Collection_Date_Time__c,ElixirSuite__Expected_Date_Time__c FROM ElixirSuite__Lab_Order__c WHERE Id=:labOrderId AND ElixirSuite__Account_Id__c=:accountid WITH SECURITY_ENFORCED LIMIT 1];
        List<ElixirSuite__Order__c> orderlist = [Select Id,(SELECT Id,ElixirSuite__Test_Id__c,ElixirSuite__Status__c,ElixirSuite__Test__r.ElixirSuite__Test_Id__c FROM ElixirSuite__Lab_Orders__r WHERE ElixirSuite__Test__r.ElixirSuite__Test_Id__c IN:removedTests) from ElixirSuite__Order__c WHERE Id=:labOrderList[0].ElixirSuite__Order__c WITH SECURITY_ENFORCED];
        
        if(orderlist != null && !orderlist.isEmpty()){
            for(ElixirSuite__Lab_Order__c labOrd : orderlist[0].ElixirSuite__Lab_Orders__r){
                labOrd.ElixirSuite__Status__c = 'C';
                labOrderLst.add(labOrd);
            }
        }
        if (Schema.sObjectType.ElixirSuite__Lab_Order__c.isUpdateable() && labOrderLst != null && !labOrderLst.isEmpty()) {
            Database.update(labOrderLst);
        }

        for(ElixirSuite__Lab_Order__c labOrder : labOrderList){
            if(ordertypevalue == 'Standard'){
                labOrder.ElixirSuite__Order_Type__c = ordertypevalue;
                if (String.isNotBlank(collectionDateTime)) {
                    String formatDateTime = collectionDateTime;
                    formatDateTime = formatDateTime.replace('T', ' ');
                    Datetime dt = DateTime.valueOf(formatDateTime);
                    Integer offset = UserInfo.getTimezone().getOffset(dt);
                    labOrder.ElixirSuite__Collection_Date_Time__c = dt.addSeconds(offset/1000);
                }
            }else if(ordertypevalue =='PSC'){
                labOrder.ElixirSuite__Order_Type__c = ordertypevalue;
                if (String.isNotBlank(expectedDateTime)) {
                    String formatDateTime = expectedDateTime;
                    formatDateTime = formatDateTime.replace('T', ' ');
                    Datetime dt = DateTime.valueOf(formatDateTime);
                    Integer offset = UserInfo.getTimezone().getOffset(dt);
                    labOrder.ElixirSuite__Expected_Date_Time__c = dt.addSeconds(offset/1000);
                }
            }
                labOrder.ElixirSuite__Entered_By__c = enteredById;
                labOrder.ElixirSuite__Verified_By__c = verifiedById;
                labOrder.ElixirSuite__Ordering_Provider__c = physicianId;
                labOrder.ElixirSuite__Lab_Id__c = labId;
                labOrder.ElixirSuite__Facility_Id__c = facilityId;
                labOrder.ElixirSuite__Bill_Type__c = billtype;
                if(String.isNotBlank(guarantorRecordId)){
                    labOrder.ElixirSuite__Contact__c = guarantorRecordId;
                }
                if(String.isNotBlank(parentInsuranceID)){
                    labOrder.ElixirSuite__Insurance__c = parentInsuranceID;
                }
                if(!ICDs.isEmpty()){
                    labOrder.ElixirSuite__ICD_Id__c = String.join(ICDs, ';');
                }
        }
        //if (Schema.sObjectType.ElixirSuite__Lab_Order__c.isUpdateable()) {
         //   Database.update(labOrderList);
        //}
        List<String> LabTestIds = new List<String>();
 
        if (Schema.sObjectType.ElixirSuite__Lab_Order__c.isUpdateable()) {
            List<Id> updatedId = new List<Id>();
            Database.SaveResult[] updateResults = Database.update(labOrderList, false);
        
            for (Database.SaveResult result : updateResults) {
                if (result.isSuccess()) {
                    // The record was updated successfully
                     updatedId.add(result.getId());
                      
                   // System.debug('Updated Lab Order ID: ' + updatedId);
                } else {
                    // Handle any update errors
                    for (Database.Error error : result.getErrors()) {
                        System.debug('Error updating Lab Order: ' + error.getMessage());
                    }
                }
            }
            LabTestIds.addAll(updatedId);
           
        }
        return LabTestIds;
    }
}