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
	if($('#order input[name=departure_address]').prop('value').length < 1) {
		result.push("departure_address");
	}
	if($('#order input[name=destination_address]').prop('value').length < 1) {
		result.push("destination_address");
	}
	if($('#order select[name=transport_class_id]').prop('value').length < 1) {
		result.push("transport_class_id");
	}
	result.forEach(function(item, i, arr) { 
		$('#'+item+"_error").css("display", "block"); 
	}); 
	return result;
}; 

function doOrder(form) {
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
        url: 'api/placeorder', // url where to submit the request 
        type : "POST", // type of action POST || GET  
        dataType : 'text', // data type
        data : JSON.stringify( $("#order").serializeArray() ), // post data || get data
        success : function(result) {   
            // you can see the result from the console 
            // tab of the developer tools
            //console.log(result);
        	if(result=="true") {
            window.location.href = "myorders"; 
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

function keyDownHandler(e) { 
	if(e.keyCode == 13){
	$("#filter").submit();
	}
};

function setPage(page) { 
	$("#filter input[name=page]").val(page);
	$("#filter").submit();
};