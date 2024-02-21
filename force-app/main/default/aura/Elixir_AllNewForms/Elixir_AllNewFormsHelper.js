({
	filterByCategoryIfCategoryProvided : function(cmp, event, helper) {   
        var action = cmp.get("c.filterFormsIfUserDefinedCategoryGiven");
        cmp.set("v.searchKey",'');
        action.setParams({
            "category": cmp.get("v.customCategory") 
        });
       
        action.setCallback(this, function(a) {
            
            var allData=  a.getReturnValue(); 
            console.log('123 '+allData);
            var b = [];
            for (var i = 0; i < allData.length; i++) {
                console.log('inside for' +b);
                b[i] = {
                    'label': allData[i],
                    'value': allData[i]
                };                 
            }
            console.log('response + data  bee  '+JSON.stringify(b));       
            cmp.set("v.options", b);
             cmp.set("v.customCategoryResults", JSON.parse(JSON.stringify(b)));
            cmp.set("v.optionsForSearching", JSON.parse(JSON.stringify(b)));
            
        });
        $A.enqueueAction(action);
        
    },
   getCustomFormsHelper : function(component, event, helper, actionType) {
        return new Promise(function(resolve, reject) {
            var flag = false;
            var action = component.get('c.getCustomForms');
            action.setParams({
                "actionType": actionType,
            });
            action.setCallback(this, function(response) {
                var state = response.getReturnValue();
                if(state.length>0){
                    component.set("v.customFormCmp", state);
                    flag = true;
                }
                console.log(JSON.stringify(state));
                resolve(flag);
            });
            $A.enqueueAction(action);
        });
    },
	myAction : function(component, event, helper) {   
        console.log('inti');
        try{
             var action = component.get("c.fetchAllForms");
        // alert(component.get("v.categorized"));
        action.setParams({
            "category": component.get("v.categorized"),
            "subCategory": '',
            "accountId": component.get("v.patientID")
        });
        action.setCallback(this, function(response) {
          
            
            console.log('accname '+component.get('v.patientID'));
            var state = response.getState();
            if (state === "SUCCESS") {
            var data = response.getReturnValue();
            console.log('response + data  '+JSON.stringify(data));       
            component.set("v.accName",data);
            var res = data.formNames;
            // component.set('v.accName',data.accName);
                var a = res;
                var b = [];
                for (var i = 0; i < res.length; i++) {
                    console.log('inside for' +b);
                    b[i] = {
                        'label': res[i],
                        'value': res[i]
                    };
                    
                }
                console.log('response + data  bee  '+JSON.stringify(b));       
                component.set("v.options", b);
                component.set("v.optionsForSearching", JSON.parse(JSON.stringify(b)));
            }
            
        });
        
        $A.enqueueAction(action);
         
        }
        catch(e){
        }
        //alert(JSON.stringify(component.get("v.accName")));
      
        
    },
})