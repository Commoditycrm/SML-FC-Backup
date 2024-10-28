public class RedesignNL_CSVEmailSender {
    public static void sendCSVAsEmail(List<sObject> records) {
        // Check if records list is empty
        if (records.isEmpty()) {
            return;
        }

        // Create a set to hold field names from the query
        Set<String> queriedFields = new Set<String>();
        // Example record to extract the queried fields
        Map<String, Object> fieldsMap = records[0].getPopulatedFieldsAsMap();
        queriedFields.addAll(fieldsMap.keySet());

        // Create CSV header from the fields actually queried
        String header = '';
        for (String fieldName : queriedFields) {
            header += fieldName + ',';
        }
        header = header.removeEnd(',');

        // Generate CSV content
        String csvContent = header + '\n';
        for (sObject record : records) {
            String row = '';
            for (String fieldName : queriedFields) {
                // Append field value, handle null values and ensure proper CSV formatting
                Object value = record.get(fieldName);
                row += '"' + (value != null ? value.toString().replace('"', '""') : '') + '",';
            }
            row = row.removeEnd(',');
            csvContent += row + '\n';
        }

        // Create email and attach CSV
        Messaging.EmailFileAttachment csvAttachment = new Messaging.EmailFileAttachment();
        csvAttachment.setFileName('data.csv');
        csvAttachment.setBody(Blob.valueOf(csvContent));
        csvAttachment.setContentType('text/csv');

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new String[] {System.Label.Email_Address});
        mail.setSubject('CSV Data');
        mail.setPlainTextBody('Please find the attached CSV file.');
        mail.setFileAttachments(new Messaging.EmailFileAttachment[] {csvAttachment});

        // Send the email
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
    }
}