({
    toggleSection : function(component, event, helper) {
        
        var sectionAuraId = event.target.getAttribute("data-auraId");
        var sectionDiv = component.find(sectionAuraId).getElement();
        
        var sectionState = sectionDiv.getAttribute('class').search('slds-is-open'); 
        
        if(sectionState == -1){
            sectionDiv.setAttribute('class' , 'slds-section slds-is-open');
        }else{
            sectionDiv.setAttribute('class' , 'slds-section slds-is-close');
        }
    },
    doInit : function(component, event, helper) {
        helper.initialize(component, event, helper);
    }
})