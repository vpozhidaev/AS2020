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
  %rest:path('/')
  %output:method('xhtml')
  %output:omit-xml-declaration('no')
  %output:doctype-public('-//W3C//DTD XHTML 1.0 Transitional//EN')
  %output:doctype-system('http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd')
function page:start(
)  {
let $content:=
                                <div class="profile">
                                    <h3>Мои заявки</h3>
<div class="box__row box__row_wrap">

                                </div>
                                </div>

return f:page($content, "Заголовок", "Описание", ())

};