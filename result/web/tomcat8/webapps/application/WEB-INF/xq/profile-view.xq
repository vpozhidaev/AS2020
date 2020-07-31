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
  %rest:path('/profile')
  %output:method('xhtml')
  %output:omit-xml-declaration('no')
  %output:doctype-public('-//W3C//DTD XHTML 1.0 Transitional//EN')
  %output:doctype-system('http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd')
function page:start(
)  {
let $content:=
					<div>
						<h1>Профиль</h1>
						<div class="Main_body">
							<div class="flex">
								<div class="flex_col">
									<img src="api/get-avatar" style="width: 120px;"/>
									<button class="mt-5 btn_blue" onclick="window.location.href='profile-edit'">Редактировать</button>
								</div>
								<div class="ml-5">
									<label>Фамилия
                  <div class="profile-field-text" >{string(session:get("user")/last_name)}</div>
                  </label>
                  
                  <label>Имя
                  <div class="profile-field-text" >{string(session:get("user")/first_name)}</div>
                  </label><label>Отчество
                  <div class="profile-field-text" >{string(session:get("user")/middle_name)}</div>
                  </label><label>Дата рождения
										<div class="profile-field-text" >{string(session:get("user")/birth_date_format)} </div>
									</label><label>Пол
										<div class="profile-field-text" >{string(session:get("user")/gender_format)} </div>
									</label>
								</div>
								<div class="ml-5">
									<label>Email
                  <div class="profile-field-text" >{string(session:get("user")/email)} </div>
                  </label><label>Телефон
                  <div class="profile-field-text" >{string(session:get("user")/phone)} </div>
                  </label>
								</div>
							</div>

						</div>
					</div>



return f:page($content, "Заголовок", "Описание", "profile")

};
 
declare
  %rest:GET
  %rest:path('/profile-edit')
  %output:method('xhtml')
  %output:omit-xml-declaration('no')
  %output:doctype-public('-//W3C//DTD XHTML 1.0 Transitional//EN')
  %output:doctype-system('http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd')
