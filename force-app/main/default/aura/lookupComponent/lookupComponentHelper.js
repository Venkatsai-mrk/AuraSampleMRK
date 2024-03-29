({
    searchRecordsHelper : function(component, event, helper, value) {
        
        var searchString = component.get('v.searchString').trim();
        
        component.set('v.message', '');
        component.set('v.recordsList', []);
        let stringLen = searchString.length;
        if(stringLen >= component.get("v.forSearchCharLimit")){
        $A.util.removeClass(component.find("Spinner"), "slds-hide");
        var action = component.get('c.fetchRecords');// initiate a single callabck
        // Calling Apex Method
        action.setParams({
            'objectName' : component.get('v.objectName'),
            'filterField' : component.get('v.fieldName'),
            'filterClause' : component.get('v.filterClause'),
            'searchString' : searchString,
            'value' : value,
            'accountId':component.get('v.accountId')
        });
        action.setCallback(this,function(response){
            var result = response.getReturnValue();
            if(response.getState() === 'SUCCESS') {
                if(!$A.util.isUndefinedOrNull(result) && result.length > 0) {
                    // To check if value attribute is prepopulated or not
                    if( $A.util.isEmpty(value) ) {
                        component.set('v.recordsList',result);        
                    } else {
                        component.set('v.selectedRecord', result[0]);
                    }
                } else {
                    component.set('v.message', "No Records Found for '" + searchString + "'");
                }
            } else {
                // If server throws any error
                var errors = response.getError();
                if (errors && errors[0] && errors[0].message) {
                    component.set('v.message', errors[0].message);
                }
            }
            // To open the drop down list of records
            if( $A.util.isEmpty(value) )
                $A.util.addClass(component.find('resultsDiv'),'slds-is-open');
            $A.util.addClass(component.find("Spinner"), "slds-hide");
        });
        $A.enqueueAction(action);
        }
    }
})
/*
Code by CafeForce
Website: http://www.cafeforce.com
DO NOT REMOVE THIS HEADER/FOOTER FOR FREE CODE USAGE
*/