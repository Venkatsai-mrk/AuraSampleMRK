({
  
    closeAllDropDown: function() {
        //Close drop down by removing slds class
        Array.from(document.querySelectorAll('#ms-picklist-dropdown')).forEach(function(node){
            node.classList.remove('slds-is-open');
        });
    },

    onDropDownClick: function(dropDownDiv) {
        //Getting classlist from component
        var classList = Array.from(dropDownDiv.classList);
        if(!classList.includes("slds-is-open")){
            //First close all drp down
            this.closeAllDropDown();
            //Open dropdown by adding slds class
            dropDownDiv.classList.add('slds-is-open');
        } else{
           //Close all drp down
            this.closeAllDropDown();
        }
        
    },
    
    handleClick: function(component, event, where) {
        //getting target element of mouse click
        var tempElement = event.target;
        
        var outsideComponent = true;
        //click indicator
        //1. Drop-Down is clicked
        //2. Option item within dropdown is clicked
        //3. Clicked outside drop-down
        //loop through all parent element
        while(tempElement){
            if(tempElement.id === 'ms-list-item'){
                //2. Handle logic when picklist option is clicked
                //Handling option click in helper function
                if(where === 'component'){
                	this.onOptionClick(component, event.target);
                }
                outsideComponent = false;
                break;
            } else if(tempElement.id === 'ms-dropdown-items'){
                //3. Clicked somewher within dropdown which does not need to be handled
                //Break the loop here
                outsideComponent = false;
                break;
            } else if(tempElement.id === 'ms-picklist-dropdown'){
                //1. Handle logic when dropdown is clicked
                if(where === 'component'){
                	this.onDropDownClick(tempElement);
                }
                outsideComponent = false;
                break;
            }
            //get parent node
            tempElement = tempElement.parentNode;
        }
        if(outsideComponent){
            this.closeAllDropDown();
         
        }
    },
    
    rebuildPicklist: function(component) {
        var allSelectElements = component.getElement().querySelectorAll("li");
        Array.from(allSelectElements).forEach(function(node){
            node.classList.remove('slds-is-selected');
        });
    },
    
    filterDropDownValues: function(component, inputText) {
        var allSelectElements = component.getElement().querySelectorAll("li");
        Array.from(allSelectElements).forEach(function(node){
            if(!inputText){
                node.style.display = "block";
            }
            else if(node.dataset.name.toString().toLowerCase().indexOf(inputText.toString().trim().toLowerCase()) != -1){
                node.style.display = "block";
            } else{
                node.style.display = "none";
            }
        }); 
    },
    
    resetAllFilters : function(component) {
        this.filterDropDownValues(component, '');
    },
    
    setPickListName : function(component, selectedOptions) {
        const maxSelectionShow = component.get("v.maxSelectedShow");
        //Set drop-down name based on selected value
        if(selectedOptions.length < 1){
            component.set("v.selectedLabel", selectedOptions.length+' Options Selected');
        } else if(selectedOptions.length > maxSelectionShow){
            component.set("v.selectedLabel", 'Template Selected');
        } else{
            var selections = '';
            selectedOptions.forEach(option => {
                selections += option.ElixirSuite__Form_Description__c+',';
            });
                 component.set("v.selectedLabel", 'Template Selected');
               // component.set("v.selectedLabel", selections.slice(0, -1));
                
            }
                var duplicateVal = component.get("v.dupVal");
                var selections1 = '';
                selectedOptions.forEach(option => {
                selections1 += option.ElixirSuite__Form_Description__c+'<br/>';
            });
                var newval = duplicateVal + selections1 ;
                if(!$A.util.isUndefinedOrNull(newval))
                newval = '';
                component.set("v.selectedLabelDuplicate" ,newval);
            },
                
   setPickListNameDup : function(component, selectedOptions, selectOpt) {
       const maxSelectionShow = component.get("v.maxSelectedShow");
       //Set drop-down name based on selected value
       if(selectedOptions.length < 1){
           component.set("v.selectedLabel", 'Template Selected');
       } else if(selectedOptions.length > maxSelectionShow){
           component.set("v.selectedLabel", 'Template Selected');
       } else{
           var selections = '';
           selectedOptions.forEach(option => {
               selections += option.ElixirSuite__Form_Description__c+',';
           });
               component.set("v.selectedLabel", 'Template Selected');
             //  component.set("v.selectedLabel", selections.slice(0, -1));
               
           }
              
               var duplicateVal = component.get("v.selectedLabelDuplicate");//abc def
               
               var selections1 = '';
               
               selections1 += selectOpt+'<br/>';
               
               var newval = duplicateVal + selections1 ;
               component.set("v.selectedLabelDuplicate" ,newval);
      },
                    
    onOptionClick: function(component, ddOption) {
        var consentData = component.get("v.consentData");
        // code for autopopulation of account and user data in macros
       var textValue = ddOption.closest("li").getAttribute('data-name');
        var column = component.get("v.column");
        //var consentData = component.get("v.consentData");
        var obj = {};
        if($A.util.isUndefinedOrNull(textValue)){
            return;
        }
        while(textValue.lastIndexOf("{") != -1){
            let lastIdx = textValue.lastIndexOf("}") + 1;
            let startIdx = textValue.lastIndexOf("{");
            var extractedTextWithinBrackets = textValue.substring(
                lastIdx-1,
                startIdx+1
            );
            if(extractedTextWithinBrackets.includes(".")){//extractedTextWithinBrackets.replace( /(<([^>]+)>)/ig, '')
                let splittedValues = extractedTextWithinBrackets.split(".");
                let objName = splittedValues[0];
                let fieldName = splittedValues[1];
                var finalValue = '';
                if(consentData.hasOwnProperty(objName)){
                    let sObj = consentData[objName];
                    if(sObj.hasOwnProperty(fieldName)){
                        finalValue = sObj[fieldName];
            }
        }
                textValue = textValue.replace('{'+ extractedTextWithinBrackets +'}',finalValue);
        }
        }
        //END code for autopopulation of account and user data in macros
        
        
            //get clicked option id-name pair
            var clickedValue = {"Id":ddOption.closest("li").getAttribute('data-id'),
                                "ElixirSuite__Form_Description__c":textValue };
       // var clickedValue1 = [ddOption.closest("li").getAttribute('data-name')];
            //Get all selected options
            var selectedOptions = component.get("v.selectedOptions");
            //Boolean to indicate if value is alredy present
            var alreadySelected = false;
            //Looping through all selected option to check if clicked value is already present
            selectedOptions.forEach((option,index) => {
                if(option.Id === clickedValue.Id){
                    //Clicked value already present in the set
                    selectedOptions.splice(index, 1);
                    //Make already selected variable true	
                    alreadySelected = true;
                    //remove check mark for the list item
                    ddOption.closest("li").classList.remove('slds-is-selected');
                }
            });
            //If not already selected, add the element to the list
            if(!alreadySelected){
                selectedOptions.push(clickedValue);
                //Add check mark for the list item
                 ddOption.closest("li").classList.add('slds-is-selected');
            }
        //Set picklist label
        this.setPickListNameDup(component, selectedOptions, clickedValue.ElixirSuite__Form_Description__c);
        component.set("v.selectedOptions" , selectedOptions);
        
        component.set("v.msOptionList" , component.get("v.selectedOptions"));
        console.log("test----" , component.get("v.msOptionList"));
        var column = component.get("v.column");
        column['formMacro'] = component.get("v.selectedLabelDuplicate");
        component.set("v.column",column);
        //console.log('all test' , JSON.stringify(component.get("v.column")));
        }
               
})