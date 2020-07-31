function validateRegNo(regNo) {
  const re = /^[A-Z]{3} \d{3}-\d{3}-\d{3}$/;
  return re.test(regNo);
};

function validate() {
	var result=[];
	if($('#order input[name=registration_no]').prop('value').length < 1) {
		result.push("registration_no");
	} else {
		if(!validateRegNo($('#order input[name=registration_no]').prop('value'))) {
			result.push("registration_no_format");
		} 
	}
	
	if($('#order input[name=model]').prop('value').length < 1) {
		result.push("model");
	}
	if($('#order select[name=vehicle_class_id]').prop('value').length < 1) {
		result.push("vehicle_class_id");
	}
	if($('#order input[name=registration_date]').prop('value').length < 1) {
		result.push("registration_date");
	}
	if($('#order select[name=brand_id]').prop('value').length < 1) {
		result.push("brand_id");
	}
	if($('#order input[name=production_year]').prop('value').length < 1) {
		result.push("production_year");                
	} 
	result.forEach(function(item, i, arr) { 
		$('#'+item+"_error").css("display", "block"); 
	}); 
	return result;
};


function doValidate(form) {
	console.log("validation");
	$("[id$=_error]").each(function( index ) {
		var input=$( this );
		input.css("display","none");
	});
                       
	var validationResult=validate();
	if(validationResult.length > 0) {
		console.log(validationResult);
		$("#login-error").css("display","block");
		return false;                     
	}
	

	return true;
};

function keyDownHandler(e) { 
	if(e.keyCode == 13){
	$("#filter").submit();    
	}
};

function setPage(page) { 
	$("#filter input[name=page]").val(page);
	$("#filter").submit();
};    

$("input[type=checkbox]").change(function() {
    if(this.checked) {
    	var my=this; 
    	$("#vehicle_id").prop("value", $(my).data("id")); 
    	$("input[type=checkbox]").each(function( index , check) {
    		console.log(check, my); 
    		if($(check).attr('name') != $(my).attr('name')) {
    			$(check).prop( "checked", false );
    		}
    	});
    }
});