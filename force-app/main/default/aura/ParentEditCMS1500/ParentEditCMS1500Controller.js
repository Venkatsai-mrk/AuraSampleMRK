({
    myAction : function(component, event, helper) {
          var pageRef = component.get( "v.pageReference" );
        var strInp = pageRef.state.c__strInput;
        console.log('test--',strInp );
        component.set("v.claimId" , strInp); 
        component.set("v.callClaimSubmit" , true);
        component.set("v.closeSection" , false);
    }
   
})