public class TestComponentTriggerHelper {
    public static void beforeInsertValidations(List<ElixirSuite__Test_Component__c> testComponentLst){
        for (ElixirSuite__Test_Component__c record : testComponentLst) {
            if (record.ElixirSuite__Min_Value__c != null && record.ElixirSuite__Max_Value__c == null){
                if (record.ElixirSuite__Max_Value_Male__c == null){
                    record.addError('Please specify  max range value.'); 
                }
             }
            if (record.ElixirSuite__Min_Value__c == null && record.ElixirSuite__Max_Value__c != null){
                if (record.ElixirSuite__Min_Value__c == null){
                   record.addError('Please specify  min range value.'); 
                }
            }
            if (record.ElixirSuite__Min_Value_Male__c != null || record.ElixirSuite__Max_Value_Male__c != null ||
                 record.ElixirSuite__Min_Value_Female__c != null || record.ElixirSuite__Max_Value_Female__c != null){
                 if (record.ElixirSuite__Min_Value_Male__c == null){
                     record.addError('Please specify  male min range value.'); 
				 }
                 if (record.ElixirSuite__Max_Value_Male__c == null){
                     record.addError('Please specify  male max range value.'); 
                 }       
                 if (record.ElixirSuite__Min_Value_Female__c == null){
                     record.addError('Please specify  female min range value.'); 
                 }
                 if (record.ElixirSuite__Max_Value_Female__c == null){
                     record.addError('Please specify  female max range value.'); 
                 }
                 
                 if ((record.ElixirSuite__Min_Value_Male__c != null || record.ElixirSuite__Max_Value_Male__c != null) &&
                    (record.ElixirSuite__Min_Value_Female__c == null && record.ElixirSuite__Max_Value_Female__c == null)) {
            		 if (record.ElixirSuite__Min_Value_Male__c == null){
                        record.addError('Please specify  male min range value.'); 
                     }
                     if (record.ElixirSuite__Max_Value_Male__c == null){
                        record.addError('Please specify  male max range value.'); 
                     }
                  }
                     
                 if ((record.ElixirSuite__Min_Value_Male__c != null && record.ElixirSuite__Max_Value_Male__c != null) &&
                 	(record.ElixirSuite__Min_Value_Female__c == null && record.ElixirSuite__Max_Value_Female__c == null)) {
            		 record.addError('Please put reference range for female as well.');                        
        		 }
                     
                if ((record.ElixirSuite__Min_Value_Female__c != null || record.ElixirSuite__Max_Value_Female__c != null) &&
                   (record.ElixirSuite__Min_Value_Male__c == null && record.ElixirSuite__Max_Value_Male__c == null)) {
            		if (record.ElixirSuite__Min_Value_Female__c == null){
                    record.addError('Please specify  female min range value.'); 
                    }
                   if (record.ElixirSuite__Max_Value_Female__c == null){
                       record.addError('Please specify  female max range value.'); 
                    }
        		}
                if ((record.ElixirSuite__Min_Value_Female__c != null || record.ElixirSuite__Max_Value_Female__c != null) &&
                   (record.ElixirSuite__Min_Value_Male__c == null && record.ElixirSuite__Max_Value_Male__c == null)) {
            		record.addError('Please put reference range for male as well.');
        		}
                
            }
            if ((record.ElixirSuite__Min_Value__c != null || record.ElixirSuite__Max_Value__c != null) && 
                (record.ElixirSuite__Min_Value_Male__c != null || record.ElixirSuite__Max_Value_Male__c != null ||
                 record.ElixirSuite__Min_Value_Female__c != null || record.ElixirSuite__Max_Value_Female__c != null)
                ){
                 record.addError('Please specify either the max & min ranges or gender-specific ranges only, not both.');
                
            }
            // Check for all values
            if (record.ElixirSuite__Min_Value__c != null && record.ElixirSuite__Max_Value__c != null &&
                 record.ElixirSuite__Min_Value_Male__c != null && record.ElixirSuite__Max_Value_Male__c != null &&
                 record.ElixirSuite__Min_Value_Female__c != null && record.ElixirSuite__Max_Value_Female__c != null) {
            
            record.addError('Please specify either the max & min ranges or gender-specific ranges only, not both.');
        }
            // Check for Empty Values
            if (record.ElixirSuite__Min_Value__c == null && record.ElixirSuite__Max_Value__c == null &&
                 record.ElixirSuite__Min_Value_Male__c == null && record.ElixirSuite__Max_Value_Male__c == null &&
                 record.ElixirSuite__Min_Value_Female__c == null && record.ElixirSuite__Max_Value_Female__c == null) {
           
            record.addError('Please specify either the max & min ranges or gender-specific ranges.');
        }
      
        
    }
    }

}