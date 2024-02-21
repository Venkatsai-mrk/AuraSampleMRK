({
    
    fetchdata : function(component, event){
        console.log("Heyyyyyyyyyy33333333333333333");
        component.set('v.mycolumns', [
            {label: 'Payer', fieldName: 'ElixirSuite__Payer__c', type: 'text'},
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
            
            var action = component.get("c.getVob");
            action.setParams({
            'accountId': component.get("v.PatientId"),
            'recordtypeLabel' : component.get("v.headerLabel"),
            'recName' : component.get("v.heading")   
            });
            
            action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var res = response.getReturnValue();
                var vobLst = [];
                var selectedRowsIds =[];
                var firstId='';
                vobLst =res.vobList;
               
                     if(vobLst.length >0){
                        firstId = vobLst[0].Id;
                    }
                    for(let rec in vobLst){
                    if(!$A.util.isUndefinedOrNull(vobLst[rec].ElixirSuite__Payer__c)){    
                    vobLst[rec]['ElixirSuite__Payer__c'] = vobLst[rec].ElixirSuite__Payer__r.Name;
                    }
                    var st = vobLst[rec].ElixirSuite__VOB_Verification_Status__c;
                    console.log('st',st);
                        if(!$A.util.isUndefinedOrNull(vobLst[rec].ElixirSuite__VOB_Verification_Status__c)){
                            var atl = st.replace(/(<([^>]+)>)/gi, "");
                            console.log(atl);
                            //vobLst[rec]['ElixirSuite__Payer__c'] = 
                            vobLst[rec]['ElixirSuite__VOB_Verification_Status__c'] = st.replace(/(<([^>]+)>)/gi, "");
                        }
                    
                        
                }
                    selectedRowsIds.push(firstId);
                    console.log('vobLst '+JSON.stringify(vobLst));
                    component.set("v.VobList", vobLst);
                    component.set("v.displayTable", true);
                    component.set("v.selectedRows", selectedRowsIds);
                    component.set('v.selectedVOBList', vobLst[0]);
                    component.set("v.recordTypeId",res.recTypeid);
                    
                   
            }
        });
        $A.enqueueAction(action);
        
    },
    fetchInsDetail : function(cmp,event){
       console.log("Hututu") 
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