module namespace util = 'urn:atomskills:util';

declare variable $util:conn:=util:connect();

declare function util:convertResult($result) {
  for $row in $result
  return element { xs:QName("row") } {
    for $column in $row/*:column
    return  element { xs:QName(lower-case($column/@name)) } {$column/text()}
  }
};

declare function util:convertJsonForm($data) {
  <data>{
  for $row in $data/json/_
  return element { xs:QName(lower-case($row/name)) } { $row/value/text() }
}</data>
};

declare function util:connect() {
  let $init:=sql:init(
    "org.postgresql.Driver"
  )
  let $connect:=sql:connect("jdbc:postgresql://"||environment-variable("db.host")||":"||environment-variable("db.port")||"/"||environment-variable("db.dbname"), 
    environment-variable("db.user"), 
    environment-variable("db.password"), 
    map { "autocommit": true() })
return $connect
};