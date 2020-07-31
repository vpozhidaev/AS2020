function validateEmail(email) {
  const re = /^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
  return re.test(email);
};

function validate() {
	var result=[];
	if($('#register input[name=first_name]').prop('value').length < 1) {
		result.push("first_name");
	}
	if($('#register input[name=last_name]').prop('value').length < 1) {
		result.push("last_name");
	}
	if($('#register input[name=email]').prop('value').length < 1) {
		result.push("email");
	} else {
		var email=$('#register input[name=email]').prop('value');
		if(!validateEmail(email)) {
			result.push("email");
		}
	}
	if($('#register input[name=password]').prop('value').length < 6) {
		result.push("password");
	} else {
		var valid=true;
		var password=$('#register input[name=password]').prop('value');
		var password2=$('#register input[name=password2]').prop('value');
		if(!/[A-ZА-Я]/.test(password)) {
			result.push("password");
			valid=false;
		}
		if(!/[0-9]/.test(password)) {
			result.push("password");
			valid=false;
		}
		if(valid) {
			if(password != password2) {
				result.push("password2");	
			}
		}
	}
	result.forEach(function(item, i, arr) {
		$('#'+item+"_error").css("display", "block");
	});
	return result;
}; 

function doRegister(form) {
	const urlParams = new URLSearchParams(window.location.search);
	console.log(JSON.stringify( $(form).serializeArray() ));
	$("[id$=_error]").each(function( index ) {
		var input=$( this );
		input.css("display","none");
	});
	$("#login-error").css("display","none");
	$("#user-error").css("display","none");
	var validationResult=validate();
	if(validationResult.length > 0) {
		console.log(validationResult);
		$("#login-error").css("display","block");
		return false; 
	}
	$.ajax({
        url: 'register', // url where to submit the request 
        type : "POST", // type of action POST || GET  
        dataType : 'text', // data type
        data : JSON.stringify( $("#register").serializeArray() ), // post data || get data
        success : function(result) {   
            // you can see the result from the console 
            // tab of the developer tools
            //console.log(result);
        	if(result=="true") {
            window.location.href = "../profile";
        	} else {
        		$(form).addClass('error'); 
        		$("#user-error").css("display","block");
        	}
        },
        error: function(xhr, resp, text) {  
            console.log(xhr, resp, text); 
        } 
    });

	return false;
};

