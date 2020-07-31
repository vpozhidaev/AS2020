module namespace page = 'urn:atomskills:file-upload';

import module namespace f="urn:atomskills:fragments" at "fragments.xq";
import module namespace data="urn:atomskills:data" at "data.xq";
declare namespace uuid="java:java.util.UUID";
(:~ 

return (
    file:write-binary($path, $content),
    <file name="{ $name }" size="{ file:size($path) }"/>
  )

 :)

declare
  %rest:POST
  %rest:path('/upload-avatar')
  %output:method('json')
  %rest:form-param("file", "{$file}")
  %rest:form-param("id", "{$id}")
  %rest:form-param("dst", "{$dst}")
function page:change($id,$dst, $file) {
  for $name    in map:keys($file)
  let $content := $file($name)
  let $r1 := replace($name,'\.[^.]*$','')
  let $fileId  :=uuid:randomUUID()
  let $newName :=replace($name,$r1,$fileId)
  let $storedUrl := () (:upload:uploadAvatar($id, $newName, $dst, $content):)
  let $saveResult:=data:save-avatar($id, $dst, $storedUrl)
  return $storedUrl
};

(:img/clear-prof.png:)
declare
  %rest:GET
  %rest:path('/get-avatar')
  %rest:produces("image/*", "image/*")
function page:download() {
  let $bin:=file:read-binary("D:\Чемпионат atomskills\source\webapp\application\war\static\img\flying-taxi_clr.7c2de6b.jpg")
  return (<rest:response>
  <http:response status="200">
  </http:response>
    <output:serialization-parameters>
      <output:media-type value='image/*'/>
    </output:serialization-parameters>
  </rest:response>,$bin)
};