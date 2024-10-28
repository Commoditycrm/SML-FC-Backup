import { LightningElement, api,wire,track } from 'lwc';
import myImageResource from '@salesforce/resourceUrl/SMLBanner';
import permissionSet from '@salesforce/apex/PermissionSetChecker.permissionSet';


export default class BannerImage extends LightningElement {
    @api resourceName; // The name of the static resource
    @api imageName;    // The image file name inside the static resource
    imageUrl;
    @track showBanner = false;

    connectedCallback() {
        this.getPermissionset();
       
    }

    getPermissionset() {
        permissionSet().then(result => {
            if (result != null && result != '') {
                this.showBanner = true;
                if(result == 'Standard Banner Permission Set'){
                    this.imageUrl = myImageResource + '/LogoVitro.png';
                }else if(result == 'Rehirg Pacific Banner Permission Set'){
                    this.imageUrl = myImageResource + '/RehigPacificCompany.jpg';
                }else if(result == 'Cardinal Banner Permission Set'){
                     this.imageUrl = myImageResource + '/CardinalCompany.png';
                }else if(result == 'Minus works Banner Permission Set'){
                     this.imageUrl = myImageResource + '/MinusWorks.jpg';
                }else if(result == 'Saudi Aramco Banner Permission Set'){
                    this.imageUrl = myImageResource + '/SaudiAcroma.jpg';
                }
            } 
        })
            .catch(error => {
                //this.showToast('Error', error.body.message, 'error');
            })
    }
    // Construct the URL dynamically based on user input
    /* get bannerImageUrl() {
         if (this.resourceName && this.imageName) {
             return `/resource/${this.resourceName}/${this.imageName}`;
         }
         return null;
     }*/
}