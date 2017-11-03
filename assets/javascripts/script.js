var datepickerOptions={dateFormat: 'yy-mm-dd', firstDay: 1, showOn: 'button', buttonImageOnly: false,
  buttonImage: '/images/calendar.png', showButtonPanel: false, showWeek: true, showOtherMonths: true,
  selectOtherMonths: true, changeMonth: true, changeYear: true, beforeShow: beforeShowDatePicker};

function versionSelect(id) {
  document.getElementById('v_id').value = id;
  if (confirm("Are you sure?")) {
    document.getElementById('version_form').submit();
  }
  return false;
}
