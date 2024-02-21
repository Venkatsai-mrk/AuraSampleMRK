public class ElixirOEM_FormConfigTableHandling { 

public static String tableDataSaving(Map<String, Object> mapOfCSSData,List<Object_1_css__c> toInsertChildrecords){
    String heading  = '';
    List<Object> table_Heading = (List<Object>) mapOfCSSData.get('table_HeadingArr');
    heading = collectHeading(table_Heading);
    List<Object> table_row = (List<Object>) mapOfCSSData.get('table_fieldLst');        
    for(Object rowsObj : table_row){
        Map<String, Object> mapOfRowRecord = (Map<String, Object>) rowsObj;
        List<Object> table_col = (List<Object>) mapOfRowRecord.get('colLst');
        for(Object colsObj : table_col){
            Map<String, Object> mapOfchildCSSRecord = (Map<String, Object>) colsObj;                             
            Object_1_css__c childCSSRecord = new Object_1_css__c();
            childCSSRecord.Row__c =  Integer.valueOf(mapOfRowRecord.get('RowNumber')); // ROW WITH PARENT
            childCSSRecord.Column__c =  Integer.valueOf(mapOfchildCSSRecord.get('ColNumber')); // COL WITH CHILD
            childCSSRecord.ElixirSuite__Is_matrix__c = true;
            childCSSRecord.ElixirSuite__Select_Form_Component__c = String.valueOf(mapOfCSSData.get('formComponentVal'));
            childCSSRecord.Field_Label_Long__c  = String.valueOf(mapOfchildCSSRecord.get('defaultLabel'));     
            if(String.valueOf(mapOfchildCSSRecord.get('table_fieldSelected')).contains(';')){     
                List<String> selectedFiledJunction = (String.valueOf(mapOfchildCSSRecord.get('table_fieldSelected'))).split(';');
                system.debug('fld value '+selectedFiledJunction);
                if(selectedFiledJunction.size()>0 && selectedFiledJunction!=null) {
                    childCSSRecord.Data_Type__c =  selectedFiledJunction[1]; 
                    childCSSRecord.Default_Field_Label__c = selectedFiledJunction[2]; // Label of field saved in a default field regardless of the external label
                    childCSSRecord.Field_Name__c =  selectedFiledJunction[0];
                    childCSSRecord.Object_Name__c = selectedFiledJunction[3];
                   if(childCSSRecord.Data_Type__c == 'ONLYTEXT'){
                    childCSSRecord.ElixirSuite__Default_text__c  = String.valueOf(mapOfchildCSSRecord.get('defaultLabel'));
                    }
                 //   childCSSRecord.ElixirSuite__Is_formula_Field__c = ElixirOEM_FormConfigurationHelper.checkFormulaField(selectedFiledJunction[3], selectedFiledJunction[0]); //Added by vidish
                    if(String.valueOf(childCSSRecord.Data_Type__c).equalsIgnoreCase('REFERENCE')){
                                        String refObjectName = childCSSRecord.Object_Name__c;
                                        String refFieldName = childCSSRecord.Field_Name__c;
                                        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();       
                                        Schema.SObjectType leadSchema = schemaMap.get(refObjectName);        
                                        Map<String, Schema.SObjectField> fieldMap = leadSchema.getDescribe().fields.getMap();
                                        List<String> fieldApiAndFieldTypeMap = new  List<String>();
                                        for (String fieldName: fieldMap.keySet()) {
                                            if(fieldName == refFieldName){
                                                Schema.DescribeFieldResult f = fieldMap.get(fieldName).getDescribe();
                                                // Schema.DescribeFieldResult f = leadSchema.getDescribe().fields.fieldName; 
                                                
                                                for(Schema.SObjectType reference : f.getReferenceTo()) {
                                                    refObjectName = reference.getDescribe().getName(); 
                                                    childCSSRecord.Reference_to_object__c = refObjectName;
                                                }
                                                
                                                
                                                //Schema.DescribeFieldResult f = Schema.sObjectType.ElixirSuite__Object_2__c.fields.ElixirSuite__Case__c;
                                                //System.debug('Relationship Name: ' + f.getRelationshipName());    
                                            }
                                        }
                                    }
                }
            }
            else {
                childCSSRecord.Data_Type__c = String.valueOf(mapOfchildCSSRecord.get('table_fieldSelected'));
                childCSSRecord.ElixirSuite__Is_matrix__c = false;
            }
            toInsertChildrecords.add(childCSSRecord);    
        }           
    } 
    
    
    return heading;
}
public static String collectHeading(List<Object> table_Heading){         
    String postVal = '';
    Integer size  = table_Heading.size();
    Integer i = 1;
    for(Object headingsObj : table_Heading){
        Map<String, Object> mapOfHeadingRecord = (Map<String, Object>) headingsObj;
        String heading  = String.valueOf(mapOfHeadingRecord.get('heading'));  
        if(i!=size){
            if(String.isBlank(heading)){
                postVal += ';'; 
            }
            else{
                postVal+= heading+';';  
            }
        }
        else{
            postVal+= heading;
        }
        i++;
    }        
    return postVal;
}
public static String tableDataSaving_Update(Map<String, Object> mapOfCSSData,List<Object_1_css__c> toInsertChildrecords,String parentID){
    String heading  = '';
    List<Object> table_Heading = (List<Object>) mapOfCSSData.get('table_HeadingArr');
    heading = collectHeading(table_Heading);
    List<Object> table_row = (List<Object>) mapOfCSSData.get('table_fieldLst');
    if(table_row!=null){        
        for(Object rowsObj : table_row){
            Map<String, Object> mapOfRowRecord = (Map<String, Object>) rowsObj;
            List<Object> table_col = (List<Object>) mapOfRowRecord.get('colLst');
            for(Object colsObj : table_col){
                Map<String, Object> mapOfchildCSSRecord = (Map<String, Object>) colsObj;                              
                Object_1_css__c childCSSRecord = new Object_1_css__c();
                if(String.isNotBlank(String.valueOf(mapOfchildCSSRecord.get('Id')))){ // add ID if existing record otherwise it will consider for insert 
                childCSSRecord.Id = String.valueOf(mapOfchildCSSRecord.get('Id')); 
                }  
                childCSSRecord.Object_1_css__c = parentID;
                childCSSRecord.Row__c =  Integer.valueOf(mapOfRowRecord.get('RowNumber')); // ROW WITH PARENT
                childCSSRecord.Column__c =  Integer.valueOf(mapOfchildCSSRecord.get('ColNumber')); // COL WITH CHILD
                childCSSRecord.ElixirSuite__Is_matrix__c = true;
                childCSSRecord.ElixirSuite__Select_Form_Component__c = String.valueOf(mapOfCSSData.get('formComponentVal'));
                system.debug('row col nukmber' +  Integer.valueOf(mapOfRowRecord.get('RowNumber')) + ',' +  Integer.valueOf(mapOfchildCSSRecord.get('ColNumber')));
                childCSSRecord.Field_Label_Long__c  = String.valueOf(mapOfchildCSSRecord.get('defaultLabel'));     
                if(String.valueOf(mapOfchildCSSRecord.get('table_fieldSelected')).contains(';')){     
                    List<String> selectedFiledJunction = (String.valueOf(mapOfchildCSSRecord.get('table_fieldSelected'))).split(';');               
                    if(selectedFiledJunction.size()>0 && selectedFiledJunction!=null) {
                        childCSSRecord.Data_Type__c =  selectedFiledJunction[1]; 
                        childCSSRecord.Default_Field_Label__c = selectedFiledJunction[2]; // Label of field saved in a default field regardless of the external label
                        childCSSRecord.Field_Name__c =  selectedFiledJunction[0];
                        childCSSRecord.Object_Name__c = selectedFiledJunction[3];
                        if(childCSSRecord.Data_Type__c == 'ONLYTEXT'){
                    childCSSRecord.ElixirSuite__Default_text__c  = String.valueOf(mapOfchildCSSRecord.get('defaultLabel'));
                    }
                        //  childCSSRecord.ElixirSuite__Is_formula_Field__c = ElixirOEM_FormConfigurationHelper.checkFormulaField(selectedFiledJunction[3], selectedFiledJunction[0]); //Added by vidish
                        if(String.valueOf(childCSSRecord.Data_Type__c).equalsIgnoreCase('REFERENCE')){
                                        String refObjectName = childCSSRecord.Object_Name__c;
                                        String refFieldName = childCSSRecord.Field_Name__c;
                                        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();       
                                        Schema.SObjectType leadSchema = schemaMap.get(refObjectName);        
                                        Map<String, Schema.SObjectField> fieldMap = leadSchema.getDescribe().fields.getMap();
                                        List<String> fieldApiAndFieldTypeMap = new  List<String>();
                                        for (String fieldName: fieldMap.keySet()) {
                                            if(fieldName == refFieldName){
                                                Schema.DescribeFieldResult f = fieldMap.get(fieldName).getDescribe();                                           
                                                for(Schema.SObjectType reference : f.getReferenceTo()) {
                                                    refObjectName = reference.getDescribe().getName(); 
                                                    childCSSRecord.Reference_to_object__c = refObjectName;
                                                }
                                        
                                            }
                                        }
                                    }
                    }                   
                }
                else {
                    childCSSRecord.Data_Type__c =  String.valueOf(mapOfchildCSSRecord.get('table_fieldSelected'));
                    childCSSRecord.ElixirSuite__Is_matrix__c = false;
                }
                toInsertChildrecords.add(childCSSRecord);   
       
            
            }           
        } 
    }
    return heading;
}
}