module namespace page = 'urn:atomskills:main-view';

import module namespace data="urn:atomskills:data" at "data.xq";
import module namespace util="urn:atomskills:util" at "util.xq";
import module namespace f="urn:atomskills:fragments" at "fragments.xq";
declare namespace bcrypt="java:org.mindrot.jbcrypt.BCrypt";
(:~
 : Главная страница
 : @return HTML page
 :)
declare
  %rest:GET
  %rest:path('/login')
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
<link rel="icon" type="image/x-icon"
	href="{$static}/favicon.ico"/>
<link  rel="stylesheet"
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
            <h3 id="login-error" style="display:none;color: #ff0000">Введен неверный логин или пароль</h3>
            <form id="login" onsubmit='return doAuth(this); ' method="POST">
            <label>Логин<input name="login" placeholder="Введите логин"/></label> 
            <label>Пароль<input name="password" type="password" placeholder="Ввведите пароль"/></label>
						<div class="flex y_center my-3">
							<label class="flex_1 flex y_center"><input name="remember" type="checkbox"/>Запомнить</label>
							<button type="submit" class="flex_1 btn_blue" >Войти</button>
						</div>
                        </form>
            {if(environment-variable("atomskills.web")="true") then
						<button class="w_100 btn_green" onclick="window.location.href='api/register'">Регистрация</button> 
            else ()
            }

					</div>
				</div>
			</div>
		</div>
	</div>


	<div style="position: static; display: block;"></div>

<script src="{$static}/js/jquery-3.5.1.min.js" type="text/javascript"></script>
<script type="text/javascript" src="{$static}/login.js"></script>
</body>
</html>

return $content

};

declare function page:setsession($data) {
  let $saveuser:=session:set("user", $data[1])
let $sql:=<s>
select f.* from r_function f
inner join mtm_role2function rf on rf.function_id=f.id
inner join mtm_user2role r on r.role_id=rf.role_id
where r.user_id=?
  </s>
let $prep:=sql:prepare($util:conn, $sql/text())
       let $params := <sql:parameters>
                         <sql:parameter type='int'>{trace(string(trace($data[1])/id))}</sql:parameter>
               </sql:parameters>
let $functions:=util:convertResult(sql:execute-prepared($prep, $params))
let $savefunctions:=session:set("functions", $functions)
return $saveuser
};

declare
  %rest:POST("{$data}")
  %rest:path('/api/auth')
function page:authenticate($data)  {
let $form:=trace(util:convertJsonForm(trace(json:parse($data))), "loginData:")
let $sql:=<s>
select u.*, to_char(birth_date, 'DD.MM.YYYY') as birth_date_format,
(case when gender='M' then 'М' when 'F' then 'Ж' else '' end) as gender_format
from users u where u.login=?
  </s>
let $prep:=sql:prepare($util:conn, $sql/text())
       let $params := <sql:parameters>
                         <sql:parameter type='string'>{string($form/login)}</sql:parameter>
               </sql:parameters>
let $data:=util:convertResult(sql:execute-prepared($prep, $params))
let $success:= count($data/id)=1
let $success2:=try {
  bcrypt:checkpw(string($form/password), string($data/password))
} catch * {
  false()
}
let $createSession:=if($success2) then page:setsession($data) else ()
return $success2
};

declare
  %rest:GET
  %rest:path('/logout')
function page:logout()  {
let $ops:=(session:delete("user"),session:delete("functions"))
return web:forward("login")
};

declare
  %rest:GET
  %rest:path('/null')
function page:nullpage()  {
web:forward("profile")
};


declare
  %rest:GET
  %rest:path('/api/register')
  %output:method('xhtml')
  %output:omit-xml-declaration('no')
  %output:doctype-public('-//W3C//DTD XHTML 1.0 Transitional//EN')
  %output:doctype-system('http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd')
