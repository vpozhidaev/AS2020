module namespace data = 'urn:atomskills:data';

import module namespace util="urn:atomskills:util" at "util.xq";


declare function data:get-profile($id) {
let $conn:=$util:conn
  let $sql:=<s>
  SELECT 
  u.id,
  u.email,
  u.email_verified,
  u.first_name,
  u.last_name,
  up.middle_name,
  u.first_name || ' ' || u.last_name as full_name,
  up.avatar,
  u.realm_id,
  u.username,
  to_char(profile.crtd_totimestamp(u.created_timestamp), 'DD.MM.YYYY') as registration_date,
  up.gender,
  to_char(up.birth_date, 'DD.MM.YYYY') as birth_date,
  up.passport_series,
  up.passport_no,
   to_char(up.passport_issue_date, 'DD.MM.YYYY') as passport_issue_date,
  up.passport_issuer_name,
  up.passport_issuer_code,
  coalesce(up.snils, snils1.value, snils2.value) as snils,
  coalesce(up.inn, inn1.value, inn2.value) as inn,
  (addr.address).*,
  concat(
    (addr.address).postcode,', г. ',
(addr.address).cityname,
', ул. ',
(addr.address).streetname,
', ', (addr.address).housenum,
', кв. ', (addr.address).apartment,
' ОКАТО ', (addr.address).okato
) as full_address,
(addr.address).okato as okato,
  ca.address as phone,
  up.points,
  up.moderator_points,
  roles.role_id as esia_role
FROM 
  public.user_entity u 
  inner join profile.user_profile up on up.id=u.id::uuid
  left join profile.address addr on addr.profile_id=up.id and addr.address_type=2
  left join public.user_attribute snils1 on u.id=snils1.user_id and snils1.name='snils'
  left join public.user_attribute snils2 on u.id=snils2.user_id and snils2.name='SNILS'
  left join public.user_attribute inn1 on u.id=inn1.user_id and inn1.name='SNILS'
  left join public.user_attribute inn2 on u.id=inn2.user_id and inn2.name='snils'
  left join profile.contact_attribute ca on ca.profile_id=up.id and ca.type='phone'
  left join user_role_mapping roles on roles.user_id=u.id and roles.role_id='df61b479-1f4b-485e-9ec4-813714c19ac4'
  where u.id=?
  </s>
  
let $prep := sql:prepare($conn, $sql/text())
let $params := <sql:parameters>
                 <sql:parameter type='string'>{$id}</sql:parameter>
               </sql:parameters>

return util:convertResult(sql:execute-prepared($prep, $params))[1]
  
};


declare function data:get-notifications($profileId, $servicesIn, $recent, $pagesize) {
  let $conn:=$util:conn
  let $services:=if($recent="on" )  then map{} else $servicesIn
  let $sql:=<s>
SELECT 
n.sender_id, n.organization_id, op.full_name as org_full_name, n.title, n.short_content,
--to_char(profile.crtd_totimestamp(n.created_at), 'DD.MM.YYYY HH24:MI') as created_at,
to_char(((to_timestamp(n.created_at / 1000.0)::timestamp AT TIME ZONE 'utc')), 'DD.MM.YYYY HH24:MI') as created_at1,
n.created_at as created_at,
nt.name as notification_type_name,
nt.description as notification_type_description,
n.content,
n.html_content,
n.id,
lower(s.code) as service_code,
s.icon as service_icon,
s.name as service_name
FROM 
  profile.user_profile p 
  inner join   profile.mtm_notification_profile np on np.profile_id=p.id
  inner join profile.notification n on np.notification_id=n.id
  inner join profile.r_notification_type nt on n.notification_type_id=nt.id
  inner join profile.r_service s on nt.service_id=s.id
  left join profile.organization_profile op on op.id=n.organization_id
where p.id='{$profileId}'::uuid {
if(map:size($services) > 0) then <s> and 
  lower(s.code) in ({string-join(map:keys($services), ",")})  
</s>/text()
else ()
}
  order by n.created_at desc
{
  if($recent="on") then 
  <s>
  limit 3
  </s>/text() 
  else <s>
  limit 50
  </s>/text()
}
  </s>
  
let $prep := sql:prepare($conn, $sql/text())
(: Values and types of prepared statement parameters :)
let $log:=admin:write-log($sql/text())
let $params := <sql:parameters>
                 
               </sql:parameters>
(: Execute prepared statement :)

return util:convertResult(sql:execute-prepared($prep, $params))
  
};


