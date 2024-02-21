({
    showDependentValues : function(component,event, helper){
        var cssRecords = component.get("v.cssRecords");
        console.log(JSON.stringify(cssRecords)+' cssRecords');
        var column = component.get("v.column");
        console.log(JSON.stringify(column)+' column in json stringify');
        var controllerValue = event.getSource().get("v.value"); 
        console.log(controllerValue+' controllerValue');
        var name = event.getSource().get("v.name");
        console.log(name+' name');
        var names = name.split('#');
        console.log(names+' names');
        var dataType = names[1];
        console.log(dataType+' dataType');
        var isControlling = column.isControlling;
        console.log(isControlling+' isControlling');
        if(column.value != '' && isControlling){                   
            var dependentField = column.dependentField;
            console.log(dependentField+' dependentField');
        if(column.value != '' && isControlling){      
            var pickListMap = column.DependentPicklistValues;  
            console.log(JSON.stringify(pickListMap)+' pickListMap');         
            if (controllerValue != '--- None ---') {        
                var childValues = pickListMap[controllerValue];
                console.log('childValues '+childValues);
                var childValueList = [];
                //childValueList.push('--- None ---');
                if(!$A.util.isUndefinedOrNull(childValues)){
                for (var i = 0; i < childValues.length; i++) {
                    childValueList.push(childValues[i]);
                    }
                }
                console.log(childValueList+' childValueList');
                //Code to populate dependent field values
                for(let section in cssRecords){
                    console.log(section+' section');
                    let rows = cssRecords[section].ElixirSuite__Object_1_css__r;
                    console.log(rows+' rows');
                    for(let row in rows){
                        console.log(row+' row');
                        let columns = rows[row].Columns;
                        console.log(columns+' columns');
                        for(let column in columns){
                            console.log(column+' column');
                            if(columns[column].ElixirSuite__Field_Name__c === dependentField){
                                if(columns[column].ElixirSuite__Form_Data_Type__c == 'Radio'){
                                    console.log('radio');
                                    var radioList = [];
                                    for(let child in childValueList){
                                        console.log(child);
                                        let obj = {'value' : childValueList[child], 'label' : childValueList[child]};  
                                        console.log(obj+' obj');
                                        radioList.push(obj);                                        
                                    }
                                console.log('radioList '+radioList);
                                columns[column]['PicklistValues'] = radioList;    
                                }
                                else if(columns[column].ElixirSuite__Data_Type__c == 'MULTIPICKLIST'){
                                    console.log('MULTIPICKLIST');
                                    let multiList = [];
                                    for(let child in childValueList){
                                        console.log(child+' child');
                                        let obj = {'value' : childValueList[child], 'label' : childValueList[child]};  
                                        console.log(obj+' obj');
                                        multiList.push(obj);                                        
                                    }
                                console.log('multipickList '+multiList);
                                columns[column]['PicklistValues'] = multiList;    
                                }           
                                else{
                                columns[column]['PicklistValues'] = childValueList;
                                console.log(childValueList+' childValueList');
                                }
                                break;
                            }
                        }
                    }
                }
                
               
            }
            else {

            }
            component.set("v.cssRecords",cssRecords);
        }
    }
}
})