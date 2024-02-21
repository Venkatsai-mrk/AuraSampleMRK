({
    doInit : function(component, event, helper) {
        var monthNames = ["Jan", "Feb", "Mar", "Apr", "May", "Jun",
                          "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
                         ];
        var today = new Date();
        var dd = today.getDate();
        //var mm = monthNames[today.getMonth()]; //January is 0!
        var mm = today.getMonth() + 1; //January is 0!
        
        var yyyy = today.getFullYear();
        if(dd<10) {
            dd = '0'+dd
        }         
        if(mm<10) {
            mm = '0'+mm
        }       
        //today = mm + ' ' + dd + ', ' + yyyy;
        var todayString = yyyy + "-" + mm + "-" + dd;
         console.log('todate' , todayString);
        //component.set("v.fromDate" , todayString);
        component.set("v.toDate" , todayString);
        
        //Figure out the date one year before today which will become our lower limit
        var minDate = new Date();
        minDate.setFullYear(minDate.getFullYear() - 1);
        minDate.setDate(minDate.getDate() + 1);
        dd = minDate.getDate();
        mm = minDate.getMonth() + 1; //January is 0!
        
        var yyyy = minDate.getFullYear();
        if(dd<10) {
            dd = '0'+dd
        }         
        if(mm<10) {
            mm = '0'+mm
        }
        var minString = yyyy + "-" + mm + "-" + dd;
        console.log('fromdate' , minString);
        component.set("v.fromDate" , minString);
        
    },
    
    fetchData : function(component, event, helper) {
        var today = new Date();
        var dd = today.getDate();
        var mm = today.getMonth() + 1; //January is 0!
        
        var yyyy = today.getFullYear();
        if(dd<10) {
            dd = '0'+dd
        }         
        if(mm<10) {
            mm = '0'+mm
        }       
        //today = mm + ' ' + dd + ', ' + yyyy;
        var todayString = yyyy + "-" + mm + "-" + dd;
        var fromDate = component.get("v.fromDate");
        var toDate = component.get("v.toDate");
     //   var changeValue = component.get("v.value");
         console.log('toDate'+toDate);    
        var x=364;
        if(yyyy%4==0)
        {
            x=365;
        }
        // console.log(typeof yyyy);
        // code to subtract 1 year from current Date
        var dateToSubtract=new Date(todayString);
        dateToSubtract.setDate(dateToSubtract.getDate()-x);
        console.log('Subtracted Date'+dateToSubtract);
        component.set("v.firstvalidation",false);
        component.set("v.secondvalidation",false);
        component.set("v.thirdvalidation",false);
        component.set("v.fourthvalidation",false);
        var dateForCompare=new Date(fromDate);
       	console.log('dateForCompare'+dateForCompare);   
        if(dateForCompare>=dateToSubtract||toDate==null||fromDate==null){  //problematic
            if(toDate>fromDate||toDate==null||fromDate==null){
                if(toDate!=null||toDate>todayString){
                    if(toDate<=todayString){
                        if(fromDate!=null)
                        {
                            helper.getMarRecord(component, helper, fromDate, toDate);
                      
                        }
                        else{
                            component.set("v.secondvalidation",true);
                        }
                    }
                    else{
                        component.set("v.firstvalidation",true);
                    }
                }
                else{
                    component.set("v.thirdvalidation",true);
                }
            }
            else{
                component.set("v.fourthvalidation",true);
            }
        }
        
        else{
            component.set("v.secondvalidation",true); 
        }
    },
    
     Search: function(component, event, helper) {
         console.log('bchjb');
         debugger;
        var searchField = component.find('searchField');
        var allData = component.get('v.allDataCopy');
         console.log('bchjb', allData);
        var searchKeyWord = component.get("v.searchKeyword");
         console.log('----', searchKeyWord);
        var nameSpace = 'ElixirSuite__' ;
         var DrugName =  nameSpace.concat('Drug_Name__c'); 
        var fillData = allData.filter(function(dat) {
            return (dat.ElixirSuite__Drug_Name__c.toLowerCase()).startsWith(searchKeyWord.toLowerCase());
        });
        
        component.set("v.allData", fillData);
    },
    
    onNext : function(component, event, helper) {        
        var pageNumber = component.get("v.currentPageNumber");
        component.set("v.currentPageNumber", pageNumber+1);
        helper.buildData(component, helper);
    },
    
    onPrev : function(component, event, helper) {        
        var pageNumber = component.get("v.currentPageNumber");
        component.set("v.currentPageNumber", pageNumber-1);
        helper.buildData(component, helper);
    },
    
    processMe : function(component, event, helper) {
        component.set("v.currentPageNumber", parseInt(event.target.name));
        helper.buildData(component, helper);
    },
    
    onFirst : function(component, event, helper) {        
        component.set("v.currentPageNumber", 1);
        helper.buildData(component, helper);
    },
    
    onLast : function(component, event, helper) {        
        component.set("v.currentPageNumber", component.get("v.totalPages"));
        helper.buildData(component, helper);
    },
})