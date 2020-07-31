
function orgFormValidations(formCode) {
   return ogrnValidate(formCode);// && patternValidate(formCode);
}

function patternValidate(formCode) {
	var result=true;
	$('#'+formCode+'  input[data-validation-pattern]').each(function( index ) {
		var input=$( this );
		var formParent = input.parent();
		var formHelp=formParent.siblings('.form-help:last');
		console.log(input.prop('value')); 
		if(!new RegExp(input.data("validation-pattern")).test(input.prop('value'))) {
			console.log(input.prop('value') + ' - ' + input.data("validation-pattern") + ' - invalid');
			result = false;
			formParent.addClass('field__error');
			formParent.removeClass('field__success');
			input.addClass('field__input_invalid'); 
			input.removeClass('field__input_valid');
			formHelp.empty().append(input.data('errors'));
			formHelp.removeClass('d_n');
		} else {
			console.log(input.prop('value') + ' - ' + input.data("validation-pattern") + ' - valid');
			formParent.removeClass('field__error');
			formParent.addClass('field__success');
			input.removeClass('field__input_invalid');
			input.addClass('field__input_valid');
			formHelp.empty();
			formHelp.addClass('d_n');
		}
	});
	
	
	return result;
};

function ogrnValidate(formCode) { 
	var input = $('#'+formCode+'  input[name = "ogrn"]');
	
	var formParent = input.parent();
	var formHelp=formParent.siblings('.form-help:last');
	var ogrn = input.prop('value');
	var ogrnVal = ogrn.replace(/_/g,'');
	var maxLen = input.data('maxlength');
	if(ogrnVal.length != ogrn.length) {
		formParent.addClass('field__error');
		formParent.removeClass('field__success');
		input.addClass('field__input_invalid'); 
		input.removeClass('field__input_valid');
		formHelp.empty().append('Введите корректный ОГРН (длина ОГРН должна быть '+maxLen+')');
		formHelp.removeClass('d_n'); 
		return false; 
	}
	var modResult = ogrnVal.substring(0, maxLen - 1) % (maxLen - 2);
	//var checkDigit = modResult+''.substr(modResult.length - 1);
	var checkDigit = +modResult.toString().split('').pop();
	console.log(modResult);
	console.log(modResult+''.substr(modResult.length - 1));
	if(checkDigit != (ogrnVal.substring(maxLen - 1, maxLen)) ) {
		formParent.addClass('field__error');
		formParent.removeClass('field__success');
		input.addClass('field__input_invalid');
		input.removeClass('field__input_valid');
		formHelp.empty().append('Введите корректный ОГРН (последняя цифра должна быть равна '+checkDigit+')');
		formHelp.removeClass('d_n'); 
		return false;
	}
	
	return true;
};

function submitOrgFormImpl(formCode) {
	orgFormValidations(formCode);
	if($(".field__input_invalid").length == 0 && orgFormValidations(formCode)) {
	$.ajax({
        url: '/account/restxq/organization-save', // url where to submit the request
        type : "POST", // type of action POST || GET
        dataType : 'text', // data type
        data : JSON.stringify( $("#"+formCode).serializeArray() ), // post data || get data
        success : function(result) {
            // you can see the result from the console
            // tab of the developer tools
            console.log(result);
            window.location.href = "/account/restxq/organizations?id="+result;
        },
        error: function(xhr, resp, text) {
            console.log(xhr, resp, text);
        } 
    });
	}
	return false;
};

function submitOrgForm(formCode) {
	setTimeout(submitOrgFormImpl, 30, formCode);
};