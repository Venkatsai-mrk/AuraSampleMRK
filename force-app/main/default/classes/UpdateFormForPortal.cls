public with sharing class UpdateFormForPortal {
    public static UpdateFormResponse updateForm(String accountId,String formUniqueID,String formName){
        System.debug('formUniqueID '+formUniqueID);
        System.debug('formName '+formName);
        List<String> allObjectForForms =   ElixirOEM_DependentPicklist.fetchAllValidObject();
        
        
        List<ElixirSuite__Object_1_css__c> obj1List = New List<ElixirSuite__Object_1_css__c >();
        List<ElixirSuite__Form_Value__c> formValueList = New List<ElixirSuite__Form_Value__c>();
        Boolean isSignRequired = false;
        Boolean isSigned = false;
        Boolean throwAlert = false;
        obj1List=[SELECT Id, ElixirSuite__Approval_Level__c, ElixirSuite__Form__c,ElixirSuite__Approval_Members__c FROM 
                  ElixirSuite__Object_1_css__c WHERE ElixirSuite__Form__c=:formName AND ElixirSuite__Approval_Level__c!=NULL WITH SECURITY_ENFORCED Order
                  By ElixirSuite__Approval_Level__c Asc Limit 1];
        if(obj1List!=Null && obj1List.size()>0){
            if(obj1List[0].ElixirSuite__Approval_Members__c=='Patient'){
                isSignRequired = true;
            }
        }
        if(isSignRequired == true)  {
            formValueList = [select ElixirSuite__Approval_Level__c,  ElixirSuite__Form_Name__c,ElixirSuite__Is_old__c FROM  
                             ElixirSuite__Form_Value__c WHERE  ElixirSuite__Is_Approver__c = true AND ElixirSuite__Form_Id__c=:formUniqueID 
                             WITH SECURITY_ENFORCED 
                             order by ElixirSuite__Approval_Level__c];
            if(formValueList!=Null && formValueList.size()>0){
                isSigned = true;
            }
        } 
            
        if(allObjectForForms!=null && allObjectForForms.size()>0 &&
           ((isSignRequired==true && isSigned==true) || (isSignRequired==false)) ){
               System.debug('allObjectForForms '+allObjectForForms);
               List<CreateFormForPortal.ObjectAndRecordTypeAsForm> objectsForFormsToUpdate = new List<CreateFormForPortal.ObjectAndRecordTypeAsForm>();
               objectsForFormsToUpdate = CreateFormForPortal.findObjectsPerRecordType(allObjectForForms,new List<String>{formName});          
               Sobject[] formsToUpdate = new List<sobject>();
               ElixirSuite__Form_Value__c[] formValues = new List<ElixirSuite__Form_Value__c>();            
               for(CreateFormForPortal.ObjectAndRecordTypeAsForm obj : objectsForFormsToUpdate){
                   if(ElixirOEM_FormConfigurationHelper.isObjectExist(obj.objectName)){
                       List<sObject> recordLst = fetchForm(obj.objectName,formUniqueID,accountId);
                       system.debug('recordLst '+ recordLst);
                       if(recordLst!=null && recordLst.size()>0){
                           recordLst[0].put('Is_Patient_Portal_Form__c', 'Portal And EHR Form');
                           formsToUpdate.add(recordLst[0]);
                       }
                   } 
               }
               System.debug('formsToUpdate ' + formsToUpdate);
               //DMLManager.updateAsUser(formsToUpdate);
               List<ElixirSuite__Form_Value__c> formValLSt = updateFormsStatus(formUniqueID);
               UpdateFormResponse response;
               if(!formsToUpdate.isEmpty() && !formValLSt.isEmpty()){
                   response = new UpdateFormResponse(formsToUpdate, formValLSt);
               }
               
               return response;
           }else{
               return NULL;
           }
    }
    public static List<ElixirSuite__Form_Value__c> updateFormsStatus(String formUnqId){
        System.debug('formUnqId ************** '+formUnqId);
        List<ElixirSuite__Form_Value__c> formValLSt = fetchFormValue(formUnqId);
        System.debug('formValLSt ************** '+formValLSt);
        if(formValLSt!=null && formValLSt.size()>0){
            for(ElixirSuite__Form_Value__c obj : formValLSt){
                obj.ElixirSuite__Status__c = 'Completed';
                obj.ElixirSuite__Form_Portal_Status__c = 'Submitted to Provider';
            }
            //DMLManager.updateAsUser(formValLSt);
        }
        return formValLSt;
    }
    public static void updateFormWhenPatientStartsFillingOnPortal(String formUnqId){
        List<ElixirSuite__Form_Value__c> formValLSt = fetchFormValue(formUnqId);
        System.debug('formValLSt ************** '+formValLSt);
        if(formValLSt!=null && formValLSt.size()>0){
            for(ElixirSuite__Form_Value__c obj : formValLSt){
                obj.ElixirSuite__Form_Portal_Status__c = 'In Progress';
               
            }
            DMLManager.updateAsUser(formValLSt);
        }
    }
    public static  List<ElixirSuite__Form_Value__c> fetchFormValue(String formUnqId){
        return [SELECT ID,ElixirSuite__Status__c FROM ElixirSuite__Form_Value__c
        WHERE Form_Id__c = : formUnqId AND ElixirSuite__Form_Detail__c = true with security_enforced];
    }
    public static sObject[] fetchForm(String objectName,String formUnqId,String accountId){
       return Database.query('SELECT ID,Is_Patient_Portal_Form__c FROM '+String.escapeSingleQuotes(objectName) + ' WHERE Form_unique_id__c = : formUnqId AND AccountId__c = : accountId');
    }
    public class UpdateFormResponse {
        public List<sObject> formsToUpdate;
        public List<ElixirSuite__Form_Value__c> formValLst;
        
        public UpdateFormResponse(List<sObject> formsToUpdate, List<ElixirSuite__Form_Value__c> formValLst) {
            this.formsToUpdate = formsToUpdate;
            this.formValLst = formValLst;
        }
    }
}