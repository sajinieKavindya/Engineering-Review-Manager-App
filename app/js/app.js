/**
 * Created by sajinie on 11/5/17.
 */
var reviewTypeForTitle = "";
var componentNameForTitle = "";

function renderTeamInfo() {
    var url = "components/teamDetails.jag";
    var response;
    $.ajax({
        type: "GET",
        url: url,
        data:{},
        async: true,
        success: function(data){
            response = JSON.parse(data);

            if(response && response.error.status === true){
                document.getElementById("teamSelection").innerHTML = '<div class="alert alert-danger" role="alert">'+ response.error.msg +'</div>';
            }else if(response){
                var select = document.getElementById('Team');

                var optionAll =  document.createElement('option');
                var all = "";
                var nameAll =  "";

                optionAll.setAttribute('value',all);
                optionAll.appendChild(document.createTextNode(nameAll));
                select.appendChild(optionAll);

                var  totalComponents = response.teams.length;
                for(var i=0; i<totalComponents; i++) {
                    var option = document.createElement('option');
                    var id =  response.teams[i].teamId + "," + response.teams[i].teamName;
                    var name =  response.teams[i].teamName;

                    option.setAttribute("value",id);
                    option.appendChild(document.createTextNode(name));
                    select.appendChild(option);
                }

                $('#Team').chosen();

            }
        }
    });


}
$(window).on('load', function() {
    renderTeamInfo();

});

$(document).ready(function() {

    document.getElementById('date').innerHTML = moment().format('MMMM D, YYYY');

    $('#product').chosen();

    $('#ReviewNotes').summernote({height: '200px'});
    $('#Reference').summernote({height: '100px'});

    $('#Reporter').focusin(function(){
        $('#reporterDiv').removeClass('has-error');
        $('#reporterSpan').removeClass('glyphicon glyphicon-remove form-control-feedback');
        $('#outerReporterSpan').html("");
    });

    $('#Contributor').focusin(function(){
        $('#contributorDiv').removeClass('has-error');
        $('#innerContributorSpan').removeClass('glyphicon glyphicon-remove form-control-feedback');
        $('#outerContributorSpan').html("");
    });

    $('#Participants').focusin(function(){
        $('#participantsDiv').removeClass('has-error');
        $('#innerParticipantsSpan').removeClass('glyphicon glyphicon-remove form-control-feedback');
        $('#outerParticipantsSpan').html("");
    });

    $('#GroupEmail').focusin(function(){
        $('#groupEmailsDiv').removeClass('has-error');
        $('#innerGroupEmailsSpan').removeClass('glyphicon glyphicon-remove form-control-feedback');
        $('#outerGroupEmailsSpan').html("");
    });

    $('#ReviewType').focusin(function(){
        $('#reviewTypeDiv').removeClass('has-error');
        $('#outerReviewTypeSpan').html("");
    });

    $('#ReviewedDate').focusout(function(){
        var dateAndTime = $(this).val();
        if(dateAndTime !== ""){
            date = dateAndTime.split(" ");
            $('#date').html(moment(date[0], 'YYYY-MM-DD').format('MMMM D, YYYY'));
            $('#outerDatePickerSpan').removeClass('has-error');
        }else{
            $('#date').html("");
            $('#datetimepicker1').addClass('has-error');
            $('#outerDatePickerSpan').html('Please select a valid date');
        }
    });
    $('#ReviewedDate').focusin(function(){
        $('#outerDatePickerSpan').removeClass('has-error');
        $('#outerDatePickerSpan').html("");
    });

    $('#teamSection').focusin(function(){
        $('#teamSection').removeClass('has-error');
        $('#outerTeamSpan').html("");
    });

    $('#productSection').focusin(function(){
        $('#productSection').removeClass('has-error');
        $('#outerProductSpan').html("");
    });

    $('#productVersionSection').focusin(function(){
        $('#productVersionSection').removeClass('has-error');
        $('#outerProductVersionSpan').html("");
    });

    $('#componentSection').focusin(function(){
        $('#componentSection').removeClass('has-error');
        $('#outerComponentSpan').html("");
    });

    $('#componentSection').focusout(function(){
        componentNameForTitle = document.getElementById('Component').value;
        document.getElementById('mainTitle').innerHTML = "Create Review - " + reviewTypeForTitle +" "+ componentNameForTitle;

    });

    $('#componentVersionSection').focusin(function(){
        $('#componentVersionSection').removeClass('has-error');
        $('#outerComponentVersionSpan').html("");
    });

    $('#reviewNotesDiv').focusin(function(){
        $('#reviewNotesDiv').removeClass('has-error');
        $('#outerReviewNotesSpan').html("");
    });
});


$(function () {
    $('#datetimepicker1').datetimepicker({
        defaultDate:  moment(),
        format: 'YYYY-MM-DD'
    });
});



$(document).on('change','#Team',function(){
    var teamName = document.getElementById('Team').value;
    if(teamName !== ""){
        renderProductInfo(teamName);
    }else{
        $('#product').prop( 'disabled', true );
        $('#product_chosen').addClass( 'chosen-disabled' );
        document.getElementById('product').innerHTML = '<option value=""></option>';

    }

});

$(document).on('change','#ReviewType',function(){
    var reviewType = document.getElementById('ReviewType').value;
    reviewTypeForTitle = "[ " + reviewType + " ]";
    document.getElementById('mainTitle').innerHTML = "Create Review - " + reviewTypeForTitle + " " + componentNameForTitle;
});

$(document).on('change','#datetimepicker1',function(){
    var reviewDate = document.getElementById('ReviewedDate').value;
    document.getElementById('date').innerHTML = reviewDate;
});



function renderProductInfo(param) {
    var url = "components/productDetail.jag?team=" + param;
    var response;
    $.ajax({
        type: "GET",
        url: url,
        data:{},
        async: true,
        success: function(data){
            response = JSON.parse(data);

            if(response && response.error.status === true){
                document.getElementById('productSelection').innerHTML = '<div class="alert alert-danger" role="alert">'+ response.error.msg +'</div>';
            }else if(response){
                var item = document.getElementById('productSelection');
                item.innerHTML = "";
                var select = document.createElement('select');
                select.setAttribute('class','form-control chosen-select');
                select.setAttribute('id','product');
                select.setAttribute('name','product');
                select.setAttribute('style','padding: 5px;');

                var optionAll =  document.createElement('option');
                var all = "";
                var nameAll =  "";

                optionAll.setAttribute('value',all);
                optionAll.appendChild(document.createTextNode(nameAll));
                select.appendChild(optionAll);

                var  totalComponents = response.products.length;
                for(var i=0; i<totalComponents; i++) {
                    var option = document.createElement('option');
                    var id =  response.products[i].productId + "," + response.products[i].productName;
                    var name =  response.products[i].productName;

                    option.setAttribute('value',id);
                    option.appendChild(document.createTextNode(name));
                    select.appendChild(option);
                }
                item.appendChild(select);
                $('#product').chosen();
            }

        }
    });

}

