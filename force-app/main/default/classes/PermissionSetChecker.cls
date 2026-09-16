/**
* @File Name : PermissionSetChecker.cls
* @Description : it is beeing used to check permission sets of user for the banner
* @Author : Govardhan
* @Last Modified By : 
* @Last Modified On : September 24, 2024
* @Modification Log :
*==============================================================================
* Ver | Date | Author | Modification
*==============================================================================
* 1.0 | September 24, 2024 |   | Initial Version
**/

public class PermissionSetChecker {
	@AuraEnabled
	Public static string permissionSet(){
		Id currentUserId = UserInfo.getUserId();
		List<PermissionSetAssignment> userPermissions = [ SELECT PermissionSet.Label FROM PermissionSetAssignment WHERE AssigneeId = :currentUserId ];
        Set<String> assignedPermissionSetNames = new Set<String>();
        
        for (PermissionSetAssignment psa : userPermissions) {
            assignedPermissionSetNames.add(psa.PermissionSet.Label);
        }
		string permissionsetvalue = '' ;
		List<String> permissionSetNamesToCheck = new List<String>{'Standard Banner Permission Set', 'Rehirg Pacific Banner Permission Set' ,'Cardinal Banner Permission Set' , 'Minus works Banner Permission Set' , 'Saudi Aramco Banner Permission Set'};
        for (String permissionSetName : permissionSetNamesToCheck) {
            if (assignedPermissionSetNames.contains(permissionSetName)) {
                permissionsetvalue=permissionSetName;
				break;
            }
        }
		return permissionsetvalue;
	}
}