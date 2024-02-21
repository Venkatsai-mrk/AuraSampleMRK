({
    getMarRecord : function(component, helper, fromDate, toDate) {
        var action = component.get("c.getMARForRangeApex");
        action.setParams({
            "fromDate" : fromDate,
            "toDate" : toDate,
            "recordVal" : component.get("v.recordId")
        });
        action.setCallback(this,function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var aggregateWrapper = response.getReturnValue();
                 console.log('Aggregate Data:', aggregateWrapper);
                
                var aggregateList = aggregateWrapper.statList;
                var nameSpace=aggregateWrapper.nameSpace;
                component.set("v.nameSpace",nameSpace);
                    console.log('Aggregate Data list'+JSON.stringify(aggregateWrapper));
                /* for(var scheduledTime in aggregateList){
                        
                    var milliseconds = parseInt((taggregateList[scheduledTime] % 1000) / 100),
                    seconds = Math.floor((aggregateList[scheduledTime] / 1000) % 60),
                    minutes = Math.floor((aggregateList[scheduledTime] / (1000 * 60)) % 60),
                    hours = Math.floor((aggregateList[scheduledTime] / (1000 * 60 * 60)) % 24);
                
                hours = (hours < 10) ? "0" + hours : hours;
                minutes = (minutes < 10) ? "0" + minutes : minutes;
                seconds = (seconds < 10) ? "0" + seconds : seconds;
                var newTime =  hours + ":" + minutes ;
                aggregateList[scheduledTime]=newTime;
                    }
                    */
           //     component.set("v.totalPages", Math.ceil(masterData.length/component.get("v.pageSize")));
                component.set("v.allData", aggregateList);
                 component.set("v.allDataCopy", aggregateList);
           //     component.set("v.currentPageNumber",1);
            //    helper.sortData(component, helper, "Name", "asc");
            }
        });
        $A.enqueueAction(action);
    },

    //for sorting data
    sortData: function (component, helper, fieldName, sortDirection) {
        var changeValue = component.get("v.value");
        if(changeValue == 'agents'){
            var data = component.get("v.allData");
            var reverse = sortDirection !== 'asc';
            data.sort(this.sortBy(fieldName, reverse))
            component.set("v.allData", data);
            helper.buildData(component, helper);
        }
        else{
            var dataCC = component.get("v.allDataCC");
            var reverse = sortDirection !== 'asc';
            dataCC.sort(this.sortBy(fieldName, reverse))
            component.set("v.allDataCC", dataCC);
            helper.buildData(component, helper)
        }
    },
    
    //for selecting order of sorting
    sortBy: function (field, reverse, primer) {
        var key = primer ?
            function(x) {return primer(x[field])} :
        function(x) {return x[field]};
        reverse = !reverse ? 1 : -1;
        return function (a, b) {
            return a = key(a), b = key(b), reverse * ((a > b) - (b > a));
        }
    },
    
    
    /*
     * this function will build table data
     * based on current page selection
     * */
    buildData : function(component, helper) {
        var changeValue = component.get("v.value");
        if(changeValue == 'agents'){
            var data = [];
            var pageNumber = component.get("v.currentPageNumber");
            var pageSize = component.get("v.pageSize");
            var allData = component.get("v.allData");
            var x = (pageNumber-1)*pageSize;
            
            //creating data-table data
            for(; x<=(pageNumber)*pageSize; x++){
                if(allData[x]){
                    data.push(allData[x]);
                }
            }
            component.set("v.data", data);
            
            helper.generatePageList(component, pageNumber);
        }
        else{
            var dataCC = [];
            var pageNumber = component.get("v.currentPageNumber");
            var pageSize = component.get("v.pageSize");
            var allDataCC = component.get("v.allDataCC");
            var x = (pageNumber-1)*pageSize;
            
            //creating data-table data
            for(; x<=(pageNumber)*pageSize; x++){
                if(allDataCC[x]){
                    dataCC.push(allDataCC[x]);
                }
            }
            component.set("v.myData", dataCC);
            
            helper.generatePageList(component, pageNumber);  
        }
    },
    
    /*
     * this function generate page list
     * */
    generatePageList : function(component, pageNumber){
        pageNumber = parseInt(pageNumber);
        var pageList = [];
        var totalPages = component.get("v.totalPages");
        if(totalPages > 1){
            if(totalPages <= 10){
                var counter = 2;
                for(; counter < (totalPages); counter++){
                    pageList.push(counter);
                } 
            } else{
                if(pageNumber < 5){
                    pageList.push(2, 3, 4, 5, 6);
                } else{
                    if(pageNumber>(totalPages-5)){
                        pageList.push(totalPages-5, totalPages-4, totalPages-3, totalPages-2, totalPages-1);
                    } else{
                        pageList.push(pageNumber-2, pageNumber-1, pageNumber, pageNumber+1, pageNumber+2);
                    }
                }
            }
        }
        component.set("v.pageList", pageList);
    },
    
})