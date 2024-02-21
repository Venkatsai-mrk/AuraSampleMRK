({  
    getuploadedFiles:function(component){
        component.set("v.loaded",false);
        var action = component.get("c.getFiles");  
        console.log('ID for'+JSON.stringify(component.get("v.recordId")));
        action.setParams({  
            "recordId":component.get("v.recordId") ,
            "pathWay" : component.get("v.pathWay")
        });      
        action.setCallback(this,function(response){  
            var state = response.getState();  
            if(state=='SUCCESS'){ 
                component.set("v.loaded",true);
                var result = response.getReturnValue();           
                component.set("v.files",result);  
            }  
        });  
        $A.enqueueAction(action);  
    },
    
    delUploadedfiles : function(component,event,documentId) {  
        component.set("v.loaded",false);
        var action = component.get("c.deleteFiles");           
        action.setParams({
            "sdocumentId":documentId,
            "recordId": component.get("v.recordId")
        });  
        action.setCallback(this,function(response){  
            var state = response.getState();  
            if(state=='SUCCESS'){  
                component.set("v.loaded",true);
                this.getuploadedFiles(component);
              //  component.find("Id_spinner").set("v.class" , 'slds-hide'); 
            }  
        });  
        $A.enqueueAction(action);  
    },  
    
    UpdateDocument : function(component,event,docId) {  
        component.set("v.loaded",false);
        var action = component.get("c.UpdateFiles");  
        // var fName = component.find("fileName").get("v.value");  
        //alert('File Name'+fName);  
        action.setParams({"documentId":docId,                
                          "recordId": component.get("v.recordId"),
                          "pathWay" : component.get("v.pathWay")
                         });  
        action.setCallback(this,function(response){  
            var state = response.getState();  
            if(state=='SUCCESS'){  
                component.set("v.loaded",true);
                var result = response.getReturnValue();  
                console.log('Result Returned: ' +result);  
                // component.find("fileName").set("v.value", " ");  
                component.set("v.files",result);  
            }  
        });  
        $A.enqueueAction(action);  
    },  
    
    
})