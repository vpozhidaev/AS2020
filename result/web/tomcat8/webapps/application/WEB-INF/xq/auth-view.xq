module namespace page = 'urn:atomskills:main-view';

import module namespace data="urn:atomskills:data" at "data.xq";
import module namespace util="urn:atomskills:util" at "util.xq";
import module namespace f="urn:atomskills:fragments" at "fragments.xq";

(:~
 : Главная страница
 : @return HTML page
 :)
declare
  %rest:GET
  %rest:path('/auth')
  %output:method('xhtml')
  %output:omit-xml-declaration('no')
  %output:doctype-public('-//W3C//DTD XHTML 1.0 Transitional//EN')
  %output:doctype-system('http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd')
function page:start(
)  {
let $static:="static"
let $content:=
<html>
<head>
<title>dron_taxi</title>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
<meta charset="utf-8"/>
<link data-n-head="ssr" rel="icon" type="image/x-icon"
	href="{$static}/favicon.ico"/>
<link data-n-head="ssr" rel="stylesheet"
	href="{$static}/css2.css?family=Roboto:wght@300;400;500;700&amp;display=swap"/>
<link href="{$static}/main.css?ca5cca7b670bc75747d9" rel="stylesheet"/>
<link href="{$static}/calendar.css?ca5cca7b670bc75747d9" rel="stylesheet"/>

</head>
<body>
	<div id="__nuxt">
		<!---->
		<div id="__layout">
			<div>
				<div class="Login flex_col">
					<a href="/" class="logo nuxt-link-active">DRON TAXI</a>
					<div class="Login_form">
						<h2>АВТОРИЗАЦИЯ</h2>
						<label>Логин<input placeholder="Ввведите логин"/></label> <label>Пароль<input
							placeholder="Ввведите пароль"/></label>
						<div class="flex y_center my-3">
							<label class="flex_1 flex y_center"><input
								type="checkbox"/>Запомнить</label>
							<button class="flex_1 btn_blue">Войти</button>
						</div>
						<button class="w_100 btn_green">Регистрация</button>
					</div>
				</div>
			</div>
		</div>
	</div>


	<div style="position: static; display: block;"></div>
</body>
</html>

return $content

};


declare
  %rest:POST
  %rest:path('/auth')
function page:authenticate()  {
let $content:=html:parse(file:read-text("../../static/auth.html"))

return $content

};