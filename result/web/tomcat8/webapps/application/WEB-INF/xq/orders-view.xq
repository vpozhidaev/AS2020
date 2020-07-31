module namespace page = 'urn:atomskills:orders-view';

import module namespace data="urn:atomskills:data" at "data.xq";
import module namespace util="urn:atomskills:util" at "util.xq";
import module namespace f="urn:atomskills:fragments" at "fragments.xq";


declare function page:get-orders($from, $to, $status_1, $status_2, $status_3, $status_4, $status_5, $page) {
let $statuses1 := map {"1":$status_1, "2":$status_2, "3": $status_3, "4":$status_4, "5":$status_5}
let $f := function($k, $v) 
  {if($v="on") then 
  map{$k:$v}
  else ()
}

let $statuses:=map:merge(
map:for-each($statuses1, $f)
)  

let $sql:=<s>
select o.*, to_char(created_at, 'DD.MM.YYYY HH24:MI') as created_time, st.name as status_name, vc.name as class_name,
(case when st.id = 4 then 'executed_order_row' when st.id in (1,2) then 'cancellable_order_row' else '' end) as row_class
from orders o
left join r_order_status st on o.state_id=st.id
left join r_vehicle_class vc on o.transport_class_id=vc.id
where 1=1 
{if(string-length($from)>0) then <s> and created_at::date &gt;= to_date('{$from}','DD.MM.YYYY') </s>/text() else ()}
{if(string-length($to)>0) then <s> and created_at::date &lt;= to_date('{$to}','DD.MM.YYYY') </s>/text() else ()}
{
if(map:size($statuses) > 0) then <s> and 
  state_id in ({string-join(map:keys($statuses), ",")})   
</s>/text()
else ()
}
order by o.created_at desc
offset {($page - 1) * 10} limit 10
</s>  
let $prep:=sql:prepare($util:conn, trace($sql)/text())
       let $params := <sql:parameters>
                         
               </sql:parameters>
let $data:=util:convertResult(sql:execute-prepared($prep, $params))

let $sql:=<s>
select (ceiling(count(*) / 10)+1)::integer as count from orders where 1=1  
{if(string-length($from)>0) then <s> and created_at::date &gt;= to_date('{$from}','DD.MM.YYYY') </s>/text() else ()}
{if(string-length($to)>0) then <s> and created_at::date &lt;= to_date('{$to}','DD.MM.YYYY') </s>/text() else ()}
{
if(map:size($statuses) > 0) then <s> and 
  state_id in ({string-join(map:keys($statuses), ",")})   
</s>/text()
else ()
}
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

(:~
 : Главная страница
 : @return HTML page
 :)
declare
  %rest:GET
  %rest:path('/orders')
  %output:method('xhtml')
  %output:omit-xml-declaration('no')
  %output:doctype-public('-//W3C//DTD XHTML 1.0 Transitional//EN')
  %output:doctype-system('http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd')
  %rest:query-param("page", "{$page}", 1)
  %rest:query-param("from", "{$from}", "")
  %rest:query-param("to", "{$to}", "")
  %rest:query-param("status_1", "{$status_1}", "")
  %rest:query-param("status_2", "{$status_2}", "")
  %rest:query-param("status_3", "{$status_3}", "")
  %rest:query-param("status_4", "{$status_4}", "")
  %rest:query-param("status_5", "{$status_5}", "")
function page:start($page, $from, $to, $status_1, $status_2, $status_3, $status_4, $status_5)  {
  let $orders:=trace(page:get-orders($from, $to, $status_1, $status_2, $status_3, $status_4, $status_5, $page))
let $static:="static"
let $section:="orders"
 
let $content:=
							<div class="flex mt-4">
								<div>
									<h1>Заказы</h1>
									<div>
                  <form  class="flex mt-4" id="filter" method="GET">
										<img
											src="data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMjAiIGhlaWdodD0iMjAiIHZpZXdCb3g9IjAgMCAyMCAyMCIgZmlsbD0ibm9uZSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KPHBhdGggZD0iTTE5LjA2MTYgMEgwLjkzODU4OUMwLjEwNTg1NSAwIC0wLjMxNDM0IDEuMDEwMzkgMC4yNzU2OTkgMS42MDA0M0w3LjQ5OTk5IDguODI1ODJWMTYuODc1QzcuNDk5OTkgMTcuMTgwOSA3LjY0OTI1IDE3LjQ2NzYgNy44OTk4OCAxNy42NDNMMTEuMDI0OSAxOS44Mjk4QzExLjY0MTQgMjAuMjYxMyAxMi41IDE5LjgyMzkgMTIuNSAxOS4wNjE3VjguODI1ODJMMTkuNzI0NSAxLjYwMDQzQzIwLjMxMzMgMS4wMTE1NiAxOS44OTYgMCAxOS4wNjE2IDBaIiBmaWxsPSJ3aGl0ZSIvPgo8L3N2Zz4K"
											class="mr-3" onclick="$('#filter').submit()"/>
                      <div class="Calendar_Input">
											<input type="text" readonly="readonly"
												class="datepicker Calendar_Input_inp" value="{$from}" name="from"/>
										</div>
                      
                      <span style="width: 30px"> </span>
                      <div class="Calendar_Input">
											<input type="text" readonly="readonly"
												class="datepicker Calendar_Input_inp" value="{$to}" name="to"/>
										</div>
                    <span style="width: 30px"> </span>
                     <label>Статус
                     <input type="checkbox" class="ml-4" name="status_1">
                      {if($status_1="on")  then attribute checked {"checked"} else ()}
                     </input>Создан
                     <input type="checkbox" class="ml-4" name="status_2">
                      {if($status_2="on")  then attribute checked {"checked"} else ()}
                      </input>Исполняется
                      <input type="checkbox" class="ml-4" name="status_3">
                      {if($status_3="on")  then attribute checked {"checked"} else ()}
                      </input>Отменен
                      <input type="checkbox" class="ml-4" name="status_4">
                      {if($status_4="on")  then attribute checked {"checked"} else ()}
                      </input>Выполнен
                      <input type="checkbox" class="ml-4" name="status_5">
                      {if($status_5="on")  then attribute checked {"checked"} else ()}
                      </input>Завершен
                      
                     </label>
                    
                    <input type="hidden" name="page" value="{$page}"/>
                    </form>
									</div>
                  <div style="height: 20px"></div>
									<table class="flex" style="width: 100%; display: table">
										<tbody>
											<tr>
                        <th>Номер заказа</th>
                        <th>Место отправления</th>
												<th>Место прибытия</th>
												<th>Время заказа</th>
												<th>Статус</th>
												<th>Класс</th>
											</tr>
{
  for $r in $orders/data/row
  return
  											<tr id="order_{string($r/id)}" data-id="{string($r/id)}" class="{string($r/row_class)}">
												<td><a style="text-decoration: underline" href="order-details?id={string($r/id)}">{string($r/id)}</a></td>
                        <td>{string($r/departure_address)}</td>
												<td>{string($r/destination_address)}</td>
												<td>{string($r/created_time)}</td>
												<td>{string($r/status_name)}</td>
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
              for $i in 1 to $orders/count
              return
              <li class="page-item {if($page=$i) then 'active' else ()}"><a class="page-link" href="javascript:void(0)" onclick="setPage({$i});">{$i}</a></li>
            }
            {
              if($page < $orders/count) then
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
<script type="text/javascript" src="{$static}/orders.js?ca5cca8b670bc75747d9"/>
</s>/*

return f:page($content, "Заголовок", "Описание", $section, $foot)

};


declare function page:get-vehicles($class, $page) {
let $sql:=<s>
select v.*, b.name as brand_name, vc.name as class_name 
from vehicle v
left join r_vehicle_class vc on v.vehicle_class_id=vc.id
left join vehicle_brand b on v.brand_id=b.id
where v.id not in (
select transport_id from orders where state_id = 2
) and vc.id={$class}
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
left join vehicle_brand b on v.vehicle_class_id=b.id
where v.id not in (
select transport_id from orders where state_id = 2
) and vc.id={$class}
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

declare
  %rest:GET
  %rest:path('/order-details')
  %output:method('xhtml')
  %output:omit-xml-declaration('no')
  %output:doctype-public('-//W3C//DTD XHTML 1.0 Transitional//EN')
  %output:doctype-system('http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd')
%rest:query-param("id", "{$id}")
  %rest:query-param("page", "{$page}", 1)
function page:order-details($id, $page)  {
let $user:=session:get("user")

let $sql:=<s>
select o.*, to_char(o.created_at, 'DD.MM.YYYY HH24:MI') as created_time, st.name as status_name, vc.name as class_name,
(case when st.id = 4 then 'executed_order_row' when st.id in (1,2) then 'cancellable_order_row' else '' end) as row_class,
concat_ws(' ', c.last_name, c.first_name) as fio,
b.name as brand_name, v.registration_no, v.model,
concat_ws(' ', op.last_name, op.first_name) as operator_fio
from orders o
left join r_order_status st on o.state_id=st.id
left join r_vehicle_class vc on o.transport_class_id=vc.id
left join users c on o.client_id=c.id
left join vehicle v on o.transport_id=v.id
left join vehicle_brand b on b.id=v.brand_id
left join users op on op.id=o.operator_id
where o.id=?
</s>  
let $prep:=sql:prepare($util:conn, trace($sql)/text())
       let $params := <sql:parameters>
                      <sql:parameter type='int'>{$id}</sql:parameter>   
               </sql:parameters>
let $order:=util:convertResult(sql:execute-prepared($prep, $params))

let $vehicles:=page:get-vehicles(string($order/transport_class_id), $page)

let $content:=
					<div>
						<h1>Заказ № {$id}</h1>
						<div class="Main_body">
							<form method="POST" id="order" action="api/save-order" autocomplete="off">
              <div class="flex" >
              <input autocomplete="off" name="hidden" type="text" style="display:none;"/>
              <input type="hidden" name="id" value="{$id}"/>
              <input type="hidden" name="vehicle_id" id="vehicle_id"/>
								<div class="ml-5">
									<label>Дата заказа
                  <div class="order-field-text" >{string($order/created_time)}</div>
                  </label><label>Заказчик 
                  <div class="order-field-text" >{string($order/fio)}</div>                         
                    </label>
                  <label>Класс <div class="order-field-text" >{string($order/class_name)}</div></label>
                  {
                    if(string-length($order/brand_name)>0) then
                    <label>Обслуживает дрон <div class="order-field-text" >{string($order/brand_name)} {string($order/model)} {string($order/registration_no)}</div>
                    </label>
                    else ()
                  }
								</div>
								<div class="ml-5">
									<label>Откуда <div class="order-field-text" >{string($order/departure_address)}</div></label>
                  <label>Куда <div class="order-field-text" >{string($order/destination_address)}</div></label>
                  <label>Состояние заказа <div class="order-field-text" >{string($order/status_name)}</div></label>
                  {
                    if(string-length($order/operator_fio)>0) then
                    <label>Принял оператор <div class="order-field-text" >{string($order/operator_fio)}</div></label>
                    else ()
                  }
								</div>
                
                </div>
                
                <div  class="flex" style="margin-top: 20px; margin-left: 30px">
										{if($order/state_id=1) then
                    <div>
                    <button type="submit" name="accept" value="accept" class="btn_green">Принять заказ</button>
                    <span style="width: 10px"/>
                    </div>/*
                  }
                  {if($order/state_id=1 or $order/state_id=2) then
                  <div>
                    <button type="submit" name="cancel" value="cancel" class="btn_blue">Отменить заказ</button>
                    <span style="width: 10px"/>
                    </div>/*
                 } 
                  {if($order/state_id=4) then
                  <div>
                    <button type="submit" name="complete" value="complete" class="btn_blue">Закрыть заказ</button>
                    <span style="width: 10px"/>
                    </div>/*
                 }            
										<button class="btn_blue" onclick="window.location.href='orders'; return false;">Вернуться</button>
									</div>
                
                {
                  if($order/state_id=1) then
                  <div>
                <div class="flex" style="margin-top: 20px; margin-left: 30px">
<table class="flex" style="display: table; width: 700px">
										<tbody>
											<tr>
                        <th> </th>
                        <th>Номер дрона</th>
												<th>Марка</th>
                        <th>Модель</th>
												<th>Класс</th>
											</tr>
{
  for $r in $vehicles/data/row
  return
  											<tr id="vehicle_{string($r/id)}" data-id="{string($r/id)}" class="{string($r/row_class)}">
												<td><input data-id="{string($r/id)}" type="checkbox" name="vehicle_{string($r/id)}"/></td>
                        <td>{string($r/registration_no)}</td>
                        <td>{string($r/brand_name)}</td>
												<td>{string($r/model)}</td>
												<td>{string($r/class_name)}</td>
											</tr>
}

										</tbody>
									</table>
                
                </div>
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
  
  </div>/*
                else ()
              }

							</form>





						</div>
					</div>
          
let $foot:= <s>
<script type="text/javascript" src="static/orders.js?ca5cca8b670bc75747d9"/>
</s>/*

return f:page($content, "Заголовок", "Описание", "orders", $foot)

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
  %rest:path('/api/save-order')
%rest:form-param("page", "{$page}", 1)
%rest:form-param("vehicle_id", "{$vehicleId}")
%rest:form-param("id", "{$id}")
%rest:form-param("accept", "{$accept}")
%rest:form-param("cancel", "{$cancel}")
%rest:form-param("complete", "{$complete}")
function page:complete-order($vehicleId, $id, $accept, $cancel, $complete, $page)  {
let $userId:=string(session:get("user")/id)
let $sql:=<s>
UPDATE 
  public.orders 
SET 
  {
    if(string-length($accept)>0) then <s>state_id=2, vehicle_id={$vehicleId}, operator_id={$userId}</s>/text()
    else if(string-length($cancel)>0) then
      <s>state_id=3</s>/text()
    else
    <s>state_id=5</s>/text()    
  }
WHERE 
  id = ?
RETURNING *;
  </s>
let $prep:=sql:prepare($util:conn, $sql/text())
       let $params := <sql:parameters>
                         <sql:parameter type='int'>{$id}</sql:parameter>
               </sql:parameters>
let $data:=util:convertResult(sql:execute-prepared($prep, $params))
return web:redirect("order-details?id="||$id)
};