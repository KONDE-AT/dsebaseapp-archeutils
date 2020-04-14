xquery version "3.1";

import module namespace archeutils="http://www.digital-archiv.at/ns/archeutils" at 'archeutils.xql';
import module namespace app="http://www.digital-archiv.at/ns/templates" at "../modules/app.xql";

declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace tei = "http://www.tei-c.org/ns/1.0";


declare option output:method "json";
declare option output:media-type "application/json";

let $docs := collection($app:editions)//tei:TEI[@xml:id and @xml:base]
let $arche_constants := $archeutils:app_base_url||"/archeutils/dump-arche-cols.xql"
let $ids := for $x in subsequence($docs, 1, 10)
  let $filename := data($x/@xml:id)
  let $id := $archeutils:base_url||'/editions/'||$filename
  let $html :=  $archeutils:app_base_url||"/pages/show.html?document="||$filename||"&amp;directory=editions"
  let $payload := $archeutils:app_base_url||"/resolver/resolve-doc.xql?doc-name="||$filename||"&amp;collection=editions"
  order by $id
  return
    <ids>
      <id>{$id}</id>
      <filename>{$filename}</filename>
      <html>{$html}</html>
      <payload>{$payload}</payload>
    </ids>

return
  <graph>
    <arche_constants>{$arche_constants}</arche_constants>
    <id_prefix>{$archeutils:base_url}</id_prefix>
    {$ids}
  </graph>
