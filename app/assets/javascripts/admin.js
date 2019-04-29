$(document).ready(function() {

    $('.switch-datasource').on('click', function() {
        var id = $(this).attr('id')
        if ($(this).is(':checked')) {
            $('#settings_' + id).removeClass('hidden')
            $(this).val(1)
        } else {
            $('#settings_' + id).addClass('hidden')
            $(this).val(0)
        }
        console.log('set ' + id  + ' to: ' + $(this).val())
    })

    $('.choose-publication-filter').each(function() {
        var id = $(this).attr('id').replace('filterfield_', '')
        console.log('Show checkboxes: ' + id + '-' + $(this).val() )
        $('#list-' + id + '-' + $(this).val()).removeClass('hidden')
    })

    $('.choose-publication-filter').on('change', function() {
        console.log('choose-publication-filter: list-' + $(this).val())
        $('.list-publication-filters').addClass('hidden')
        $('#list-' + $(this).attr('id') + '-' + $(this).val()).removeClass('hidden')
    })

})
