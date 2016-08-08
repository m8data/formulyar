


function select(obj)
{
    $.ajax({
        type: "GET",
        url: "/m8/$/reg.pl",
        data: $( obj ).serialize(),
       // success: function(msg){"input, textarea, select"
         //   if(parseInt(msg.status)==1)
        //    {
        //        window.location=msg.txt;
        //    }
        //    else if(parseInt(msg.status)==0)
        //    {
        //        result(1,msg.txt);
        //    }
        //}
		success: function( json ) {
        $( "<h1>" ).text( json.title ).appendTo( "body" );
        $( "<div class=\"content\">").html( json.html ).appendTo( "body" );
    },
 
    // Code to run if the request fails; the raw request and
    // status codes are passed to the function
    error: function( xhr, status, errorThrown ) {
        alert( "Sorry, there was a problem!" );
        console.log( "Error: " + errorThrown );
        console.log( "Status: " + status );
        console.dir( xhr );
    },
 
    // Code to run regardless of success or failure
    complete: function( xhr, status ) {
       // alert( "The request is complete!" );
    }
	
    });

}

function result(act,txt)
{
    if(txt) $('#subcategory').html(txt);
}
