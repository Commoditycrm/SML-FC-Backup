({
	warningMessage : function(divClass) {
		var divName=document.getElementsByClassName(divClass)[0];
            divName.style.display = 'block';    
        	setTimeout(function () {
            divName.style.display = 'none';
            }, 4000);
	}
})