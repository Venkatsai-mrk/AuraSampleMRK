({
    
    pageOpenDecision : function(component, event, helper) {
        try{
            var message = event.getParam("pageNumber");         
            console.log('files '+JSON.stringify(component.get("v.files")));
            let lengthOfDiagnosisLst=0;
            let patientDiagnosisLstValues= component.get("v.patientDiagnosisLst");
            patientDiagnosisLstValues.forEach(element=>{
                if(element.isSelected){
                lengthOfDiagnosisLst++;
                
            }        });
            component.set("v.patientDiagnosisLstLength",lengthOfDiagnosisLst);
            let lengthOfPatientProcedureLst=0;
            
            let patientProcedureLstValues= component.get("v.patientProcedureLst");
            patientProcedureLstValues.forEach(element=>{
                if(element.isSelected){
                lengthOfPatientProcedureLst++;
                
            }        });
            component.set("v.patientProcedureLstLength",lengthOfPatientProcedureLst);
            let lengthOfFileLst=0;
            component.get("v.files").forEach(element=>{
                if(element.isSelected){
                lengthOfFileLst++;
                
            }        });
            component.set("v.fileListSize",lengthOfFileLst);
               console.log(component.get("v.fileListSize"));
            if(message == 'One'){
                
                helper.setFlySyncDataForPageOne(component, event, helper);
                // Hide Page 1
                var pageOne = component.find("pageOne");
                $A.util.toggleClass(pageOne, 'slds-hide');  
                // Hide Page 3
                var pageThree = component.find("pageThree");       
                $A.util.removeClass(pageThree, "slds-show");
                $A.util.addClass(pageThree, "slds-hide");  
                // Open page 2
                var pageTwo = component.find("pageTwo");       
                $A.util.removeClass(pageTwo, "slds-hide");
                $A.util.addClass(pageTwo, "slds-show");         
            }
            else if(message == 'Two'){
                
                helper.setFlySyncDataForPageTwo(component, event, helper);
                // Hide Page 1
                var pageOne = component.find("pageOne");       
                $A.util.removeClass(pageOne, "slds-show");
                $A.util.addClass(pageOne, "slds-hide");       
                // Hide Page 2
                var pageTwo = component.find("pageTwo");
                $A.util.removeClass(pageTwo, "slds-show");
                $A.util.addClass(pageTwo, "slds-hide");                  
                // Open page 3
                var pageThree = component.find("pageThree");       
                $A.util.removeClass(pageThree, "slds-hide");
                $A.util.addClass(pageThree, "slds-show");      
            }
                else if(message == 'BackFromTwo'){
                    
                    // Open Page 1 
                    var pageOne = component.find("pageOne");       
                    $A.util.removeClass(pageOne, "slds-hide");
                    $A.util.addClass(pageOne, "slds-show"); 
                    // Hide Page 2
                    var pageTwo = component.find("pageTwo");
                    $A.util.removeClass(pageTwo, "slds-show");
                    $A.util.addClass(pageTwo, "slds-hide");  
                    // Hide page 3
                    var pageThree = component.find("pageThree");       
                    $A.util.removeClass(pageThree, "slds-show");
                    $A.util.addClass(pageThree, "slds-hide");   
                    
                    
                }
                    else if(message == 'BackFromThree'){
                        // hide Page 1 
                        var pageOne = component.find("pageOne");       
                        $A.util.removeClass(pageOne, "slds-show");
                        $A.util.addClass(pageOne, "slds-hide"); 
                        // open Page 2
                        var pageTwo = component.find("pageTwo");
                        $A.util.removeClass(pageTwo, "slds-hide");
                        $A.util.addClass(pageTwo, "slds-show");  
                        // Hide page 3
                        var pageThree = component.find("pageThree");       
                        $A.util.removeClass(pageThree, "slds-show");
                        $A.util.addClass(pageThree, "slds-hide");   
                    }
        }
        catch(e){
            alert('container error '+e);
        }
    }
})