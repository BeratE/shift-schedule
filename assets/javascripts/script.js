var datepickerOptions={dateFormat: 'yy-mm-dd', firstDay: 1, showOn: 'button', buttonImageOnly: false,
  buttonImage: '/images/calendar.png', showButtonPanel: false, showWeek: true, showOtherMonths: true,
  selectOtherMonths: true, changeMonth: true, changeYear: true, beforeShow: beforeShowDatePicker};

function idSelect(id, ask) {
  document.getElementById('_id').value = id;
  if (ask) {
    if (confirm("Are you sure?")) {
      document.getElementById('id_form').submit();
    }
  } else {
    document.getElementById('id_form').submit();
  }
  return false;
}
