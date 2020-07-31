    $(function() {
        $.contextMenu({
            selector: '.cancellable_order_row', 
            callback: function(key, options) {
                var m = "clicked: " + key;
                console.log(m, options, $(this).data("id"));
                var id=$(this).data("id");
                var dto={};  
                dto.id=id;
                $.ajax({
                    url: 'api/cancelorder', // url where to submit the request 
                    type : "POST", // type of action POST || GET  
                    dataType : 'text', // data type
                    data : JSON.stringify( dto ), // post data || get data
                    success : function(result) {   
                    	$("#filter").submit();
                    },
                    error: function(xhr, resp, text) {  
                        console.log(xhr, resp, text); 
                    } 
                });
            },
            items: {  
                "cancel": {name: "Отменить"}
            }
        });
        $.contextMenu({
            selector: '.executed_order_row',    
            callback: function(key, options) {
            	  var m = "clicked: " + key;
                  console.log(m, options, $(this).data("id"));
                  var id=$(this).data("id");
                  var dto={};
                  dto.id=id;
                  $.ajax({
                      url: 'api/completeorder', // url where to submit the request 
                      type : "POST", // type of action POST || GET  
                      dataType : 'text', // data type
                      data : JSON.stringify( dto ), // post data || get data
                      success : function(result) {   
                      	$("#filter").submit();
                      },
                      error: function(xhr, resp, text) {  
                          console.log(xhr, resp, text); 
                      } 
                  });
            },
            items: {
                "complete": {name: "Завершить"} 
            }
        });
 
    });
 
function validate() {
	var result=[];
	if($('#order input[name=registration_no]').prop('value').length < 1) {
		result.push("registration_no");
	}
	if($('#order input[name=model]').prop('value').length < 1) {
		result.push("model");
	}
	if($('#order select[name=vehicle_class_id]').prop('value').length < 1) {
		result.push("vehicle_class_id");
	}
	if($('#order select[name=registration_date]').prop('value').length < 1) {
		result.push("registration_date");
	}
	if($('#order select[name=brand_id]').prop('value').length < 1) {
		result.push("brand_id");
	}
	if($('#order select[name=brand_id]').prop('value').length < 1) {
		result.push("brand_id");
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