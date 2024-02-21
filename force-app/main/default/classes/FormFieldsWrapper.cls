/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 11-10-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
global class FormFieldsWrapper implements Comparable {
    public Form_Field__c oppy;
    public FormFieldsWrapper(Form_Field__c op) {
        oppy = op;
    }
    //FormFieldsWrapper object
    global Integer compareTo(Object compareTo) {      
        FormFieldsWrapper compareToOppy = (FormFieldsWrapper)compareTo;
        Integer returnValue = 0;
        if (oppy.Sequence_Order__c > compareToOppy.oppy.Sequence_Order__c) {          
            returnValue = 1;
        } else if (oppy.Sequence_Order__c < compareToOppy.oppy.Sequence_Order__c) {            
            returnValue = -1;
        }        
        return returnValue;       
    }
}