({
    getAccountIdFromURL : function(component) {
        try {
           const contextAttributes = JSON.parse(atob(component.get('v.pageReference').state.inContextOfRef.substring(2))).attributes;
           let accountId = contextAttributes.objectApiName === 'Account' ? contextAttributes.recordId : '';
  

           if($A.util.isUndefinedOrNull(accountId) || $A.util.isEmpty(accountId)){
            try{
            let nonAttributes = JSON.parse(atob(component.get('v.pageReference').state.inContextOfRef.substring(2))).state.ws;
            // Define a regular expression as a string to match Salesforce record Ids
            let regexString = "\\/([a-zA-Z0-9]{15}|[a-zA-Z0-9]{18})\\/";
            let regex = new RegExp(regexString);
            
            // Use the regular expression to find matches in the URL
            let matches = nonAttributes.match(regex);
            
            // Extract the recordId from the matches
            accountId = matches ? matches[1] : null;
            console.log('AccountId==='+accountId);
            }catch(e){
                console.log(e);
            }
        }
            
            if (accountId) {
                component.set("v.accountId", accountId);
                component.set("v.isAccountIdPrePopulated", true);
            }
            else {
                component.set("v.isAccountIdPrePopulated", false);
            }
        } catch (error) {
            component.set("v.accountId", "");
            component.set("v.isAccountIdPrePopulated", false);
            console.log('Failed to fetch accountId. Possibly called from reservation list view, no account id required here anyway:');
            console.warn(error);
        }
    }
})