$(document).ready(function() {

    $('.switch-datasource').on('click', function() {
        var id = $(this).attr('id')
        if ($(this).is(':checked')) {
            $('#settings_' + id).removeClass('hidden')
        } else {
            $('#settings_' + id).addClass('hidden')
        }
    })

    $('.choose-publication-filter').on('change', function() {
        console.log('choose-publication-filter: list-' + $(this).val())
        $('.list-publication-filters').addClass('hidden')
        $('#list-' + $(this).val()).removeClass('hidden')
    })

})
