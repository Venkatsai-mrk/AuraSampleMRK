({
    fetchMasterEraData : function(cmp, event, parentEraPage,recordToDisplay) {
        cmp.set("v.loaded",false);
       
		var action = cmp.get("c.getMasterERA");
        
        action.setParams({
            fromDate : cmp.get('v.FromDate'),
            toDate : cmp.get('v.ToDate'),
            paymentTrace : cmp.get('v.paymentTrace'),
            eraId : cmp.get('v.ERA_Id'),
            payerId : cmp.get("v.selRec").value,
            eraNo : cmp.get("v.selRecERAParent").value,
            parentERAPageNo:parentEraPage,
            recordToDisplay:recordToDisplay
        });
        console.log(cmp.get('v.FromDate'));
        console.log(cmp.get('v.ToDate'));
        console.log(cmp.get('v.paymentTrace'));
        console.log(cmp.get('v.ERA_Id'));
        console.log(cmp.get('v.selRec'));
        console.log(cmp.get('v.selRecERAParent'));
        action.setCallback(this,function(resp)
        {
            if(resp.getState() == 'SUCCESS')
            {
                  cmp.set("v.loaded",true);
                if(resp.getReturnValue().parentEob != null && resp.getReturnValue().parentEob.length >0)
                {
                    
                    var MasterEraList = resp.getReturnValue().parentEob;
                    for(var i in resp.getReturnValue().parentEob)
                    {
                        MasterEraList[i]['EraName'] = resp.getReturnValue().parentEob[i].Name;
                        MasterEraList[i]['EraId'] = resp.getReturnValue().parentEob[i].ElixirSuite__EOB_Id__c;
                        MasterEraList[i]['PaymentTrace'] = resp.getReturnValue().parentEob[i].ElixirSuite__Payment_Trace__c;
                        if( resp.getReturnValue().parentEob[i].ElixirSuite__Payer__c == undefined){ 
                            MasterEraList[i]['PayerName'] = '';
                        }
                        else{
                            MasterEraList[i]['PayerName'] = resp.getReturnValue().parentEob[i].ElixirSuite__Payer__r.Name;
                        }
                        MasterEraList[i]['CreatedDate'] = resp.getReturnValue().parentEob[i].CreatedDate;
                    }
                   cmp.set('v.MasterEraList',MasterEraList);
                var parentERAPageNo=resp.getReturnValue().parentERAPageNo;
                var RecordDisplay=resp.getReturnValue().recordToDisplay;
                var totalParentERA=resp.getReturnValue().totalParentERA; 
                    
                cmp.set("v.parentEraPage", parentERAPageNo); 
                cmp.set("v.parentEraPages", Math.ceil(totalParentERA / RecordDisplay));      
                   
                }
          else
                {
                      
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : '',
                        message: 'No Data Found.',
                        type: 'info',
                        mode: 'dismissible'
                    });
                    toastEvent.fire();
                    cmp.set('v.MasterEraList',null);
                    cmp.set("v.parentEraPage", 1); 
                    cmp.set("v.parentEraPages",1); 
                   // cmp.set('v.ChildEraList',null);
                  //  cmp.set('v.showChildEraTable',false);
                  //  cmp.set('v.showEraItemsTable',false);
                    
                }
            }
                 else{ 
                        
                        var errors = resp.getError();
                        if (errors) {
                            if (errors[0] && online[0].message) {
                                console.log("Error message: " +
                                            errors[0].message);
                            }        }
                    }  
                
            
        });
        $A.enqueueAction(action);
        
	},
    
    
    fetchClaimEraData : function(cmp, event, childEraPage,recordToDisplay) {
        cmp.set("v.loaded",false);
        var ab = cmp.get("v.matched");
		var action = cmp.get("c.getClaimERA");
        action.setParams({
            fromDate : cmp.get('v.FromDateChild'),
            toDate : cmp.get('v.ToDateChild'),
            eraNo : cmp.get('v.selRecERA').value,
            patName : cmp.get('v.selRecClaim').value,
            claimId : cmp.get("v.selRecPatient").value,
            childERAPageNo:childEraPage,
            recordToDisplay:recordToDisplay
            //statusCde : cmp.get("v.statusCode"),
            // matchedUnmatched : cmp.get("v.matched")
        });
        console.log(cmp.get('v.FromDateChild'));
        console.log(cmp.get('v.ToDateChild'));
        console.log(cmp.get('v.selRecPatient'));
        console.log(cmp.get('v.selRecClaim'));
        console.log(cmp.get('v.selRecERA'));
       action.setCallback(this,function(resp)
        {
            if(resp.getState() == 'SUCCESS')
            {
                  cmp.set("v.loaded",true);
                if(resp.getReturnValue().childEob != null && resp.getReturnValue().childEob.length > 0)
                {
                    console.log('shiva sai prasad' );
                   var claimEraList = resp.getReturnValue().childEob;
                    for(var i in resp.getReturnValue().childEob)
                    {
                        claimEraList[i]['childEraName'] = resp.getReturnValue().childEob[i].Name;
                        if( resp.getReturnValue().childEob[i].ElixirSuite__Claim__c == undefined){ 
                            claimEraList[i]['ClaimNo'] = '';
                        }
                        else{
                        claimEraList[i]['ClaimNo'] = resp.getReturnValue().childEob[i].ElixirSuite__Claim__r.Name;
                        }
                        if( resp.getReturnValue().childEob[i].ElixirSuite__Account__c == undefined){ 
                           claimEraList[i]['PatientName'] = '';
                        }
                        else{
                        claimEraList[i]['PatientName'] = resp.getReturnValue().childEob[i].ElixirSuite__Account__r.Name;
                        }
                        claimEraList[i]['StatusCode'] = resp.getReturnValue().childEob[i].ElixirSuite__ERA_Status_Code__c;
                        claimEraList[i]['CreatedDate'] = resp.getReturnValue().childEob[i].CreatedDate;
                        if( resp.getReturnValue().childEob[i].ElixirSuite__Unmatched_Amount__c == 0){
                             claimEraList[i]['Matched'] = true;
                        }
                        else{
                              claimEraList[i]['Matched'] = false;
                        }
                    }
                   cmp.set('v.ChildEraList',claimEraList); 
                    
                  var childERAPageNo=resp.getReturnValue().childERAPageNo;
                  var RecordDisplay=resp.getReturnValue().recordToDisplay;
                  var totalChildERA=resp.getReturnValue().totalChildERA;  
                  cmp.set("v.childEraPage", childERAPageNo); 
                  cmp.set("v.childEraPages", Math.ceil(totalChildERA / RecordDisplay));  
                }

                else
                {
                    console.log('#### inside era else');
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : '',
                        message: 'No Data Found.',
                        type: 'info',
                        mode: 'dismissible'
                    });
                    toastEvent.fire();
                   // cmp.set('v.MasterEraList',null);
                    cmp.set('v.ChildEraList',null);
                    cmp.set("v.childEraPage", 1); 
                    cmp.set("v.childEraPages", 1);  
                  //  cmp.set('v.showChildEraTable',false);
                  //  cmp.set('v.showEraItemsTable',false);
                    
                }
                 
               // cmp.set('v.ChildEraList',claimEraList);                     
            }
        });
        $A.enqueueAction(action);
	},
    
      fetchParentEOBData : function(cmp, event,parentEraPage,recordToDisplay,childEraPage) {
        cmp.set("v.loaded",false);
         
        var action = cmp.get("c.getParentERA");
       
        action.setParams({
              parentERAPageNo:parentEraPage,
              recordToDisplay:recordToDisplay,
              childERAPageNo:childEraPage
        });  
        action.setCallback(this,function(resp)
        {
            if(resp.getState() == 'SUCCESS')
            {
                cmp.set("v.loaded",true);
                var result = resp.getReturnValue().picklistOptions;
                var parentERAPageNo=resp.getReturnValue().parentERAPageNo;
                var childERAPageNo=resp.getReturnValue().childERAPageNo;
                var RecordDisplay=resp.getReturnValue().recordToDisplay;
                var totalParentERA=resp.getReturnValue().totalParentERA;
                var totalChildERA=resp.getReturnValue().totalChildERA;
                var arr = [];
                console.log('parentERAPageNo '+parentERAPageNo);
                console.log('totalParentERA '+totalParentERA);
                for(var key in result){
                    let sObj = {'label' : key, 'value' : result[key]};
                    arr.push(sObj);
                }
                cmp.set("v.picklistMap", arr);
                
                if(resp.getReturnValue().parentEob != null && resp.getReturnValue().parentEob.length > 0)
                {
                   var MasterEraList = resp.getReturnValue().parentEob;
                    for(var i in resp.getReturnValue().parentEob)
                    {
                        MasterEraList[i]['EraName'] = resp.getReturnValue().parentEob[i].Name;
                        MasterEraList[i]['EraId'] = resp.getReturnValue().parentEob[i].ElixirSuite__EOB_Id__c;
                        MasterEraList[i]['PaymentTrace'] = resp.getReturnValue().parentEob[i].ElixirSuite__Payment_Trace__c;
                        if( resp.getReturnValue().parentEob[i].ElixirSuite__Payer__c == undefined){ 
                            MasterEraList[i]['PayerName'] = '';
                        }
                        else{
                            MasterEraList[i]['PayerName'] = resp.getReturnValue().parentEob[i].ElixirSuite__Payer__r.Name;
                        }
                        MasterEraList[i]['CreatedDate'] = resp.getReturnValue().parentEob[i].CreatedDate;
                    }   
                }
                
                if(resp.getReturnValue().childEob != null && resp.getReturnValue().childEob.length > 0)
                {
                   var claimEraList = resp.getReturnValue().childEob;
                    for(var i in resp.getReturnValue().childEob)
                    {
                        claimEraList[i]['childEraName'] = resp.getReturnValue().childEob[i].Name;
                        if( resp.getReturnValue().childEob[i].ElixirSuite__Claim__c == undefined){ 
                            claimEraList[i]['ClaimNo'] = '';
                        }
                        else{
                        claimEraList[i]['ClaimNo'] = resp.getReturnValue().childEob[i].ElixirSuite__Claim__r.Name;
                        }
                        if( resp.getReturnValue().childEob[i].ElixirSuite__Account__c == undefined){ 
                           claimEraList[i]['PatientName'] = '';
                        }
                        else{
                        claimEraList[i]['PatientName'] = resp.getReturnValue().childEob[i].ElixirSuite__Account__r.Name;
                        }
                        claimEraList[i]['StatusCode'] = resp.getReturnValue().childEob[i].ElixirSuite__ERA_Status_Code__c;
                        claimEraList[i]['CreatedDate'] = resp.getReturnValue().childEob[i].CreatedDate;
                        if( resp.getReturnValue().childEob[i].ElixirSuite__Unmatched_Amount__c == 0){
                             claimEraList[i]['Matched'] = true;
                        }
                        else{
                              claimEraList[i]['Matched'] = false;
                        }
                       
                    }   
                }
                
                cmp.set('v.MasterEraList',MasterEraList);
                cmp.set('v.ChildEraList',claimEraList);
                console.log('Before set in attribute '+parentERAPageNo +' '+totalParentERA+' '+RecordDisplay);
                cmp.set("v.parentEraPage", parentERAPageNo); 
                if(totalParentERA == 0){
                    console.log('AKKKKK');
                 cmp.set("v.parentEraPages",  cmp.get("v.parentEraPage"));   
                }else{
                cmp.set("v.parentEraPages", Math.ceil(totalParentERA / RecordDisplay));
                }
                cmp.set("v.childEraPage", childERAPageNo); 
                if(totalChildERA == 0){
                     console.log('AKKKKK11');
                cmp.set("v.childEraPages", cmp.get("v.childEraPage"));    
                }else{
                cmp.set("v.childEraPages", Math.ceil(totalChildERA / RecordDisplay));
                }
               
            }
        });
        $A.enqueueAction(action);
      },
    sortData: function (component, fieldName, sortDirection) {
        var fname = fieldName;
        var data = component.get("v.MasterEraList");
        var reverse = sortDirection !== 'asc';
        data.sort(this.sortByfield(fieldName, reverse))
        component.set("v.MasterEraList", data);
    },
    //on clicking parent ERA 
    claimEraDefaultValues : function (cmp, event){
            cmp.set("v.FromDateChild", null);
            cmp.set("v.ToDateChild", null);
            cmp.set("v.searchStringClaim", '');
            cmp.set("v.selectedPatientRec" , '');
            cmp.set("v.selRecClaim", '');
        
            cmp.set("v.selectedClaimRec", '');
            cmp.set("v.searchStringPatient" , '');
            cmp.set("v.selRecPatient", '');
        
            cmp.set("v.selectedEraRec", '');
            cmp.set("v.searchStringEra" , '');
            cmp.set("v.selRecERA", '');
        
            cmp.set("v.statusCode", null);
            cmp.set("v.matched", false);
            cmp.set("v.childSearch",false);
    },
     //on clicking claim  ERA 
    parentEraDefaultValues : function (cmp, event){
            cmp.set("v.FromDate", null);
            cmp.set("v.ToDate", null);
            cmp.set("v.paymentTrace", null);
            cmp.set("v.ERA_Id", null);
        
            cmp.set("v.selectedEraRecParent", '');
            cmp.set("v.searchStringEraParent" , '');
            cmp.set("v.selRecERAParent", '');
        
            cmp.set("v.recList", '');
            cmp.set("v.selRec" , '');
            cmp.set("v.searchString", '');
            cmp.set("v.parentSearch",false);
         },
    
    sortDataChild: function (component, fieldName, sortDirection) {
        var fname = fieldName;
        var data = component.get("v.ChildEraList");
        var reverse = sortDirection !== 'asc';
        data.sort(this.sortByfieldChild(fieldName, reverse))
        component.set("v.ChildEraList", data);
    },
    sortByfieldChild: function (field, reverse) {
        var key = function(x) {return x[field]};
        reverse = !reverse ? 1 : -1;
        return function (a, b) {
            return a = key(a), b = key(b), reverse * ((a > b) - (b > a));
        }
    },
    sortByfield: function (field, reverse) {
        var key = function(x) {return x[field]};
        reverse = !reverse ? 1 : -1;
        return function (a, b) {
            return a = key(a), b = key(b), reverse * ((a > b) - (b > a));
        }
    },
   
})