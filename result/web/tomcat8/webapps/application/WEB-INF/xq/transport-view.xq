module namespace page = 'urn:atomskills:transport-view';

import module namespace data="urn:atomskills:data" at "data.xq";
import module namespace util="urn:atomskills:util" at "util.xq";
import module namespace f="urn:atomskills:fragments" at "fragments.xq";


declare function page:get-vehicles($page, $registration_no, $brand_id, $model) {
let $sql:=<s>
select v.*, b.name as brand_name, vc.name as class_name,
(case when decomission_date is not null then 'Списан' when extract(year from now()) -  production_year > 5 then 'Требуется списание' else 'Нормальное' end) as state
from vehicle v
left join r_vehicle_class vc on v.vehicle_class_id=vc.id
left join vehicle_brand b on v.brand_id=b.id
where 1=1
{if(string-length($registration_no)>0) then <s> and lower(registration_no) like '%{lower-case($registration_no)}%' </s>/text() else ()}
{if(string-length($brand_id)>0) then <s> and brand_id ={$brand_id} </s>/text() else ()}
{if(string-length($model)>0) then <s> and lower(model) like '%{lower-case($model)}%' </s>/text() else ()}
order by v.id
offset {($page - 1) * 10} limit 10
</s>  
let $prep:=sql:prepare($util:conn, trace($sql)/text())
       let $params := <sql:parameters>
                         
               </sql:parameters>
let $data:=util:convertResult(sql:execute-prepared($prep, $params))

let $sql:=<s>
select (ceiling(count(*) / 10)+1)::integer as count 
from vehicle v
left join r_vehicle_class vc on v.vehicle_class_id=vc.id
left join vehicle_brand b on v.brand_id=b.id
where 1=1
{if(string-length($registration_no)>0) then <s> and lower(registration_no) like '%{lower-case($registration_no)}%' </s>/text() else ()}
{if(string-length($brand_id)>0) then <s> and brand_id ={$brand_id} </s>/text() else ()}
{if(string-length($model)>0) then <s> and lower(model) like '%{lower-case($model)}%' </s>/text() else ()}
</s>  
let $prep:=sql:prepare($util:conn, $sql/text())
       let $params := <sql:parameters>
                         
               </sql:parameters>
let $count:=util:convertResult(sql:execute-prepared($prep, $params))

return <result>
<count>{string($count/count)}</count>
<data>{$data}</data>
</result>
};

declare function page:get-brands() {
let $sql:=<s>
select * from vehicle_brand order by id
</s>  
let $prep:=sql:prepare($util:conn, trace($sql)/text())
       let $params := <sql:parameters>
                         
               </sql:parameters>
let $data:=util:convertResult(sql:execute-prepared($prep, $params))
return $data
};

(:~
 : Главная страница
 : @return HTML page
 :)
declare
  %rest:GET
  %rest:path('/transport')
  %output:method('xhtml')
  %output:omit-xml-declaration('no')
  %output:doctype-public('-//W3C//DTD XHTML 1.0 Transitional//EN')
  %output:doctype-system('http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd')
  %rest:query-param("page", "{$page}", 1)
  %rest:query-param("registration_no", "{$registration_no}", "")
  %rest:query-param("brand_id", "{$brand_id}", "")
  %rest:query-param("model", "{$model}", "")
