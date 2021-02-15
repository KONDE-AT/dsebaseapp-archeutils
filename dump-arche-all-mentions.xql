xquery version "3.1";

import module namespace archeutils="http://www.digital-archiv.at/ns/archeutils" at 'archeutils.xql';
import module namespace app="http://www.digital-archiv.at/ns/templates" at "../modules/app.xql";

declare namespace acdh="https://vocabs.acdh.oeaw.ac.at/schema#";
declare namespace rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare option exist:serialize "method=xml media-type=text/xml omit-xml-declaration=no indent=yes";

let $starting-at := request:get-parameter('starting-at', 1)
let $length := request:get-parameter('length', 10)
let $col_name := request:get-parameter('col-name', 'editions')

let $mentions_lookup := $archeutils:constants//acdh:Mentions[@collection=$col_name]/*

let $docs := collection($app:data||"/"||$col_name)//tei:TEI[@xml:id and @xml:base]
let $sample := subsequence($docs, $starting-at, $length)

let $res :=
    for $item in $sample
        let $doc_id := $item/@xml:base||'/'||$item/@xml:id
        let $ent_nodes := $item//tei:back//tei:*[starts-with(local-name(), 'list')]/tei:*[@xml:id]
        return 
        <acdh:Resource rdf:about="{$doc_id}">
        {
        for $ent in $ent_nodes
            let $res_id := archeutils:get_entity_id($ent)
            let $el_name := name($ent)
            let $arche_node :=
                switch ($el_name)
                case "place" return 'acdh:hasSpatialCoverage'
                default return 'acdh:hasActor'
            return
                element {$arche_node} {attribute rdf:resource {$res_id} }
                (: <el_name>{$el_name}</el_name> :)
        }
        </acdh:Resource>
return 
    <rdf:RDF
        xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
        xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
        xmlns:acdh="https://vocabs.acdh.oeaw.ac.at/schema#"
        xml:base="https://id.acdh.oeaw.ac.at/">
        {$res}
    </rdf:RDF>
