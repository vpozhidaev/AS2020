module namespace page = 'urn:atomskills:main-view';

import module namespace data="urn:atomskills:data" at "data.xq";
import module namespace util="urn:atomskills:util" at "util.xq";
import module namespace f="urn:atomskills:fragments" at "fragments.xq";


declare function page:get-orders($from, $to, $page) {
let $userId:=string(session:get("user")/id)
let $sql:=<s>
select o.*, to_char(created_at, 'DD.MM.YYYY HH24:MI') as created_time, st.name as status_name, vc.name as class_name,
(case when st.id = 4 then 'executed_order_row' when st.id in (1,2) then 'cancellable_order_row' else '' end) as row_class
from orders o
left join r_order_status st on o.state_id=st.id
left join r_vehicle_class vc on o.transport_class_id=vc.id
where client_id=? 
{if(string-length($from)>0) then <s> and lower(departure_address) like '%{lower-case($from)}%' </s>/text() else ()}
{if(string-length($to)>0) then <s> and lower(destination_address) like '%{lower-case($to)}%' </s>/text() else ()}
order by o.created_at desc
offset {($page - 1) * 10} limit 10
</s>  
let $prep:=sql:prepare($util:conn, trace($sql)/text())
       let $params := <sql:parameters>
                         <sql:parameter type='int'>{$userId}</sql:parameter>
               </sql:parameters>
let $data:=util:convertResult(sql:execute-prepared($prep, $params))

let $sql:=<s>
select (ceiling(count(*) / 10)+1)::integer as count from orders where client_id=? 
{if(string-length($from)>0) then <s> and lower(departure_address) like '%{lower-case($from)}%' </s>/* else ()}
{if(string-length($to)>0) then <s> and lower(destination_address) like '%{lower-case($to)}%' </s>/* else ()}
</s>  
let $prep:=sql:prepare($util:conn, $sql/text())
       let $params := <sql:parameters>
                         <sql:parameter type='int'>{$userId}</sql:parameter>
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
  %rest:path('/myorders')
  %output:method('xhtml')
  %output:omit-xml-declaration('no')
  %output:doctype-public('-//W3C//DTD XHTML 1.0 Transitional//EN')
  %output:doctype-system('http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd')
  %rest:query-param("page", "{$page}", 1)
  %rest:query-param("from", "{$from}", "")
  %rest:query-param("to", "{$to}", "")
function page:start($page, $from, $to)  {
  let $orders:=trace(page:get-orders($from, $to, $page))
let $static:="static"
  let $section:="myorders"
 
let $content:=
							<div class="flex mt-5">
								<div>
									<h2>Мои поездки</h2>
									<div>
                  <form  class="flex mt-3" id="filter" method="GET">
										<img
											src="data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMjAiIGhlaWdodD0iMjAiIHZpZXdCb3g9IjAgMCAyMCAyMCIgZmlsbD0ibm9uZSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KPHBhdGggZD0iTTE5LjA2MTYgMEgwLjkzODU4OUMwLjEwNTg1NSAwIC0wLjMxNDM0IDEuMDEwMzkgMC4yNzU2OTkgMS42MDA0M0w3LjQ5OTk5IDguODI1ODJWMTYuODc1QzcuNDk5OTkgMTcuMTgwOSA3LjY0OTI1IDE3LjQ2NzYgNy44OTk4OCAxNy42NDNMMTEuMDI0OSAxOS44Mjk4QzExLjY0MTQgMjAuMjYxMyAxMi41IDE5LjgyMzkgMTIuNSAxOS4wNjE3VjguODI1ODJMMTkuNzI0NSAxLjYwMDQzQzIwLjMxMzMgMS4wMTE1NiAxOS44OTYgMCAxOS4wNjE2IDBaIiBmaWxsPSJ3aGl0ZSIvPgo8L3N2Zz4K"
											class="mr-3" onclick="$('#filter').submit()"/>
                      <input name="from" value="{$from}" placeholder="Место отправления" onkeydown="keyDownHandler(event)"/>
                      <span style="width: 30px"> </span>
										<input name="to" value="{$to}" placeholder="Место назначения" onkeydown="keyDownHandler(event)"/>
                    <input type="hidden" name="page" value="{$page}"/>
                    </form>
									</div>
									<table class="mt-4">
										<tbody>
											<tr>
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
								<div class="ml-5">
									<h2>Новая поездка</h2>
                  <form id="order" onsubmit='doOrder(this);return false;' method="POST">
									<input name="departure_address" placeholder="Откуда" />
                  <div class="error_msg" id="departure_address_error">
            Заполните обязательное поле
            </div>
                  <input name="destination_address" placeholder="Куда" style="margin-top: 10px"/>
                  <div class="error_msg" id="destination_address_error">
            Заполните обязательное поле
            </div>
                  <label>Tранспорт
                  <select name="transport_class_id" placeholder="Обязательно"><option value="">Выберите
												класс</option>
											<option value="1">Эконом</option>
											<option value="2">Бизнес</option>
											<option value="3">Премиум</option></select>
                   
                      </label>
                      <div class="error_msg" id="transport_class_id_error">
            Заполните обязательное поле
            </div>
                      <div style="height: 10px; width: 10px"></div>
                    <button class="btn_green">Поехали</button>
                    </form>
								</div>
							</div>

let $foot:= <s>
<script type="text/javascript" src="{$static}/js/jquery.ui.position.js?ca5cca8b670bc75747d9"/>
<script type="text/javascript" src="{$static}/js/jquery.contextMenu.min.js?ca5cca8b670bc75747d9"/>
<script type="text/javascript" src="{$static}/myorders.js?ca5cca8b670bc75747d9"/>
</s>/*

return f:page($content, "Заголовок", "Описание", $section, $foot)

};


declare
  %rest:POST("{$data}")
  %rest:path('/api/placeorder')
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
  %rest:path('/api/cancelorder')
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
  %rest:POST("{$data}")
  %rest:path('/api/completeorder')
function page:complete-order($data)  {
let $id:=trace(json:parse($data)/json/id)
let $userId:=string(session:get("user")/id)
let $sql:=<s>
UPDATE 
  public.orders 
SET 
  state_id=5
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