({
    doInit : function(component, event, helper){
        
        
    },
    onfocus : function(component,event,helper){
        $A.util.addClass(component.find("mySpinner"), "slds-show");
        var forOpen = component.find("searchRes");
        $A.util.addClass(forOpen, 'slds-is-open');
        $A.util.removeClass(forOpen, 'slds-is-close');
        // Get Default 5 Records order by createdDate DESC  
        var getInputkeyWord = '';
        helper.searchHelper(component,event,getInputkeyWord);
    },
    onblur : function(component,event,helper){       
        component.set("v.listOfSearchRecords", null );
        var forclose = component.find("searchRes");
        $A.util.addClass(forclose, 'slds-is-close');
        $A.util.removeClass(forclose, 'slds-is-open');
    },
    keyPressController : function(component, event, helper) {
        // get the search Input keyword   
        var getInputkeyWord = component.get("v.SearchKeyWord");
        // check if getInputKeyWord size id more then 0 then open the lookup result List and 
        // call the helper 
        // else close the lookup result List part.   
        if( getInputkeyWord.length > 0 ){
            var forOpen = component.find("searchRes");
            $A.util.addClass(forOpen, 'slds-is-open');
            $A.util.removeClass(forOpen, 'slds-is-close');
            helper.searchHelper(component,event,getInputkeyWord);
        }
        else{  
            component.set("v.listOfSearchRecords", null ); 
            var forclose = component.find("searchRes");
            $A.util.addClass(forclose, 'slds-is-close');
            $A.util.removeClass(forclose, 'slds-is-open');
        }
    },
    
    // function for clear the Record Selaction 
    clear :function(component,event,heplper){
        
        var pillTarget = component.find("lookup-pill");
        var lookUpTarget = component.find("lookupField"); 
        
        $A.util.addClass(pillTarget, 'slds-hide');
        $A.util.removeClass(pillTarget, 'slds-show');
        
        $A.util.addClass(lookUpTarget, 'slds-show');
        $A.util.removeClass(lookUpTarget, 'slds-hide');
        
        component.set("v.SearchKeyWord",null);
        component.set("v.listOfSearchRecords", null );
        component.set("v.selectedRecord", {} );   
        
        var AllRowsList = component.get('v.VaccineList');
        var vaccineIndex = component.get('v.index');
        
        AllRowsList[vaccineIndex].Vaccine = '';
        AllRowsList[vaccineIndex].CvxCode = '';
        AllRowsList[vaccineIndex].Route = '';
        AllRowsList[vaccineIndex].VaccineSite = '';
        AllRowsList[vaccineIndex].VaccineSeries = ''
        AllRowsList[vaccineIndex].Id = ''
        AllRowsList[vaccineIndex].Name = '';
        
         component.set("v.VaccineList" , AllRowsList);
    },
    
    // This function call when the end User Select any record from the result list.   
    handleComponentEvent : function(component, event, helper) {
        
        var selectedAccountGetFromEvent = event.getParam("recordByEvent");
        var AllRowsList = component.get('v.VaccineList');
        var vaccineIndex = component.get('v.index');
        
        AllRowsList[vaccineIndex].Vaccine = selectedAccountGetFromEvent;
        AllRowsList[vaccineIndex].CvxCode = selectedAccountGetFromEvent.ElixirSuite__CVX_Code__c;
        AllRowsList[vaccineIndex].Route = selectedAccountGetFromEvent.ElixirSuite__Vaccine_Route__c;
        AllRowsList[vaccineIndex].VaccineSite = selectedAccountGetFromEvent.ElixirSuite__Vaccine_Site__c;
        AllRowsList[vaccineIndex].VaccineSeries = selectedAccountGetFromEvent.ElixirSuite__Vaccine_Series__c;
        AllRowsList[vaccineIndex].Id = selectedAccountGetFromEvent.Id;
        AllRowsList[vaccineIndex].Name = selectedAccountGetFromEvent.Name;
        if(vaccineIndex >0){
            var lastAddedTemplate =-1;
            for(var i=0;i<AllRowsList.length-1; i++){
               
                if(AllRowsList[i].Id == selectedAccountGetFromEvent.Id){
                    lastAddedTemplate = i;
                }
            }
            console.log("lastAddedTemplate",lastAddedTemplate);
            if(lastAddedTemplate >-1){
                var days =selectedAccountGetFromEvent.ElixirSuite__Next_Dose_in_Series_After__c;
                console.log('today',AllRowsList[lastAddedTemplate].AdministratioDate);
                var d;
                if(AllRowsList[lastAddedTemplate].AdministratioDate){
                    var today = AllRowsList[lastAddedTemplate].AdministratioDate;
                    
                    d= new Date(today).setDate(new Date(today).getDate() + days);
                    console.log('1',d);
                    
                }else{
                    d = new Date().setDate(new Date().getDate() + days);
                }                
                AllRowsList[vaccineIndex].AdministratioDate =$A.localizationService.formatDate(d, "yyyy-MM-dd");
                   // $A.localizationService.formatDate(d, "MMMM dd yyyy");
                AllRowsList[vaccineIndex].status = 'Planned';
            }
        }
       
        
        component.set("v.selectedRecord" , selectedAccountGetFromEvent);
        component.set("v.SelectRecordName" , selectedAccountGetFromEvent.Name);
        component.set("v.VaccineList" , AllRowsList);
        
        var forclose = component.find("lookup-pill");
        $A.util.addClass(forclose, 'slds-show');
        $A.util.removeClass(forclose, 'slds-hide');
        
        var forclose = component.find("searchRes");
        $A.util.addClass(forclose, 'slds-is-close');
        $A.util.removeClass(forclose, 'slds-is-open');
        
        var lookUpTarget = component.find("lookupField");
        $A.util.addClass(lookUpTarget, 'slds-hide');
        $A.util.removeClass(lookUpTarget, 'slds-show');  
        
        
    },
})