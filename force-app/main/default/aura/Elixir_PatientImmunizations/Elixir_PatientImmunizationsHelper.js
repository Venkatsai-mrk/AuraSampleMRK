({
	createTable : function(component,event) {
		var action = component.get("c.getSelectOptions");
        
       
        //component.set("v.loaded",false);
        action.setCallback(this, function(response){
                var state = response.getState();
                if(state ==='SUCCESS'){
                    try{
                        
                        var res = response.getReturnValue();
                        console.log('res',res);
                        
                        
                        var seriesArr = [{value:"--None--",label:"--None--"}];
                        var siteArr = [{value:"--None--",label:"--None--"}];
                        var userArr = [{value:"--None--",label:"--None--"}];
                        var routeArr = [{value:"--None--",label:"--None--"}];
                        
                          
                        for(let obj in res.mapOfVaccineSeries){
                            let sObj = {'label' : obj, 'value' : res.mapOfVaccineSeries[obj]};
                            seriesArr.push(sObj);
                        }  
                        for(let obj1 in res.mapOfRoute){
                            let sObj1 = {'label' : obj1, 'value' : res.mapOfRoute[obj1]};
                            routeArr.push(sObj1);
                        } 
                        for(let obj2 in res.mapOfVaccineSite){
                            let sObj1 = {'label' : obj2, 'value' : res.mapOfVaccineSite[obj2]};
                            siteArr.push(sObj1);
                        } 
                        var userLst = res.listOfUser;
                        if(userLst.length >0){
                            for(var i=0;i<userLst.length; i++){
                                var obj ={'label': userLst[i].Name, 'value':userLst[i].Id};
                                userArr.push(obj);
                            }
                        }
                        
                        var statusArr=[
                            {value:"--None--",label:"--None--"},
                            {value:"Complete",label:"Complete"},
                            {value:"Not Administered",label:"Not Administered"},
                            {value:"Refused",label:"Refused"},
                            {value:"Planned",label:"Planned"}
                        ];
                        
                        
                        
                        component.set("v.vaccineSeriesOptions",seriesArr);
                        component.set("v.routeOptions",routeArr);
                        component.set("v.vaccineSiteOptions",siteArr);
                        component.set("v.userOptions",userArr);
                        component.set("v.statusOptions",statusArr);
                        
                        
                        
                        this.createRow(component,event);
                        this.getUrl(component,event);
                    }
                    catch(e){
                        alert(e);
                    }
                    
                }
        });
        $A.enqueueAction(action);
	},
    
    createRow :    function(component,event) {
        var userId = $A.get("$SObjectType.CurrentUser.Id");
        console.log('userId',userId);
        var Id = component.get("v.accId");
        var RowItemList = component.get("v.VaccineList");
        RowItemList.push({
            
            'Vaccine':'',
            'CvxCode': '',
            'VaccineSeries': '',
            'Route' : '',
            'VaccineSite' : '',
            'status' : '',
            'Notes' :'',
            'AdministratioDate' : '',
            'AdministrationBy' : userId,
            'AccountId' : Id,
            'Id':'',
            'Name':''
        });
       // component.set("v.VaccineList", []);      
        component.set("v.VaccineList", RowItemList);
        
    },
    getUrl : function(component,event){
        var action = component.get("c.getURL");
        
        action.setParams({
            "accountId": component.get("v.accId")
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                try{
                    var storeResponse = response.getReturnValue();
                    
                    console.log('storeResponse',storeResponse);
                    
                    component.set("v.url", storeResponse);
                    
                }catch(e){
                    alert(e);
                }
            }
        });
        
        
        
        $A.enqueueAction(action);  
    },
    dataSave : function(component,event) {
        let saveData = component.get("v.VaccineList");
        let vaccineName;
        let administrationDate;
        saveData.forEach(function(element, index) {
            vaccineName = element.Vaccine;
            administrationDate = element.AdministratioDate;
             console.log('vaccineName ',vaccineName);
        });
        if(vaccineName){
            if(administrationDate){
    var action = component.get("c.saveVaccine");
        
        console.log('lst',JSON.stringify({'key' : component.get("v.VaccineList")}));
        
       action.setParams({
            "stringifiedVaccineLst":  JSON.stringify({'key' : component.get("v.VaccineList")})
        });
        //component.set("v.loaded",false);
        action.setCallback(this, function(response){
                var state = response.getState();
                if(state ==='SUCCESS'){
                        var res = response.getReturnValue();
                        console.log('res',res);
                        // alert('Upcoming Vaccinations have been planned for the patient!');
                       sforce.one.showToast({
                            "title": "Success!",
                           "type":"success",
                            "message": "Upcoming Vaccinations have been planned for the patient!"
                        });
                        var url = component.get("v.url");
                        sforce.one.navigateToURL(url,true);
                       // $A.get('e.force:refreshView').fire();
                }
        });
        $A.enqueueAction(action);
            }else{
               sforce.one.showToast({
                            "title": "Error!",
                           "type":"Warning",
                            "message": "Please select Administered/Planned date!"
                        });   
                
            }
        }else{
           sforce.one.showToast({
                            "title": "Error!",
                           "type":"Error",
                            "message": "Please enter the details!"
                        }); 
        }
    }
})