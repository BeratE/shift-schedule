var datepickerOptions={dateFormat: 'yy-mm-dd', firstDay: 1, showOn: 'button', buttonImageOnly: false,
  buttonImage: '/images/calendar.png', showButtonPanel: false, showWeek: true, showOtherMonths: true,
  selectOtherMonths: true, changeMonth: true, changeYear: true, beforeShow: beforeShowDatePicker};

function rowSelect(id) {
  document.getElementById('v_id').value = id;
  document.getElementById('f_new').submit();
}
