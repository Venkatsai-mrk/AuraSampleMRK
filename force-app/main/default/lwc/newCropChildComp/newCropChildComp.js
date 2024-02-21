import { LightningElement ,track,api} from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class NewCropChildComp extends NavigationMixin(LightningElement) {

  
    @api recordId;
   @track src;
   @api page;
   @api pageName;
  

    connectedCallback()
        
    {
        this.src="/apex/ElixirSuite__"+ this.pageName +"?recordId="+ this.recordId+"&page=" + this.page;  
console.log(this.recordId);
    }
}