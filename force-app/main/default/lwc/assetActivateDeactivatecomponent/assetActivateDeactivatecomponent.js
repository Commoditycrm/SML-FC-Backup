import { LightningElement, api, track, wire } from 'lwc';
import getAssetsByAccountId from '@salesforce/apex/AssetController.getAssetsByAccount';
import forActivation from '@salesforce/apex/RedesignAC_AssetPowerChange.ForActivation';

const columns = [
    { fieldName: 'rowNumber', type: 'number' , fixedWidth: 50 },
    { label: 'Name', fieldName: 'Name' },
    { label: 'Account Name', fieldName: 'Account_Name__c' },
    { label: 'Last Connected', fieldName: 'Last_Connected__c' },
    { label: 'Last Modified', fieldName: 'LastModifiedDate' }
];

export default class AssetTable extends LightningElement {
    @api accountId;
    @api selectedAssetNames = [];
    @track totalSelectedRows = 0;
    @track allData = [];
    @track outMsg;
    @track pagedData = [];
    @track columns = columns;
    @track selectedDevices = new Set();
    @track selectedRowIds = [];
    @track error;
    @track currentPage = 1;
    @track pageSize = 100;

    @track isFirstPage = true;
    @track isLastPage = false;
    @track showActionButton = false;
    @track totalPageCount = 1;
    @track pageNumbers = [];
    
    @track selectedStatus = 'None'; // Set default value to 'None'
    @track statusOptions = [
        { label: 'None', value: 'None' }, // Default option
        { label: 'Activate', value: 'Activate' },
        { label: 'Deactivate', value: 'Deactivate' }
    ];

    handleStatusChange(event) {
        const checkvalue = event.detail.value;
        if (checkvalue != 'None') {
            this.selectedStatus = checkvalue;
            this.showActionButton = true;
        } else {
            this.showActionButton = false;
        }
    }

    handleActionButtonClick(event) {
        const selectedAssets = Array.from(this.selectedDevices);
        if (this.selectedStatus != 'None') {
            forActivation({ assetNames: selectedAssets, status: this.selectedStatus, accId: this.accountId })
                .then(result => {
                    console.log('Assets activated:', result);
                    this.outMsg = result;
                })
                .catch(error => {
                    console.error('Error activating assets:', error);
                    this.outMsg = error.body.message;
                });
        }
    }

    handleActionButtontorefreshScreen() {
        this.outMsg = null;
        this.accountId = null;
        this.selectedDevices = new Set();
        this.selectedRowIds = [];
        this.currentPage = 1;
        this.fetchAssets();
    }

    handleSelectAll() {
        if (this.selectedDevices.size > 500) {
            alert("You cannot select more than 500 assets!");
            return;
        }

        // Add up to 500 assets to the selectedDevices set
        for (let i = 0; i < this.allData.length && this.selectedDevices.size < 500; i++) {
            this.selectedDevices.add(this.allData[i].Name);
        }

        // Update selectedRowIds and apply the selection to the datatable
        this.applySelectedRows();
    }
    handleDeSelectAll() {
        
         this.selectedDevices = new Set();
        // Update selectedRowIds and apply the selection to the datatable
        this.applySelectedRows();
    }

    handleAccountSelection(event) {
        this.accountId = event.target.value;
        this.selectedDevices = new Set();
        if (this.accountId) {
            this.fetchAssets();
        }
    }

    connectedCallback() {
        if (this.accountId) {
            this.fetchAssets();
        }
    }

    fetchAssets() {
        getAssetsByAccountId({ accountId: this.accountId })
            .then(result => {
                this.allData = result.map((record, index) => ({
                    ...record,
                    rowNumber: index + 1
                }));
                this.totalPageCount = Math.ceil(this.allData.length / this.pageSize);
                this.updatePagedData();
                this.updatePaginationStatus();
                
            })
            .catch(error => {
                this.error = error;
                console.error('Error fetching assets:', error);
            });
    }

    updatePagedData() {
        const start = (this.currentPage - 1) * this.pageSize;
        const end = this.currentPage * this.pageSize;
        this.pagedData = this.allData.slice(start, end);
        this.applySelectedRows();
        this.updatePageNumbers();
    }

    applySelectedRows() {
        // Check if any rows in the current page are in the selected devices
        this.selectedRowIds = this.pagedData
            .filter(row => this.selectedDevices.has(row.Name))
            .map(row => row.Id);
        
        // Update the datatable's selected rows to reflect the current selection state
        const datatable = this.template.querySelector('lightning-datatable[data-id="assetTable"]');
        if (datatable) {
            datatable.selectedRows = this.selectedRowIds;
        }
    }

    getSelectedRows(event) {
        const selectedRows = event.detail.selectedRows;
        const newSelections = selectedRows.filter(row => !this.selectedDevices.has(row.Name));

        // Check if the new selections plus the existing selections exceed 500
        if (this.selectedDevices.size + newSelections.length > 500) {
            alert("You cannot select more than 500 assets!");
            
            // Revert to the previous selection state
            this.applySelectedRows();
            return;
        }

        // Add new selected rows to the selectedDevices set
        newSelections.forEach(row => {
            this.selectedDevices.add(row.Name);
        });

        // Remove deselected rows from the selectedDevices set
        this.pagedData.forEach(row => {
            if (!selectedRows.some(selectedRow => selectedRow.Id === row.Id)) {
                this.selectedDevices.delete(row.Name);
            }
        });

        // Update selectedRowIds for the current page
        this.applySelectedRows();

        // Update the @api selectedAssetNames property for Flow
        this.selectedAssetNames = Array.from(this.selectedDevices);
        this.totalSelectedRows = this.selectedDevices.size;
    }

    handleFirstPage() {
        this.currentPage = 1;
        this.updatePagedData();
        this.updatePaginationStatus();
    }

    handlePrevious() {
        if (this.currentPage > 1) {
            this.currentPage -= 1;
            this.updatePagedData();
            this.updatePaginationStatus();
        }
    }

    handlePageClick(event) {
        this.currentPage = parseInt(event.target.dataset.page, 10);
        this.updatePagedData();
        this.updatePaginationStatus();
    }

    handleNext() {
        if (this.currentPage < this.totalPageCount) {
            this.currentPage += 1;
            this.updatePagedData();
            this.updatePaginationStatus();
        }
    }

    handleEndPage() {
        this.currentPage = this.totalPageCount;
        this.updatePagedData();
        this.updatePaginationStatus();
    }

    updatePaginationStatus() {
        this.isFirstPage = this.currentPage === 1;
        this.isLastPage = this.currentPage === this.totalPageCount;
    }

    updatePageNumbers() {
        const pageNumbers = [];
        const totalNumbers = 12;
        const half = Math.floor(totalNumbers / 2);
        let start = Math.max(1, this.currentPage - half);
        let end = Math.min(this.totalPageCount, this.currentPage + half);

        if (end - start + 1 < totalNumbers) {
            if (start === 1) {
                end = Math.min(start + totalNumbers - 1, this.totalPageCount);
            } else if (end === this.totalPageCount) {
                start = Math.max(end - totalNumbers + 1, 1);
            }
        }

        for (let i = start; i <= end; i++) {
            pageNumbers.push(i);
        }

        this.pageNumbers = pageNumbers;
    }

    get selectedDevicesArray() {
        return Array.from(this.selectedDevices);
    }
}