function page:start($page, $registration_no, $brand_id, $model)  {
let $static:="static"
let $section:="transport"
let $vehicles:=page:get-vehicles($page, $registration_no, $brand_id, $model)
let $brands:=page:get-brands()
let $content:=
							<div class="flex mt-4">
								<div>
									<h1>Транспорт</h1>
									<div style="width: 90%">
                  <form  class="flex mt-4" id="filter" method="GET">
										<img
											src="data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMjAiIGhlaWdodD0iMjAiIHZpZXdCb3g9IjAgMCAyMCAyMCIgZmlsbD0ibm9uZSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KPHBhdGggZD0iTTE5LjA2MTYgMEgwLjkzODU4OUMwLjEwNTg1NSAwIC0wLjMxNDM0IDEuMDEwMzkgMC4yNzU2OTkgMS42MDA0M0w3LjQ5OTk5IDguODI1ODJWMTYuODc1QzcuNDk5OTkgMTcuMTgwOSA3LjY0OTI1IDE3LjQ2NzYgNy44OTk4OCAxNy42NDNMMTEuMDI0OSAxOS44Mjk4QzExLjY0MTQgMjAuMjYxMyAxMi41IDE5LjgyMzkgMTIuNSAxOS4wNjE3VjguODI1ODJMMTkuNzI0NSAxLjYwMDQzQzIwLjMxMzMgMS4wMTE1NiAxOS44OTYgMCAxOS4wNjE2IDBaIiBmaWxsPSJ3aGl0ZSIvPgo8L3N2Zz4K"
											class="mr-3" onclick="$('#filter').submit()"/>
                      <input name="registration_no" style="width:200px" value="{$registration_no}" placeholder="Регистрационный номер" onkeydown="keyDownHandler(event)"/>
                      <span style="width: 30px"> </span>
										  <input name="model" value="{$model}" style="width: 200px" placeholder="Модель" onkeydown="keyDownHandler(event)"/>
                      <span style="width: 30px"> </span>
                      <label style="width: 200px"><select name="brand_id" placeholder="Марка"><option value="">Выберите марку</option>
                        {
                          for $b in $brands
                          return
                          <option value="{string($b/id)}">{string($b/name)}</option>
                        }
											
                      </select>
                   
                      </label>
                      <span style="width: 70px"> </span>
                      <button  class="btn_blue flex y_center" onclick="window.location.href='transport-new';  return false;"><img src="data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMjMiIGhlaWdodD0iMjUiIHZpZXdCb3g9IjAgMCAyMyAyNSIgZmlsbD0ibm9uZSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KPHBhdGggZD0iTTIwLjA1NzkgMC44ODg5MTZIMi40Mjk3M0MxLjEwMjYgMC44ODg5MTYgMC4wMjU4Nzg5IDIuMDA4NzEgMC4wMjU4Nzg5IDMuMzg4OTJWMjEuNzIyMkMwLjAyNTg3ODkgMjMuMTAyNSAxLjEwMjYgMjQuMjIyMiAyLjQyOTczIDI0LjIyMjJIMjAuMDU3OUMyMS4zODUxIDI0LjIyMjIgMjIuNDYxOCAyMy4xMDI1IDIyLjQ2MTggMjEuNzIyMlYzLjM4ODkyQzIyLjQ2MTggMi4wMDg3MSAyMS4zODUxIDAuODg4OTE2IDIwLjA1NzkgMC44ODg5MTZaTTE4LjQ1NTQgMTQuMDEzOUMxOC40NTU0IDE0LjM1NzcgMTguMTg0OSAxNC42Mzg5IDE3Ljg1NDQgMTQuNjM4OUgxMy4yNDdWMTkuNDMwNkMxMy4yNDcgMTkuNzc0MyAxMi45NzY2IDIwLjA1NTYgMTIuNjQ2MSAyMC4wNTU2SDkuODQxNTlDOS41MTEwNiAyMC4wNTU2IDkuMjQwNjIgMTkuNzc0MyA5LjI0MDYyIDE5LjQzMDZWMTQuNjM4OUg0LjYzMzI1QzQuMzAyNzIgMTQuNjM4OSA0LjAzMjI5IDE0LjM1NzcgNC4wMzIyOSAxNC4wMTM5VjExLjA5NzJDNC4wMzIyOSAxMC43NTM1IDQuMzAyNzIgMTAuNDcyMiA0LjYzMzI1IDEwLjQ3MjJIOS4yNDA2MlY1LjY4MDU4QzkuMjQwNjIgNS4zMzY4MyA5LjUxMTA2IDUuMDU1NTggOS44NDE1OSA1LjA1NTU4SDEyLjY0NjFDMTIuOTc2NiA1LjA1NTU4IDEzLjI0NyA1LjMzNjgzIDEzLjI0NyA1LjY4MDU4VjEwLjQ3MjJIMTcuODU0NEMxOC4xODQ5IDEwLjQ3MjIgMTguNDU1NCAxMC43NTM1IDE4LjQ1NTQgMTEuMDk3MlYxNC4wMTM5WiIgZmlsbD0id2hpdGUiLz4KPC9zdmc+Cg==" style="margin-right: 10px"/>   Добавить</button>
                    <input type="hidden" name="page" value="{$page}"/>
                    </form>
									</div>
                  <div style="height: 20px"></div>
									<table class="flex" style="width: 100%; display: table">
										<tbody>
											<tr>
                        <th>Регистрационный номер</th>
                        <th>Марка</th>
												<th>Модель</th>
												<th>Год производства</th>
												<th>Дата регистрации</th>
                        <th>Состояние</th>
                        <th>Класс</th>
											</tr>
{
  for $r in $vehicles/data/row
  return
  											<tr id="transport_{string($r/id)}" data-id="{string($r/id)}">
												<td><a style="text-decoration: underline" href="transport-details?id={string($r/id)}">{string($r/registration_no)}</a></td>
                        <td>{string($r/brand_name)}</td>
                        <td>{string($r/model)}</td>
												<td>{string($r/production_year)}</td>
												<td>{string($r/registration_date)}</td>
												<td>{string($r/state)}</td>
												<td>{string($r/class_name)}</td>
											</tr>
}

										</tbody>
									</table>
                  
<div class="mt-3 ml-5">
            <nav>
        <ul class="pagination">
            {
              if($page > 1) then
                            <li class="page-item">
                    <a class="page-link" href="javascript:void(0)" rel="prev" aria-label="« Назад" onclick="setPage({$page - 1});">‹</a>
                </li>
                else ()
              }
            {
              for $i in 1 to $vehicles/count
              return
              <li class="page-item {if($page=$i) then 'active' else ()}"><a class="page-link" href="javascript:void(0)" onclick="setPage({$i});">{$i}</a></li>
            }
            {
              if($page < $vehicles/count) then
<li class="page-item">
<a class="page-link" href="javascript:void(0)" rel="next" aria-label="Далее »" onclick="setPage({$page + 1});">›</a>
</li>
else ()}
</ul>

    </nav>

            </div>
                  
								</div>

							</div>

let $foot:= <s>
<script type="text/javascript" src="{$static}/js/jquery.ui.position.js?ca5cca8b670bc75747d9"/>
<script type="text/javascript" src="{$static}/js/jquery.contextMenu.min.js?ca5cca8b670bc75747d9"/>
<script type="text/javascript" src="{$static}/transport.js?ca5cca8b670bc75747d9"/>
</s>/*

return f:page($content, "Заголовок", "Описание", $section, $foot)

};




declare
  %rest:GET
  %rest:path('/transport-details')
  %output:method('xhtml')
  %output:omit-xml-declaration('no')
  %output:doctype-public('-//W3C//DTD XHTML 1.0 Transitional//EN')
  %output:doctype-system('http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd')
%rest:query-param("id", "{$id}")
function page:transport-details($id)  {
let $user:=session:get("user")
let $brands:=page:get-brands()
let $sql:=<s>
select v.*, b.name as brand_name, vc.name as class_name,
(case when decomission_date is not null then 'Списан' when extract(year from now()) -  production_year > 5 then 'Требуется списание' else 'Нормальное' end) as state,
to_char(registration_date, 'DD.MM.YYYY') as registration_date_format
from vehicle v
left join r_vehicle_class vc on v.vehicle_class_id=vc.id
left join vehicle_brand b on v.brand_id=b.id
where v.id=?
</s>  
let $prep:=sql:prepare($util:conn, trace($sql)/text())
       let $params := <sql:parameters>
                      <sql:parameter type='int'>{$id}</sql:parameter>   
               </sql:parameters>
let $transport:=util:convertResult(sql:execute-prepared($prep, $params))

let $content:=
					<div>
						<h1>Дрон № {string($transport/registration_no)}</h1>
						<div class="Main_body">
							<form method="POST" id="order" action="api/save-transport" autocomplete="off" onsubmit="return doValidate(this);">
              <div class="flex" >
              <input autocomplete="off" name="hidden" type="text" style="display:none;"/>
              <input type="hidden" name="id" value="{$id}"/>
								<div class="ml-5">
									<label>Марка
                  <select name="brand_id" placeholder="Марка"><option value="">Выберите марку</option>
                        {
                          for $b in $brands
                          return
                          <option value="{string($b/id)}">{if($transport/brand_id=$b/id)  then attribute selected {"selected"} else ()}{string($b/name)}</option>
                        }
											
                      </select>
                      <div class="error_msg" id="brand_id_error">Заполните обязательное поле</div>
                  </label>
                  <label>Модель 
                  <input name="model" value="{string($transport/model)}" placeholder="Модель"/>
                  <div class="error_msg" id="model_error">
            Заполните обязательное поле
            </div>
                    </label>
                  <label>Класс 
                  <select name="vehicle_class_id" placeholder="Обязательно"><option value="">Выберите
												класс</option>
											<option value="1">{if($transport/vehicle_class_id=1)  then attribute selected {"selected"} else ()}Эконом </option>
											<option value="2">{if($transport/vehicle_class_id=2)  then attribute selected {"selected"} else ()}Бизнес </option>
											<option value="3">{if($transport/vehicle_class_id=3)  then attribute selected {"selected"} else ()}Премиум </option>
                   </select>
                   <div class="error_msg" id="vehicle_class_id_error">Заполните обязательное поле</div>
                  </label>
                  
								</div>
								<div class="ml-5">
									<label>Регистрационный номер* <input name="registration_no" value="{string($transport/registration_no)}" placeholder="Регистрационный номер"/>
                  <div class="error_msg" id="registration_no_error">Заполните обязательное поле</div>
                  <div class="error_msg" id="registration_no_format_error">Регистрационный номер должен иметь формат ABV 992-123-983</div>                  
                  </label>
                  
                  
                  <label>Дата регистрации * 
                  <div class="Calendar_Input">
											<input type="text" readonly="readonly"
												class="datepicker Calendar_Input_inp" value="{string($transport/registration_date_format)}" name="registration_date"/>
										</div>
                    <div class="error_msg" id="registration_date_error">Заполните обязательное поле</div>
                  </label>
                  <label>Год производства <input name="production_year" value="{string($transport/production_year)}" placeholder="Год производства"/>
                  <div class="error_msg" id="production_year_error">Заполните обязательное поле</div>
                  </label>
								</div>
                
                </div>
                
                <div  class="flex" style="margin-top: 20px; margin-left: 60px">
                Состояние: {string($transport/state)}
                </div>
                
                <div  class="flex" style="margin-top: 20px; margin-left: 30px">
                <button type="submit" name="save" value="save" class="btn_green">Сохранить</button>
                    <span style="width: 10px"/>
										<button type="submit" name="revoke" value="revoke" class="btn_blue">Списать</button>
                    <span style="width: 10px"/>
                         
										<button class="btn_blue" onclick="window.location.href='transport'; return false;">Вернуться</button>
									</div>
							</form>

						</div>
					</div>
          
let $foot:= <s> 
<script type="text/javascript" src="static/transport.js?ca5cca8b670bc75747d9"/>
</s>/*

return f:page($content, "Заголовок", "Описание", "transport", $foot)

};


declare
  %rest:GET
  %rest:path('/transport-new')
  %output:method('xhtml')
  %output:omit-xml-declaration('no')
  %output:doctype-public('-//W3C//DTD XHTML 1.0 Transitional//EN')
  %output:doctype-system('http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd')
function page:transport-new()  {
let $user:=session:get("user")
let $brands:=page:get-brands()

let $content:=
					<div>
						<h1>Новая транспортная единица</h1>
						<div class="Main_body">
							<form method="POST" id="order" action="api/new-transport" autocomplete="off" onsubmit="return doValidate(this);">
              <div class="flex" >
              <input autocomplete="off" name="hidden" type="text" style="display:none;"/>
								<div class="ml-5">
									<label>Марка
                  <select name="brand_id" placeholder="Марка"><option value="">Выберите марку</option>
                        {
                          for $b in $brands
                          return
                          <option value="{string($b/id)}">{string($b/name)}</option>
                        }
											
                      </select>
                      <div class="error_msg" id="brand_id_error">Заполните обязательное поле</div>
                  </label>
                  <label>Модель 
                  <input name="model" placeholder="Модель"/>
                  <div class="error_msg" id="model_error">
            Заполните обязательное поле
            </div>
                    </label>
                  <label>Класс 
                  <select name="vehicle_class_id" placeholder="Обязательно"><option value="">Выберите
												класс</option>
											<option value="1">Эконом </option>
											<option value="2">Бизнес </option>
											<option value="3">Премиум </option>
                   </select>
                   <div class="error_msg" id="vehicle_class_id_error">Заполните обязательное поле</div>
                  </label>
                  
								</div>
								<div class="ml-5">
									<label>Регистрационный номер* <input name="registration_no" placeholder="Регистрационный номер"/>
                  <div class="error_msg" id="registration_no_error">Заполните обязательное поле</div>
                  <div class="error_msg" id="registration_no_format_error">Регистрационный номер должен иметь формат ABV 992-123-983</div>                  
                  </label>
                  
                  
                  <label>Дата регистрации * 
                  <div class="Calendar_Input">
											<input type="text" readonly="readonly"
												class="datepicker Calendar_Input_inp" name="registration_date"/>
										</div>
                    <div class="error_msg" id="registration_date_error">Заполните обязательное поле</div>
                  </label>
                  <label>Год производства <input name="production_year" placeholder="Год производства"/>
                  <div class="error_msg" id="production_year_error">Заполните обязательное поле</div>
                  </label>
								</div>
                
                </div>
                
                <div  class="flex" style="margin-top: 20px; margin-left: 30px">
                <button type="submit" name="save" value="save" class="btn_green">Сохранить</button>
                    <span style="width: 10px"/>
								<button class="btn_blue" onclick="window.location.href='transport'; return false;">Вернуться</button>
									</div>
							</form>

						</div>
					</div>
          
let $foot:= <s> 
<script type="text/javascript" src="static/transport.js?ca5cca8b670bc75747d9"/>
</s>/*

return f:page($content, "Заголовок", "Описание", "transport", $foot)

};


declare
  %rest:POST("{$data}")
  %rest:path('/api/acceptorder')
function page:register($data)  {
let $form:=trace(util:convertJsonForm(trace(json:parse($data))), "orderData:")
let $userId:=string(session:get("user")/id)
let $sql:=<s>
INSERT INTO 
  public.orders
(
  client_id,
  departure_address,
  destination_address,
  state_id,
  transport_class_id
)
VALUES (
  ?,--client_id,
  ?,--departure_address,
  ?,--destination_address,
  1,
  ?--transport_class_id
) RETURNING *;
  </s>
let $prep:=sql:prepare($util:conn, $sql/text())
       let $params := <sql:parameters>
                         <sql:parameter type='int'>{$userId}</sql:parameter>
                         <sql:parameter type='string'>{string($form/departure_address)}</sql:parameter>
                         <sql:parameter type='string'>{string($form/destination_address)}</sql:parameter>
                         <sql:parameter type='int'>{string($form/transport_class_id)}</sql:parameter>
               </sql:parameters>
let $data:=util:convertResult(sql:execute-prepared($prep, $params))
let $success:= count(trace($data, "resultData")/id)=1
return $success
};


declare
  %rest:POST("{$data}")
  %rest:path('/api/cancelorder2')
function page:cancel-order($data)  {
let $id:=trace(json:parse($data)/json/id)
let $userId:=string(session:get("user")/id)
let $sql:=<s>
UPDATE 
  public.orders 
SET 
  state_id=3
WHERE 
  id = ?
RETURNING *;
  </s>
let $prep:=sql:prepare($util:conn, $sql/text())
       let $params := <sql:parameters>
                         <sql:parameter type='int'>{$id}</sql:parameter>
               </sql:parameters>
let $data:=util:convertResult(sql:execute-prepared($prep, $params))
return $data
};

declare
  %rest:POST
  %rest:path('/api/save-transport')
%rest:form-param("id", "{$id}")
%rest:form-param("save", "{$save}")
%rest:form-param("revoke", "{$revoke}")
%rest:form-param("brand_id", "{$brand_id}")
%rest:form-param("model", "{$model}")
%rest:form-param("registration_date", "{$registration_date}")
%rest:form-param("registration_no", "{$registration_no}")
%rest:form-param("production_year", "{$production_year}")
%rest:form-param("vehicle_class_id", "{$vehicle_class_id}")
function page:complete-order( $id, $save, $revoke, $brand_id, $model, $registration_date, $registration_no, $production_year, $vehicle_class_id)  {
let $userId:=string(session:get("user")/id)
let $sql:=<s>
UPDATE 
  public.vehicle 
SET 
  brand_id = {$brand_id},
  model = '{$model}',
  production_year = {$production_year},
  registration_no = '{$registration_no}',
  registration_date = to_date('{$registration_date}','DD.MM.YYYY'),
  {
    if(string-length($revoke)>0) then
    <s>decomission_date = now(), </s>/text()
    else ()
  }
  vehicle_class_id = {$vehicle_class_id}
WHERE 
  id = ?
RETURNING *;
  </s>
let $prep:=sql:prepare($util:conn, trace($sql/text()))
       let $params := <sql:parameters>
                         <sql:parameter type='int'>{$id}</sql:parameter>
               </sql:parameters>
let $data:=util:convertResult(sql:execute-prepared($prep, $params))
return web:redirect("../transport-details?id="||$id)
};

declare
  %rest:POST
  %rest:path('/api/new-transport')
%rest:form-param("id", "{$id}")
%rest:form-param("save", "{$save}")
%rest:form-param("revoke", "{$revoke}")
%rest:form-param("brand_id", "{$brand_id}")
%rest:form-param("model", "{$model}")
%rest:form-param("registration_date", "{$registration_date}")
%rest:form-param("registration_no", "{$registration_no}")
%rest:form-param("production_year", "{$production_year}")
%rest:form-param("vehicle_class_id", "{$vehicle_class_id}")
function page:new-transport( $id, $save, $revoke, $brand_id, $model, $registration_date, $registration_no, $production_year, $vehicle_class_id)  {
let $userId:=string(session:get("user")/id)
let $sql:=<s>

INSERT INTO 
  public.vehicle
(
  brand_id,
  model,
  production_year,
  registration_no,
  registration_date,
  vehicle_class_id
)
VALUES (
  {$brand_id},
  '{$model}',
  {$production_year},
  '{$registration_no}',
  to_date('{$registration_date}','DD.MM.YYYY'),
  {$vehicle_class_id}
) RETURNING *
  </s>
let $prep:=sql:prepare($util:conn, trace($sql/text()))
       let $params := <sql:parameters>

               </sql:parameters>
let $data:=util:convertResult(sql:execute-prepared($prep, $params))
return web:redirect("../transport-details?id="||string($data//id))
};