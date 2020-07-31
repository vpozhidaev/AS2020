( function( factory ) {
	if ( typeof define === "function" && define.amd ) {

		// AMD. Register as an anonymous module.
		define( [ "../widgets/datepicker" ], factory );
	} else {

		// Browser globals
		factory( jQuery.datepicker );
	}
}( function( datepicker ) {

datepicker.regional.ru = {
	closeText: "Закрыть",
	prevText: "Назад",
	nextText: "Вперед",
	currentText: "Сегодня",
	monthNames: [ "январь", "февраль", "март", "апрель", "май", "июнь",
		"июль", "август", "сентябрь", "октябрь", "ноябрь", "декабрь" ],
	monthNamesShort: [ "янв.", "февр.", "март", "апр.", "май", "июнь",
		"июль", "авг.", "сент.", "окт.", "ноя.", "дек." ],
	dayNames: [ "воскресенье", "понедельник", "вторник", "среда", "четверг", "пятница", "суббота" ],
	dayNamesShort: [ "вс.", "пнд.", "вт.", "ср.", "чтв.", "птн.", "суб." ],
	dayNamesMin: [ "В","П","В","С","Ч","П","С" ],
	weekHeader: "Нед.",
	dateFormat: "dd.mm.yy",
	firstDay: 1, 
	isRTL: false,
	showMonthAfterYear: false,
	yearSuffix: "г." };
datepicker.setDefaults( datepicker.regional.en  );

return datepicker.regional.ru;

} ) );
