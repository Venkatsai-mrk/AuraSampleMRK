({
	createObjectData : function(component, event) {
        try{
            console.log('updated medicationList in helper')
           console.log('@@@@medicationList',component.get("v.medicationList"));
		var RowItemList = component.get("v.medicationList");
        RowItemList.push({
            'sobjectType': 'ElixirSuite__Prescription_Order__c',
            'MedicationId': '',
            'MedicationName':'',
            'Strength': '',
            'Status': '',
            'Direction': '',
            'PrescribedBy':'',
            'StartDate':new Date(),
            'EndDate':new Date(),
            'Notes':'',
            'ElixirSuite__Account__c' : component.get("v.patientID")
        });
             
        component.set("v.medicationList", RowItemList); 
        }
        catch(e){
            console.log('Error at add medications:   '+e)
        }
	},
    getUser : function(component, event, helper) {
        var action = component.get("c.getCurrentlyLoggedInUser");
        console.log('AccountId--'+component.get("v.AccountId"));
        action.setCallback(this, function (response){
            component.set("v.CurrentUserDetails",response.getReturnValue());
            console.log("user details-"+JSON.stringify(component.get("v.CurrentUserDetails")));
        });
        $A.enqueueAction(action);
        
    },
    
    fetchPicklistValues: function(component, event) {
        var action = component.get("c.picklistValues");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                let statusPickList = response.getReturnValue().statusPickListValues; 
                let arr = [];
                for(let obj in statusPickList){
                        let sObj = {'label' : obj, 'value' : statusPickList[obj]};
                        arr.push(sObj);
                    }
                console.log('list val '+JSON.stringify(arr));
                    component.set("v.statusList",arr);
                
                let directionPickList = response.getReturnValue().directionPickListValues; 
                let direction = [];
                for(let obj in directionPickList){
                        let sObj = {'label' : obj, 'value' : directionPickList[obj]};
                        direction.push(sObj);
                    }
                console.log('list val '+JSON.stringify(direction));
                    component.set("v.directionPickList",direction);
            } else {
                console.error('Error fetching picklist values: ' + state);
            }
        });
        $A.enqueueAction(action);
    }
})