function page:edit(
)  {
let $user:=session:get("user")

let $content:=
					<div>
						<h1>Профиль</h1>
						<div class="Main_body">
							<form class="flex" method="POST" id="profile" onsubmit='return saveProfile(this);' autocomplete="off">
              <input autocomplete="off" name="hidden" type="text" style="display:none;"/>
								<div class="flex_col">
                <input id="file" type="file" name="file" style="position: absolute;z-index:11; opacity: 0;width: 120px;height: 220px;padding: 0px;margin:0px;"/>
									<img id="avatar" src="api/get-avatar" style="width: 120px; height: 120px;object-fit: contain;"/>

									<button id="fileup" class="mt-5 btn_blue">
                  Обновить</button>
                  
								</div>
								<div class="ml-5">
									<label>Фамилия *<input name="last_name" value="{string($user/last_name)}" placeholder="Фамилия"/>
                  <div class="error_msg" id="last_name_error">
            Заполните обязательное поле
            </div>                  
                  </label><label>Имя *<input
										placeholder="Имя" name="first_name" value="{string($user/first_name)}"/>
                    <div class="error_msg" id="first_name_error">
            Заполните обязательное поле
            </div>                            
                    </label><label>Отчество<input
										placeholder="Отчество" name="middle_name" value="{string($user/middle_name)}"/>
                    <div class="error_msg" id="middle_name_error">
            Заполните обязательное поле
            </div>        
                    </label><label>Дата рождения
										<div class="Calendar_Input">
											<input id="datepicker" type="text" readonly="readonly"
												class="Calendar_Input_inp" value="{string($user/birth_date_format)}" name="birth_date"/>
											
										</div>
									</label><label>Пол
										<div>
											<input type="checkbox" name="gender_male">
                      {if($user/gender='M')  then attribute checked {"checked"} else ()}
                      </input>
                      M
                      <input type="checkbox" class="ml-4" name="gender_female">
                      {if($user/gender='F')  then attribute checked {"checked"} else ()}
                      </input>
                      Ж
										</div>
									</label>
								</div>
								<div class="ml-5">
									<label>Email *<input placeholder="Email" name="email" autocomplete="off" value="{string($user/email)}"/>
                  <div class="error_msg" id="email_error">
            Некорректный email-адрес
            </div>
                  </label><label>Телефон<input
										placeholder="Телефон" name="phone" value="{string($user/phone)}"/>
                    <div class="error_msg" id="phone_error">
            Некорректный номер телефона
            </div>
                    </label><label>Пароль<input
										placeholder="Пароль" type="password" autocomplete="new-password" name="password"/>
                    <div class="error_msg" id="password_error">
            Пароль должен содержать хотя бы 1 символ в верхнем регистре, минимум 1 цифру и быть длиной не менее 6 символов.
            </div>
                    </label><label>Подтверждение
										пароля<input placeholder="Подтверждение пароля" autocomplete="new-password" type="password" name="password2"/>
                    <div class="error_msg" id="password2_error">Пароль и подтверждение не совпадают</div>
									</label>
									<div class="mt-4 flex x_end">
										<button class="btn_green">Сохранить</button>
                    <span style="width: 10px"/>
										<button class="btn_blue">Отмена</button>
									</div>
								</div>
							</form>

						</div>
					</div>
          
let $foot:= <s>
<script type="text/javascript" src="static/profile.js?ca5cca8b670bc75747d9"/>
</s>/*

return f:page($content, "Заголовок", "Описание", "profile", $foot)

};


declare
  %rest:POST
  %rest:path('api/upload-avatar')
  %output:method('json')
  %rest:form-param("id", "{$id}")
  %rest:form-param("file", "{$file}")
function page:upload($id, $file) {
  let $userId:=string(session:get("user")/id)
  for $name    in map:keys($file)
  let $content := $file($name)
  let $r1 := replace($name,'\.[^.]*$','')
  let $sql:=<s>
update users
set avatar=decode(?, 'base64')::bytea
where id=?
returning id
  </s>
let $prep:=sql:prepare($util:conn, $sql/text())
       let $params := <sql:parameters>
                         <sql:parameter type='string'>{$content}</sql:parameter>
                         <sql:parameter type='int'>{$userId}</sql:parameter>
               </sql:parameters>
let $result:=util:convertResult(sql:execute-prepared($prep, $params))
  
  return $result
};


declare
  %rest:GET
  %rest:path('api/get-avatar')
  %rest:produces("image/*", "image/*")
function page:download() {
  let $userId:=string(session:get("user")/id)
    let $sql:=<s>
select encode(avatar, 'base64') as avatar from users where id=?
  </s>
let $prep:=sql:prepare($util:conn, $sql/text())
       let $params := <sql:parameters>
                         <sql:parameter type='int'>{$userId}</sql:parameter>
               </sql:parameters>
  let $data:=util:convertResult(sql:execute-prepared($prep, $params))
  
  let $bin:=xs:base64Binary($data/avatar)
  return 
  if(string-length($data/avatar)>0) then
  (<rest:response>
  <http:response status="200">
  </http:response>
    <output:serialization-parameters>
      <output:media-type value='image/*'/>
    </output:serialization-parameters>
  </rest:response>,$bin)
  else web:redirect("../static/img/clear-prof.png")
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
  %rest:path('/api/profile-save')
function page:profile-save($data)  {
let $userId:=string(session:get("user")/id)
let $form:=trace(util:convertJsonForm(trace(json:parse($data))), "regData:")
let $password:=if(string-length(string($form/password))>0) then bcrypt:hashpw(string($form/password)) else ""
let $gender:=if(string($form/gender_male)="on") then "M" else if(string($form/gender_female)="on") then "F" else ""

let $sql:=<s>
UPDATE 
  public.users 
SET 
  birth_date = to_date(?,'DD.MM.YYYY'), --birth_date,
  first_name = ?,--first_name,
  last_name = ?,--last_name,
  middle_name = ?,--middle_name,
  email = ?,--email,
  login = ?,--email,
  phone = ?,--phone,
  gender = case when ? in ('M','F') then ?::enum_gender else null end --gender
WHERE 
  id = ?
RETURNING *, to_char(birth_date, 'DD.MM.YYYY') as birth_date_format,
(case when gender='M' then 'М' when 'F' then 'Ж' else '' end) as gender_format;
  </s>
let $prep:=sql:prepare($util:conn, $sql/text())
       let $params := <sql:parameters>
                         <sql:parameter type='string'>{string($form/birth_date)}</sql:parameter>
                         <sql:parameter type='string'>{string($form/first_name)}</sql:parameter>
                         <sql:parameter type='string'>{string($form/last_name)}</sql:parameter>
                         <sql:parameter type='string'>{string($form/middle_name)}</sql:parameter>
                         <sql:parameter type='string'>{string($form/email)}</sql:parameter>
                         <sql:parameter type='string'>{string($form/email)}</sql:parameter>
                         <sql:parameter type='string'>{string($form/phone)}</sql:parameter>
                         <sql:parameter type='string'>{string($gender)}</sql:parameter>
                         <sql:parameter type='string'>{string($gender)}</sql:parameter>
                         <sql:parameter type='int'>{$userId}</sql:parameter>
               </sql:parameters>
let $data:=util:convertResult(sql:execute-prepared($prep, $params))
let $success:= count(trace($data)/id)=1
let $createSession:=if($success) then page:setsession($data) else ()

let $sql:=<s>
UPDATE 
  public.users 
SET 
 password=?
WHERE 
  id = ?
RETURNING *;
  </s>
let $prep:=sql:prepare($util:conn, $sql/text())
       let $params := <sql:parameters>
                         <sql:parameter type='string'>{trace($password, "$password: ")}</sql:parameter>
                         <sql:parameter type='int'>{$userId}</sql:parameter>
               </sql:parameters>
let $data:=if(string-length($password) > 0) then util:convertResult(sql:execute-prepared($prep, $params)) else ()


return $success
};