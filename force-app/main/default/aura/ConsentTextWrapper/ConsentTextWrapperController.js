({
    myAction : function(component, event, helper) {
        console.log('my Action called');
        component.find('consent_text').sendParamsToAura();   
    },
    getValueFromLwc: function(component, event, helper) {
        var column = component.get("v.column");
        var dataToSend = event.getParam('dataToSend');
        column['inputJSON'] = JSON.stringify(dataToSend.inputJSON);
        column['defaultText'] = dataToSend.defaultText;
        column['consentPdf'] = dataToSend.consentPdf;
        component.set("v.column",column);
    }
})