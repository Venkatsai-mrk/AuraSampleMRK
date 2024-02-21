({
    doInit : function(component, event, helper) {
        helper.getUsers(component, event);
    },
    handleSave:function(component,event,helper){
        
        helper.dataSave(component,event,helper);
    },                        
    handleCancel:function(component,event,helper){
        
        var url = component.get("v.url");
        sforce.one.navigateToURL(url);
    },
    
    addNewRow: function(component, event, helper) {
        
        helper.createObjectData(component, event);
    },
    
    removeDeletedRow: function(component, event, helper) {
        
        var ctarget = event.currentTarget;
        var index = ctarget.dataset.value;
        
        var AllRowsList = component.get("v.MedicalExamList");
        AllRowsList.splice(index, 1);
        
        component.set("v.MedicalExamList", AllRowsList);
    },
    
   /* setSubType_onExamTypeChange: function(component, event, helper) {
        
        var tempArr = [];
        var index = event.getSource().get("v.name");
        var AllRowsList = component.get("v.MedicalExamList");
        if(AllRowsList[index].ExaminationType == 'Medical Test'){
            
            tempArr=[
                {value:"--None--",label:"--None--"},
                {value:"Strep Test",label:"Strep Test"},
                {value:"Spirometry",label:"Spirometry"}
            ];
            AllRowsList[index].subtypedisable = false;
            AllRowsList[index].starttimedisable = true;
            AllRowsList[index].frequencydisable = true;
            AllRowsList[index].subTypeOptions = tempArr;
        }
        if(AllRowsList[index].ExaminationType == 'Vital Signs'){
            AllRowsList[index].subtypedisable = true;
            AllRowsList[index].starttimedisable = false;
            AllRowsList[index].frequencydisable = false;
            
        } 
        if(AllRowsList[index].ExaminationType == 'HEDIS Measures'){
            tempArr=[
                {value:"--None--",label:"--None--"},
                {value:"Colonoscopy",label:"Colonoscopy"},
                {value:"Mammogram",label:"Mammogram"},
                {value:"Pap Smear",label:"Pap Smear"},
                {value:"DEXA Scan",label:"DEXA Scan"}
                
            ];
            
            AllRowsList[index].subtypedisable = false;
            AllRowsList[index].starttimedisable = true;
            AllRowsList[index].frequencydisable = true;
            AllRowsList[index].subTypeOptions = tempArr;
        }
        
        
        
        // component.set("v.SubTypeOptions", tempArr);
        component.set("v.MedicalExamList", AllRowsList);
        console.log('med',component.get("v.MedicalExamList"))
    },*/
    
    Save : function(component, event, helper) {
        helper.saveTsk(component, event, helper);
    },
    handleComponentEvent : function(component,event,helper){
        var message = event.getParam("searchValue");
        var index = event.getParam("indexVal");
        var AllRowsList = component.get("v.MedicalExamList");
        if(message != 'Vital Sign'){
            AllRowsList[index].starttimedisable = true;
            AllRowsList[index].frequencydisable = true;
        }   
        else{
             AllRowsList[index].starttimedisable = false;
            AllRowsList[index].frequencydisable = false;
        }
         component.set("v.MedicalExamList", AllRowsList);
    },
})