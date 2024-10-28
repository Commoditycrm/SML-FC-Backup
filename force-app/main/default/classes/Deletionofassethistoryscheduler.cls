global class Deletionofassethistoryscheduler {
global void execute(SchedulableContext sc) 
{
        DeletionofAssetHistory AH_del = new DeletionofAssetHistory(); 
        // To execute batch in 9,00,000 lakhs record will be processing
        Database.executeBatch(AH_del,900000);
    }
}