function page:registration(
)  {
let $static:="../static"
let $content:=
<html>
<head>
<title>dron_taxi</title>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
<meta charset="utf-8"/>
<link rel="icon" type="image/x-icon"
	href="{$static}/favicon.ico"/>
<link  rel="stylesheet"
	href="{$static}/css2.css?family=Roboto:wght@300;400;500;700&amp;display=swap"/>
<link href="{$static}/main.css?ca5dca7b670bc75747d9" rel="stylesheet"/>
<link href="{$static}/calendar.css?ca5cca7b670bc75747d9" rel="stylesheet"/>

</head>
<body>
	<div id="__nuxt">
		<!---->
		<div id="__layout">
			<div>
				<div class="Login flex_col">
					<a href="/" class="logo nuxt-link-active">DRON TAXI</a>
					<div class="Register_form">
						<h2>Регистрация</h2>
            <p id="login-error" style="display:none;color: #ff0000">Проверьте правильность заполнения формы, заполните обязательные поля</p>
            <p id="user-error" style="display:none;color: #ff0000">Пользователь с таким email уже зарегистрирован, выберите другой email</p>
            <form id="register" onsubmit='return doRegister(this);' method="POST">
            <label>Фамилия *<input name="last_name" placeholder="Фамилия"/>
            <div class="error_msg" id="last_name_error">
            Заполните обязательное поле
            </div>
            </label> 
            <label>Имя *<input name="first_name" placeholder="Имя"/>
            <div class="error_msg" id="first_name_error">
            Заполните обязательное поле
            </div>
            </label> 
            <label>Отчество<input name="middle_name" placeholder="Отчество"/></label> 
            <label>E-mail *<input name="email" placeholder="Укажите email"/>
            <div class="error_msg" id="email_error">
            Некорректный email-адрес
            </div>
            </label> 
            <label>Пароль *<input type="password" name="password" placeholder="Ввведите пароль"/>
            <div class="error_msg" id="password_error">
            Пароль должен содержать хотя бы 1 символ в верхнем регистре, минимум 1 цифру и быть длиной не менее 6 символов.
            </div>
            </label>
            <label>Подтвердите пароль *<input type="password" name="password2" placeholder="Подтвердите пароль"/>
            <div class="error_msg" id="password2_error">Пароль и подтверждение не совпадают</div></label>
            <div style="height: 20px"></div>
            <button type="submit" class="w_100 btn_green">Регистрация</button> 
            </form>
					</div>
				</div>
			</div>
		</div>
	</div>


	<div style="position: static; display: block;"></div>

<script src="{$static}/js/jquery-3.5.1.min.js" type="text/javascript"></script>
<script type="text/javascript" src="{$static}/register.js"></script>
</body>
</html>

return $content

};

declare
  %rest:POST("{$data}")
  %rest:path('/api/register')
function page:register($data)  {
let $form:=trace(util:convertJsonForm(trace(json:parse($data))), "regData:")
let $password:=bcrypt:hashpw(string($form/password))
let $sql:=<s>
INSERT INTO 
  users
(
  login,
  password,
  first_name,
  last_name,
  middle_name,
  email
)
VALUES (
  ?,--login,
  ?,--password,
  ?,--first_name,
  ?,--last_name,
  ?,--middle_name,
  ?--email
) RETURNING *, to_char(birth_date, 'DD.MM.YYYY') as birth_date_format,
(case when gender='M' then 'М' when 'F' then 'Ж' else '' end) as gender_format;
  </s>
let $prep:=sql:prepare($util:conn, $sql/text())
       let $params := <sql:parameters>
                         <sql:parameter type='string'>{string($form/email)}</sql:parameter>
                         <sql:parameter type='string'>{string($password)}</sql:parameter>
                         <sql:parameter type='string'>{string($form/first_name)}</sql:parameter>
                         <sql:parameter type='string'>{string($form/last_name)}</sql:parameter>
                         <sql:parameter type='string'>{string($form/middle_name)}</sql:parameter>
                         <sql:parameter type='string'>{string($form/email)}</sql:parameter>
               </sql:parameters>
let $data:=try {
  util:convertResult(sql:execute-prepared($prep, $params))
} catch * {
  ()
}
let $success:= count(trace($data)/id)=1
let $createSession:=if($success) then page:setsession($data) else ()
return $success
};