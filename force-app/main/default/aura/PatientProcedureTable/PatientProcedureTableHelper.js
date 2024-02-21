({
	setColumns: function(component) {
        var actions = [
            {label: '$', name: 'Amount'},
            {label: '%', name: 'Percentage'}
        ];
         component.set('v.columns', [
                //{label: 'Procedure Name', fieldName: 'ElixirSuite__Procedure_Name__c', type: 'text', sortable :true}   ,
             {label: 'Procedure Name', fieldName: 'ElixirSuite__Procedure__c', type: 'button', typeAttributes: { label: { fieldName: 'ElixirSuite__Procedure_Name__c' }, target: '_blank', name: 'Link', variant: 'Base' }},
                {label: 'DOS', fieldName: 'ElixirSuite__Date_Of_Service__c', type: 'date', sortable :true, typeAttributes: {  
                day: 'numeric',  
                month: 'short',  
                year: 'numeric'  
                }},
                {label: 'Status', fieldName: 'ElixirSuite__Procedure__r.ElixirSuite__Status__c', type: 'text', sortable :true},
                {label: 'Claim Generated', fieldName: 'ElixirSuite__Procedure__r.ElixirSuite__Claim_Generation__c', type: 'text', sortable :true},
                {label: 'Billed Amount', fieldName: 'ElixirSuite__Actual_Price__c', type : 'currency', sortable :true,cellAttributes: { alignment: 'left' }},
                {label: 'Primary Insurance Paid Amount', fieldName: 'ElixirSuite__Insurance_Paid__c', type : 'currency', sortable :true,cellAttributes: { alignment: 'left' }},
                {label: 'Secondary Insurance Paid Amount', fieldName: 'ElixirSuite__Secondary_Insurance_Paid__c', type : 'currency', sortable :true,cellAttributes: { alignment: 'left' }},
                {label: 'Adjustment Amount', fieldName: 'ElixirSuite__Total_Adjustment_Amount__c', type : 'currency', sortable :true,cellAttributes: { alignment: 'left' }},
                {label: 'Patient Responsibility', fieldName: 'ElixirSuite__Patient_Responsibility__c', type : 'currency', sortable :true,cellAttributes: { alignment: 'left' }},
                {label: 'Total Discount', fieldName: 'ElixirSuite__Other_Discount__c', type : 'currency', sortable :true,cellAttributes: { alignment: 'left' }},
             	{label: 'Add Discount',
                fieldName: 'discountStr',
                type: 'button' ,typeAttributes:
                { label: { fieldName: 'discountStr'}, title: 'Click to Add Discount', 
                variant:'base', 
                name: 'recLink', 
                iconName: 'utility:add',
                class: 'slds-align_absolute-center',
                target: '_blank'
                }},
                {label: 'Patient Paid Amount', fieldName: 'ElixirSuite__Total_Actual_Patient_Paid_Amount__c', type: 'currency', sortable :true,cellAttributes: { alignment: 'left' }},
                {label: 'Patient Outstanding', fieldName: 'ElixirSuite__PatientOutstanding__c', type : 'currency', sortable :true,cellAttributes: { alignment: 'left' }},
            ]);
             
             component.set('v.allCol1', [
                {label: 'Procedure Name', fieldName: 'ElixirSuite__Procedure__c', type: 'button', typeAttributes: { label: { fieldName: 'ElixirSuite__Procedure_Name__c' }, target: '_blank', name: 'Link', variant: 'Base' }},
                {label: 'DOS', fieldName: 'ElixirSuite__Date_Of_Service__c', type: 'date', sortable :true, typeAttributes: {  
                day: 'numeric',  
                month: 'short',  
                year: 'numeric'  
                }},
                {label: 'Claim Generated', fieldName: 'ElixirSuite__Procedure__r.ElixirSuite__Claim_Generation__c', type: 'text', sortable :true},
                {label: 'Billed Amount', fieldName: 'ElixirSuite__Actual_Price__c', type : 'currency', sortable :true,cellAttributes: { alignment: 'left' }},
                {label: 'Primary Insurance Paid Amount', fieldName: 'ElixirSuite__Insurance_Paid__c', type : 'currency', sortable :true,cellAttributes: { alignment: 'left' }},
                {label: 'Secondary Insurance Paid Amount', fieldName: 'ElixirSuite__Secondary_Insurance_Paid__c', type : 'currency', sortable :true,cellAttributes: { alignment: 'left' }},
                {label: 'Adjustment Amount', fieldName: 'ElixirSuite__Total_Adjustment_Amount__c', type : 'currency', sortable :true,cellAttributes: { alignment: 'left' }},
                {label: 'Patient Responsibility', fieldName: 'ElixirSuite__Patient_Responsibility__c', type : 'currency', sortable :true,cellAttributes: { alignment: 'left' }},
             	{label: 'Total Discount', fieldName: 'ElixirSuite__Other_Discount__c', type : 'currency', sortable :true,cellAttributes: { alignment: 'left' }},
                {label: 'Patient Paid Amount', fieldName: 'ElixirSuite__Total_Actual_Patient_Paid_Amount__c', type: 'currency', sortable :true,cellAttributes: { alignment: 'left' }},
                {label: 'Patient Outstanding', fieldName: 'ElixirSuite__PatientOutstanding__c', type : 'currency', sortable :true,cellAttributes: { alignment: 'left' }},
            ]);

             
        component.set('v.columns1', [
                {label: 'Procedure Name', fieldName: 'ElixirSuite__Procedure__c', type: 'button', typeAttributes: { label: { fieldName: 'ElixirSuite__Procedure_Name__c' }, target: '_blank', name: 'Link', variant: 'Base' }},
                {label: 'DOS', fieldName: 'ElixirSuite__Date_Of_Service__c', type: 'date', sortable :true, typeAttributes: {  
                day: 'numeric',  
                month: 'short',  
                year: 'numeric'  
                }},
                {label: 'Status', fieldName: 'ElixirSuite__Procedure__r.ElixirSuite__Status__c', type: 'text', sortable :true},
                {label: 'Claim Generated', fieldName: 'ElixirSuite__Procedure__r.ElixirSuite__Claim_Generation__c', type: 'text', sortable :true},
                {label: 'Claim No', fieldName: 'ProcedureClaim', type : 'text', sortable :true},
                {label: 'Billed Amount', fieldName: 'ElixirSuite__Actual_Price__c', type : 'currency', sortable :true,cellAttributes: { alignment: 'left' }},
                {label: 'Primary Insurance Paid Amount', fieldName: 'ElixirSuite__Insurance_Paid__c', type : 'currency', sortable :true,cellAttributes: { alignment: 'left' }},
                {label: 'Secondary Insurance Paid Amount', fieldName: 'ElixirSuite__Secondary_Insurance_Paid__c', type : 'currency', sortable :true,cellAttributes: { alignment: 'left' }},
                {label: 'Adjustment Amount', fieldName: 'ElixirSuite__Total_Adjustment_Amount__c', type : 'currency', sortable :true,cellAttributes: { alignment: 'left' }},
                {label: 'Patient Responsibility', fieldName: 'ElixirSuite__Patient_Responsibility__c', type : 'currency', sortable :true,cellAttributes: { alignment: 'left' }},
                {label: 'Total Discount', fieldName: 'ElixirSuite__Other_Discount__c', type : 'currency', sortable :true,cellAttributes: { alignment: 'left' }},
                {
                label: 'Add Discount',
                fieldName: 'discountStr',
                type: 'button' ,typeAttributes:
                { label: { fieldName: 'discountStr'}, title: 'Click to Add Discount', 
                variant:'base', 
                name: 'recLink', 
                iconName: 'utility:add', 
                class: 'slds-align_absolute-center',
                target: '_blank'
                }
                },
                {label: 'Patient Paid Amount', fieldName: 'ElixirSuite__Total_Actual_Patient_Paid_Amount__c', type: 'currency', sortable :true,cellAttributes: { alignment: 'left' }},
                {label: 'Patient Outstanding', fieldName: 'ElixirSuite__PatientOutstanding__c', type : 'currency', sortable :true,cellAttributes: { alignment: 'left' }},
                
            ]);

            component.set('v.allIns1', [
                {label: 'Procedure Name', fieldName: 'ElixirSuite__Procedure__c', type: 'button', typeAttributes: { label: { fieldName: 'ElixirSuite__Procedure_Name__c' }, target: '_blank', name: 'Link', variant: 'Base' }},
                {label: 'DOS', fieldName: 'ElixirSuite__Date_Of_Service__c', type: 'date', sortable :true, typeAttributes: {  
                day: 'numeric',  
                month: 'short',  
                year: 'numeric'  
                }},
                {label: 'Claim Generated', fieldName: 'ElixirSuite__Procedure__r.ElixirSuite__Claim_Generation__c', type: 'text', sortable :true},
                {label: 'Claim No', fieldName: 'ProcedureClaim', type : 'text', sortable :true},
                {label: 'Billed Amount', fieldName: 'ElixirSuite__Actual_Price__c', type : 'currency', sortable :true,cellAttributes: { alignment: 'left' }},
                {label: 'Primary Insurance Paid Amount', fieldName: 'ElixirSuite__Insurance_Paid__c', type : 'currency', sortable :true,cellAttributes: { alignment: 'left' }},
                {label: 'Secondary Insurance Paid Amount', fieldName: 'ElixirSuite__Secondary_Insurance_Paid__c', type : 'currency', sortable :true,cellAttributes: { alignment: 'left' }},
                {label: 'Adjustment Amount', fieldName: 'ElixirSuite__Total_Adjustment_Amount__c', type : 'currency', sortable :true,cellAttributes: { alignment: 'left' }},
                {label: 'Patient Responsibility', fieldName: 'ElixirSuite__Patient_Responsibility__c', type : 'currency', sortable :true,cellAttributes: { alignment: 'left' }},
             	{label: 'Total Discount', fieldName: 'ElixirSuite__Other_Discount__c', type : 'currency', sortable :true,cellAttributes: { alignment: 'left' }},
                {label: 'Patient Paid Amount', fieldName: 'ElixirSuite__Total_Actual_Patient_Paid_Amount__c', type: 'currency', sortable :true,cellAttributes: { alignment: 'left' }},
                {label: 'Patient Outstanding', fieldName: 'ElixirSuite__PatientOutstanding__c', type : 'currency', sortable :true,cellAttributes: { alignment: 'left' }},
                
            ]);
            
        component.set('v.columns2',[
            {label: 'Procedure Name', fieldName: 'ElixirSuite__Procedure__c', type: 'button', typeAttributes: { label: { fieldName: 'ElixirSuite__Procedure_Name__c' }, target: '_blank', name: 'Link', variant: 'Base' }},
            /*{label: 'CPT Code', fieldName: 'procedureName', type: 'text', sortable :true}  , */          
            {label: 'DOS', fieldName: 'ElixirSuite__Date_Of_Service__c', type: 'date', sortable :true, typeAttributes: {  
                day: 'numeric',  
                month: 'short',  
                year: 'numeric'  
                }},
            {label: 'Status', fieldName: 'ElixirSuite__Procedure__r.ElixirSuite__Status__c', type: 'text', sortable :true},
            {label: 'Billed Amount', fieldName: 'ElixirSuite__Actual_Price__c', type: 'currency', sortable :true,cellAttributes: { alignment: 'left' }}  ,
            {label: 'Total Discount', fieldName: 'ElixirSuite__Other_Discount__c', type : 'currency', sortable :true,cellAttributes: { alignment: 'left' }},
            {
                label: 'Add Discount',
                fieldName: 'discountStr',
                type: 'button' ,typeAttributes:
                { label: { fieldName: 'discountStr'}, title: 'Click to Add Discount', 
                variant:'base', 
                name: 'recLink', 
                iconName: 'utility:add', 
                class: 'slds-align_absolute-center',
                target: '_blank'
                }
            },
            {label: 'Paid Amount', fieldName: 'ElixirSuite__Total_Actual_Patient_Paid_Amount__c', type: 'currency',sortable :true,cellAttributes: { alignment: 'left' }} 
            , {label: 'Remaining Amount', fieldName: 'ElixirSuite__PatientOutstanding__c', type: 'currency',sortable :true,cellAttributes: { alignment: 'left' }}  ,   
            
        ]);

            component.set('v.allPriv1',[
            {label: 'Procedure Name', fieldName: 'ElixirSuite__Procedure__c', type: 'button', typeAttributes: { label: { fieldName: 'ElixirSuite__Procedure_Name__c' }, target: '_blank', name: 'Link', variant: 'Base' }},    
            {label: 'DOS', fieldName: 'ElixirSuite__Date_Of_Service__c', type: 'text', sortable :true, typeAttributes: {  
                 day: 'numeric',  
                month: 'short',  
                year: 'numeric'
                }}  ,
            {label: 'Billed Amount', fieldName: 'ElixirSuite__Actual_Price__c', type: 'currency', sortable :true,cellAttributes: { alignment: 'left' }}  ,
            {label: 'Total Discount', fieldName: 'ElixirSuite__Other_Discount__c', type : 'currency', sortable :true,cellAttributes: { alignment: 'left' }},
            {label: 'Paid Amount', fieldName: 'ElixirSuite__Total_Actual_Patient_Paid_Amount__c', type: 'currency',sortable :true,cellAttributes: { alignment: 'left' }} 
            , {label: 'Remaining Amount', fieldName: 'ElixirSuite__PatientOutstanding__c', type: 'currency',sortable :true,cellAttributes: { alignment: 'left' }}  ,   
            
        ]);

    }, 
    navigateToRecordDetail: function(component, event, helper) {
         var action = event.getParam('action');
        var row = event.getParam('row');
        
        var procrecordId = row['ElixirSuite__Procedure__c'];
        
        var navService = component.find("navService");
        var pageReference = {
            type: 'standard__recordPage',
            attributes: {
                recordId: procrecordId,
                objectApiName: 'ElixirSuite__Procedure__c',
                actionName: 'view'
            }
        };

        navService.navigate(pageReference);
    },
    
    displayDetails:function(component, event, helper){	
       var action = component.get("c.getdata");
       action.setParams({ accountId : component.get("v.recordId") });
       action.setCallback(this, function(response) {
       var state = response.getState();
       console.log('!@!@2',response.getReturnValue());
       if (state === "SUCCESS") {     
            var result = response.getReturnValue();
            helper.procedureData(component,result);
            
       }
       });
            
       $A.enqueueAction(action);
		
	},
    procedureData :function(component, result){
            var allData =result.procData;
            let allproceduredata = [];
            let insurancedata = [];
            let privatedata = [];
            var claimsList = result.claimData;
        	 let allProcedureOnMT = allData;
                if(!$A.util.isEmpty(allData)){
                    allData.forEach(function(element) {
                        if(element.hasOwnProperty('ElixirSuite__Procedure__r')){
                            element['ElixirSuite__Procedure__r.ElixirSuite__Status__c'] = element.ElixirSuite__Procedure__r.ElixirSuite__Status__c;
                        }
                    });                         
                }
            for(var recdata in result.procData){
            	if(allData[recdata].ElixirSuite__Procedure__r.ElixirSuite__Claim_Generation__c == true){
                        
                    allData[recdata]['ElixirSuite__Procedure__r.ElixirSuite__Claim_Generation__c'] = 'Yes';
                    
                }else if(allData[recdata].ElixirSuite__Procedure__r.ElixirSuite__Claim_Generation__c == false){
                    
                    allData[recdata]['ElixirSuite__Procedure__r.ElixirSuite__Claim_Generation__c'] = 'No';
                    
                }
        		if(allData[recdata].ElixirSuite__Procedure__r.ElixirSuite__Claim__r!=null){
                    allData[recdata]['ProcedureClaim'] = allData[recdata].ElixirSuite__Procedure__r.ElixirSuite__Claim__r.Name;
                }
                if(allData[recdata].RecordTypeId == result.insuranceId){
                    insurancedata.push(allData[recdata]);
                }
            	if(allData[recdata].RecordTypeId == result.privateId){
                    privatedata.push(allData[recdata]);
                }
            }
        
        	console.log('!@!@1',claimsList);
         	for(var i in claimsList){
                claimsList[i]['Selected'] = false;
                claimsList[i]['ShowProc'] = false;
                claimsList[i]['NoOfSelectedProcs'] = 0;
                claimsList[i]['ClaimName'] = claimsList[i].claimName;
                claimsList[i]['ClaimId'] = claimsList[i].claimId;
                claimsList[i]['OpenProc'] = claimsList[i].openProc;
                claimsList[i]['TotalAllowed'] = claimsList[i].totalAllowed;
                claimsList[i]['InsuranceResp'] =claimsList[i].insuranceResp;
                claimsList[i]['PatientResp'] = claimsList[i].patientResp;
                if(claimsList[i].procWrap != null && claimsList[i].procWrap != undefined)
                {
                    var procWrap = claimsList[i].procWrap;
                    var count = 1;
                    for(var j in claimsList[i].procWrap)
                    {
                        procWrap[j]['SNo'] = count+'.';
                        procWrap[j]['Selected'] = false;
                        procWrap[j]['ProcId'] =claimsList[i].procWrap[j].Id;
                        procWrap[j]['ElixirSuite__PatientOutstanding__c'] =claimsList[i].procWrap[j].ElixirSuite__PatientOutstanding__c;
                        procWrap[j]['ElixirSuite__Procedure_Name__c'] = claimsList[i].procWrap[j].ElixirSuite__Procedure_Name__c;
                        procWrap[j]['ElixirSuite__Date_Of_Service__c'] = claimsList[i].procWrap[j].ElixirSuite__Date_Of_Service__c;
                     //   procWrap[j]['ElixirSuite__Procedure__r.ElixirSuite__Status__c'] = claimsList[i].procWrap[j].ElixirSuite__Procedure__r.ElixirSuite__Status__c;
                        if (isNaN(claimsList[i].procWrap[j].ElixirSuite__Patient_Responsibility__c)) 
                        {
                            procWrap[j]['ElixirSuite__Patient_Responsibility__c'] = 0;
                        }
                        else
                        {
                            procWrap[j]['ElixirSuite__Patient_Responsibility__c'] = claimsList[i].procWrap[j].ElixirSuite__Patient_Responsibility__c;
                        }
                        count = count + 1;
                    }
                    claimsList[i]['procWrap'] = procWrap;
                }
            }
        	component.set("v.Allprocedures",result.procData);
        	component.set("v.claimsList",claimsList);
            component.set("v.InsuranceData",insurancedata);
            component.set("v.PrivateData",privatedata);
        	console.log('!@!@4',component.get("v.claimsList"));
            
        },

        sortData : function(component,fieldName,sortDirection){
        var proceduretype = component.get("v.procedureType");
        var data = [];
        if(proceduretype == 'All Procedures')
        {
            data = component.get("v.Allprocedures");
        }else if(proceduretype == 'Insurance Procedures')
        {
            data = component.get("v.InsuranceData");
        }else if(proceduretype == 'Private Procedures')
        {
            data = component.get("v.PrivateData");
        }
        //function to return the value stored in the field
        var key = function(a) { return a[fieldName]; }
        var reverse = sortDirection == 'asc' ? 1: -1;
        
        data.sort(function(a,b){
            var c = key(a) ? key(a) : '';
            var d = key(b) ? key(b) : '';
            return reverse * ((c>d) - (d>c));
        });
        if(proceduretype == 'All Procedures')
        {
            component.set("v.Allprocedures",data);
        }else if(proceduretype == 'Insurance Procedures')
        {
            component.set("v.InsuranceData",data);
        }else if(proceduretype == 'Private Procedures')
        {
            component.set("v.PrivateData",data);
        }
        
    },
        
    getProcedureRec : function(cmp, event, helper){
        var procsFromClaimList =[];
        cmp.get("v.claimsList").forEach((item)=>{
            item.procWrap.forEach((innerItem)=>{
            if(innerItem.Selected==true){
            procsFromClaimList.push(innerItem);
        }
        })
        })
       cmp.set("v.selectedProcedureRows",procsFromClaimList);
       console.log('selectedProcedureRows--',cmp.get("v.selectedProcedureRows"));
        var cmpEvent = cmp.getEvent("procedurehandlerEvent");
        cmpEvent.setParams( { "procedureList" :  procsFromClaimList,
                             "Type" : cmp.get("v.procedureType")} );
        cmpEvent.fire();
    },
         globalFlagToast : function(cmp, event, helper,title,message,type) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message":  message,
            "type" :type
        });
        toastEvent.fire();
    }
})