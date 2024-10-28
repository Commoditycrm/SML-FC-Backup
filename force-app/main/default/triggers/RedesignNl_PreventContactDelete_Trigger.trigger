trigger RedesignNl_PreventContactDelete_Trigger on Contact (before delete) {
    // Get the current user's profile ID
    Id currentUserProfileId = [SELECT ProfileId FROM User WHERE Id = :UserInfo.getUserId()].ProfileId;
    
    for (Contact con : Trigger.old) {
        // Check if the current user is not the owner and doesn't have the specific profile ID
        if (con.OwnerId != UserInfo.getUserId() && currentUserProfileId == '00e8a0000012KtcAAE') {
            con.addError('You cannot delete a contact that you do not own, and you do not have the necessary profile permissions.');
        }
    }
}