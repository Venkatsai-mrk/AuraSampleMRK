({
	
     myAction : function(component, event, helper,initial) {
         if(initial == true){
             let childComponent = component.find("childComponent");
             
             var forclose = childComponent.find("lookup-pill");
             $A.util.addClass(forclose, 'slds-hide');
             $A.util.removeClass(forclose, 'slds-show');
             
             
             var forclose = childComponent.find("searchRes");
             $A.util.addClass(forclose, 'slds-is-open');
             $A.util.removeClass(forclose, 'slds-is-close');
             
             
             var lookUpTarget = childComponent.find("lookupField");
             $A.util.addClass(lookUpTarget, 'slds-show');
             $A.util.removeClass(lookUpTarget, 'slds-hide');
             
         }
        component.set('v.mycolumns', [
            {label: 'Insured First Name', fieldName: 'ElixirSuite__Insured_First_Name__c', type: 'text'},
            {label: 'Insured Last Name', fieldName: 'ElixirSuite__Insured_Last_Name__c', type: 'text'},
            {label: 'Insurance Policy Number', fieldName: 'ElixirSuite__Member_Id__c', type: 'text'},
            {label: 'Insurance Plan Name', fieldName: 'ElixirSuite__Insurance_Plan_Name__c', type: 'text'},
            {label: 'Patient Relationship with Insured', fieldName: 'ElixirSuite__Patient_Relationship_With_Insured__c', type: 'text',
            sortable: true,
            cellAttributes: { alignment: 'left' },
            },
            {label: 'Insurance Status', fieldName: 'ElixirSuite__Status__c', type: 'text',
            sortable: true,
            cellAttributes: { alignment: 'left' },},
            {label: 'Insurance Verification Status', fieldName: 'ElixirSuite__VOB_Verification_Status__c', type: "richText",
            sortable: true,
            cellAttributes: { alignment: 'left' },},
            {label: 'Insurance verification date', fieldName: 'ElixirSuite__Last_Verified_Date__c', type: 'date',
            sortable: true,
            cellAttributes: { alignment: 'left' },
            },
            {label: 'VOB Created Date', fieldName: 'CreatedDate', type: 'date',
             sortable: true,
            cellAttributes: { alignment: 'left' },
            }
        ]);
      /*  var action = component.get("c.fetchRecords");
      
        action.setParams({
            'accountId': component.get("v.recordId"),
            'recordtypeLabel' : component.get("v.headerLabel")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {*/
              //  var res = response.getReturnValue();
                var payerLst = [];
                  //  payerLst =res.payerList;
                 payerLst =component.get("v.payerList");
         console.log('payerLst '+JSON.stringify(component.get("v.payerList")));
                var vobLst = [];
              var vobLstFinal = [];
         var vobLstSinglePayer = [];
                var selectedRowsIds =[];
                var firstId='';
              var singleVOB = false;
                //vobLst =res.vobList;
                vobLst =component.get("v.VobList");
         console.log('vobLst '+JSON.stringify(component.get("v.VobList")));  
               vobLst.forEach(function(element, index) {
                     if(element.ElixirSuite__Set_Default_VOB__c == 'Yes'){
                         vobLstFinal.push(element);
                          singleVOB = true;
                       }                        
                     }); 
         const unique = [];
         for (const item of vobLstFinal) {
             const isDuplicate = unique.find((obj) => obj.ElixirSuite__Payer__c === item.ElixirSuite__Payer__c);
             if (!isDuplicate) {
                 unique.push(item);
             }
         }
         console.log('unique ',JSON.stringify(unique));
         console.log('unique.length ',unique.length);
                console.log('payerLst',payerLst);
         if(vobLstFinal.length >= 1 && unique.length==1){
             let payerList = {Id:vobLstFinal[0].ElixirSuite__Payer__c, Name: vobLstFinal[0].ElixirSuite__Payer__r.Name};
             console.log('payerLst id',payerList);
             console.log('payerLst name',vobLstFinal[0].ElixirSuite__Payer__r.Name);
             
             component.set("v.selectedPayer" , payerList);
             component.set("v.SelectRecordName" , vobLstFinal[0].ElixirSuite__Payer__r.Name);
             
                    
                    if(vobLstFinal.length >0){
                        firstId = vobLstFinal[0].Id;
                    }
                    for(let rec in vobLstFinal){
                    var st = vobLstFinal[rec].ElixirSuite__VOB_Verification_Status__c;
                    console.log('st',st);
                        if(!$A.util.isUndefinedOrNull(vobLstFinal[rec].ElixirSuite__VOB_Verification_Status__c)){
                            var atl = st.replace(/(<([^>]+)>)/gi, "");
                            console.log(atl);
                            vobLstFinal[rec]['ElixirSuite__VOB_Verification_Status__c'] = st.replace(/(<([^>]+)>)/gi, "");
                        }
                    
                        
                }
                    selectedRowsIds.push(firstId);
                    console.log('vobLst select payer '+JSON.stringify(vobLstFinal));
                    component.set("v.VobList", vobLstFinal);
                    component.set("v.displayTable", true);
                    component.set("v.selectedRows", selectedRowsIds);
                    component.set('v.selectedVOBList', vobLstFinal[0]);
                    console.log('payerLst',vobLst);
                    console.log('payerLst',selectedRowsIds);
                    
                    let childComponent = component.find("childComponent");
                    
                    var forclose = childComponent.find("lookup-pill");
                    $A.util.addClass(forclose, 'slds-show');
                    $A.util.removeClass(forclose, 'slds-hide');
                    
                    var forclose = childComponent.find("searchRes");
                    $A.util.addClass(forclose, 'slds-is-close');
                    $A.util.removeClass(forclose, 'slds-is-open');
                    
                    var lookUpTarget = childComponent.find("lookupField");
                    $A.util.addClass(lookUpTarget, 'slds-hide');
                    $A.util.removeClass(lookUpTarget, 'slds-show');
                    
                }else{
                    if(payerLst.length > 1){
                        component.set("v.VobList", []);
                        component.set("v.selectedRows", []);
                         component.set("v.selectedPayer", {} );
                    }
                    if(vobLst.length >0){
                        firstId = vobLst[0].Id;
                    }
                    
                }
         //   }
       // });
       // $A.enqueueAction(action);
	},
    sortData : function(component,fieldName,sortDirection){
            var data = component.get("v.VobList");
            //function to return the value stored in the field
            var key = function(a) { return a[fieldName]; }
                var reverse = sortDirection == 'asc' ? 1: -1;
                
                data.sort(function(a,b){
            var a = key(a) ? key(a) : '';
            var b = key(b) ? key(b) : '';
            return reverse * ((a>b) - (b>a));
        });
        component.set("v.VobList",data);
    },
   
})