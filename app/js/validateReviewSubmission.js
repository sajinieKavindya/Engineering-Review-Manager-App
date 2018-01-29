/**
 * Created by sajinie on 11/5/17.
 */
function isValidEmailAddress(emailAddress) {
    var pattern = /^([a-z\d!#$%&'*+\-\/=?^_`{|}~\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]+(\.[a-z\d!#$%&'*+\-\/=?^_`{|}~\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]+)*|"((([ \t]*\r\n)?[ \t]+)?([\x01-\x08\x0b\x0c\x0e-\x1f\x7f\x21\x23-\x5b\x5d-\x7e\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]|\\[\x01-\x09\x0b\x0c\x0d-\x7f\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]))*(([ \t]*\r\n)?[ \t]+)?")@(([a-z\d\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]|[a-z\d\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF][a-z\d\-._~\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]*[a-z\d\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])\.)+([a-z\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]|[a-z\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF][a-z\d\-._~\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]*[a-z\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])\.?$/i;
    return pattern.test(emailAddress);
}

function isValidVersion(versionNumber) {
    var pattern = /^-?\d*(\.\d+)?$/;
    return pattern.test(versionNumber);
}

function postForm() {
    var reporter = $('#Reporter').val();
    console.log('reporter: ' + reporter);
    if (reporter === "") {
        $('#reporterDiv').addClass('has-error');
        $('#reporterSpan').addClass('glyphicon glyphicon-remove form-control-feedback');
        $('#outerReporterSpan').html('Please fill out this field');
        return false;
    }
    if (reporter !== "") {
        if( !isValidEmailAddress(reporter) ) {
            $('#reporterDiv').addClass('has-error');
            $('#reporterSpan').addClass('glyphicon glyphicon-remove form-control-feedback');
            $('#outerReporterSpan').html("Please enter a valid email address including the '@'.");
            return false;
        }
    }

    var contributor = $('#Contributor').val();
    if (contributor === "") {
        $('#contributorDiv').addClass('has-error');
        $('#innerContributorSpan').addClass('glyphicon glyphicon-remove form-control-feedback');
        $('#outerContributorSpan').html('Please fill out this field');
        return false;
    }else{
        var contributors = contributor.split(',');
        var len = contributors.length;

        for (var i=0; i<len; i++){
            var contr = contributors[i];
            if( !isValidEmailAddress(contr.trim()) ) {
                $('#contributorDiv').addClass('has-error');
                $('#innerContributorSpan').addClass('glyphicon glyphicon-remove form-control-feedback');
                $('#outerContributorSpan').html("Please enter a valid email address including the '@'.");
                return false;
            }

        }
    }

    var participants = $('#Participants').val();
    if (participants === "") {
        $('#participantsDiv').addClass('has-error');
        $('#innerParticipantsSpan').addClass('glyphicon glyphicon-remove form-control-feedback');
        $('#outerParticipantsSpan').html('Please fill out this field');
        return false;
    }else{
        var participantsArray = participants.split(',');
        var numOfParticipants = participantsArray.length;

        for (var index=0; index<numOfParticipants; index++){
            var par = participantsArray[index];

            if( !isValidEmailAddress(par.trim()) ) {
                $('#participantsDiv').addClass('has-error');
                $('#innerParticipantsSpan').addClass('glyphicon glyphicon-remove form-control-feedback');
                $('#outerParticipantsSpan').html("Please enter a valid email address including the '@'.");
                return false;
            }

        }
    }

    var groupEmails = $('#GroupEmail').val();
    if (groupEmails !== "") {
        var groupEmailsArray = groupEmails.split(',');
        var numOfGroupEmails = groupEmailsArray.length;

        for (var index=0; index<numOfGroupEmails; index++){

            var group = groupEmailsArray[index];
            if( !isValidEmailAddress(group.trim()) ) {
                $('#groupEmailsDiv').addClass('has-error');
                $('#innerGroupEmailsSpan').addClass('glyphicon glyphicon-remove form-control-feedback');
                $('#outerGroupEmailsSpan').html("Please enter a valid email address including the '@'.");
                return false;
            }

        }
    }



    var reviewedDate = $('#ReviewedDate').val();
    if (reviewedDate === "") {
        $('#datetimepicker1').addClass('has-error');
        $('#outerDatePickerSpan').html('Please select a valid date');
        return false;
    }

    var reviewType = $('#ReviewType').val();
    if (reviewType === "") {
        $('#reviewTypeDiv').addClass('has-error');
        $('#outerReviewTypeSpan').html('Please select a review type');
        return false;
    }

    var team = $('#Team').val();
    if (team === "") {
        $('#teamSection').addClass('has-error');
        $('#outerTeamSpan').html('Please select a team');
        return false;
    }

    var product = $('#product').val();
    if (product === "") {
        $('#productSection').addClass('has-error');
        $('#outerProductSpan').html('Please select a product');
        return false;
    }

    var productVersion = $('#ProductVersion').val();
    if (productVersion === "") {
        $('#productVersionSection').addClass('has-error');
        $('#outerProductVersionSpan').html('Please enter a product version');
        return false;
    }

    var reviewNotes = $('#ReviewNotes').val();
    if (reviewNotes === "") {
        $('#reviewNotesDiv').addClass('has-error');
        $('#outerReviewNotesSpan').html('Please give your review notes above');
        return false;
    }
    return true;
}