declare function data:get-user-notification-settings($id) {
let $conn:=$util:conn
  let $sql:=<s>
with base as (
select 
chan.id as chan_id,
chan.code as chan_code,
chan.name as chan_name,
notif.id as notif_id,
notif.code as notif_code,
notif.name as notif_name,
profile_id,
s.id as s_id,
s.code as s_code,
s.name as s_name
from 
 profile.r_delivery_channel chan 
inner join profile.r_notification_type notif on true
left join 
profile.mtm_subscription sub on sub.delivery_channel_id=chan.id and sub.notification_type_id=notif.id
and sub.profile_id=?::UUID
inner join profile.r_service s on notif.service_id=s.id
where chan.code in ('EMAIL','PUSH')
),
notifs as (
--notif_id, notif_code, notif_name, profile_id, chan_id, chan_code, chan_name
select s_id, s_code, s_name, notif_id, notif_code, notif_name, json_agg(base.*) as agg_notifs from base
group by s_id, s_code, s_name, notif_id, notif_code, notif_name
order by notif_id, notif_code, notif_name
),
services as (
select s_id, s_code, s_name, json_agg(notifs.*) as agg from notifs
group by s_id, s_code, s_name
order by s_id, s_code, s_name)
select json_agg(services.*) from services
  </s>
  
let $prep := sql:prepare($conn, $sql/text())
let $params := <sql:parameters>
                 <sql:parameter type='string'>{$id}</sql:parameter>
               </sql:parameters>

return json:parse(sql:execute-prepared($prep, $params)[1]/*:column)/*:json
};

declare function data:save-subscription($subscription) {
  
let $conn:=$util:conn
  let $sql:=<s>
WITH 
data(profile_id, notification_type_id, delivery_channel_id) as (
VALUES(?::UUID,?,?)
),
del AS (
        DELETE FROM profile.mtm_subscription a
        using data
        where a.profile_id = data.profile_id 
     AND a.notification_type_id = data.notification_type_id
     AND a.delivery_channel_id = data.delivery_channel_id
        returning *
        )
INSERT INTO 
  profile.mtm_subscription
(
  profile_id,
  notification_type_id,
  delivery_channel_id
)
select * from data
where not exists (select * from del)
     ;
  </s>
  
let $prep := sql:prepare($conn, $sql/text())
let $params := <sql:parameters>
                 <sql:parameter type='string'>{string($subscription/profile__id)}</sql:parameter>
                 <sql:parameter type='int'>{string($subscription/notification__type__id)}</sql:parameter>
                 <sql:parameter type='int'>{string($subscription/delivery__channel__id)}</sql:parameter>
               </sql:parameters>
let $exec1:= sql:execute-prepared($prep, $params)
  return $exec1
};

declare function data:save-avatar($id, $dst, $url) {
  
  let $conn:=$util:conn
  let $sql:=
  if($dst="avatar") then
  <s>
UPDATE profile.user_profile set avatar=? where id=?::uuid
</s>
else if($dst="logo") then
  <s>
UPDATE profile.organization_profile set logo=? where id=?::uuid
</s>
else ()

let $prep := sql:prepare($conn, $sql/text())
let $params := <sql:parameters>
                 <sql:parameter type='string'>{string($url)}</sql:parameter>
                 <sql:parameter type='string'>{string($id)}</sql:parameter>
               </sql:parameters>
let $exec1:= sql:execute-prepared($prep, $params)

return $sql
};

declare function data:save-profile($id,$first_name, $last_name, $gender,$birth_date,$passport_series,$passport_no,
$passport_issue_date,$passport_issuer_name,$passport_issuer_code,$snils,$inn, $email, $middle_name,
$postcode, $cityname, $streetname, $housenum, $apartment, $phone) {
  
let $conn:=$util:conn
  let $sql:=<s>
UPDATE 
  profile.user_profile p
SET 
  first_name = ?,
  last_name = ?,
  middle_name = ?,
  gender = ?::profile.enum_gender,
  birth_date =  case when (length(?)>0 and ? not like '%_%') then to_date(?,'DD.MM.YYYY') else null end,
  passport_series = ?,
  passport_no = ?,
  passport_issue_date = case when (length(?)>0 and ? not like '%_%') then to_date(?,'DD.MM.YYYY') else null end,
  passport_issuer_name = ?,
  passport_issuer_code = ?,
  snils = ?,
  inn = ?
where p.id=?::uuid
  </s>
  
let $prep := sql:prepare($conn, $sql/text())
let $params := <sql:parameters>
                 <sql:parameter type='string'>{string($first_name)}</sql:parameter>
                 <sql:parameter type='string'>{string($last_name)}</sql:parameter>
                 <sql:parameter type='string'>{string($middle_name)}</sql:parameter>
                 <sql:parameter type='string'>{string($gender)}</sql:parameter>
                 <sql:parameter type='string'>{string($birth_date)}</sql:parameter>
                 <sql:parameter type='string'>{string($birth_date)}</sql:parameter>
                 <sql:parameter type='string'>{string($birth_date)}</sql:parameter>
                 <sql:parameter type='string'>{string($passport_series)}</sql:parameter>
                 <sql:parameter type='string'>{string($passport_no)}</sql:parameter>
                 <sql:parameter type='string'>{string($passport_issue_date)}</sql:parameter>
                 <sql:parameter type='string'>{string($passport_issue_date)}</sql:parameter>
                 <sql:parameter type='string'>{string($passport_issue_date)}</sql:parameter>
                 <sql:parameter type='string'>{string($passport_issuer_name)}</sql:parameter>
                 <sql:parameter type='string'>{string($passport_issuer_code)}</sql:parameter>
                 <sql:parameter type='string'>{string($snils)}</sql:parameter>
                 <sql:parameter type='string'>{string($inn)}</sql:parameter>
                 <sql:parameter type='string'>{string($id)}</sql:parameter>
               </sql:parameters>
let $exec1:= sql:execute-prepared($prep, $params)

  let $sql:=<s>
UPDATE 
  profile.profile p
SET 
 email = ?
where id=?::uuid
  </s>
  
let $prep := sql:prepare($conn, $sql/text())
let $params := <sql:parameters>
                 <sql:parameter type='string'>{string($email)}</sql:parameter>
                 <sql:parameter type='string'>{string($id)}</sql:parameter>
               </sql:parameters>

let $exec2:= sql:execute-prepared($prep, $params)


  let $sql:=<s>
INSERT INTO 
  profile.address
(
  id,
  address_type,
  profile_id,
  address.postcode,
  address.regioncode,
  address.regionname,
  address.autocode,
  address.autoname,
  address.areacode,
  address.areaname,
  address.citycode,
  address.cityname,
  address.streetcode,
  address.streetname,
  address.housenum,
  address.buildnum,
  address.apartment
)
VALUES (
  uuid_generate_v4(),
  2,
  ?::uuid,
  ?, --address.postcode,
  null, --address.regioncode,
  null, --address.regionname,
  null, --address.autocode,
  null, --address.autoname,
  null, --address.areacode,
  null, --address.areaname,
  null, --address.citycode,
  ?, --address.cityname,
  null, --address.streetcode,
  ?, --address.streetname,
  ?, --address.housenum,
  null, --address.buildnum,
  ? --address.apartment
)
ON CONFLICT (profile_id, address_type) 
DO UPDATE SET 
  address.postcode=(EXCLUDED.address).postcode,
  address.regioncode=(EXCLUDED.address).regioncode,
  address.regionname=(EXCLUDED.address).regionname,
  address.autocode=(EXCLUDED.address).autocode,
  address.autoname=(EXCLUDED.address).autoname,
  address.areacode=(EXCLUDED.address).areacode,
  address.areaname=(EXCLUDED.address).areaname,
  address.citycode=(EXCLUDED.address).citycode,
  address.cityname=(EXCLUDED.address).cityname,
  address.streetcode=(EXCLUDED.address).streetcode,
  address.streetname=(EXCLUDED.address).streetname,
  address.housenum=(EXCLUDED.address).housenum,
  address.buildnum=(EXCLUDED.address).buildnum,
  address.apartment=(EXCLUDED.address).apartment
;
  </s>
  
let $prep := sql:prepare($conn, $sql/text())
let $params := <sql:parameters>
                 <sql:parameter type='string'>{string($id)}</sql:parameter>
                 <sql:parameter type='string'>{string($postcode)}</sql:parameter>
                 <sql:parameter type='string'>{string($cityname)}</sql:parameter>
                 <sql:parameter type='string'>{string($streetname)}</sql:parameter>
                 <sql:parameter type='string'>{string($housenum)}</sql:parameter>
                 <sql:parameter type='string'>{string($apartment)}</sql:parameter>
               </sql:parameters>
let $exec3:= sql:execute-prepared($prep, $params)


  let $sql:=<s>
UPDATE 
  public.user_entity
SET 
 first_name = ?,
 last_name = ?,
 email = ?
where id=?
  </s>
  
let $prep := sql:prepare($conn, $sql/text())
let $params := <sql:parameters>
<sql:parameter type='string'>{string($first_name)}</sql:parameter>
<sql:parameter type='string'>{string($last_name)}</sql:parameter>
<sql:parameter type='string'>{string($email)}</sql:parameter>
<sql:parameter type='string'>{string($id)}</sql:parameter>
</sql:parameters>
let $exec4:= sql:execute-prepared($prep, $params)

let $exec5:=data:save-phone($conn, $id, $phone)


return 1

};

declare function data:save-phone($conn, $id, $phone) {
 let $deletePhone:=string-length($phone) < 5 or contains($phone, "__")
 let $sql:=if($deletePhone) then 
  <s>delete from profile.contact_attribute where profile_id=?::uuid and type='phone'</s>
  else
  <s>
insert into profile.contact_attribute(address, "type", profile_id)
values(?, 'phone', ?::uuid)
on conflict(profile_id, type, address) do update
set address=?
  </s>
  
let $prep := sql:prepare($conn, $sql/text())
let $params := <sql:parameters>
{
if(not($deletePhone)) then 
<sql:parameter type='string'>{string($phone)}</sql:parameter>
else () }
<sql:parameter type='string'>{string($id)}</sql:parameter>
{
if(not($deletePhone)) then 
<sql:parameter type='string'>{string($phone)}</sql:parameter>
else () }
</sql:parameters>
let $exec5:= sql:execute-prepared($prep, $params)

return $exec5
};


declare function data:get-services() {
let $conn:=$util:conn
  let $sql:=<s>
SELECT *, lower(code) as lcode, ntile(2) over () as part FROM profile.r_service where ui_show=true order by display_order;
  </s>
  
let $prep := sql:prepare($conn, $sql/text())
let $params := <sql:parameters>
               </sql:parameters>

return util:convertResult(sql:execute-prepared($prep, $params))
  
};

declare function data:get-notification-services() {
let $conn:=$util:conn
  let $sql:=<s>
SELECT *, lower(code) as lcode FROM profile.r_service where id in (select service_id from profile.r_notification_type) order by display_order;
  </s>
  
let $prep := sql:prepare($conn, $sql/text())
let $params := <sql:parameters>
               </sql:parameters>

return util:convertResult(sql:execute-prepared($prep, $params))
  
};


declare function data:save-push-token($id, $token) {
let $conn:=$util:conn
  let $sql:=<s>
INSERT INTO 
  profile.contact_attribute
(
  address, type,
  confirmed, profile_id
)
VALUES (
  ?, --address
  'firebase_id'::profile.enum_contact_attribute_type,
  true,
  ?::uuid --?profile_id,
) on conflict (profile_id, type, address) do nothing;
  </s>
  
let $prep := sql:prepare($conn, $sql/text())
let $params := <sql:parameters>
<sql:parameter type='string'>{string($token)}</sql:parameter>
<sql:parameter type='string'>{string($id)}</sql:parameter>
</sql:parameters>
let $exec1:= sql:execute-prepared($prep, $params)

  let $sql:=<s>
INSERT INTO 
  profile.mtm_subscription
(
  profile_id,
  notification_type_id,
  delivery_channel_id
)
select ?::uuid, nt.id, 2  from profile.r_notification_type nt
on conflict (profile_id, notification_type_id, delivery_channel_id) DO nothing;
  </s>
  
let $prep := sql:prepare($conn, $sql/text())
let $params := <sql:parameters>
<sql:parameter type='string'>{string($id)}</sql:parameter>
</sql:parameters>
let $exec2:= <s>sql:execute-prepared($prep, $params)</s>

return $exec1
};


declare function data:get-points($profileId, $servicesIn, $recent, $pagesize) {
  let $conn:=$util:conn
  let $services:=if($recent="on" )  then map{} else $servicesIn
  let $sql:=<s>
SELECT 
n.user_id, n.content, 
to_char(profile.crtd_totimestamp(n.created_at), 'DD.MM.YYYY HH:MI') as created_at,
pt.name as point_type_name,
pt.description as point_type_description,
n.id,
lower(s.code) as service_code,
s.icon as service_icon,
s.name as service_name
FROM 
  profile.user_profile p 
  inner join profile.points n on n.user_id=p.id
  inner join profile.r_points_type pt on n.points_type_id=pt.id
  inner join profile.r_service s on pt.service_id=s.id
where p.id='{$profileId}'::uuid {
if(map:size($services) > 0) then <s> and 
  lower(s.code) in ({string-join(map:keys($services), ",")})  
</s>/text()
else ()
}
  order by n.created_at desc
{
  if($recent="on") then 
  <s>
  limit 3
  </s>/text() 
  else ()
}
</s>
  
let $prep := sql:prepare($conn, $sql/text())
(: Values and types of prepared statement parameters :)
let $log:=admin:write-log($sql/text())
let $params := <sql:parameters>
                 
               </sql:parameters>
(: Execute prepared statement :)

return util:convertResult(sql:execute-prepared($prep, $params))
  
};
