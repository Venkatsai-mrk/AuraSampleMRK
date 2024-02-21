/*
 * Copyright (c) 2020, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */

import { LightningElement, api, wire } from 'lwc';
import { getRecord, getFieldValue, updateRecord } from 'lightning/uiRecordApi';
import { FlowAttributeChangeEvent } from 'lightning/flowSupport';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import { getSObjectValue } from '@salesforce/apex';
import getStamps from '@salesforce/apex/StampingHelper.getStamps';
import createStaticStuff from '@salesforce/apex/FlowImageContentHelper.inserStaticResourceFromLWC';
import checkStaticResourceReacordExistence from '@salesforce/apex/FlowImageContentHelper.checkStaticResourceReacordExistence';
import GetResourceURL from  '@salesforce/apex/StaticResourceURL.GetResourceURL';
import myCustomSave from '@salesforce/apex/FlowImageContentHelper.myCustomSave';
import savedImage from '@salesforce/apex/FlowImageContentHelper.savedImage';
import DeleteImage from '@salesforce/apex/FlowImageContentHelper.DeleteImage';
//import getNamespaceCustomSetting from '@salesforce/apex/Elixir_Utility.getNamespaceCustomSetting';
import LightningConfirm from 'lightning/confirm';

// watch out for Custom Metadata Types, they can't be used
// with import field from '@salesforce/schema...' calls
// see Import Limitations at https://developer.salesforce.com/docs/component-library/documentation/en/lwc/lwc.data_wire_service_about
const LABEL_FIELD = 'c25draw__DA_Stamps__mdt.MasterLabel';
const SVG_FIELD = 'c25draw__DA_Stamps__mdt.Stamp_SVG_String__c';
const SVG_FIELD_WITH_NS = 'c25draw__DA_Stamps__mdt.c25draw__Stamp_SVG_String__c';

import staticResources from "@salesforce/resourceUrl/backgrounds";
import EmailPreferencesStayInTouchReminder from '@salesforce/schema/User.EmailPreferencesStayInTouchReminder';
 
//var ehrSetting ; 
const countryCode =  'ehr';
//var resourcePath = `${staticResources}_${countryCode}/dynamic.jpg`;
var resourcePath = `${staticResources}/dynamic.jpg`;

export default class dynamicDrawAnnotation extends LightningElement {


    @api existingImageRecord;
   

    searchKey = '';
    contacts;
    error
    @api staticName = '';
    isStaticResourceAvailable = false;
   
    @api staticFileName = '';
    @api fileName = '';
    @api recordId;
    @api objectApiName;
    @api flexipageRegionWidth; //https://developer.salesforce.com/docs/component-library/documentation/en/lwc/lwc.use_width_aware
    @api isLoaded = false;
    // Config Properties
    @api fieldName;
    @api autoSave = false;
    @api autoLoad = false;
    @api captureSave = false;
    @api get canHandleSave() {
        return this.autoSave || this.captureSave;
    }
    @api currentCanvasOut = "{}";
    @api currentPngOut = "";
    @api backgroundImage = "";
    calcBackgroundImage = "";
    @api canvasWidth = 500;
    @api canvasHeight = 300;
    @api ImageDimensionsAvaialable;
    @api allowCanvasResize = false;
    @api stampingMode = false;
    @api drawingMode = false;
    @api formUniqueId ="";
    @api formCssId ="";
    @api accountId ="";
    @api isNew = false;
    @api isView = false;
    @api viewMode = false;
    /* === ===
     * Data Management
     */
    _record;
    recordId = "";
    fieldsFormatted; // keep this unassigned as it gets assigned dynamically
    /*@wire(getRecord, { recordId: "$recordId", fields: "$fieldsFormatted" })
    wiredRecord({ error, data }) {
        if (error) {
            this.logAndDisplayError("Error loading wiredRecord of getRecord", error);
        } else { // if (data) {
            this._record = data;
            console.log('data '+data);
            if (this.autoLoad && data) {
                // map the record value into the canvas value
                //this.getCanvas().currentCanvasValue = this.currentRecordValue;
                //this.loadBackgroundImage(); // overwrite the loaded value
            }
        }
    }*/

