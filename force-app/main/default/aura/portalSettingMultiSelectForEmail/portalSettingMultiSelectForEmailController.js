({
	// To prepopulate the seleted value pill if value attribute is filled
    doInit : function( component, event, helper ) {
        helper.doInitHelper(component);
        console.log('===options==='+component.get('v.options'));
    },
    
    // When a keyword is entered in search box
    filterOptions : function( component, event, helper ) {
        
        if( !$A.util.isEmpty(component.get('v.searchString')) ) {
            helper.filterOptionsHelper(component);
        } else {
            $A.util.removeClass(component.find('resultsDiv'),'slds-is-open');
        }
    },
    
    // When an item is selected
    selectItem : function( component, event, helper ) {
        
        if(!$A.util.isEmpty(event.currentTarget.id)) {
            helper.selectItemHelper(component, event);
        }
    },
    
    showOptions : function( component, event, helper ) {
        
        var disabled = component.get("v.disabled");
        if(!disabled) {
            component.set("v.message", '');
            component.set("v.isDropdownOpen",true);
            component.set('v.searchString', '');
            var options = component.get("v.options");
            options.forEach( function(element,index) {
                element.isVisible = true;
            });
            component.set("v.options", options);
            if(!$A.util.isEmpty(component.get('v.options'))) {
                $A.util.addClass(component.find('resultsDiv'),'slds-is-open');
            } 
        }
       
    },
    
    // To remove the selected item.
    removePill : function( component, event, helper ){
        helper.removePillHelper(component, event);
    },
    
    // To close the dropdown if clicked outside the dropdown.
    blurEvent : function( component, event, helper ){
      
        helper.blurEventHelper(component, event);
    },
    
    
    // Show or hide the dropdown options
    changeDropdownVisibility : function( component, event, helper ){
        
      var isVisible=component.get("v.isDropdownOpen");
        console.log('isVisible before',isVisible);
      isVisible=!isVisible;
       console.log('isVisible after',isVisible);
      component.set("v.isDropdownOpen",isVisible);
    }
})