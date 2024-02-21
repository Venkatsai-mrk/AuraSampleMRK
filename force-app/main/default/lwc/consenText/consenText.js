import { LightningElement, api, wire, track } from 'lwc';
import { getRecord, getFieldValue, updateRecord } from 'lightning/uiRecordApi';
import { FlowAttributeChangeEvent } from 'lightning/flowSupport';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import { getSObjectValue } from '@salesforce/apex';
export default class ConsenText extends LightningElement {
		defaultText;
		consentPdf;
		@api textValue;
		@api column;
		@api consentData;
		@track valueMap = {};
		renderedCallback(){
				var container = this.template.querySelector('[data-id="sidebar"]');
				var copiedText = this.textValue;
				var textToShowOnUI = '';
				var consentPdf = '';
				this.defaultText = '';
				if (copiedText !== null && copiedText !== undefined) {
				var idx = copiedText.indexOf("{");
				while(idx != -1){
						let lastIdx = copiedText.indexOf("}");
						let startIdx = copiedText.indexOf("{");
						let inputKey = Math.floor(Math.random() * 10000000) + idx;
						var extractedTextWithinBrackets = copiedText.substring(
								startIdx+1,
								lastIdx
						);      
						textToShowOnUI += copiedText.substr(0,startIdx);
						consentPdf += copiedText.substr(0,startIdx);
						//console.log('textToShowOnUI '+textToShowOnUI);
						this.defaultText += copiedText.substr(0,startIdx);
						//console.log('this.defaultText '+this.defaultText);
						if(extractedTextWithinBrackets.includes('.')){
								let splittedValues = extractedTextWithinBrackets.split(".");
								let objName = splittedValues[0];
								let fieldName = splittedValues[1];
								let consentData = JSON.parse(JSON.stringify(this.consentData));
								let finalValue = '';
								if(consentData){
										//console.log('Consent data '+JSON.stringify(consentData));
										for(let value of Object.keys(consentData)){
												let changedKey = value.toUpperCase();
												//console.log('changedKey '+changedKey);
												//console.log('consentData[value] '+ JSON.stringify(consentData[value]));
												consentData[changedKey] = consentData[value];
												//console.log('Consent data '+JSON.stringify(consentData));
												for(let childValue of Object.keys(consentData[changedKey])){
														let changedChildKey = childValue.toUpperCase();
														//console.log('changedChildKey '+changedChildKey);
														consentData[changedKey][changedChildKey] = consentData[value][childValue];
												}
										}
										if(consentData.hasOwnProperty(objName.toUpperCase())){
												let sObj = consentData[objName.toUpperCase()];
												//console.log('sObj '+sObj);
												if(sObj.hasOwnProperty(fieldName.toUpperCase())){
														finalValue = sObj[fieldName.toUpperCase()];
														//console.log('finalValue '+finalValue);
														textToShowOnUI += finalValue;
														consentPdf += finalValue;
														this.defaultText += finalValue;
												}
										}
								}
						}else{
							let name = inputKey;
							let style = "margin:2px 2px";
							let generatedKey = '{'+ inputKey + '#' + extractedTextWithinBrackets.toLowerCase() + '}';
							//console.log('generatedKey '+generatedKey);
							this.defaultText += generatedKey;
							textToShowOnUI += `<input type="${extractedTextWithinBrackets.toLowerCase()}" name="${name}" style="${style}"/>`;
							consentPdf += inputKey;
							//console.log('textToShowOnUI '+textToShowOnUI);		 
						}
						copiedText = copiedText.substr(lastIdx+1);
						idx = copiedText.indexOf("{");
				}
				//console.log('copiedText '+copiedText);
				if(copiedText!=''){
						textToShowOnUI += copiedText;
						consentPdf += copiedText;
						this.defaultText += copiedText;
				}
				container.innerHTML = textToShowOnUI;
				this.consentPdf = consentPdf;
				}
				
		}
		@api
		sendParamsToAura(){
				var inputs, index;
				var dataToSend = {};
				var inputJSON = {};
				inputs = document.getElementsByTagName('input');
				for (index = 0; index < inputs.length; ++index) {
						let element = inputs[index];
						//console.log('element '+element);
						//console.log('element.type '+element.type);
						//console.log('element.type '+element.name);
						if(element.type === 'checkbox'){
								let checkedPresent = false;
								if(element.checked){
									checkedPresent = true;
								}
								//console.log('checkedPresent '+checkedPresent);
								inputJSON[element.name] = checkedPresent;
								if(this.consentPdf!=undefined && element.name){
									this.consentPdf = this.consentPdf.replaceAll(element.name,checkedPresent);
								}
								
						}else if(element.type === 'date'){
							let dateValue = element.value;
							inputJSON[element.name] = element.value;

							if(dateValue!=undefined){
								let dateValues = dateValue.split("-");
								dateValue = `${dateValues[2]}-${dateValues[1]}-${dateValues[0]}`; 
							}
							if(this.consentPdf!=undefined && element.name){
							this.consentPdf = this.consentPdf.replaceAll(element.name,dateValue);
							}
					}else if(element.type === 'datetime-local'){
						//console.log('xxyyzz '+element.type);
						//console.log('xxyyzz '+element.value);
						let dateValue = element.value;
						inputJSON[element.name] = element.value;
						if(dateValue!=undefined){
							let timeValues = dateValue.split("T");
							let onlyDate = timeValues[0];
							//console.log('onlyDate '+onlyDate);
							let onlyTime = timeValues[1];
							//console.log('onlyTime '+onlyTime);
							let dateValues = onlyDate.split("-");
							dateValue = `${dateValues[2]}-${dateValues[1]}-${dateValues[0]} ${onlyTime}`;
							//console.log('dateValue '+dateValue);
					}
						if(this.consentPdf!=undefined && element.name){
							this.consentPdf = this.consentPdf.replaceAll(element.name,dateValue);
						}
				}else{
								inputJSON[element.name] = element.value;
								if(this.consentPdf!=undefined && element.name){
								this.consentPdf = this.consentPdf.replaceAll(element.name,element.value);
								}
						}
				}
				dataToSend['inputJSON'] = inputJSON;
				dataToSend['defaultText'] = this.defaultText;
				dataToSend['consentPdf'] = this.consentPdf;
				let valueChangeEvent = new CustomEvent("valuechange", {
						detail: { dataToSend }
				});
				this.dispatchEvent(valueChangeEvent);				
		}
}