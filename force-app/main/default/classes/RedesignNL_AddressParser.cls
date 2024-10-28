public class RedesignNL_AddressParser {
    public static String getState(String address) {
        String states;
        List<String> parts = address.split(',');
        for(Integer i = parts.size() - 1; i >= 0; i--) {
            String part = parts[i].trim().replaceAll('\\s', ''); // Remove any spaces
            // Remove any digits from the part
            String stateAbbreviation = part.replaceAll('\\d', '');
            // Check if the remaining part is a two-letter state abbreviation
            if(stateAbbreviation.length() == 2 && stateAbbreviation == stateAbbreviation.toUpperCase()) {
                states= stateAbbreviation;
                break; // Stop further iteration if state is found in this address
            }
            
        }
        
        return states; // Output the extracted states
    }
}