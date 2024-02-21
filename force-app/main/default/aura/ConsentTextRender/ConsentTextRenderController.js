({
    myAction : function(component, event, helper) {
        var textValue = component.get("v.textValue");
        var column = component.get("v.column");
        var bluePrints = column.bluePrint;
        var inputMentioned = false;
        var doValuesExist = false;
        if($A.util.isUndefinedOrNull(bluePrints)){
            bluePrints = [];
        }else{
            if(column['OnlyText'] == true){
                //bluePrints = bluePrints.replaceAll('&quot;','"');
                column['consentValue'] = bluePrints;
                component.set("v.onlyText",true);   
                component.set("v.column",column);
                return;
            }
            bluePrints = bluePrints.replaceAll('&quot;','"');
            bluePrints = bluePrints.replaceAll('style=""','');
            bluePrints = JSON.parse(bluePrints);
            column['consentValue'] = bluePrints;
            component.set("v.column",column);
            return;
        }
        var consentData = component.get("v.consentData");
        console.log('consentData '+JSON.stringify(consentData));
        var obj = {};
        if($A.util.isUndefinedOrNull(textValue)){
            return;
        }
        console.log('rohit11' , textValue);
        while(textValue.lastIndexOf("{") != -1){ 
            doValuesExist = true;
            let lastIdx = textValue.lastIndexOf("}") + 1;
            let startIdx = textValue.lastIndexOf("{");
            var extractedTextWithinBrackets = textValue.substring(
                lastIdx-1,
                startIdx+1
            );            
            //Rohit - Start
            //Rohit - End
            let lastPart = textValue.substr(lastIdx);
            obj = {};
            var textObj = {};
            if(extractedTextWithinBrackets.toLowerCase()=='input'){
                obj = {"text":"text","type":"input"};
                inputMentioned = true;
                /*try{
                    var checkBeforeInput = textValue.substring(
                        lastIdx-2,
                        startIdx
                    ); 
                    if(checkBeforeInput != '>'){
                        obj["class"] = 'align_inline';
                    }      
                    alert(obj["class"]);
                }catch(e){                
                }*/
                 obj['class'] = 'adjust_block';
            }
            else if(extractedTextWithinBrackets.includes(".")){//extractedTextWithinBrackets.replace( /(<([^>]+)>)/ig, '')
                let splittedValues = extractedTextWithinBrackets.replace( /(<([^>]+)>)/ig, '').split(".");
                let objName = splittedValues[0];
                let fieldName = splittedValues[1];
                let finalValue = '';
                if(!$A.util.isUndefinedOrNull(consentData)){
                    for(let value of Object.keys(consentData)){
                        let changedKey = value.toUpperCase();
                        consentData[changedKey] = consentData[value];
                        for(let childValue of Object.keys(consentData[changedKey])){
                            let changedChildKey = childValue.toUpperCase();
                            consentData[changedKey][changedChildKey] = consentData[value][childValue];
                        }
                    }
                    if(consentData.hasOwnProperty(objName.toUpperCase())){
                        let sObj = consentData[objName.toUpperCase()];
                        if(sObj.hasOwnProperty(fieldName.toUpperCase())){
                            finalValue = sObj[fieldName.toUpperCase()];
                        }
                    }
                }
                
                obj = {"text":finalValue,"type":"text"};
            }
            //textObj["text"] = lastPart.replace( /(<([^>]+)>)/ig,'');
            textObj["text"] = lastPart;
            textObj["type"] = "text";
            
            bluePrints.push(textObj);
            bluePrints.push(obj);      
            console.log('bluePrints '+JSON.stringify(bluePrints));
            textValue = textValue.substr(0, startIdx);   
            console.log('textValue ',textValue);
            //Create Blue Print Values              
        }
        obj={};     
        console.log('doValuesExist 1'+doValuesExist);
        console.log('inputMentioned 1'+inputMentioned);
        if(doValuesExist){
            obj["text"] = textValue;
            //obj["text"] = textValue.replace( /(<([^>]+)>)/ig,'');
        }
             if(!inputMentioned && doValuesExist){
            console.log('inside inputMentioned');
            var totalText = '';
            obj["type"] = "text";
            bluePrints.push(obj);
            var invertedValues = [];
            invertedValues = bluePrints.reverse();
            invertedValues.forEach((element) => { 
                console.log("test" + JSON.stringify(element));
                totalText+=element.text;
            });
                column['consentValue'] = totalText;
                console.log('totalText '+totalText);
                column['OnlyText'] = true;
                component.set("v.onlyText",true);
                //column['consentValue'] = textValue;
                //column['OnlyText'] = true;
                //component.set("v.onlyText",true);
            }
                else if(!doValuesExist){
                column['consentValue'] = textValue;
                column['OnlyText'] = true;
                component.set("v.onlyText",true);
            }
                if(doValuesExist && inputMentioned){
                obj["type"] = "text";
                bluePrints.push(obj);
                for(let i = 0; i<bluePrints.length; i++){
                if(bluePrints[i]['class'] == 'adjust_block' && bluePrints[i]['type'] == 'input' && (bluePrints[i+1] !== undefined)){
                bluePrints[i+1]['class'] = bluePrints[i]['class'];
            }
            }
                console.log('bluePrints 1'+JSON.stringify(bluePrints));
                var invertedValues = [];
                invertedValues = bluePrints.reverse();
                column['consentValue'] = invertedValues;
            }
                component.set("v.column",column);
                
            }, 
                inputValue : function(component, event, helper) {
                    var inputValue = event.target.value;
                    var idx = event.target.id;
                    var column = component.get("v.column");
                    var textArray = column['consentValue'];
                    textArray[idx]['value'] = inputValue;
                    component.set("v.column",column);
                    console.log(component.get("v.column").consentValue);
                }
            })