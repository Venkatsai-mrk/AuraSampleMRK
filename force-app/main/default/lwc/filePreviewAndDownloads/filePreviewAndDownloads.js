import { LightningElement, api, wire,track } from 'lwc';
import getRelatedFilesByRecordId from '@salesforce/apex/filePreviewAndDownloadController.getRelatedFilesByRecordId'
import {NavigationMixin} from 'lightning/navigation'

export default class FilePreviewAndDownloads extends NavigationMixin(LightningElement) {
    @api rec=''
    filesList =[]
    @wire(getRelatedFilesByRecordId, {recordId: '$rec'})
    wiredResult({data, error}){ 
        if(data){ 
            console.log(data)
            this.filesList = Object.keys(data).map(item=>({"label":data[item],
             "value": item,
             "url":`/sfc/servlet.shepherd/document/download/${item}`
            }))
            console.log(this.filesList)
        }
        if(error){ 
            console.log(error)
        }
    }
    closeModal() {
        this.dispatchEvent(new CustomEvent('close'))
    }
}