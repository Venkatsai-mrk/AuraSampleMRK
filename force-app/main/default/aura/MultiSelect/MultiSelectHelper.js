({
    /**
     * This function will close all multi-select drop down on the page
     * */
    closeAllDropDown: function() {
        //Close drop down by removing slds class
        Array.from(document.querySelectorAll('#ms-picklist-dropdown')).forEach(function(node){
            node.classList.remove('slds-is-open');
        });
    },
    
    
    /**
     * This function will be called on drop down button click
     * It will be used to show or hide the drop down
     * */
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
    
    /**
     * This function will handle clicks on within and outside the component
     * */
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
        console.log('==selectoptions after click===',component.get("v.selectedOptions"));
        console.log('==selectoptions after click==='+JSON.stringify(component.get("v.selectedOptions")));
        //added by Neha
        const idToSelectedOptionsMap =[] ;
        var selectOptionsList = component.get("v.selectedOptions");
        if(!$A.util.isUndefinedOrNull(selectOptionsList)){
            for(let i=0;i<selectOptionsList.length;i++){
                var currentEraId = component.get("v.eraId");
                //console.log('===currentEraId==='+currentEraId);
                var optionValue = selectOptionsList[i].Name;
                //console.log('===optionValue==='+optionValue);
                const obj = {Id:currentEraId,Value:optionValue}
                //console.log('===obj==='+JSON.stringify(obj)); 
                idToSelectedOptionsMap.push(obj);
            }
        }
        if(idToSelectedOptionsMap.length!=0){
            
            //calling picklist event to pass values to the line item component 
            let picklistEvent = component.getEvent("sendInfoRemarks");
            //console.log('===picklistEvent==='+picklistEvent);
            picklistEvent.setParams({"infoRemarksValues":idToSelectedOptionsMap}); 
            picklistEvent.fire();
            //end- Neha
        }
    },
    //Added by Neha 
    setPills:function(component,event,helper){
        component.set("v.showPills",true);
        
    }, 
    //
    //Added by Neha 
    initialsetPills:function(component,event,helper){
        //  component.set("v.selectedOptions",'');
        var alreadySelectedList = component.get("v.infoAlreadySelected");
        /*var xyz = [];
        for(var i =0;i<alreadySelectedList.length;i++){
            if(alreadySelectedList[i].Name!='()' && alreadySelectedList[i].Name!='')
                xyz.push(alreadySelectedList[i]);
        }
        if(xyz.length>0){
        component.set("v.selectedOptions",xyz);
             component.set("v.showPills",true);
        }*/
        if($A.util.isUndefinedOrNull(alreadySelectedList)){
            alreadySelectedList = [];
        }
        if(alreadySelectedList.length>0){
        //    if(alreadySelectedList[0].Name!="()"){
                component.set("v.selectedOptions",alreadySelectedList);
                component.set("v.showPills",true);
            //    console.log('alreadySelectedList#############'+JSON.stringify(alreadySelectedList[0]));
           // }
            
            
        }
        
    }, 
    //
    //Added by Neha 
    removePillHelper:function(component, event){
        var value = event.getSource().get('v.name');
        console.log('===value is ==='+value);
        var newList = [];
        var options = component.get("v.selectedOptions");
        options.forEach( function(element, index) {
            console.log('===element is ====',element);
            if(element.Name != value ){
                newList.push(element);
            }
            
        });
        console.log('===newList====',newList);
        component.set("v.selectedOptions",newList);
        this.setPickListName(component, component.get("v.selectedOptions"));
        
        var msoptions1 = component.get("v.msoptions");
        console.log('===msoptions===',msoptions1);
        msoptions1.find(element=>element.Name==value).selected=false;
        component.set("v.msoptions",msoptions1);
        console.log('===msoptions1===',msoptions1);
        
        
    },
    //
    
    /**
     * This function will be used to filter options based on input box value
     * */
    rebuildPicklist: function(component) {
        var allSelectElements = component.getElement().querySelectorAll("li");
        Array.from(allSelectElements).forEach(function(node){
            node.classList.remove('slds-is-selected');
        });
    },
    
    /**
     * This function will be used to filter options based on input box value
     * */
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
    
    /**
     * This function clear the filters
     * */
    resetAllFilters : function(component) {
        this.filterDropDownValues(component, '');
    },
    
    /**
     * This function will set text on picklist
     * */
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
                selections += option.Name+',';
            });
                component.set("v.selectedLabel", selections.slice(0, -1));
            }
                if(component.get("v.selectedLabel")=='undefined' || component.get("v.selectedLabel")==undefined || component.get("v.selectedLabel")== '' ){
                component.set("v.selectedLabel",'');
            }
            },
                
                
                
                /* This function will be called when an option is clicked from the drop down
     * It will be used to check or uncheck drop down items and adding them to selected option list
     * Also to set selected item value in input box
     */
                onOptionClick : function(component, ddOption) {
                    console.log('==ddOption===',ddOption);
                    console.log('==ddOption==='+JSON.stringify(ddOption));
                    //get clicked option id-name pair
                    var clickedValue = {"Id":ddOption.closest("li").getAttribute('data-id'),
                                        "Name":ddOption.closest("li").getAttribute('data-name')};
                    //Get all selected options
                    var selectedOptions = component.get("v.selectedOptions");
                    //Boolean to indicate if value is alredy present
                    var alreadySelected = false;
                    //Looping through all selected option to check if clicked value is already present
                    selectedOptions.forEach((option,index) => {
                        if(option.Id === clickedValue.Id ){
                        if( !$A.util.isEmpty(clickedValue.Id)){
                        //Clicked value already present in the set
                        selectedOptions.splice(index, 1);
                        //Make already selected variable true	
                        alreadySelected = true;
                        //remove check mark for the list item
                        ddOption.closest("li").classList.remove('slds-is-selected');
                    }
                    	}
                     });
                    //If not already selected, add the element to the list
                    if(!alreadySelected ){
                        if(!$A.util.isEmpty(clickedValue.Id)){
                        selectedOptions.push(clickedValue);
                        //Add check mark for the list item
                        ddOption.closest("li").classList.add('slds-is-selected');
                    }
                    } 
                    console.log()
                    
                    //Set picklist label
                    this.setPickListName(component, selectedOptions);
                    
                    component.set("v.selectedOptions",selectedOptions);
                    
                    //
                    
                },
                
            })