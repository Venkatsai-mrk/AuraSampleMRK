({
	checkValNull : function(component, event, helper,repSobj) {
        if($A.util.isUndefinedOrNull(repSobj.ElixirSuite__Template_Problem__r)){
            repSobj['ElixirSuite__Template_Problem__r'] = {'Name' : ''};
            repSobj['ElixirSuite__Template_Problem__r'] = {'ElixirSuite__SNOMED_CT_Code__c' : ''};
            repSobj['ElixirSuite__Template_Problem__r'] = {'ElixirSuite__Note__c' : ''};
             repSobj['ElixirSuite__Template_Problem__r'] = {'ElixirSuite__Description__c' : ''};
        }
        if($A.util.isUndefinedOrNull(repSobj.ElixirSuite__Diagnosis_Code__r)){
            repSobj['ElixirSuite__Diagnosis_Code__r'] = {'Name' : ''};
        }
    }
})