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
                component.set("v.selectedLabel", component.get("v.msname"));
            } else if(selectedOptions.length > maxSelectionShow){
                component.set("v.selectedLabel", selectedOptions.length+' Options Selected');
            } else{
                var selections = '';
                selectedOptions.forEach(option => {
                    selections += option.ElixirSuite__Description__c+',';
                });
                    
                component.set("v.selectedLabel", selections.slice(0, -1));
                    
            }
                    var selections1 = '';
                selectedOptions.forEach(option => {
                    selections1 += option.ElixirSuite__Description__c+'.';
                });
                    component.set("v.selectedLabelDuplicate" ,selections1);
    },
                    
    onOptionClick: function(component, ddOption) {
            //get clicked option id-name pair
            var clickedValue = {"Id":ddOption.closest("li").getAttribute('data-id'),
                                "ElixirSuite__Description__c":ddOption.closest("li").getAttribute('data-name')};
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
        this.setPickListName(component, selectedOptions);
        component.set("v.selectedOptions" , selectedOptions);
       // console.log("test" , JSON.stringify(component.get("v.selectedOptions" )));
    //    component.set("v.selectedOptionsString" , JSON.stringify(selectedOptions));
    /* var evidenceVal = component.get("v.msoptions");
        evidenceVal['listOfEvidences'] = selectedOptions ;
         console.log("test----" , evidenceVal);*/
       component.set("v.msOptionList" , component.get("v.selectedOptions" ));
         console.log("test----" , component.get("v.msOptionList"));
        
    },
               
})