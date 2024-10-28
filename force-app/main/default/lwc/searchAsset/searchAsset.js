import { LightningElement, api, wire, track } from 'lwc';
import getAssetsByAccount from '@salesforce/apex/AssetController.getAssetsByAccount';

export default class AssetSelector extends LightningElement {
    @api accountId;  // Account ID from the previous screen
    @track assets = [];
    @track filteredAssets = [];
    @track selectedAsset = [];
    @api selectedAssets = [];
    @track error;
    @track searchKey = '';  // Search input for filtering assets

    // Fetch assets based on the accountId
    @wire(getAssetsByAccount, { accountId: '$accountId' })
    wiredAssets({ error, data }) {
        if (data) {
            // Ensure that each asset has a label and value for the checkbox group
            this.assets = data.map(asset => ({
                label: asset.Name,   // Label to display in the checkbox
                value: asset.Id      // Value to pass for selection
            }));
            this.filteredAssets = this.assets;
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.assets = [];
            this.filteredAssets = [];
        }
    }

    // Handle search input to filter assets
    handleSearch(event) {
        this.searchKey = event.target.value.toLowerCase();
        this.filteredAssets = this.assets.filter(asset => 
            asset.label.toLowerCase().includes(this.searchKey)
        );
    }

    // Handle checkbox group selection
    handleAssetSelection(event) {
        this.selectedAsset = event.detail.value;  // Capture selected asset IDs
    }

    // Validation for asset selection in the flow
    @api
    validate() {
        if (this.selectedAsset.length === 0) {
            return {
                isValid: false,
                errorMessage: 'Please select at least one asset.'
            };
        }
        return { isValid: true };
    }

    // Return the selected assets to the flow
    @api
    getSelectedAssets() {
        this.selectedAssets = this.selectedAsset;
        return this.selectedAssets;
    }
}