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
		@api disabled;
		@track valueMap = {};
		renderedCallback(){
				var container = this.template.querySelector('[data-id="sidebar"]');
				var copiedText = this.column.bluePrint;
				var consentPdf = '';
				var inputJSON = JSON.parse(this.column.inputJSON);
				var disabled = this.disabled;
				console.log('inputJSON '+inputJSON);
				var textToShowOnUI = '';
				if (copiedText !== null && copiedText !== undefined) {
				var idx = copiedText.indexOf("{");
				while(idx != -1){
						let lastIdx = copiedText.indexOf("}");
						let startIdx = copiedText.indexOf("{");
						var extractedTextWithinBrackets = copiedText.substring(
								startIdx+1,
								lastIdx
						);      
						var splittedValues = extractedTextWithinBrackets.split('#');
						var inputKey = splittedValues[0];
						var type= splittedValues[1];
						console.log('inputKey '+inputKey);
						textToShowOnUI += copiedText.substr(0,startIdx);
						consentPdf += copiedText.substr(0,startIdx);
						if(type.toLowerCase() =='checkbox'){
								let name = inputKey;
								let style = "margin:2px 2px";
								let value;
								console.log('inputJSON[inputKey] '+inputJSON[inputKey]);
								if(inputJSON[inputKey]!=undefined){
										value = inputJSON[inputKey];
								}
								if(disabled){
									if(value == true){
										textToShowOnUI += `<input checked type="${type}" name="${name}" style="${style}" disabled/>`;
									}else{
										textToShowOnUI += `<input type="${type}" name="${name}" style="${style}" disabled/>`;
									}
								}else{
									if(value == true){
										textToShowOnUI += `<input checked type="${type}" name="${name}" style="${style}"/>`;
									}else{
										textToShowOnUI += `<input type="${type}" name="${name}" style="${style}"/>`;
									}
								}
								consentPdf += inputKey;
								console.log('textToShowOnUI '+textToShowOnUI);
						}else{
								let name = inputKey;
								let style = "margin:2px 2px";
								let value;
								console.log('inputJSON 1 '+inputJSON);
								console.log('inputJSON 2 '+inputKey);
								console.log('inputJSON 2 '+inputJSON[inputKey]);
								if(inputJSON[inputKey]!=undefined){
										value = inputJSON[inputKey];
								}
								if(disabled){
										textToShowOnUI += `<input value="${value}" type="${type}" name="${name}" style="${style}" readonly/>`;
								}else{
										textToShowOnUI += `<input value="${value}" type="${type}" name="${name}" style="${style}"/>`;
										consentPdf += inputKey;
								}
								
								console.log('textToShowOnUI '+textToShowOnUI);
						}
						copiedText = copiedText.substr(lastIdx+1);
						idx = copiedText.indexOf("{");
				}
				if(copiedText!=''){
						textToShowOnUI += copiedText;
						consentPdf += copiedText;
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
				console.log('this.consentPdf Ground zero '+this.consentPdf);
				for (index = 0; index < inputs.length; ++index) {
						let element = inputs[index];
						if(element.type === 'checkbox'){
							let checkedPresent = false;
								if(element.checked){
									checkedPresent = true;
								}
							inputJSON[element.name] = checkedPresent;
							if(this.consentPdf!=undefined){
								this.consentPdf = this.consentPdf.replaceAll(element.name,checkedPresent);
							}
						}else if(element.type === 'date'){
								let dateValue = element.value;
								inputJSON[element.name] = element.value;
								if(dateValue!=undefined){
										let dateValues = dateValue.split("-");
										dateValue = `${dateValues[2]}-${dateValues[1]}-${dateValues[0]}`; 
								}
								if(this.consentPdf!=undefined){
									this.consentPdf = this.consentPdf.replaceAll(element.name,dateValue);
								}
						}else if(element.type === 'datetime-local'){
							console.log('xxyyzz '+element.type);
							console.log('xxyyzz '+element.value);
							let dateValue = element.value;
							inputJSON[element.name] = element.value;
							if(dateValue!=undefined){
								let timeValues = dateValue.split("T");
								let onlyDate = timeValues[0];
								console.log('onlyDate '+onlyDate);
								let onlyTime = timeValues[1];
								console.log('onlyTime '+onlyTime);
								let dateValues = onlyDate.split("-");
								dateValue = `${dateValues[2]}-${dateValues[1]}-${dateValues[0]} ${onlyTime}`;
								console.log('dateValue '+dateValue);
						}
							if(this.consentPdf!=undefined){
								this.consentPdf = this.consentPdf.replaceAll(element.name,dateValue);
							}
					}else{
							inputJSON[element.name] = element.value;
							console.log('aabbcc '+element.type);
							console.log('aabbcc '+element.value);
							if(this.consentPdf!=undefined){
								this.consentPdf = this.consentPdf.replaceAll(element.name,element.value);
							}
						}
				}
				console.log('this.consentPdf '+this.consentPdf);
				dataToSend['inputJSON'] = inputJSON;
				dataToSend['consentPdf'] = this.consentPdf;
				let valueChangeEvent = new CustomEvent("valuechange", {
						detail: { dataToSend }
				});
				this.dispatchEvent(valueChangeEvent);				
		}
}