    connectedCallback(){
        savedImage({accountId: this.accountId, formUniqueId:this.formUniqueId, 
            formCssId:this.formCssId, isNew:this.isNew, resourceName :this.staticName})
            .then(result => {
                console.log('result data '+result);
                if(result){
                    this.getCanvas().currentCanvasValue = {"data":'image/png;base64,'+result};
                    if(!result.includes('resource')){
                        this.staticFileName = 'data:image/png;base64,'+ result;
                    }else{
                        this.staticFileName = result;
                    }
                    this.loadBackgroundImage();
                    this.showAfterImageAvailable();
                }
            })
            .catch(error => {
                console.log('result error'+error);
            });
    }
    
    get currentRecordValue() {
        let result = "";
        if (this._record) {
            result = getFieldValue(this._record, this.formatFieldName(this.fieldName));
        }
        return result;
    }
    set currentRecordValue(value) {
        if (this.autoSave) {
            let recInput = this.createRecordInput(value);
            updateRecord(recInput)
                .then(() => {
                })
                .catch(error => {
                    this.logAndDisplayError("Error updating updateRecord", error);
                }); // update record
        }
    } 
    get acceptedFormats() {
        return ['.png','.jpg','.jpeg'];
    }
    renderedCallback(){
 
        this.loadBackgroundImage(); // load the image to a blank canvas
   
    }
    CountryCode(){
        console.log('callback console');
        return 'ehr';
    }

  async  handleClick() {
        console.log('handlePNG');
        this.staticName =null;
        ////////////////////////Confirmation prompt////////////////////////////
            console.log('shivam');
        const result = await LightningConfirm.open({
            message: 'This will completely clear out all modifications done on the Canvas and remove the image. Are you sure you want to select this option?',
            variant: 'headerless',
        });
        if(result){
            if(!this.isNew){
                DeleteImage({accountId: this.accountId, formUniqueId:this.formUniqueId, 
                    formCssId:this.formCssId, isNew:this.isNew, resourceName :this.staticName})
        
                    .then(result => {
                        console.log('result data '+result);
                           this.loadBackgroundImage();
                           this.showAfterImageAvailable();
                           this.showAfterImageDelete();
                        })
            }else{
                this.loadBackgroundImage();
                this.showAfterImageAvailable();
                this.showAfterImageDelete();
            } 
        }    
    }

    handleClearModificationClick() {
        console.log('handlePNG');
        // var dataToSend = {'pngOut' : ''};
        // const lwcEvent= new CustomEvent('loadNewImage', {
        //     detail:{dataToSend} 
        //     });
        // this.dispatchEvent(lwcEvent);
        this.getCanvas().currentCanvasValue = {"data": this.staticFileName};
        this.loadBackgroundImage();
     }
handleUploadFinished(event) {
        // Get the list of uploaded files
        this.isLoaded = !this.isLoaded; 
        const uploadedFiles = event.detail.files;
       console.log('uploaded files '+JSON.stringify(event.detail.files));
        let uploadedFileNames = '';
        for(let i = 0; i < uploadedFiles.length; i++) {
            uploadedFileNames += uploadedFiles[i].name + ', ';
        }
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: uploadedFiles.length + ' Files uploaded Successfully: ' + uploadedFileNames,
                variant: 'success', 
            }),
        ); 
        //alert('file name '+event.detail.files[0].name);
        this.fileName = event.detail.files[0].name;
        //alert('after name set '+this.filename);
       // this.backgroundImage = 'Adam.png';
       // this.calcBackgroundImage = staticResources + "/" +  this.backgroundImage;
       // this.calcBackgroundImage = 'https://elixirehr-force-dev-ed.lightning.force.com/lightning/r/CombinedAttachment/0012w00000HJkFhAAL/related/CombinedAttachments/view';
        console.log('link '+this.calcBackgroundImage);
