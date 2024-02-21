import { LightningElement } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import uploadFile from '@salesforce/apex/BillReceiptLogoClass.uploadFile'
export default class BillReceiptLogo extends LightningElement {
    fileData;
    filename;
    convertedbase64;
    disableButton=true;
    size;
    file;
    fileMessage = 'No file uploaded';
    messageClass = 'slds-text-color_error';
    openfileUpload(event) {
       // const acceptedFormats = ['image/png', 'image/jpeg','image/jpg'];
        var file = event.target.files[0]
        console.log('file'+event.target.files[0]);
        var reader = new FileReader()
        reader.onload = () => {
            var base64 = reader.result.split(',')[1]
            this.fileData = {
                'base64': base64
              }
            console.log(this.fileData)
            console.log('file.name'+file.name);
            console.log('format'+file.type);
           this.convertedbase64=base64;
           this.filename=file.name;
            console.log('base64'+base64)
            var size=file.size;
            //  if (size>1000000) {
            //    // alert('File size should be less than 1MB !');
            //     this.showErrorToast()
            //      this.disableButton=true;
            //  }
             if (!file) {
                this.fileMessage = 'No file uploaded';
                this.messageClass = 'slds-text-color_error';
                this.disableButton=true;
            } else if ((file.type === 'image/jpeg' || file.type === 'image/png' || file.type === 'image/jpg') && (size<1000000))  {
                this.fileMessage = `File uploaded: ${file.name}`;
                this.messageClass = 'slds-text-color_success';
                this.disableButton=false;
            }
            else if ((file.type === 'image/jpeg' || file.type === 'image/png' || file.type === 'image/jpg') && (size>1000000))  {
                this.fileMessage = 'Error: File size should be less than 1 MB!';
                this.messageClass = 'slds-text-color_error';
               // this.showErrorToast()
                 this.disableButton=true;
            }
            else if ((file.type != 'image/jpeg' || file.type != 'image/png' || file.type != 'image/jpg') && (size>1000000))  {
                this.fileMessage = 'Error: Only .jpeg, .png, and .jpg files are supported';
                this.messageClass = 'slds-text-color_error';
                this.disableButton=true;
            }
             else {
                this.fileMessage = 'Error: Only .jpeg, .png, and .jpg files are supported';
                this.messageClass = 'slds-text-color_error';
                this.disableButton=true;
            }
            //  else  if (!acceptedFormats.includes(file.type)) {
            //     this.errorMes=true;
            //     this.errorMessage = 'File type not accepted. Only JPG, PNG and JPEG formats are allowed.';
            //     this.disableButton=true;
            //   }
            //  else{
            //     this.errorMes=false;
            //      this.disableButton=false;
            //  }
            console.log('size',+size);
        }
        reader.readAsDataURL(file)
    }

   
	   handleClick(){
        console.log('siva');
        console.log('sai'+this.convertedbase64);
       // const {base64} = this.fileData
        var base=this.convertedbase64;
        var filename=this.filename;
        console.log('filename',+filename);
        console.log('base'+base);
        uploadFile({ base:base,filename:filename }).then(result=>{
            this.fileData = null
            let title = `${filename} uploaded successfully!!`
            this.toast(title)
        })
    }

    toast(title){
        const toastEvent = new ShowToastEvent({
            title, 
            variant:"success"
        })
        this.dispatchEvent(toastEvent)
        this.disableButton=true;
    }
  /*  showErrorToast() {
        const evt = new ShowToastEvent({
            title: 'Error',
            message: 'File size should be less than 1 MB!',
            variant: 'error',
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
    }*/
}