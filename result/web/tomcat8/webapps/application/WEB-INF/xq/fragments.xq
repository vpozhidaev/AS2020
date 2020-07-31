module namespace f = 'urn:atomskills:fragments';

import module namespace data="urn:atomskills:data" at "data.xq";
import module namespace util="urn:atomskills:util" at "util.xq";


declare variable $f:structure:=<struct>
<section code="profile" title="Мой профиль" titleCode="profile" description="Мой профиль"/>
<section code="home" title="Мой профиль" titleCode="home" description="Мой профиль"/>
</struct>;

declare variable $f:static:="static";

declare function f:convert-html($fileName) {
  let $html:=html:parse(file:read-text($fileName))
  return $html
};

declare function f:page($content, $title, $description, $section)  {
  f:page($content, $title, $description, $section, ())
};

declare function f:page($content, $title, $description, $section, $footer)  {
let $static:=$f:static

let $html:=
<html>
<head>
<title>Dron Taxi</title>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
<meta charset="utf-8"/>
<meta name="pinterest" content="nopin" />
<link data-n-head="ssr" rel="icon" type="image/x-icon"
	href="{$static}/favicon.ico"/>
<link rel="stylesheet" href="{$static}/jqueryui/jquery-ui.min.css"/>
<link href="{$static}/main.css?ca5cca7b670bc75747d9" rel="stylesheet"/>
<link href="{$static}/calendar.css?ca5cca7b670bc75747d9" rel="stylesheet"/> 
<link href="{$static}/js/jquery.contextMenu.min.css?ca5cca7b670bc75747d9" rel="stylesheet"/> 
<link data-n-head="ssr" rel="stylesheet"
	href="{$static}/css2.css?family=Roboto:wght@300;400;500;700&amp;display=swap"/>
</head>
<body>
	<div id="__nuxt">
		<!---->
		<div id="__layout">
			<div class="Grid">
				<div class="Header">
					<a href="/" class="logo nuxt-link-active">DRON TAXI</a>
				</div>
				<div class="Sidebar flex_col x_sb">
{
  if(environment-variable("atomskills.web")="true") then
            <div class="Nav">
            <a href="profile" class="Nav_item {if($section='profile') then ' nuxt-link-exact-active nuxt-link-active ' else ()} i_1" aria-current="page">Профиль</a>
            <a href="myorders" class="Nav_item {if($section='myorders') then ' nuxt-link-exact-active nuxt-link-active ' else ()} i_2" aria-current="page">Мои заказы</a>
					</div>
else
          <div class="Nav">
          {
            if(count(session:get("functions")/code[.='EDIT_PROFILE'])>0) then
            <a href="profile" class="Nav_item  {if($section='profile') then ' nuxt-link-exact-active nuxt-link-active ' else ()} i_1" aria-current="page">Профиль</a>
            else ()
          }
          {
            if(count(session:get("functions")/code[.='USER_MANAGEMENT'])>0) then
            <a href="users" class="Nav_item  {if($section='users') then ' nuxt-link-exact-active nuxt-link-active ' else ()} i_2">Упр. пользователями</a>
            else ()
          }
          {
            if(count(session:get("functions")/code[.='ROLE_MANAGEMENT'])>0) then
            <a href="roles" class="Nav_item  {if($section='roles') then ' nuxt-link-exact-active nuxt-link-active ' else ()} i_3">Упр. ролями</a>
            else ()
          }
          {
            if(count(session:get("functions")/code[.='ORDER_MANAGEMENT'])>0) then
            <a href="orders" class="Nav_item  {if($section='orders') then ' nuxt-link-exact-active nuxt-link-active ' else ()} i_5">Упр. заказами</a>
            else ()
          }
          {
            if(count(session:get("functions")/code[.='VEHICLE_MANAGEMENT'])>0) then
            <a href="transport" class="Nav_item  {if($section='transport') then ' nuxt-link-exact-active nuxt-link-active ' else ()} i_5">Упр. транспортом</a>
            else ()
          }
					</div>
}

					<a id="exit-app" href="logout" class="Nav_item i_4">Выход</a>
				</div>
				<div class="Main">
{$content}
				</div>
			</div>
		</div>
	</div>

	<div style="position: static; display: block;"></div>
<script src="{$static}/js/jquery-3.5.1.min.js" type="text/javascript"></script>
<script src="{$static}/jqueryui/jquery-ui.min.js"></script>
<script src="{$static}/jqueryui/datepicker-ru.js"></script>
<script src="{$static}/js/jquery.maskedinput.min.js"></script>
 {$footer}
<script>
<![CDATA[
  $( function() {
    $( "#datepicker" ).datepicker( $.datepicker.regional[ "ru" ] );
    $( ".datepicker" ).datepicker( $.datepicker.regional[ "ru" ] );
  } );
]]>
  </script>
</body>
</html>
  return $html
};