////////////////////////////////////////////////////////////////////////////////////////
        // documenmtID  = {'documentId' : event.detail.files[0].documenmtID};
        
      //   alert('value '+event.detail.files[0].documentId); 
        
       // alert('after');
        createStaticStuff({ createdAttachmentID: event.detail.files[0].documentId })
        .then((result) => {
           // alert('1st resulkt'+this.isStaticResourceAvailable);
            this.contacts = result;
            this.error = undefined;
          //  this.calcBackgroundImage = '/resource/1597315198000/'+'ElixirCS__'+ 'draw'+event.detail.files[0].documentId;
          //  this.getCanvas().backgroundImage = this.calcBackgroundImage;
          //  alert('3'+this.calcBackgroundImage);
          
          //  this.template.querySelector(".da-canvas").backgroundImage = this.calcBackgroundImage;
           if(!this.isStaticResourceAvailable){
            var that = this;
            var refreshId =  setInterval(function(){ 
              // alert('intervalk');
               
              //  alert('3'+calcBackgroundImage);
              
                //this.template.querySelector(".da-canvas").backgroundImage = this.calcBackgroundImage;
                checkStaticResourceReacordExistence({ createdAttachmentID: event.detail.files[0].documentId })
                .then((result) => {
                   
                    this.isStaticResourceAvailable = result;
                    if(result){
                     
                      GetResourceURL({ resourceName: 'draw'+event.detail.files[0].documentId })
                        .then((result) => {
                            console.log('the final returned result is '+result);
                           // this.calcBackgroundImage = result;
                            that.getCanvas().backgroundImage = result;
                           // alert('complerted rendring');
                            clearInterval(refreshId);
                            that.isLoaded = false;
                            // this.contacts = result;
                            // this.error = undefined;
                        })
                        .catch((error) => {
                            this.error = error;
                            this.contacts = undefined;
                        });
  
                    }
                    else {
                      
                    }
                    this.error = undefined;
                })
                .catch((error) => {
                    this.error = error;
                    this.contacts = undefined;
                });
             }, 3000);
           
            }
        })
        .catch((error) => {
            this.error = error;
            this.contacts = undefined;
        });
    }

    _stamps;
    _stampsAdded;
    @api get stampsAdded() {
        return this._stampsAdded;
    }
    @wire(getStamps)
    wiredStamps({ error, data }) {
        if (error) {
            this.logAndDisplayError("Error loading wiredRecord of getRecord", error);
        } else { // if (data) {
            this._stamps = data;
            this._stampsAdded = 0;
            this.loadStamps();
        }
    }
    loadStamps() {
        if (this._stamps && this.getCanvas()) {
            for (let i = 0; i < this._stamps.length; i++) {
                let mLabel = getSObjectValue(this._stamps[i], LABEL_FIELD);
                let svgField = getSObjectValue(this._stamps[i], SVG_FIELD);
                svgField = svgField ? svgField : getSObjectValue(this._stamps[i], SVG_FIELD_WITH_NS);
                if (mLabel && mLabel != "") {
                    this.getCanvas().addStampOption(mLabel, svgField);
                    if (this.stampingMode) {
                        this.getCanvas().interactionMode(this.getCanvas().stampingMode);
                    }
                    this._stampsAdded += 1;
                }
            }
        }
    }

    // call after the child canvas is created and available
   /* renderedCallback() {
       // alert('calling renderd callback');
        this.calcBackgroundImage = staticResources + "/" + this.backgroundImage;
        console.log('SR '+staticResources);
        console.log('SR 2'+this.backgroundImage);
        this.loadBackgroundImage(); // load the image to a blank canvas

        if (this.autoLoad) {
            let fields = [this.fieldName, "Id"];
            this.fieldsFormatted = fields.map(field => this.formatFieldName(field));
        }

        this.loadStamps();

        if (this.getCanvas()) {
            if (this.stampingMode) {
                this.getCanvas().interactionMode(this.getCanvas().stampingMode);
            } else if (this.drawingMode) {
                this.getCanvas().interactionMode(this.getCanvas().drawingMode);
            } else {
                this.getCanvas().interactionMode(this.getCanvas().fullMode);
            }
        }
    }*/

    @api handleSaveForm() {
        // check if canvas is visible
        if (this.template.querySelector(".afterUpload").style.display != "none") {
            console.log("sent canvas image: staticDrawAnnotation.js");
            this.currentPngOut = this.getCanvas().currentCanvasPng;
            var dataToSend = {'pngOut' : this.currentPngOut,'fileName' :  this.fileName};
            return dataToSend;
        }
    }

    handleSaveCanvas(event) {
        this.currentPngOut = this.getCanvas().currentCanvasPng;
      //  alert('save updated+'+'record id' +this.fileName);
      //  alert('file name ' +this.recordId);
        var dataToSend = {'pngOut' : this.currentPngOut,'fileName' :  this.fileName};
        const lwcEvent= new CustomEvent('imageDataStatic', {
            detail:{dataToSend} 
           });
          this.dispatchEvent(lwcEvent);
        //alert('dispath complete');

       /* myCustomSave({paramToSave: this.currentPngOut,acocuntID : this.recordId,nameToSave : this.fileName
           })
        .then(result => {
          //  this.attachment = result;
           // console.log('attachment id=' + this.attachment.Id);
            //show success message
            updateRecord({fields: this.recordId})
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'IMAGE SAVED SUCCESSFULLY!',
                    variant: 'success',
                }),
            );
        })
        .catch(error => {
            //show error message
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error creating Attachment record',
                    message: error.body.message,
                    variant: 'error',
                }),
            );
        });

       /* alert('here SAVE ');
        if (this.autoSave) {
            alert('AUTO SAVE ');
            this.currentRecordValue = this.getCanvas().currentCanvasValue;
       // } else if (this.captureSave) {
         } else {
            alert('CAPTURE SAVE ');
            this.currentCanvasOut = this.getCanvas().currentCanvasValue;
            const canvasChangeEvent = new FlowAttributeChangeEvent("currentCanvasOut", this.currentCanvasOut);
            console.log('Current canvas '+this.currentCanvasOut);
            console.log('Current canvas '+JSON.stringify(this.currentCanvasOut));
            this.dispatchEvent(canvasChangeEvent); 

            // need to disconnect this from the above so the canvas renders
            setTimeout(() => {
                // http://santanuboral.blogspot.com/2019/10/LWC-capture-signature.html
                this.currentPngOut = this.getCanvas().currentCanvasPng;

                const pngChangeEvent = new FlowAttributeChangeEvent("currentPngOut", this.currentPngOut);
                this.dispatchEvent(pngChangeEvent);
                console.log('Current PNG OUT  '+this.currentPngOut);
            console.log('stringified  '+JSON.stringify(this.currentPngOut));
            }, 500);
        }*/
    }

    loadBackgroundImage() {
     //   if (this.backgroundImage && this.backgroundImage != "") {
         //  /resource/1653991652000/backgrounds_ehr/dynamic.jpg
          console.log('my dynamic url is  '+this.staticFileName);
          this.getCanvas().backgroundImage = this.staticFileName;
        //    this.getCanvas().backgroundImage =  `url('${resourcePath}')`;
       // } 
    }

    createRecordInput(value) {
        let result = {
            "fields" : {}
        }

        result.fields["Id"] = this.recordId;
        result.fields[this.fieldName] = value;
        return result;
    }
    formatFieldName(fname) {
        return this.objectApiName + "." + fname;
    }
    getCanvas() {
        return this.template.querySelector(".da-canvas");
    }

    /* === ===
     * Logging utilities
     */
    logTextEvent(text) {
        console.log(text);
    }
    logObjectEvent(text, obj) {
        this.logTextEvent(text);
        console.log(obj);
    }
    logAndDisplayError(text, error) {
        this.logObjectEvent(text, error);
    }


    // allow user to upload a file 
    handleUpload(event) {
        // get url of uploaded file
        console.log(URL.createObjectURL(event.target.files[0]));

        // set staticFileName to this url 
        this.staticFileName = URL.createObjectURL(event.target.files[0]);
       
        console.log('uploaded file url: ', this.staticFileName);

        // set staticFileName in canvas
        this.loadBackgroundImage();

        this.showAfterImageAvailable();

        // save this canvas once
        //this.handleSaveCanvas();
    }

    // show canvas after image is available
    showAfterImageAvailable() {
        if (this.staticFileName) {
            let allAfterUploadElements = this.template.querySelectorAll(".afterUpload");
            let totalElements = allAfterUploadElements.length;

            for (let i = 0; i < totalElements; i++ ) {
                allAfterUploadElements[i].style.display = 'block';
            }
            
        }
    }
showAfterImageDelete() {
        if (this.staticFileName) {
            let allAfterUploadElements = this.template.querySelectorAll(".afterUpload");
            let totalElements = allAfterUploadElements.length;

            for (let i = 0; i < totalElements; i++ ) {
                allAfterUploadElements[i].style.display = 'none';
            }
            
        }
    }

}