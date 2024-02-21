({  
    getUsers : function(component, event) {
        
        var action = component.get("c.getUserNames");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                try{
                    var storeResponse = response.getReturnValue();
                    var tempArr = [];
                    if(storeResponse.length >0){
                        for(var i=0;i<storeResponse.length; i++){
                            var obj ={'label': storeResponse[i].Name, 'value':storeResponse[i].Id};
                            tempArr.push(obj);
                        }
                    }
                    console.log('userId',tempArr);
                    component.set("v.userOptions", tempArr);
                    this.createObjectData(component, event);
                    
                }catch(e){
                    alert(e);
                }
            }
        });
        
        
        
        $A.enqueueAction(action);  
        
    },
    createObjectData: function(component, event) {
      
        var Id = component.get("v.accId");
        var RowItemList = component.get("v.MedicalExamList");
        
      /*  var examType=[
            {value:"--None--",label:"--None--"},
            {value:"Vital Signs",label:"Vital Signs"},
            {value:"Medical Test",label:"Medical Test"},
            {value:"HEDIS Measures",label:"HEDIS Measures"}        
        ];
        
        var subType=[{
             value:"--None--",label:"--None--"
        }];*/
        var frquencyOpts = [
            {value:"--None--",label:"--None--"},
            { value: "Every 2 hours", label: "Every 2 hours" },
            { value: "Every 4 hours", label: "Every 4 hours" },
            { value: "Every 6 hours", label: "Every 6 hours"},
            { value:"Every 8 hours",label:"Every 8 hours"},
            { value:"Every 12 hours",label:"Every 12 hours"},
            { value:"Once Daily", label:"Once Daily"}
            
        ];
       var userId = $A.get("$SObjectType.CurrentUser.Id");
        RowItemList.push({
            
            'ExaminationType':'',
            'SubType': '',
            'StartTime': '',
            'EndTime' : '',
            'Frequency' : '',
            'Notes' : '',
            'Assignee' : userId,
            'subtypedisable' : false,
            'starttimedisable' : false,
            'frequencydisable' : false,
            'subTypeOptions' : [],
            'AccountId' : Id
        });



        component.set("v.frequencyOptions", frquencyOpts);
     //   component.set("v.ExaminationTypeOptions", examType);
      //  component.set("v.SubTypeOptions", subType);
      //  component.set("v.MedicalExamList", []);      
        component.set("v.MedicalExamList", RowItemList);
        
        var action = component.get("c.getURL");
        
        action.setParams({
            "accountId": component.get("v.accId")
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                try{
                    var storeResponse = response.getReturnValue();
                    
                    console.log('storeResponse',storeResponse);
                    
                    component.set("v.url", storeResponse);
                    
                }catch(e){
                    alert(e);
                }
            }
        });
        
        
        
        $A.enqueueAction(action);  
        
        
    },
  dataSave : function(component,event,helper){
      var action = component.get("c.taskManagement");
      var selectdate = component.get("v.duedate");
      if(component.get("v.selectedTest") == 'Vital Sign'){
          selectdate = component.get("v.endDateTime");
      }  
      
        action.setParams({
            "checkType": component.get("v.selectedTest"),
             "medicalTesttype": component.get("v.selectedmedicaltype"),
             "selecteddate": selectdate,
             "notes": component.get("v.note"),
             "assigneId": component.get("v.userId"),
             "accountId": component.get("v.accId")
            
        });
        
        
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state ==='SUCCESS'){
                try{
                    
                    var res = response.getReturnValue();
                    console.log('res',res);
                    alert('success');
                    
                }
                catch(e)
                {
                    alert(e);
                }
            }
        });
        $A.enqueueAction(action);
  },
    saveTsk : function(component,event,helper){
        var action = component.get("c.saveTask");
        console.log('lst ',JSON.stringify({'key' : component.get("v.MedicalExamList")}));
        action.setParams({
            "stringifiedExaminationLst":  JSON.stringify({'key' : component.get("v.MedicalExamList")})
        });
        
        
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state ==='SUCCESS'){
                try{
                    
                    var res = response.getReturnValue();
                    sforce.one.showToast({
                        "title": "Success!",
                        "message": "Medical Examinations have been scheduled for the patient!",
                        "type": "success"
                    });
                    
                    var url = component.get("v.url");
                    sforce.one.navigateToURL(url);
                }
                catch(e)
                {
                    alert(e);
                }
            }
        });
        $A.enqueueAction(action);
  }
})