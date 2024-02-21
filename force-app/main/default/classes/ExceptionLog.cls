global with sharing class ExceptionLog {
    global static void logError(Exception e){
        String exceptionText = e.getMessage(); 
        if(String.isNotBlank(exceptionText) && exceptionText.length()>255){
            exceptionText = exceptionText.substring(0,255);
        }
        Exception_Log__c obj = new Exception_Log__c();
        obj.line_Number__c = e.getLineNumber();
        obj.message__c = exceptionText;
        obj.Stack_Trace_Long__c = e.getStackTraceString();
        String stackTrace = e.getStackTraceString().substringBefore('\n');
        String className = stackTrace.substringAfter('.').substringAfter('.').substringBefore('.');	
        obj.ElixirSuite__StackTrace__c = className;
        DMLManager.insertAsUser(obj);
    }
    global static void logDebugString(String myDebugString){
        Exception_Log__c obj = new Exception_Log__c();
        obj.line_Number__c = 1;
        obj.message__c = 'For Stack Track';
        obj.Stack_Trace_Long__c = myDebugString;
        DMLManager.insertAsUser(obj);
    }
    public static void logHTTPtransaction(String statusCode, String reqBody, String resBody, String endPoint, String apexMethod, String httpMethod){
        IntegrationInformation integrationInfo = new IntegrationInformation();
        integrationInfo.statusCode = statusCode;
        integrationInfo.httpMethod = httpMethod;
        if(String.isNotBlank(reqBody) && reqBody.length()>10000){
            integrationInfo.requestBody = reqBody.substring(0,10000);
        }
        if(String.isNotBlank(resBody) && resBody.length()>10000){
            integrationInfo.responseBody = resBody.substring(0,10000);
        }
        integrationInfo.endPoint = endPoint;
        integrationInfo.apexMethod = apexMethod;
        Exception_Log__c exce = new Exception_Log__c();
        exce.Integration_Status__c = JSON.serialize(integrationInfo);
        if(Schema.sObjectType.Exception_Log__c.isCreateable() &&
        Schema.sObjectType.Exception_Log__c.fields.Integration_Status__c .isCreateable ()){
        insert exce;
        }
    }
    class IntegrationInformation{
        String statusCode;
        String endPoint;        
        String requestBody;
        String responseBody;
        String httpMethod;
        String apexMethod;        
    }
}