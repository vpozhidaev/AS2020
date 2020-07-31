function validateEmail(email) {
  const re = /^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
  return re.test(email);
};

function validate() {
	var result=[];
	if($('#profile input[name=first_name]').prop('value').length < 1) {
		result.push("first_name");
	}
	if($('#profile input[name=last_name]').prop('value').length < 1) {
		result.push("last_name");
	}
	if($('#profile input[name=email]').prop('value').length < 1) {
		result.push("email");
	} else {
		var email=$('#profile input[name=email]').prop('value');
		if(!validateEmail(email)) {
			result.push("email");
		}
	}
	if($('#profile input[name=password]').prop('value').length > 0) {
	if($('#profile input[name=password]').prop('value').length < 6) {
		result.push("password");
	} else {
		var valid=true;
		var password=$('#profile input[name=password]').prop('value');
		var password2=$('#profile input[name=password2]').prop('value');
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
	}
	result.forEach(function(item, i, arr) {
		$('#'+item+"_error").css("display", "block");
	});
	return result;
}; 

function saveProfile(form) {
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
	console.log(JSON.stringify( $(form).serializeArray() ));
	$.ajax({
        url: 'api/profile-save', // url where to submit the request
        type : "POST", // type of action POST || GET
        dataType : 'text', // data type
        data : JSON.stringify( $("#profile").serializeArray() ), // post data || get data
        success : function(result) {
            // you can see the result from the console
            // tab of the developer tools    
            //console.log(result);
        	if(result=="true") {
               window.location.href = "profile-edit";
        	} else {
        		$(form).addClass('error');   
        		$("#login-error").css("display","block");
        	}
        },
        error: function(xhr, resp, text) {                      
            console.log(xhr, resp, text);
        } 
    });

	return false;
};

$("input[type=checkbox]").change(function() {
    if(this.checked) {
        if($(this).attr("name")=="gender_male") {
        	$("input[name=gender_female]").prop( "checked", false );
        } else {
        	$("input[name=gender_male]").prop( "checked", false );
        }
    }
});
 

$("#file").change(function() {  
	console.log(typeof $(this)[0].files[0]);
	console.log($(this)[0].files[0].size);
	if(typeof $(this)[0].files[0] !== 'undefined'){
        var maxSize = $($(this)[0]).data('max-size'),
        size = $(this)[0].files[0].size;
        console.log(maxSize);
        if(maxSize < size) {
          //alert("Максимальный размер файла: "+maxSize);
          $('#alertDlg').modal('show'); 
          return;
        } 
        //$(".jj-image-picker-img")[0].src=window.URL.createObjectURL($(this)[0].files[0]);
    }
    var file_data = $(this)[0].files[0]; 
    var file_name = $(this)[0].files[0].name;
    var form_data = new FormData();                  
    form_data.append('id', $(this).attr('data-id'));
    form_data.append('dst', $(this).attr('data-dst'));
    form_data.append('file', file_data, file_name);
    console.log(file_data);                             
    console.log(file_name);
    var img=$("#avatar")[0];
    $.ajax({
        url: 'api/upload-avatar', // point to server-side script 
        dataType: 'json',  // what to expect back from the script, if anything
        cache: false,
        contentType: false,
        processData: false,
        data: form_data,                         
        type: 'post',
        xhr: function() {
            var myXhr = $.ajaxSettings.xhr();
            if(myXhr.upload){       
                myXhr.upload.onprogress = progress;
            }
            return myXhr;
        },
        success: function(response){   
        	var timestamp = new Date().getTime(); 
            console.log(response); // display response from the script, if any
            img.src="api/get-avatar?t=" + timestamp;
        },
        failure: function(errMsg) {  
	        console.log(errMsg);
	        alert("Произошла ошибка при загрузке файла. Команда проекта уведомлена.");
	    }
     });
    
    function progress(e){

        if(e.lengthComputable){
            var max = e.total;
            var current = e.loaded;

            var Percentage = (current * 100)/max;
            console.log(Percentage);
            if(Percentage >= 100)
            {
               // process completed  
            }
        }  
     } 

});

$('#fileup').click(function() {
	   $('#file').click();
	});

jQuery(function($){
	   $("input[name=phone]").mask("9 (999) 999-9999");

	});