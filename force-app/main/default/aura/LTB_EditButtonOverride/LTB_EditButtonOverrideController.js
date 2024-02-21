({
	myAction : function(component, event, helper) {
        const queryString = window.location.href; 
        
        console.log(queryString);
        
        var result = queryString.indexOf("ElixirSuite__Lab_Test_Bundle__c");
        var id = queryString.substring(result+32,result+50);
        component.set("v.recordId",id);
        console.log('Id ltb ' + id);
        
        var result2 = queryString.indexOf("ElixirSuite__Lab__c");
        var id2 = queryString.substring(result2+22,result2+40);
        component.set("v.labId",id2);
        console.log('Id lab ' + id2);
        
	}
})