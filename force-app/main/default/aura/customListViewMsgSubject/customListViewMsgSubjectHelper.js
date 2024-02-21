({
    filterListView: function (component, event, helper) {
        
        var accId = component.get("v.patientID");
        var searchKeyWord = component.get("v.searchKeyword");
        var filterValue = component.get("v.filterVal");
        
        var action = component.get("c.fetchFilterRec");
        console.log('accId***', accId);
        action.setParams({ 'accountId': accId ,
                          'filter': filterValue,
                          'searchKeyword' :searchKeyWord,
                          "limits": component.get("v.initialRows"),
            			  "offsets": component.get("v.rowNumberOffset")});
        
        action.setCallback(this, function (response) {
            var result = response.getReturnValue();
            component.set("v.currentCount", component.get("v.initialRows"));
            console.log(result+' result');
            //  let toAddCol = [];
            var state = response.getState();
            console.log(state+' state');
            if (state === "SUCCESS") {
                 component.set("v.loaded",false); 
                for (var i = 0; i < result.length; i++) {
                    var row = result[i];
                    if (row.CreatedBy) {
                        row.CreatedBy = row.CreatedBy.Name;
                    }
                }
                component.set("v.Originaldata", result);
                component.set("v.data", result);
            }
            else {
                console.log("failure");
            }
        });
        $A.enqueueAction(action);
    },
    getTotalInitRecords : function(component, event, helper) {
        var accId = component.get("v.patientID");
         var searchKeyWord = component.get("v.searchKeyword");
         var filterValue = component.get("v.filterVal");
         
         var action = component.get("c.fetchFilterRecCount");
         console.log('accId***', accId);
         action.setParams({ 'accountId': accId ,
                           'filter': filterValue,
                           'searchKeyword' :searchKeyWord
                          });
         
         action.setCallback(this, function (response) {
             var result = response.getReturnValue();
              component.set("v.totalNumberOfRows", result);
              helper.filterListView(component, event, helper);//added by Anmol
         });
         $A.enqueueAction(action);
     },
    getTotalRecords : function(component, event, helper) {
       var accId = component.get("v.patientID");
        var searchKeyWord = component.get("v.searchKeyword");
        var filterValue = component.get("v.filterVal");
        
        var action = component.get("c.fetchFilterRecCount");
        console.log('accId***', accId);
        action.setParams({ 'accountId': accId ,
                          'filter': filterValue,
                          'searchKeyword' :searchKeyWord
                         });
        
        action.setCallback(this, function (response) {
            var result = response.getReturnValue();
             component.set("v.totalNumberOfRows", result);
             helper.getDataNoLoadMore(component, event, helper);
             console.log('totalNumberOfRows'+ result);
            
        });
        $A.enqueueAction(action);
    },
    getDataNoLoadMore : function(component, event, helper) {
        helper.filterListView(component, event, helper);//added by Anmol
    },
    getData : function(component, event, helper) {
        console.log('siva');
        //Display a spinner to signal that data is being loaded
        event.getSource().set("v.isLoading", true);
        //Display "Loading" when more data is being loaded
        component.set('v.loadMoreStatus', 'Loading');
        helper.fetchData(component, component.get('v.rowsToLoad')).then($A.getCallback(function (data) {
            if (component.get('v.data').length >= component.get('v.totalNumberOfRows')) {
                component.set('v.enableInfiniteLoading', false);
                component.set('v.loadMoreStatus', 'No more data to load');
            } else {
                var currentData = component.get('v.data');
                //Appends new data to the end of the table
                var newData = currentData.concat(data);
                component.set('v.data', newData);
                component.set('v.loadMoreStatus', 'Please wait ');
            }
            event.getSource().set("v.isLoading", false);
        }));
    },
  
    
    fetchData: function(component , rows){
        var accId = component.get("v.patientID");
        var searchKeyWord = component.get("v.searchKeyword");
        var filterValue = component.get("v.filterVal");
        return new Promise($A.getCallback(function(resolve, reject) {
            var action = component.get('c.fetchFilterRec');
            var counts = component.get("v.currentCount");
            console.log('accId'+accId);
             console.log('searchKeyWord'+searchKeyWord);
             console.log('filterValue'+filterValue);
             console.log('initialRows'+component.get("v.initialRows"));
            console.log('counts'+counts);
            action.setParams({
               			  'accountId': accId ,
                          'filter': filterValue,
                          'searchKeyword' :searchKeyWord,
                          "limits": component.get("v.initialRows"),
                		  "offsets": counts 
            });
            action.setCallback(this, function(a) {
                console.log('result on load more '+a.getReturnValue());
                resolve(a.getReturnValue());
                var countstemps = component.get("v.currentCount");
                countstemps = countstemps+component.get("v.initialRows");
                component.set("v.currentCount",countstemps);
                
            });
            
            $A.enqueueAction(action);
            
            
        }));
        
    } ,

    sortData : function(component,fieldName,sortDirection){
        var data = component.get("v.data");
        var key = function(a) { return a[fieldName]; }
        var reverse = sortDirection == 'asc' ? 1: -1;
        
        data.sort(function(a,b){
            var a = key(a) ? key(a) : '';
            var b = key(b) ? key(b) : '';
            return reverse * ((a>b) - (b>a));
        });
        let count = 1;
        data.forEach(function(element, index) {
            element['SNo'] = count;
            count++;
        }); 
        component.set("v.data",data);
    },
    fetchAccountName : function(component, event, helper){
        var action = component.get("c.getAccountName");
        action.setParams({
            "accountId": component.get("v.patientID")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var accName = response.getReturnValue();
                component.set("v.accName",accName);
            }
            else{
                console.log("failure" , response.getError());
            }
        });
        $A.enqueueAction(action);
    }
})