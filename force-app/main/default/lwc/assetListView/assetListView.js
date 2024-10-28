import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import createAssetList from '@salesforce/apex/AssetFilterController.createAssetList';
import getFilteredAccounts from '@salesforce/apex/AssetFilterController.getFilteredAccounts';


export default class AssetListView extends LightningElement {
    @track showFilter = false;
    @track assetType = '';
    @track assetTypeOperator = ''; // Operator for Asset Type

    handleAccountChange(event) {
        this.account = event.detail.value;
        console.log(this.account);
    }

    connectedCallback() {
        // Optionally load initial set of accounts or use some logic to decide
        this.fetchAccounts('');
    }

    fetchAccounts(searchKey) {
        getFilteredAccounts({ searchKey })
            .then(data => {
                this.accountOptions = data.map(account => {
                    return { label: account.Name, value: account.Id };
                });
            })
            .catch(error => {
                console.error('Error fetching accounts:', error);
            });
    }
    

    get typeoperatorOptions() {
        return [
            { label: 'equal', value: '= ' },
            { label: 'not equal', value: '!= ' },
        ];
    }

    

    toggleFilterVisibility() {
        this.showFilter = !this.showFilter;
        this.assetStatus = ''; // Name field
        this.account = ''; 
                this.accountOperator = ''; // Operator for Account
                this.assetType = '';
                this.assetTypeOperator = ''; // Operator for Asset Type
    }

    handleInputChange(event) {
        const field = event.target.dataset.id;
        this[field] = event.target.value;
    }

    handleOperatorChange(event) {
        const field = event.target.dataset.id;
        this[field] = event.target.value;
    }

    handleCreateRecord() {
        const fields = {
            Name__c: this.assetStatus,
            Asset_Type__c: this.assetType,
            Asset_Type_Operator__c: this.assetTypeOperator,
        };
        console.log(this.assetId);

        createAssetList({ fields })
        .then(result => {
            if (result.error) {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: result.error,
                        variant: 'error'
                    })
                );
            } else {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Asset List created successfully!',
                        variant: 'success'
                    })
                );
                 
                this.assetStatus = ''; // Name field
                this.assetType = '';
                this.assetTypeOperator = ''; // Operator for Asset Type
                // Dispatch a custom event with the record ID and Filter Name
                this.dispatchEvent(new CustomEvent('recordcreated', {
                    detail: {
                        recordId: result.recordId,
                        filterName: result.List_view_Name__c
                    }
                }));

                this.toggleFilterVisibility(); // Close the filter after saving
            }
        })
        .catch(error => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error creating record',
                    message: error.body.message,
                    variant: 'error'
                })
            );
        });
    }
}