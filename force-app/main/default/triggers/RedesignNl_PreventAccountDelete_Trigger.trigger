trigger RedesignNl_PreventAccountDelete_Trigger on Account (before delete) {
    // Get the current user's profile ID
    Id currentUserProfileId = [SELECT ProfileId FROM User WHERE Id = :UserInfo.getUserId()].ProfileId;
    
    for (Account acc : Trigger.old) {
        // Check if the current user is not the owner and doesn't have the specific profile ID
        if (acc.OwnerId != UserInfo.getUserId() && currentUserProfileId == '00e8a0000012KtcAAE') {
            acc.addError('You cannot delete an account that you do not own, and you do not have the necessary profile permissions.');
        }
    }
}