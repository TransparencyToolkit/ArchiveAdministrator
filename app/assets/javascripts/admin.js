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
    })

    $('.choose-publication-filter').each(function() {
        var id = $(this).attr('id').replace('filterfield_', '')
        var item = '#list-' + id + '-' + $(this).val()
        $(item).removeClass('hidden')
    })

    $('.choose-publication-filter').on('change', function() {
        var item = '#list-' + $(this).attr('id').replace('filterfield_', '') + '-' + $(this).val()
        $('.list-publication-filters').addClass('hidden')
        $(item).removeClass('hidden')
        var none_em = $(item).find('em')
        if (none_em.length > 0) {
            var name = $(this).find('option:selected').text()
            $(none_em).html('"' + name  + '" has no items')
        }
    })

})
