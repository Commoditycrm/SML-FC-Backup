import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
//import updateCount from '@salesforce/apex/TargetSummery_CTRL.updateCount';
export default class RefreshTargetSummary extends LightningElement {
    @track buttonLabel = 'Refresh Target Summary Report';
    @track disabledButton = false;

    handleClick() {
        this.buttonLabel = 'Updating Report. Please Hold On.';
        this.disabledButton = true;
        updateCount().then(result => {
            this.showToast('Success', 'Target Summary Report Refreshed successfully');
            this.refreshView();
        })
            .catch(error => {
                this.showToast('Error', error.body.message, 'error');
            })
            .finally(() => {
                this.disabledButton = false;
                this.buttonLabel = 'Refresh Target Summary Report';
            });
    }
    refreshView() {
        setTimeout(() => {
            eval("$A.get('e.force:refreshView').fire();");
        }, 1000);
    }
    redirectToReport(event) {
       
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.report,
                objectApiName: 'Report',
                actionName: 'view'
            },
            state: {
                fv0: this.recordId,
            }
        });
    }
    report;
    getReportId() {
        reportID()
            .then(result => {
                if (result) {
                    this.report = result;

                }
            })
    }
    showToast(title, message, variant = 'success') {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }
}